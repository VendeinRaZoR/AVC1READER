/*#############################################################################*/
/*##########################====ERCY CONTROLLER===#############################*/
/*#############################################################################*/
/*Description:
ERCY controller drives the DAT line state machine in ERCY file stage 
by finding, opening or creating and close ERCY file in FAT files table 
*/
module ercyctrl(
input clk, //Clock
input nclk, ///Negative clock
input reset, ///Reset
input ureset, ///Reset by START button 
input sbdone, //Shift byte done
input bload, ///load next byte in data transmit shift register on DAT line
input isdpkt, ///is data packet on DAT line indicator
input ercyrfen, ///ERCY_READ_FILE state enabled
input endpkt, ///end of data packet on DAT line, active low
input ercywacken, ///ERCY_WRITE_ACK state enabled
input ercywnullen, ///ERCY_WRITE_NULL state enabled
input ercysdataen, ///ERCY_SET_DATA state enabled
input ercywdataen, ///ERCY_WRITE_DATA state enabled
input ercysfen, ///ERCY_SET_FILE state enabled
input ercyfwr, ///ERCY data FIFO write
input tcvdptdone, ///tranceive data packet done
input tsvec, ///current vector have 3-state (input) signals
input fatecntrd, /// signal every new sector number in FAT tables (FAT1 and FAT2)
input fatp1done, /// signal at the end of FAT table sector (512 bytes)
input isfat2, ///active high signal when current FAT table is FAT2 table 
input fsprmp1en, //FAT_SET_PARAM_P1 state enabled
input ercyfsrr, ///AVC_READ_FILE byte in packet indicator input
input ercyfempty, //ERCY file empty
input [7:0] DATASI, ///Serial shift register output from DAT SD card line  
input [15:0] PTDATAPNTR, ///Byte pointer (counter) in packet from DAT SD card line 
input [31:0] FATSTRTCA, ///ERCY first cluster address
input [7:0] SPCLUST, ///Sectors per cluster
input [31:0] PTWDSECPNTR, ///ERCY write data sector pointer
input [31:0] VECTOROUT, ///AVC error vectors numbers FIFO output
input [7:0] SGNLCHAR0, ///ERCY file Signal name char 0
input [7:0] SGNLCHAR1, ///ERCY file Signal name char 1
input [7:0] SGNLCHAR2, ///ERCY file Signal name char 2
input [7:0] SGNLCHAR3, ///ERCY file Signal name char 3
input [7:0] SGNLCHAR4, ///ERCY file Signal name char 4 
input [7:0] SGNLCHAR5, ///ERCY file Signal name char 5
input [7:0] SGNLCHAR6, ///ERCY file Signal name char 6
input [7:0] SGNLCHAR7, ///ERCY file Signal name char 7
input [7:0] SGNLCHAR8, ///ERCY file Signal name char 8
input [7:0] SGNLCHAR9, ///ERCY file Signal name char 9
input [7:0] SGNLCHAR10, ///ERCY file Signal name char 10 
input [7:0] SGNLCHAR11, ///ERCY file Signal name char 11
input [7:0] SGNLCHAR12, ///ERCY file Signal name char 12
input [7:0] SGNLCHAR13, ///ERCY file Signal name char 13
input [7:0] SGNLCHAR14, ///ERCY file Signal name char 14
input [7:0] SGNLCHAR15, ///ERCY file Signal name char 15
input [7:0] SGNLCHAR16, ///ERCY file Signal name char 16
input [7:0] SGNLCHAR17, ///ERCY file Signal name char 17
input [7:0] SGNLCHAR18, ///ERCY file Signal name char 18
input [7:0] SGNLCHAR19, ///ERCY file Signal name char 19
input [7:0] SGNLCHAR20, ///ERCY file Signal name char 20
input [7:0] SGNLCHAR21, ///ERCY file Signal name char 21
input [7:0] SGNLCHAR22, ///ERCY file Signal name char 22
input [7:0] SGNLCHAR23, ///ERCY file Signal name char 23
input [7:0] SGNLCHAR24, ///ERCY file Signal name char 24
input [7:0] SGNLCHAR25, ///ERCY file Signal name char 25
input [7:0] SGNLCHAR26, ///ERCY file Signal name char 26
input [7:0] SGNLCHAR27, ///ERCY file Signal name char 27
input [7:0] SGNLCHAR28, ///ERCY file Signal name char 28
input [7:0] SGNLCHAR29, ///ERCY file Signal name char 29
input [7:0] SGNLCHAR30, ///ERCY file Signal name char 30
input [7:0] SGNLCHAR31, ///ERCY file Signal name char 31
input WSGNLOUT, ///Expected signal from SNGL lines FIFO output 
input GSGNLOUT, ///Received signal from SGNL lines FIFO output
output eclcntrnull, ///ERCY cluster counter == 0
output eofercy, ///ERCY End-of-File
output fnmnull, ///ERCY filename == 0
output fnme, ///ERCY filename empty
output fnminvld, ///ERCY filename invalid
output nextsgnl, ///read next ERCY vector's data in FIFO
output ercylstvec, ///ERCY last char data in vector 
output [31:0] ERCYVECNTR, ///ERCY vector counter
output [7:0] ERCYFLCNTR, ///ERCY filename index counter E000000*.erc, where * - index
output [31:0] ERCYFSEC, ///ERCY start sector from last empty cluster
output [7:0] ERCYFLSRDATA, ///FAT files table output data for ERCY record
output reg [7:0] MUXERCYFIFO ///ERCY file vector bytes MUX
); 

wire ercyndone;///Error vector number from HEX to CHAR itoa done signal
wire itoares; ///Error vector number itoa from HEX to CHAR reset signal
wire ercyfrd; ///ERCY data FIFO read

wire [31:0] ERCYBTNUM; ///Bytes in ERCY file counter for FAT files table record

wire [31:0] ERCYFSECOUT; ///ERCY file sector from cluster address result
wire [15:0] ERCYCLSTCNTR; ///ERCY cluster downcounter from counted ERCY file sectors output
wire [7:0] ERCYCLSTCNTREM; ///ERCY cluster downcounter remain from divide

wire [7:0] CHAR0; ///Error vector number from AVC file char 0
wire [7:0] CHAR1; ///Error vector number from AVC file char 1
wire [7:0] CHAR2; ///Error vector number from AVC file char 2
wire [7:0] CHAR3; ///Error vector number from AVC file char 3
wire [7:0] CHAR4; ///Error vector number from AVC file char 4
wire [7:0] CHAR5; ///Error vector number from AVC file char 5
wire [7:0] CHAR6; ///Error vector number from AVC file char 6
wire [7:0] CHAR7; ///Error vector number from AVC file char 7
wire [7:0] CHAR8; ///Error vector number from AVC file char 8
wire [7:0] CHAR9; ///Error vector number from AVC file char 9

reg [31:0] R_ERCYCLSTCNTR; ///ERCY cluster downcounter from counted ERCY file sectors register
reg [11:0] R_ERCYFNDCNTR; ///ERCY file record find counter in FAT files table counts
//every new FAT table's record 
reg [5:0] R_ERCYCHRCNTR; ///Counts chars every new vector (line) in ERCY file
reg [31:0] R_ERCYVECNTR; ///ERCY file vectors counter
reg [31:0] R_ERCYBTCNTR; ///ERCY file bytes counter 
reg [7:0] R_ERCYFLCNTR; ///ERCY file filename ASCII symbol prefix counter (0,1,2,...)
reg [31:0] R_ERCYFSEC; ///ERCY start sector from cluster

reg [4:0] R_ERCYFNDCNTRL; ///ERCY file record find counter in FAT files table counts
//every new byte in current FAT table's record
reg [7:0] R_STRFNAME; ///Filename char prefix in FAT files table record 
//(8'hE5 - file was deleted, e.t.c. from FAT specification) register

reg [7:0] MUXFILEBO; ///MUX output writes ERCY FAT files table record 

reg R_ERCYEOF; ///ERCY End-of-File register indicator

assign nextsgnl = R_ERCYCHRCNTR == 6'h00 & ercywdataen & endpkt & sbdone;
assign itoares = R_ERCYCHRCNTR == 6'h01 & ercywdataen & endpkt;

assign fnmnull = R_STRFNAME == 8'h00;
assign fnme = R_STRFNAME == 8'h45;
assign fnminvld = R_STRFNAME != 8'h00 & R_STRFNAME != 8'h45;
assign eclcntrnull = (R_ERCYCLSTCNTR == 0);
assign eofercy = R_ERCYEOF;
assign ercylstvec = R_ERCYCHRCNTR == 6'h3F;

assign ERCYVECNTR = R_ERCYVECNTR;
assign ERCYFSEC = R_ERCYFSEC;

assign ERCYBTNUM = (R_ERCYBTCNTR == 0) ? R_ERCYBTCNTR : (R_ERCYBTCNTR - 32'h0000_0001);

assign ercyfrd = ercywdataen & bload & !(ercyfempty & ercylstvec) & PTDATAPNTR != 16'h0200 & endpkt; 

//////////////////////////////////////////ARITHMETIC////////////////////////////////////////////////////	 
//////////ERCY file start sector = ERCY file start cluster * Sectors Per Cluster
multiply2 multercyfclust(
	.dataa(FATSTRTCA - 2'h2),
	.datab(SPCLUST),
	.result(ERCYFSECOUT)
);
//////////Clusters and of ERCY file calculation while PTWDSECPNTR counts sectors
divide2 secpntr2erctclst(
	.denom(SPCLUST),
	.numer(PTWDSECPNTR),
	.quotient(ERCYCLSTCNTR),
	.remain(ERCYCLSTCNTREM)
);

////////////////////////////////FAT FILES TABLE ERCY FILE RECORD////////////////////////////////////	 
//////////ERCY file record RAM that writes into FAT files table in FAT32 on SD RAM
fatsram ercyflsram(
	.address(ercysfen ? {R_ERCYFNDCNTR[4:1],R_ERCYFNDCNTRL} + 1'b1 : PTDATAPNTR),
	.clock(nclk),
	.data(ercyfsrr ? DATASI : MUXFILEBO),
	.wren(ercyfsrr | ercysfen),
	.q(ERCYFLSRDATA)
);

////////////////////////////////ITOA FOR ERROR VECTORS NUMBERS//////////////////////////////////////	 
//////////Converts from vector number to string of chars
itoa32 htoa(
	.clk(clk),
	.reset(ureset),
	.load(itoares),
	.NUM(VECTOROUT),
	.CHAR0(CHAR0),
	.CHAR1(CHAR1),
	.CHAR2(CHAR2),
	.CHAR3(CHAR3),
	.CHAR4(CHAR4),
	.CHAR5(CHAR5),
	.CHAR6(CHAR6),
	.CHAR7(CHAR7),
	.CHAR8(CHAR8),
	.CHAR9(CHAR9),
	.done(ercyndone)
);

////////////////////////////////MUX FOR EVERY LINE IN ERCY FILE/////////////////////////////////////	 
//////////ERCY file record forming (every line) 
always@*
begin
	case(R_ERCYCHRCNTR)
		0:  MUXERCYFIFO = 8'h45;
		1:  MUXERCYFIFO = 8'h52;
		2:  MUXERCYFIFO = 8'h43;
		3:  MUXERCYFIFO = 8'h59;
		4:  MUXERCYFIFO = 8'h20;
		5:  MUXERCYFIFO = 8'h41;
		6:  MUXERCYFIFO = 8'h4C;
		7:  MUXERCYFIFO = 8'h4C;
		8:  MUXERCYFIFO = 8'h2C;
		9:  MUXERCYFIFO = CHAR9; ///Vector number string
		10: MUXERCYFIFO = CHAR8;
		11: MUXERCYFIFO = CHAR7;
		12: MUXERCYFIFO = CHAR6;
		13: MUXERCYFIFO = CHAR5;
		14: MUXERCYFIFO = CHAR4; 
		15: MUXERCYFIFO = CHAR3;
		16: MUXERCYFIFO = CHAR2;
		17: MUXERCYFIFO = CHAR1;
		18: MUXERCYFIFO = CHAR0;
		19: MUXERCYFIFO = 8'h2C;
		20: MUXERCYFIFO = 8'h2C;
		21: MUXERCYFIFO = 8'h46;
		22: MUXERCYFIFO = {7'b0011000,WSGNLOUT}; ///Expected signal 
		23: MUXERCYFIFO = 8'h2C;
		24: MUXERCYFIFO = 8'h46;
		25: MUXERCYFIFO = {7'b0011000,GSGNLOUT}; ///Received signal 
		26: MUXERCYFIFO = 8'h2C;
		27: MUXERCYFIFO = 8'h45;
		28: MUXERCYFIFO = 8'h31;
		29: MUXERCYFIFO = 8'h2C;
		30: MUXERCYFIFO = 8'h28; ///E1
		31: MUXERCYFIFO = SGNLCHAR0; ///Signal name
		32: MUXERCYFIFO = SGNLCHAR1;	
		33: MUXERCYFIFO = SGNLCHAR2;
		34: MUXERCYFIFO = SGNLCHAR3;
		35: MUXERCYFIFO = SGNLCHAR4;
		36: MUXERCYFIFO = SGNLCHAR5;
		37: MUXERCYFIFO = SGNLCHAR6;
		38: MUXERCYFIFO = SGNLCHAR7;
		39: MUXERCYFIFO = SGNLCHAR8;
		40: MUXERCYFIFO = SGNLCHAR9;
		41: MUXERCYFIFO = SGNLCHAR10;
		42: MUXERCYFIFO = SGNLCHAR11;
		43: MUXERCYFIFO = SGNLCHAR12;
		44: MUXERCYFIFO = SGNLCHAR13;
		45: MUXERCYFIFO = SGNLCHAR14;
		46: MUXERCYFIFO = SGNLCHAR15;
		47: MUXERCYFIFO = SGNLCHAR16;
		48: MUXERCYFIFO = SGNLCHAR17;
		49: MUXERCYFIFO = SGNLCHAR18;
		50: MUXERCYFIFO = SGNLCHAR19;
		51: MUXERCYFIFO = SGNLCHAR20;
		52: MUXERCYFIFO = SGNLCHAR21;
		53: MUXERCYFIFO = SGNLCHAR22;
		54: MUXERCYFIFO = SGNLCHAR23;
		55: MUXERCYFIFO = SGNLCHAR24;
		56: MUXERCYFIFO = SGNLCHAR25;
		57: MUXERCYFIFO = SGNLCHAR26;
		58: MUXERCYFIFO = SGNLCHAR27;
		59: MUXERCYFIFO = SGNLCHAR28;
		60: MUXERCYFIFO = SGNLCHAR29;
		61: MUXERCYFIFO = SGNLCHAR30;
		62: MUXERCYFIFO = SGNLCHAR31;
		63: MUXERCYFIFO = 8'h0A; ///End-Of-Line

		default:
			MUXERCYFIFO = 8'h20;	
			
	endcase
end

/////////////////////////MUX FOR ERCY FILE RECORD IN FAT FILES TABLE///////////////////////////////	 
//////////ERCY file record in FAT file names table (32 bytes)
always@*
begin
	case(R_ERCYFNDCNTRL)
		5'h0: MUXFILEBO = 8'h45; ///E
		5'h1: MUXFILEBO = 8'h30; ///0
		5'h2: MUXFILEBO = 8'h30; ///0
		5'h3: MUXFILEBO = 8'h30; ///0
		5'h4: MUXFILEBO = 8'h30; ///0
		5'h5: MUXFILEBO = 8'h30; ///0
		5'h6: MUXFILEBO = 8'h30; ///0
		5'h7: MUXFILEBO = R_ERCYFLCNTR + 1'b1; ///File number
		5'h8: MUXFILEBO = 8'h65;
		5'h9: MUXFILEBO = 8'h72;
		5'hA: MUXFILEBO = 8'h63;
		5'hB: MUXFILEBO = 8'h20;
		5'hC: MUXFILEBO = 8'h00;
		5'hD: MUXFILEBO = 8'h64;
		5'hE: MUXFILEBO = 8'hC6;
		5'hF: MUXFILEBO = 8'h6E;
		5'h10: MUXFILEBO = 8'h03;
		5'h11: MUXFILEBO = 8'h51;
		5'h12: MUXFILEBO = 8'h03;
		5'h13: MUXFILEBO = 8'h51;
		5'h14: MUXFILEBO = FATSTRTCA[23:16];
		5'h15: MUXFILEBO = FATSTRTCA[31:24];
		5'h16: MUXFILEBO = 8'hC6;
		5'h17: MUXFILEBO = 8'h6E;
		5'h18: MUXFILEBO = 8'h03;
		5'h19: MUXFILEBO = 8'h51;
		5'h1A: MUXFILEBO = FATSTRTCA[7:0]; ///start cluster address of file
		5'h1B: MUXFILEBO = FATSTRTCA[15:8]; ///start cluster address of file
		5'h1C: MUXFILEBO = ERCYBTNUM[7:0]; ///ERCY file size in bytes
		5'h1D: MUXFILEBO = ERCYBTNUM[15:8]; ///ERCY file size in bytes
		5'h1E: MUXFILEBO = ERCYBTNUM[23:16]; ///ERCY file size in bytes
		5'h1F: MUXFILEBO = ERCYBTNUM[31:24]; ///ERCY file size in bytes
	endcase
end

//////////////////////////ARITHMETIC OUTPUT LATCH//////////////////////////////////////	 
//////////Latching ERCY file start sector from start cluster result
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_ERCYFSEC <= 0;
	else
		R_ERCYFSEC <= ERCYFSECOUT;
end

//////////////////////ERCY FILE CONTROLLER REGISTERS AND COUNTERS/////////////////////	 
//////////First character of short file name ERCY file in FAT file table
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME <= 8'hE5;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_ERCYFNDCNTR,4'b01} & endpkt & ercyrfen)
			R_STRFNAME <= DATASI; 
	end
end 
//////////ERCY file cluster downcounter for record in FAT1 and FAT2 tables
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_ERCYCLSTCNTR <= 32'hFFFF;
	else
	begin
		if(ercywacken & ERCYCLSTCNTR != 0)
			R_ERCYCLSTCNTR <= ERCYCLSTCNTR + {24'h00,ERCYCLSTCNTREM} - 32'h0002;
		else if(ercywacken & ERCYCLSTCNTR == 0)
			R_ERCYCLSTCNTR <= {24'h00,ERCYCLSTCNTREM};
		else if(fatecntrd & !fatp1done & !isfat2 & R_ERCYCLSTCNTR != 0 & fsprmp1en)
			R_ERCYCLSTCNTR <= R_ERCYCLSTCNTR - 1'b1;
	end
end
//////////Counter that counts bytes in ERCY file
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_ERCYBTCNTR <= 0;
	else
	begin
		if(ercyfrd)
			R_ERCYBTCNTR <= R_ERCYBTCNTR + 1'b1; 
	end
end
//////////ERCY char counter counts chars in ERCY file record (1 line)
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_ERCYCHRCNTR <= 6'h3F;
	else
	begin
		if(ercyfrd)
			R_ERCYCHRCNTR <= R_ERCYCHRCNTR + 1'b1;
	end
end
//////////Vectors (lines) counter of ERCY file to write on SD CARD
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_ERCYVECNTR <= 6'h00;
	else
	begin
		if(/*ercyfwr*/nextsgnl)
			R_ERCYVECNTR <= R_ERCYVECNTR + 1'b1; 
	end
end
//////////ERCY file counter in a FAT files table						
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_ERCYFNDCNTR <= 0;
	else
	begin
		if((sbdone & PTDATAPNTR == {R_ERCYFNDCNTR[11:1],1'b1,4'hF} | tcvdptdone) & ercyrfen & !fnme & !fnmnull)
		begin
			if(tcvdptdone & ercyrfen & !fnme & !fnmnull)
				R_ERCYFNDCNTR <= 0;
			else
				R_ERCYFNDCNTR <= R_ERCYFNDCNTR + 12'h02;
		end
	end		
end
//////////Counter in a record in a FAT files table
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_ERCYFNDCNTRL <= 8'h00;
	else
	begin
		if(R_ERCYFNDCNTRL != 5'h1F & ercysfen)
			R_ERCYFNDCNTRL <= R_ERCYFNDCNTRL + 1'b1;
	end
end
//////////ERCY file number in a short ERCY filename 
always@(posedge reset or negedge clk)
begin	
	if(reset)
		R_ERCYFLCNTR <= 8'h30;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_ERCYFNDCNTR,4'h8} & ercyrfen & fnme)
			R_ERCYFLCNTR <= DATASI; //For < 10 ERCY File Num
	end
end	
//////////ERCY file End-Of-File indicator
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_ERCYEOF <= 0;
	else
	begin
		if(ercywnullen)
			R_ERCYEOF <= 1;
	end
end

endmodule 