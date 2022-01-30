/*#############################################################################*/
/*#####################====FAT TABLES CONTROLLER===############################*/
/*#############################################################################*/
/*Description:
FAT controller drives the DAT line state machine in FAT table stage 
by writing ending of current FAT table (usually FAT1) to buffer,
then modifying it and writing back in FAT1 and FAT2 tables changed
information. This procedure will be every time when ERCY file greater 
than 1 cluster size
*/
module fatctrl(
input clk, ///Clock
input nclk, //Negative clock
input reset, ///Reset
input ureset, ///User reset by START button
input sbdone, ///Shift byte done
input endpkt, ///End of packet active low
input isdpkt, ///Data packet on DAT line indicator
input frprmen, ///FAT_READ_PARAM state enabled
input fsprmp1en, ///FAT_SET_PARAM_P1 state enabled
input fwprm, ///FAT_WRITE_PARAM state enabled
input eoffwe, ///End-of-FAT tables (FAT1 or FAT2) indicator write enable
input fsprmp2en, //FAT_SET_PARAM_P2 state enabled
input fwacken, ///FAT_WRITE_ACK state enabled
input tcvdptdone, ///tranceive data packet done
input lwe, ///SD card DAT line not busy 
input tcvcptdoner1, //R1 state enabled & tcvcptdone
input [7:0] DATASI, ///output data from input shift register from DAT line
input [15:0] PTDATAPNTR, ///Bytes pointer (counter) in packet from DAT SD card line 
output isfatend, ///32'hFFFFFF0F was found in FAT table
output isfat2, ///active high signal when current FAT table is FAT2 table 
output fatp1done, ///R_FATECNTR == 16'h200 counter reached 512 byte sector size
output eoff, ///end of FAT tables (FAT1 and FAT2)
output fatecntrd, /// signal every new sector number in FAT tables (FAT1 and FAT2)
output [31:0] FATSTRTCA, ///FAT table first empty cluster address
output [15:0] FATSACNTR, ///FAT sector address counter
output [7:0] FATLSRDATA ///FAT table buffer output data
);

wire rwrfrp;///write enable signal for writing 
//FAT table which contains FFFFFF0F last DWORD in buffer
wire rwrfwp;///write enable signal for writing new data in FAT table buffer

reg [15:0] R_FATECNTR; ///FAT1 or FAT2 tables through sector which contains
//FFFFFF0F last DWORD counter (512 bytes)
reg [15:0] R_FATSCNTR; ///FAT sector address counter
reg [31:0] R_FATENDCA; ///FAT table end cluster address 
reg [31:0] R_FATSTRTCA; ///FAT table first empty cluster address
reg [63:0] R_FATEND; ///End of FAT table pointer 2x DWORD register
reg R_EOFFAT1; ///End of FAT1 table indicator
reg R_EOFFAT2; ///End of FAT2 table indicator
reg R_ISFAT2; ///Current FAT table is FAT2 table to be modified

reg [7:0] MUXFATBO; ///FAT Byte output MUX to match FATENDCA bytes with FATECNTR address

assign isfatend = (R_FATEND[31:0] != 32'hFFFFFF0F);
assign fatecntrd = (R_FATECNTR[1:0] == 2'b00);
assign fatp1done = (R_FATECNTR == 16'h200);
assign isfat2 = R_ISFAT2;
assign eoff = R_EOFFAT1 & R_EOFFAT2;
assign FATSTRTCA = R_FATSTRTCA;
assign FATSACNTR = R_FATSCNTR;
assign rwrfrp = frprmen & sbdone & endpkt & isdpkt;
assign rwrfwp = fsprmp1en & !R_ISFAT2 & R_FATECNTR != 16'h0000;

//////////////////////////FAT BYTE OUTPUT MUX///////////////////////////////
//////////Last cluster address MUX in FAT1 & FAT2 tables 
always@*
begin
	case(R_FATECNTR[1:0])
		2'b01: MUXFATBO = R_FATENDCA[7:0];
		2'b10: MUXFATBO = R_FATENDCA[15:8];
		2'b11: MUXFATBO = R_FATENDCA[23:16];
		2'b00: MUXFATBO = R_FATENDCA[31:24];
	endcase
end

//////////////////////////FAT TABLE BUFFER///////////////////////////////
//////////FAT1(2) table 512 byte buffer that stores last 512 bytes in FAT1(2) table 
fatsram fatlsram(
	.address(rwrfwp ? R_FATECNTR : PTDATAPNTR),
	.clock(nclk),
	.data(rwrfrp ? DATASI : MUXFATBO),
	.wren(rwrfrp | rwrfwp),
	.q(FATLSRDATA)
);

/////////////////FAT TABLE CONTROLLER REGISTERS & COUNTERS//////////////////////
//////////Is FAT2 or FAT1 table indicator
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_ISFAT2 <= 0;
	else	
		if(tcvdptdone & fwprm)
			R_ISFAT2 <= ~R_ISFAT2;
end
//////////End-Of-FAT1 table indicator
always@(posedge ureset or negedge clk)
begin
	if(ureset)
	  	R_EOFFAT1 <= 0;
   else
	begin
		if(eoffwe & fsprmp2en & !R_ISFAT2)
			R_EOFFAT1 <= 1;
	end
end
//////////End-Of-FAT2 table indicator
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_EOFFAT2 <= 0;
   else
	begin
		if(eoffwe & fsprmp2en & R_ISFAT2)
			R_EOFFAT2 <= 1;
	end
end
//////////512 bytes counter through 512 FAT1(2) table buffer 
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FATECNTR <= 0;
	else
	begin
		if(!(R_EOFFAT1 & R_EOFFAT2) & !R_ISFAT2 & fwacken & lwe & tcvcptdoner1)
			R_FATECNTR <= 0;
		else if(sbdone & R_FATEND[31:0] != 32'hFFFFFF0F & endpkt & isdpkt & frprmen)
			R_FATECNTR <= PTDATAPNTR + 1'b1;
		else if(R_FATECNTR != 16'h200 & fsprmp1en)
			R_FATECNTR <= R_FATECNTR + 1'b1; 
	end
end
//////////FAT tables sector address counter
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FATSCNTR <= 0;
	else
	begin
		if((tcvdptdone & R_FATEND[31:0] != 32'hFFFFFF0F & frprmen) | (!eoff & !isfat2 & lwe & tcvcptdoner1 & fwacken))
			R_FATSCNTR <= R_FATSCNTR + 1'b1;
	end
end
//////////End of FAT1(2) table record storage register
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FATEND <= 0;
	else
	begin
		if(sbdone & R_FATEND[31:0] != 32'hFFFFFF0F & endpkt & isdpkt & !(R_FATSCNTR == 0 & PTDATAPNTR < 8'h0D) & frprmen)
			R_FATEND <= {R_FATEND[55:0],DATASI};
		else if(R_FATEND == 64'h00000000FFFFFF0F)
			R_FATEND[63:32] <= 32'h03000000;///for AVC files of 1 cluster size
	end
end
//////////End of FAT1(2) table record in a cluster address format
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FATENDCA <= 0;
	else
	begin
		if(frprmen | fsprmp1en)
		begin
			if(tcvdptdone & frprmen)
			begin
				R_FATENDCA[31:24] <= R_FATEND[39:32];
				R_FATENDCA[23:16] <= R_FATEND[47:40];
				R_FATENDCA[15:8] <= R_FATEND[55:48];
				R_FATENDCA[7:0] <= R_FATEND[63:56] + 8'h02;
			end
			else if(fatecntrd & R_FATECNTR != 16'h200 & !isfat2)
			begin
				if(eoffwe)
					R_FATENDCA <= 32'h0FFFFFFF;
				else
					R_FATENDCA <= R_FATENDCA + 1'b1;
			end
		end
	end
end
//////////Start cluster address in a FAT1(2) table to start from
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FATSTRTCA <= 0;
	else
	begin
		if(tcvdptdone & frprmen)
		begin
			R_FATSTRTCA[31:24] <= R_FATEND[39:32];
			R_FATSTRTCA[23:16] <= R_FATEND[47:40];
			R_FATSTRTCA[15:8] <= R_FATEND[55:48];
			R_FATSTRTCA[7:0] <= R_FATEND[63:56] + 8'h01;
		end
	end
end


endmodule 