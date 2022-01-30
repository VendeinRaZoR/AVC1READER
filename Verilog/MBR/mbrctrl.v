/*#############################################################################*/
/*##########################====MBR CONTROLLER===#############################*/
/*#############################################################################*/
/*Description:
MBR controller drives the DAT line state machine in MBR stage 
by finding and recording appropriate MBR structure fields in registers
*/
module mbrctrl(
input clk, ///Clock
input reset,///Reset
input sbdone,///Shift byte done
input mbrprmwe,///MBR_READ_PARAM state enabled
input [7:0] DATASI, ///output data from input shift register from DAT line
input [15:0] PTDATAPNTR, ///Bytes pointer (counter) in packet from DAT SD card line
output fat32valid, ///Partition type and FAT32 adress valid in MBR on SD card
output [31:0] FAT32SA ///FAT32 start sector address
);

reg [31:0] R_FAT32SECA; ///FAT32 start sector address register

reg [7:0] R_PARTYPE; ///Partition type register (FAT32 needed)

assign fat32valid = R_FAT32SECA != 0 & R_PARTYPE == 8'h0B;
assign FAT32SA = R_FAT32SECA;

//////////////////////////////////MBR STRUCT FIELDS REGISTERS//////////////////////////////////////	
//////////Partition type field latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_PARTYPE <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h01C3 & sbdone & mbrprmwe)
			R_PARTYPE <= DATASI;
	end
end
//////////FAT32 sector struct address field latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT32SECA[7:0] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h01C7 & sbdone & mbrprmwe)
			R_FAT32SECA[7:0] <= DATASI;
	end
end
//////////FAT32 sector struct address field latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT32SECA[15:8] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h01C8 & sbdone & mbrprmwe)
			R_FAT32SECA[15:8] <= DATASI;
	end
end
//////////FAT32 sector struct address field latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT32SECA[23:16] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h01C9 & sbdone & mbrprmwe)
			R_FAT32SECA[23:16] <= DATASI;
	end
end
//////////FAT32 sector struct address field latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT32SECA[31:24] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h01CA & sbdone & mbrprmwe)
			R_FAT32SECA[31:24] <= DATASI;
	end
end

endmodule 