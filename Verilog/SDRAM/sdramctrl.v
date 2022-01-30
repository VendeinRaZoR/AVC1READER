/*##############################################################*/
/*####################====SDRAM CONTROLLER====####################*/
/*##############################################################*/
/*Description:
SDRAM controller drives SDRAM lines by state machine,
sets MODE register, controls reading and writing processes,
delay line counters e.t.c
*/
module sdramctrl(
	input reset, ///system reset
	input clk, ///SDRAM clock
	input eofavc, ///End-Of-File AVC
	input eofavcfnd, ///End-Of-File AVC was found
	input we, ///Write enable AVC vector from SD CARD
	input tcvdptdone, ///transmit/receive SD CARD packet done
	input avcrden, ///R_ST_FS == AVC_READ_DATA state of AVC state machine
	input avcsndvec, ///R_ST_FS == AVC_SEND_VECTOR state of AVC state machine
	output rdbstdrdy, ///Read burst ready
	output cke, ///CKE signal of SDRAM
	output _cs, ///CS signal of SDRAM
	output _ras, ///RAS signal of SDRAM
	output _cas, ///CAS signal of SDRAM
	output _we, ///WE signal of SDRAM
	output oen, ///Output enable of SDRAM transmitter
	output oe, ///Direction of SDRAM bus
	output [12:0] A, ///Addess of SDRAM
	output [1:0] BA, ///Bank address of SDRAM
	output [15:0] WDCNTR, ///Word Counter
	output [3:0] DQM ///Word choose of SDRAM
);

parameter IDLE = 0; ///IDLE initial state 
parameter NOP = 1; ///NOP no commands state (reading or writing process)
parameter PRECHARGE = 2; ///PRECHARGE of next row state
parameter PRECHARGE_DELAY = 3; ///PRECHARGE delay pause state
parameter AUTO_REFRESH = 4; ///AUTO_REFRESH while next column reading
parameter LOAD_MODE_REG = 5; ///LOAD_MODE_REG mode register state (from specification)
parameter RESET_ADDRESS = 6; ///RESET_ADDRESS state
parameter ACTIVE = 7; ///ACTIVE state to activate row
parameter CMD_TO_READ = 8; ///Read burst or write single select state
parameter WRITE_SINGLE = 9; ///Write single word into SDRAM
parameter READ_BURST = 10; ///Read word stream from SDRAM
parameter BURST_STOP = 11; ///Stop stream reading from SDRAM

parameter MODE_REG_WRITE = 10'b1000110000; ///Mode register value for read
parameter MODE_REG_READ = 10'b0000110111; ///Mode register value for write

parameter PAGE_SIZE = 1024; ///Size of a SDRAM page

parameter CAS_LATENCY = 3'b100; ///Column address select latency time

wire bstterm; ///Burst reading terminate signal

wire [12:0] CA; //Column adress
wire [12:0] RA; //Row address
wire [12:0] MRA; ///MODE REG in address lines

reg [7:0] R_ST_SDRAM; ///SDRAM state machine
reg [1:0] R_AUTOREFCNTR; ///Auto refresh counter while AUTO_REFRESH state
reg [1:0] R_PCGCNTR; ///Precharge delay state counter
reg [2:0] R_CASLATCNTR; ///Column address strobe latency counter
reg [1:0] R_MODE; ///Mode register (from specification)

reg [1:0] R_TRCDCNTR; ///CMD_TO_READ delay counter

reg [15:0] R_WDCNTR; ///Word Counter on SDRAM DQ data line

reg [9:0] R_CADDRD0; ///Column address first SDRAM
reg [9:0] R_CADDRD1; ///Column address second SDRAM
reg [12:0] R_RADDRD0; ///Row address first SDRAM
reg [12:0] R_RADDRD1; ///Row address second SDRAM

reg [3:0] R_DQM; ///DQ line data maks

reg [12:0] R_A; ///Row address register

reg R_OE; ///Direction of SDRAM DQ bus register
reg R_CS; ///SDRAM chip select signal register
reg R_RAS; ///Row access strobe register
reg R_CAS; ///Column access strobe register
reg R_WE; ///Write enable register
reg R_OEN; ///Output enable of SDRAM transmitter register

assign RA = (R_WDCNTR[0] & R_WDCNTR[1]) ? R_RADDRD0 : R_RADDRD1;

assign MRA = eofavc ? {3'b000,MODE_REG_READ} : {3'b000,MODE_REG_WRITE};

assign CA[12:11] = 0;
assign CA[10] = R_ST_SDRAM == PRECHARGE | R_ST_SDRAM == WRITE_SINGLE;
assign CA[9:0] = (R_WDCNTR[0] & R_WDCNTR[1]) ? R_CADDRD0[9:0] : R_CADDRD1[9:0];
assign BA[1:0] = 2'b00;
assign cke = 1'b1; 

assign _cs = R_CS;
assign _ras = R_RAS;
assign _cas = R_CAS;
assign _we = R_WE;

assign A = R_A;

assign DQM = R_DQM;

assign oen = R_OEN;

assign bstterm = (R_WDCNTR == 16'h01);

assign WDCNTR = R_WDCNTR;

assign oe = R_OE;

assign rdbstdrdy = (R_ST_SDRAM == NOP & R_CASLATCNTR == CAS_LATENCY);
//////////////////////////////////////////SDRAM CONTROL REGISTERS////////////////////////////////////////////////////	
//////////Address line latch register (set MODE reg or Row/Column addresses)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_A <= 0;
	else
		R_A <= (R_ST_SDRAM == ACTIVE) ? RA : (R_ST_SDRAM == LOAD_MODE_REG) ? MRA : CA;
end
//////////Output enable register for sdramtx (active on write state)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_OEN <= 0;
	else
		R_OEN <= R_ST_SDRAM == WRITE_SINGLE;
end
//////////Mask for DQ lines register (for writing only 16 bits at time and full read burst)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DQM = 4'b0000;
	else
	begin
		if(R_ST_SDRAM == WRITE_SINGLE & ((R_WDCNTR[0] & !R_WDCNTR[1]) | (!R_WDCNTR[0] & R_WDCNTR[1])))
			R_DQM = 4'b0011;
		else if(R_ST_SDRAM == WRITE_SINGLE & R_WDCNTR[0] & R_WDCNTR[1])
			R_DQM = 4'b1100;
		else if(R_ST_SDRAM == READ_BURST | (avcsndvec & R_ST_SDRAM == NOP & R_WDCNTR != 0))
			R_DQM = 4'b0000;
		else
			R_DQM = 4'b1111; 
	end
end
//////////Direction of DQ line (1 on write, 0 on read)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_OE <= 1'b1;
	else
	begin
		if(R_ST_SDRAM == WRITE_SINGLE)
			R_OE <= 1'b1;
		else if(R_ST_SDRAM == READ_BURST)
			R_OE <= 1'b0;
	end
end
//////////Mode register configuration (from specification)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_MODE <= 0;
	else
	begin
		if(!eofavc)
			R_MODE <= 2'b01;
		else if(eofavc & avcsndvec)
			R_MODE <= 2'b10;
		else if(eofavc & !avcsndvec)
			R_MODE <= 0;
	end
end
//////////Word downcounter (while writing from 3 and while reading from PAGE_SIZE)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_WDCNTR <= 16'h00;
	else
	begin
		if(we)
			R_WDCNTR <= 16'h03;
		else if(R_ST_SDRAM == READ_BURST)
			R_WDCNTR <= PAGE_SIZE;
		else if((R_OEN | rdbstdrdy) & R_MODE != 2'b00)
			R_WDCNTR <= R_WDCNTR - 1'b1;
	end
end
//////////Column address while writing first SDRAM
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_CADDRD0 <= 0;
	else
	begin
		case(R_ST_SDRAM) 
			
			RESET_ADDRESS:
				R_CADDRD0 <= 0;
			
			WRITE_SINGLE:
			begin
				if(R_WDCNTR[0] & R_WDCNTR[1])
					R_CADDRD0 <= R_CADDRD0 + 1'b1;
			end
		
		endcase
	end
end
//////////Column address while writing second SDRAM
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_CADDRD1 <= 0;
	else
	begin
		case(R_ST_SDRAM) 
			
			RESET_ADDRESS:
				R_CADDRD1 <= 0;
			
			WRITE_SINGLE:
			begin
				if(!(R_WDCNTR[0] & R_WDCNTR[1]))
					R_CADDRD1 <= R_CADDRD1 + 1'b1;
			end
			
		endcase
	end
end
//////////Row address while writing first SDRAM
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_RADDRD0 <= 0;
	else
	begin
		case(R_ST_SDRAM) 
		
			RESET_ADDRESS:
				R_RADDRD0 <= 0;
		
			READ_BURST:
				R_RADDRD0 <= R_RADDRD0 + 1'b1;
				
			WRITE_SINGLE:
			begin
				if(R_CADDRD0 == 10'h3FF & R_WDCNTR[0] & R_WDCNTR[1])
					R_RADDRD0 <= R_RADDRD0 + 1'b1;
			end
			
		endcase
	end
end
//////////Row address while writing second SDRAM
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_RADDRD1 <= 0;
	else
	begin
		case(R_ST_SDRAM) 
		
			RESET_ADDRESS:
				R_RADDRD1 <= 0;
				
			READ_BURST:
				R_RADDRD1 <= R_RADDRD1 + 1'b1;
				
			WRITE_SINGLE:
			begin
				if(R_CADDRD1 == 10'h3FF & !(R_WDCNTR[0] & R_WDCNTR[1]))
					R_RADDRD1 <= R_RADDRD1 + 1'b1;
			end
			
		endcase
	end
end
//////////////////////////////////////////DELAY COUNTERS////////////////////////////////////////////////////	
//////////Auto refresh delay counter while AUTO_REFRESH state
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AUTOREFCNTR <= 0;
	else
	begin
		if(R_ST_SDRAM == PRECHARGE)
			R_AUTOREFCNTR <= 0;
		else if(R_ST_SDRAM == AUTO_REFRESH)
			R_AUTOREFCNTR <= R_AUTOREFCNTR + 1'b1;
	end
end
//////////Precharge delay counter while PRECHARGE_DELAY state
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_PCGCNTR <= 0;
	else
	begin
		if(R_ST_SDRAM == ACTIVE)
			R_PCGCNTR <= 0;
		else if(R_ST_SDRAM == PRECHARGE_DELAY)
			R_PCGCNTR <= R_PCGCNTR + 1'b1;
	end
end
//////////CMD_TO_READ delay counter
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_TRCDCNTR <= 0;
	else
	begin
		if(R_ST_SDRAM == ACTIVE)
			R_TRCDCNTR <= 0;
		else if(R_ST_SDRAM == CMD_TO_READ)
			R_TRCDCNTR <= R_TRCDCNTR + 1'b1;
	end
end
//////////CAS latency delay counter 
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_CASLATCNTR <= 0;
	else
	begin
		if(R_ST_SDRAM == PRECHARGE)
			R_CASLATCNTR <= 0;
		else if(R_CASLATCNTR != CAS_LATENCY & avcsndvec & R_ST_SDRAM == NOP)
			R_CASLATCNTR <= R_CASLATCNTR + 1'b1; 
	end
end
//////////////////////////////////////////SDRAM STATE MACHINES////////////////////////////////////////////////////	
//////////SDRAM signals control state machine
always@(posedge reset or negedge clk)
begin
	if(reset)
	begin
		R_CS <= 1'b1;
		R_RAS <= 1'b1;
		R_CAS <= 1'b1;
		R_WE <= 1'b1;
	end
	else
	begin
		case(R_ST_SDRAM)
		
			IDLE:
			begin
				R_CS <= 1'b1;
				R_RAS <= 1'b1;
				R_CAS <= 1'b1;
				R_WE <= 1'b1;
			end
			
			LOAD_MODE_REG:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b0;
				R_CAS <= 1'b0;
				R_WE <= 1'b0;
			end
			
			NOP:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b1;
				R_CAS <= 1'b1;
				R_WE <= 1'b1;		
			end
			
			CMD_TO_READ:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b1;
				R_CAS <= 1'b1;
				R_WE <= 1'b1;		
			end
			
			AUTO_REFRESH:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b1;
				R_CAS <= 1'b1;
				R_WE <= 1'b1;		
			end
			
			PRECHARGE_DELAY:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b1;
				R_CAS <= 1'b1;
				R_WE <= 1'b1;		
			end
			
			PRECHARGE:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b0;
				R_CAS <= 1'b1;
				R_WE <= 1'b0;			
			end
			
			RESET_ADDRESS:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b1;
				R_CAS <= 1'b1;
				R_WE <= 1'b1;	
			end
			
			ACTIVE:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b0;
				R_CAS <= 1'b1;
				R_WE <= 1'b1;		
			end
			
			WRITE_SINGLE:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b1;
				R_CAS <= 1'b0;
				R_WE <= 1'b0;	
			end
			
			READ_BURST:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b1;
				R_CAS <= 1'b0;
				R_WE <= 1'b1;				
			end
			
			BURST_STOP:
			begin
				R_CS <= 1'b0;
				R_RAS <= 1'b1;
				R_CAS <= 1'b1;
				R_WE <= 1'b0;	 		
			end
		
		endcase
	end
end
//////////SDRAM line state machine
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_ST_SDRAM <= IDLE;
	else
	begin
		case(R_ST_SDRAM)
		
			IDLE:
			begin
				if(eofavcfnd & avcrden)
					R_ST_SDRAM <= PRECHARGE;
			end
			
			PRECHARGE:
				R_ST_SDRAM <= AUTO_REFRESH;
			
			AUTO_REFRESH:
			begin
				if(R_AUTOREFCNTR == 2'b10)
					R_ST_SDRAM <= NOP;
			end
			
			NOP:
			begin
				if(R_MODE == 0)
					R_ST_SDRAM <= LOAD_MODE_REG;
				else if(R_WDCNTR != 2'b00 & !avcsndvec | R_WDCNTR == 2'b00 & avcsndvec)
					R_ST_SDRAM <= ACTIVE;
				else if(eofavc & !avcsndvec | bstterm & avcsndvec)
					R_ST_SDRAM <= PRECHARGE;
			end
			
			LOAD_MODE_REG:
				R_ST_SDRAM <= RESET_ADDRESS;
				
			RESET_ADDRESS:
				R_ST_SDRAM <= NOP;
			
			ACTIVE:
				R_ST_SDRAM <= CMD_TO_READ;
				
			CMD_TO_READ:
			begin
				if(R_TRCDCNTR == 2'b01)
				begin
					if(R_MODE == 2'b01)
						R_ST_SDRAM <= WRITE_SINGLE;
					else if(R_MODE == 2'b10)
						R_ST_SDRAM <= READ_BURST;
				end
			end
			
			WRITE_SINGLE:
				R_ST_SDRAM <= PRECHARGE_DELAY;
			
			READ_BURST:
				R_ST_SDRAM <= NOP;
			
			BURST_STOP:
				R_ST_SDRAM <= NOP;
			
			PRECHARGE_DELAY:
			begin
				if(R_PCGCNTR == 2'b11)
					R_ST_SDRAM <= PRECHARGE; 
			end
			
		endcase
	end
end


endmodule 