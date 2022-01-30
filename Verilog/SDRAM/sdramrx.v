/*##############################################################*/
/*####################====SDRAM RECEIVER====####################*/
/*##############################################################*/
/*Description:
SDRAM receiver gets signals from DQ SDRAM lines
and puts it in 1024 DQ FIFO for delay it 
Delay is useful to eliminate pause between Row
Address Access due to precharge pause
*/
module sdramrx(
	input clk, ///SDRAM clock
	input dqfifoclk, ///DQ FIFO clock (2x SDRAM clock)
	input reset, ///system reset
	input rdbstdrdy, ///Read burst ready
	input [15:0] WDCNTR, ///Word counter
	input [31:0] DATAIN, ///SDRAM DQ data input
	output swdone, ///Send word done signal
	output [31:0] PARDOUT0, ///16 States of 3-states or 3-states signals
	output [15:0] PARDOUT1 ///16 fast signals
);

parameter DQFIFO_ALMOST_FULL = 1021; ///DQ FIFO value indicates that it almost full for writing 

wire dqf; ///DQ FIFO full
wire dqe; ///DQ FIFO empty
wire dqusdw; ///Words in DQ FIFO == DQFIFO_ALMOST_FULL
wire [31:0] DATADQF; ///Output of DQ FIFO
wire [9:0] USEDW; ///Amount of words in DQ FIFO
reg [31:0] R_DATAINF; ///input data for DQ FIFO
reg [15:0] R_PARDOUT0; ///16 fast and 16 low 3-state register
reg [15:0] R_PARDOUT1; ///States for 3-state signals register
reg [31:0] R_DATAIN; ///SDRAM DQ Latch
reg [1:0] R_DQWDCNTR; ///DQ FIFO word counter 
///(changes the type of signal: 3-STATE SIGNAL or STATE OF 3-STATE SIGNAL)
reg R_DQWD; ///Reading strobe from DQ FIFO
reg R_DQFRD; ///DQ FIFO read enable register
reg R_DQFWR; ///DQ FIFO write enable register

assign PARDOUT0[15:0] = R_DATAIN[15:0];
assign PARDOUT0[31:16] = R_PARDOUT0;

assign PARDOUT1 = R_PARDOUT1; 

assign swdone = R_DQWDCNTR[1];

assign dqusdw = USEDW == DQFIFO_ALMOST_FULL;
//////////1024 32 bit delaying DQ FIFO
dqfifo sdramfifo(
	.aclr(reset),
	.wrclk(~clk),
	.rdclk(~dqfifoclk),
	.data(R_DATAINF),
	.rdreq(R_DQWD & !dqe),
	.wrreq(rdbstdrdy & R_DQFWR & !dqusdw & !dqf),
	.rdempty(dqe),
	.wrusedw(USEDW),
	.wrfull(dqf),
	.q(DATADQF));
//////////Read from DQ FIFO when it almost full
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DQFRD <= 0;
	else
	begin
		if(dqusdw)
			R_DQFRD <= 1;
	end
end
//////////Write to DQ FIFO when read busrt ready
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DQFWR <= 0;
	else
		if(rdbstdrdy)
			R_DQFWR <= 1;
end
//////////DQ FIFO reading strobe activates when read enabled
always@(posedge reset or negedge dqfifoclk)
begin
	if(reset)
		R_DQWD <= 0;
	else
	begin
		if(R_DQFRD)
			R_DQWD <= ~R_DQWD;
	end
end
//////////DQ FIFO reading word counter
always@(posedge reset or negedge dqfifoclk)
begin
	if(reset)
		R_DQWDCNTR <= 0;
	else
	begin
		if(R_DQFRD)
			R_DQWDCNTR <= R_DQWDCNTR + 2'b01;
	end
end
//////////input data from SDRAM latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DATAINF <= 0;
	else
		R_DATAINF <= DATAIN;
end	
//////////Latch output word from DQ FIFO
always@(posedge reset or negedge dqfifoclk)
begin
	if(reset)
		R_DATAIN <= 0;
	else
	begin
		R_DATAIN <= DATADQF;
	end 
end
//////////16 3-state signals or it states
always@(posedge reset or negedge dqfifoclk)
begin
	if(reset)
		R_PARDOUT0 <= 0;
	else
	begin
		if((R_DQWDCNTR == 2'b01) & R_DQFRD)
			R_PARDOUT0[15:0] <= DATADQF[31:16];
	end 
end
//////////16 fast signals
always@(posedge reset or negedge dqfifoclk)
begin
	if(reset)
		R_PARDOUT1 <= 0; 
	else
	begin
		if((R_DQWDCNTR == 2'b11) & R_DQFRD) 
			R_PARDOUT1[15:0] <= DATADQF[31:16];  
	end 
end

endmodule 