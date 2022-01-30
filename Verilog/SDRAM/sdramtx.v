/*##############################################################*/
/*##################====SDRAM TRANSMITTER====###################*/
/*##############################################################*/
/*Description:
SDRAM transmitter gets the data from SD CARD AVC file 
and send it to SDRAM DQ lines
*/
module sdramtx(
	input reset, ///System reset
	input clk, ///SDRAM clock
	input we, ///Write enable signal
	input oen, ///Output enable
	input [15:0] WDCNTR, ///Word counter
	input [15:0] DATAIN0, ///16 fast non-3-state signals
	input [15:0] DATAIN1, ///16 slow 3-state signals
	input [15:0] DATAIN2, ///16 states of 16 slow 3-state signals
	output [31:0] DATAOUT ///Output on SDRAM DQ Lines
);

reg [15:0] R_DATA0; ///16 FAST NON-TS
reg [15:0] R_DATA1; ///16 SLOW TS
reg [15:0] R_DATA2; ///16 STATES OF 16 SLOW TS
reg [31:0] R_DATAOUT; ///Output on SDRAM DQ Lines

assign DATAOUT = R_DATAOUT;
//////////SDRAM DQ Lines MUX register
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DATAOUT <= 0;
	else
	begin
		R_DATAOUT[15:0] <= R_DATA0; 
		R_DATAOUT[31:16] <= (!WDCNTR[0] & WDCNTR[1]) ? R_DATA1 : R_DATA2;	
	end
end
//////////16 fast non-ts register latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DATA0 <= 0;
	else
	begin
		if(we)
			R_DATA0 <= DATAIN0; 
	end
end
//////////16 slow ts register latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DATA1 <= 0;
	else
	begin
		if(we)
			R_DATA1 <= DATAIN1; 
	end
end
//////////16 states of 16 slow 3-state register latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DATA2 <= 0;
	else
	begin
		if(we)
			R_DATA2 <= DATAIN2; 
	end
end

endmodule 