/*#############################################################################*/
/*###################====SD MEMORY ADDRESS CONTROLLER===#######################*/
/*#############################################################################*/
/*Description:
SD memory address controller counts and prepares sector address for SD card in 
appropriate state of DATA state machine 
*/
module sdmemaddr(
input clk, ///Clock
input reset, ///Reset
input ureset, ///User reset by START button
input avcrfen, ///AVC_READ_FILE state enabled
input ercyrfen, ///ERCY_READ_FILE state enabled
input avcrden, ///AVC_READ_DATA state enabled
input ercywden, ///ERCY_WRITE_DATA state enabled
input eofercy, ///ERCY End-of-File
input resprdspntr, ///Reset AVC file sector pointer
input f32gprmen, ///FAT32_GET_PARAM state enabled
input fgprmen, ///FAT_GET_PARAM state enabled
input ercygfen, ///ERCY_GET_FILE state enabled
input avcgfen, ///AVC_GET_FILE state enabled
input fsprmp1en, ///FAT_SET_PARAM_P1 state enabled
input avcgden, ///AVC_GET_DATA state enabled
input ercysden, ///ERCY_SET_DATA state enabled
input ercysfen, ///ERCY_SET_FILE state enabled
input ercywnullen, ///ERCY_WRITE_NULL state enabled
input isfat2, ///Currect FAT1 or FAT2 table switch 
input tcvdptdone, ///tranceive (transmit/receive) DATA packet done signal
input [31:0] FAT32SA, ///FAT32 start sector address
input [15:0] FAT1SA, ///FAT1 start sector address
input [15:0] FAT2SA, ///FAT2 start sector address
input [15:0] FATSACNTR, ///FAT sector address counter
input [31:0] FATSIZE, ///FAT1 or FAT2 table size
input [15:0] AVCFSEC, ///AVC file sector offset from FAT files table
input [15:0] FROOTSEC, ///ROOT sector cluster offset from FAT files table (where first file place)
input [31:0] ERCYFSEC, ///ERCY start cluster from last empty cluster
output [31:0] DADDR, ///Sector Data Address on SD card
output [7:0] PTNULLCNTR, ///ERCY null counter in last cluster
output [31:0] PTWDSECPNTR ///ERCY write data sector pointer
);

reg [31:0] R_DADDR; ///Sector Data Address on SD card

reg [7:0] R_PTNULLCNTR; ///ERCY null counter in last cluster

reg [31:0] R_PTRDSECPNTR;  ///AVC write data sector pointer
reg [31:0] R_PTWDSECPNTR; ///ERCY write data sector pointer

reg [31:0] R_PTEGFSECPNTR; ////ERCY read file in FAT files table sector pointer
reg [31:0] R_PTAGFSECPNTR; ////AVC read file in FAT files table sector pointer


assign DADDR = R_DADDR;

assign PTNULLCNTR = R_PTNULLCNTR;
assign PTWDSECPNTR = R_PTWDSECPNTR;

////////////////////////////RESULT SD CARD MEMORY SECTOR ADDRESS//////////////////////////////////
//////////SD CARD sector address selection
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_DADDR <= 0;
	else
	begin
		if(f32gprmen)
			R_DADDR <= FAT32SA;
		else if(fgprmen)		
			R_DADDR <= FAT32SA + FAT1SA + FATSACNTR;
		else if(ercygfen)	
			R_DADDR <= FAT1SA + FATSIZE + FATSIZE + FAT32SA + R_PTEGFSECPNTR; 
		else if(avcgfen)		
			R_DADDR <= FAT1SA + FATSIZE + FATSIZE + FAT32SA + R_PTAGFSECPNTR; 
		else if(fsprmp1en)		
			R_DADDR <= isfat2 ? FAT2SA + FAT32SA + FATSACNTR : FAT1SA + FAT32SA + FATSACNTR; 
		else if(avcgden)		
			R_DADDR <= FAT1SA + FATSIZE + FATSIZE + FAT32SA + AVCFSEC - FROOTSEC + R_PTRDSECPNTR; 
		else if(ercysden)
			R_DADDR <= FAT1SA + FATSIZE + FATSIZE + FAT32SA + ERCYFSEC + R_PTWDSECPNTR + R_PTNULLCNTR;   
		else if(ercysfen)		
			R_DADDR <= FAT1SA + FATSIZE + FATSIZE + FAT32SA + R_PTAGFSECPNTR - 1'b1;
	end
end

////////////////////////////SD CARD SECTOR ADDRESS POINTERS//////////////////////////////////	
//////////Address pointer while AVC file reading
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_PTAGFSECPNTR <= 0;
	else
	begin
		if(avcrfen & tcvdptdone)	
			R_PTAGFSECPNTR <= R_PTAGFSECPNTR + 16'h0001;
	end
end
//////////Address pointer while ERCY file reading
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_PTEGFSECPNTR <= 0;
	else
	begin
		if(ercyrfen & tcvdptdone)	
			R_PTEGFSECPNTR <= R_PTEGFSECPNTR + 16'h0001;
	end
end
//////////Address pointer while AVC file writing
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_PTRDSECPNTR <= 0;
	else
	begin
		if(resprdspntr)
			R_PTRDSECPNTR <= 0;
		else if(avcrden & tcvdptdone)	
			R_PTRDSECPNTR <= R_PTRDSECPNTR + 16'h0001;
	end
end
//////////Address pointer while ERCY file writing
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_PTWDSECPNTR <= 0;
	else
	begin
		if(ercywden & tcvdptdone)	
		begin
			if(eofercy)
				R_PTWDSECPNTR <= 0;
			else
				R_PTWDSECPNTR <= R_PTWDSECPNTR + 16'h0001;
		end
	end
end
//////////Finalize ERCY file by writing NULLs in last cluster
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_PTNULLCNTR <= 0;
	else
	begin
		if(ercywnullen & tcvdptdone)
			R_PTNULLCNTR <= R_PTNULLCNTR + 8'h01;
	end
end

endmodule 