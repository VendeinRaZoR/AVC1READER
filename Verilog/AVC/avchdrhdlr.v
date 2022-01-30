/*###########################################################################*/
/*###################====AVC HEADER HANDLER (PARSER)====#####################*/
/*###########################################################################*/
/*Description:
AVC header handler parses the header of AVC file (first string in AVC file)
and gets it signal names 
*/
module avchdrhdlr(
input clk, ///Clock
input nclk, ///Negative Clock 
input ureset,///User reset (by START button)
input sbdone,///Shift byte done
input endpkt,///End-of-Packet signal active low
input isdpkt, ///DATA packet indicator on DAT line
input avcrden, ///AVC_READ_DATA enabled
input eofavcfnd, ///AVC End-of-File found 
input errrd, ///Read next signal data from error FIFO for ERCY file
input [7:0] DATASI, ///Data serial input shift register output
input [31:0] AVCVECNTR, ///AVC vector counter
input [7:0] SGNLNMNUM, ///Signal name number in AVC file header
//input [7:0] SGNLBUSNM, ///Signal bus name in AVC file header
output [7:0] SGNLCHAR0, ///ERCY file Signal name char 0
output [7:0] SGNLCHAR1, ///ERCY file Signal name char 1
output [7:0] SGNLCHAR2, ///ERCY file Signal name char 2
output [7:0] SGNLCHAR3, ///ERCY file Signal name char 3
output [7:0] SGNLCHAR4, ///ERCY file Signal name char 4
output [7:0] SGNLCHAR5, ///ERCY file Signal name char 5
output [7:0] SGNLCHAR6, ///ERCY file Signal name char 6
output [7:0] SGNLCHAR7, ///ERCY file Signal name char 7
output [7:0] SGNLCHAR8, ///ERCY file Signal name char 8
output [7:0] SGNLCHAR9, ///ERCY file Signal name char 9
output [7:0] SGNLCHAR10, ///ERCY file Signal name char 10
output [7:0] SGNLCHAR11, ///ERCY file Signal name char 11
output [7:0] SGNLCHAR12, ///ERCY file Signal name char 12
output [7:0] SGNLCHAR13, ///ERCY file Signal name char 13 
output [7:0] SGNLCHAR14, ///ERCY file Signal name char 14
output [7:0] SGNLCHAR15, ///ERCY file Signal name char 15
output [7:0] SGNLCHAR16, ///ERCY file Signal name char 16
output [7:0] SGNLCHAR17, ///ERCY file Signal name char 17
output [7:0] SGNLCHAR18, ///ERCY file Signal name char 18
output [7:0] SGNLCHAR19, ///ERCY file Signal name char 19
output [7:0] SGNLCHAR20, ///ERCY file Signal name char 20
output [7:0] SGNLCHAR21, ///ERCY file Signal name char 21
output [7:0] SGNLCHAR22, ///ERCY file Signal name char 22
output [7:0] SGNLCHAR23, ///ERCY file Signal name char 23
output [7:0] SGNLCHAR24, ///ERCY file Signal name char 24
output [7:0] SGNLCHAR25, ///ERCY file Signal name char 25
output [7:0] SGNLCHAR26, ///ERCY file Signal name char 26
output [7:0] SGNLCHAR27, ///ERCY file Signal name char 27
output [7:0] SGNLCHAR28, ///ERCY file Signal name char 28
output [7:0] SGNLCHAR29, ///ERCY file Signal name char 29
output [7:0] SGNLCHAR30, ///ERCY file Signal name char 30
output [7:0] SGNLCHAR31 ///ERCY file Signal name char 31
);

parameter IDLE = 8'h00; ///initial state after reset by START button
parameter WRITE_CHAR0 = 8'h01; ///Write error signal name in ERCY vector char 0 state
parameter WRITE_CHAR1 = 8'h02; ///Write error signal name in ERCY vector char 1 state
parameter WRITE_CHAR2 = 8'h03; ///Write error signal name in ERCY vector char 2 state
parameter WRITE_CHAR3 = 8'h04; ///Write error signal name in ERCY vector char 3 state
parameter WRITE_CHAR4 = 8'h05; ///Write error signal name in ERCY vector char 4 state
parameter WRITE_CHAR5 = 8'h06; ///Write error signal name in ERCY vector char 5 state
parameter WRITE_CHAR6 = 8'h07; ///Write error signal name in ERCY vector char 6 state
parameter WRITE_CHAR7 = 8'h08; ///Write error signal name in ERCY vector char 7 state
parameter WRITE_CHAR8 = 8'h09; ///Write error signal name in ERCY vector char 8 state
parameter WRITE_CHAR9 = 8'h0A; ///Write error signal name in ERCY vector char 9 state 
parameter WRITE_CHAR10 = 8'h0B; ///Write error signal name in ERCY vector char 10 state 
parameter WRITE_CHAR11 = 8'h0C; ///Write error signal name in ERCY vector char 11 state
parameter WRITE_CHAR12 = 8'h0D; ///Write error signal name in ERCY vector char 12 state
parameter WRITE_CHAR13 = 8'h0E; ///Write error signal name in ERCY vector char 13 state
parameter WRITE_CHAR14 = 8'h0F; ///Write error signal name in ERCY vector char 14 state
parameter WRITE_CHAR15 = 8'h10; ///Write error signal name in ERCY vector char 15 state
parameter WRITE_CHAR16 = 8'h11; ///Write error signal name in ERCY vector char 16 state
parameter WRITE_CHAR17 = 8'h12; ///Write error signal name in ERCY vector char 17 state
parameter WRITE_CHAR18 = 8'h13; ///Write error signal name in ERCY vector char 18 state
parameter WRITE_CHAR19 = 8'h14; ///Write error signal name in ERCY vector char 19 state
parameter WRITE_CHAR20 = 8'h15; ///Write error signal name in ERCY vector char 20 state
parameter WRITE_CHAR21 = 8'h16; ///Write error signal name in ERCY vector char 21 state
parameter WRITE_CHAR22 = 8'h17; ///Write error signal name in ERCY vector char 22 state
parameter WRITE_CHAR23 = 8'h18; ///Write error signal name in ERCY vector char 23 state
parameter WRITE_CHAR24 = 8'h19; ///Write error signal name in ERCY vector char 24 state
parameter WRITE_CHAR25 = 8'h1A; ///Write error signal name in ERCY vector char 25 state
parameter WRITE_CHAR26 = 8'h1B; ///Write error signal name in ERCY vector char 26 state
parameter WRITE_CHAR27 = 8'h1C; ///Write error signal name in ERCY vector char 27 state
parameter WRITE_CHAR28 = 8'h1D; ///Write error signal name in ERCY vector char 28 state
parameter WRITE_CHAR29 = 8'h1E; ///Write error signal name in ERCY vector char 29 state
parameter WRITE_CHAR30 = 8'h1F; ///Write error signal name in ERCY vector char 30 state
parameter WRITE_CHAR31 = 8'h20; ///Write error signal name in ERCY vector char 31 state
parameter CHAR_READ = 8'h21; ///Read first char of error signal name from buffer state
parameter CHAR_LAUNCH = 8'h22; ///launch first char of error signal name to trigger state
parameter CHAR_LATCH = 8'h23; ///latch first char of error signal name in trigger state
parameter WHITESPACE = 8'h24; ///skip whitespace state
parameter WRITE_END = 8'h2F; ///Write done state

wire [7:0] AVCSLNMADDRN; ///address of buffer with first chars of ERCY signal names address pointers
wire [7:0] AVCSLNMADDRM; ///address of buffer first char of ERCY signal names
wire [7:0] SIGCHAR; ///Error ERCY signal names buffer output 

reg [7:0] R_ST_SGNLNAME; ///Signal name state machine

reg [7:0] R_AVCSLNMADDRN; ///address of buffer with first chars of ERCY signal names address pointers
reg [7:0] R_AVCSLNMADDRM; ///address of buffer first char of ERCY signal names

reg [7:0] R_SGNLCHAR0; ///ERCY file error signal name char 0
reg [7:0] R_SGNLCHAR1; ///ERCY file error signal name char 1
reg [7:0] R_SGNLCHAR2; ///ERCY file error signal name char 2
reg [7:0] R_SGNLCHAR3; ///ERCY file error signal name char 3
reg [7:0] R_SGNLCHAR4; ///ERCY file error signal name char 4
reg [7:0] R_SGNLCHAR5; ///ERCY file error signal name char 5
reg [7:0] R_SGNLCHAR6; ///ERCY file error signal name char 6
reg [7:0] R_SGNLCHAR7; ///ERCY file error signal name char 7
reg [7:0] R_SGNLCHAR8; ///ERCY file error signal name char 8
reg [7:0] R_SGNLCHAR9; ///ERCY file error signal name char 9
reg [7:0] R_SGNLCHAR10; ///ERCY file error signal name char 10
reg [7:0] R_SGNLCHAR11; ///ERCY file error signal name char 11
reg [7:0] R_SGNLCHAR12; ///ERCY file error signal name char 12
reg [7:0] R_SGNLCHAR13; ///ERCY file error signal name char 13
reg [7:0] R_SGNLCHAR14; ///ERCY file error signal name char 14
reg [7:0] R_SGNLCHAR15; ///ERCY file error signal name char 15
reg [7:0] R_SGNLCHAR16; ///ERCY file error signal name char 16
reg [7:0] R_SGNLCHAR17; ///ERCY file error signal name char 17
reg [7:0] R_SGNLCHAR18; ///ERCY file error signal name char 18
reg [7:0] R_SGNLCHAR19; ///ERCY file error signal name char 19
reg [7:0] R_SGNLCHAR20; ///ERCY file error signal name char 20
reg [7:0] R_SGNLCHAR21; ///ERCY file error signal name char 21
reg [7:0] R_SGNLCHAR22; ///ERCY file error signal name char 22
reg [7:0] R_SGNLCHAR23; ///ERCY file error signal name char 23
reg [7:0] R_SGNLCHAR24; ///ERCY file error signal name char 24
reg [7:0] R_SGNLCHAR25; ///ERCY file error signal name char 25
reg [7:0] R_SGNLCHAR26; ///ERCY file error signal name char 26
reg [7:0] R_SGNLCHAR27; ///ERCY file error signal name char 27
reg [7:0] R_SGNLCHAR28; ///ERCY file error signal name char 28
reg [7:0] R_SGNLCHAR29; ///ERCY file error signal name char 29
reg [7:0] R_SGNLCHAR30; ///ERCY file error signal name char 30
reg [7:0] R_SGNLCHAR31; ///ERCY file error signal name char 31

assign SGNLCHAR0 = R_SGNLCHAR0;
assign SGNLCHAR1 = R_SGNLCHAR1;
assign SGNLCHAR2 = R_SGNLCHAR2;
assign SGNLCHAR3 = R_SGNLCHAR3;
assign SGNLCHAR4 = R_SGNLCHAR4;
assign SGNLCHAR5 = R_SGNLCHAR5;
assign SGNLCHAR6 = R_SGNLCHAR6;
assign SGNLCHAR7 = R_SGNLCHAR7;
assign SGNLCHAR8 = R_SGNLCHAR8;
assign SGNLCHAR9 = R_SGNLCHAR9;
assign SGNLCHAR10 = R_SGNLCHAR10;
assign SGNLCHAR11 = R_SGNLCHAR11;
assign SGNLCHAR12 = R_SGNLCHAR12;
assign SGNLCHAR13 = R_SGNLCHAR13;
assign SGNLCHAR14 = R_SGNLCHAR14;
assign SGNLCHAR15 = R_SGNLCHAR15;
assign SGNLCHAR16 = R_SGNLCHAR16;
assign SGNLCHAR17 = R_SGNLCHAR17;
assign SGNLCHAR18 = R_SGNLCHAR18;
assign SGNLCHAR19 = R_SGNLCHAR19;
assign SGNLCHAR20 = R_SGNLCHAR20;
assign SGNLCHAR21 = R_SGNLCHAR21;
assign SGNLCHAR22 = R_SGNLCHAR22;
assign SGNLCHAR23 = R_SGNLCHAR23;
assign SGNLCHAR24 = R_SGNLCHAR24;
assign SGNLCHAR25 = R_SGNLCHAR25;
assign SGNLCHAR26 = R_SGNLCHAR26;
assign SGNLCHAR27 = R_SGNLCHAR27;
assign SGNLCHAR28 = R_SGNLCHAR28;
assign SGNLCHAR29 = R_SGNLCHAR29;
assign SGNLCHAR30 = R_SGNLCHAR30;
assign SGNLCHAR31 = R_SGNLCHAR31;

/////////////////////////////HEADER DOUBLE BUFFERS (MATRIX)//////////////////////////

///First chars of signals names addresses RAM
avcheader avcheaderm(
	.aclr(ureset),
	.address(R_AVCSLNMADDRN),
	.clock(nclk),
	.data(R_AVCSLNMADDRM),
	.wren(sbdone & avcrden & isdpkt & AVCVECNTR == 0 & DATASI == 8'h20 & !eofavcfnd),
	//.rden(1'b1),
	.q(AVCSLNMADDRN)
);

///Signal names RAM
avcheader avcheadern(
	.aclr(ureset),
	.address(R_AVCSLNMADDRM),
	.clock(nclk),
	.data(DATASI == 8'h3B ? 8'h20 : DATASI),
	.wren(sbdone & avcrden & isdpkt & AVCVECNTR == 0 & DATASI != 8'h0A & !eofavcfnd), 
	//.rden(1'b1),
	.q(SIGCHAR)
);

/////////////////////////////HEADER MATRIX POINTERS//////////////////////////
//////////Pointer (address) while reading signal's names first chars from 
//////////header from SD card and writing them into RAM
//////////also while getting chars from RAM and writing on SD card 
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_AVCSLNMADDRN <= 0;
	else
	begin
		if(AVCVECNTR == 0 & !eofavcfnd)
		begin
			if(sbdone & avcrden & endpkt & isdpkt & DATASI == 8'h20)
				R_AVCSLNMADDRN <= R_AVCSLNMADDRN + 1'b1;
		end
		else 
		begin
			if(eofavcfnd)
				R_AVCSLNMADDRN <= SGNLNMNUM; 
		end
	end
end
////////////////////////////////////////////////////////////////////////
//////////Pointer (address) while reading signal's full names from 
//////////header from SD card and writing them into RAM
//////////also while getting full names from RAM and writing on SD card 
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_AVCSLNMADDRM <= 0;
	else
	begin
		if(R_ST_SGNLNAME == CHAR_READ)
			R_AVCSLNMADDRM <= AVCSLNMADDRN;
		else if((sbdone & avcrden & isdpkt & AVCVECNTR == 0 & !eofavcfnd) | R_ST_SGNLNAME != IDLE)
			R_AVCSLNMADDRM <= R_AVCSLNMADDRM + 1'b1;
	end
end

/////////////////////////////WRITE SIGNAL NAME'S CHARS INTO REGISTERS//////////////////////////
//////////Signal name char 0
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR0 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR0 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR0)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR0 <= 8'h29;
				else
					R_SGNLCHAR0 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 1
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR1 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR1 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR1)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR1 <= 8'h29;
				else
					R_SGNLCHAR1 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 2
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR2 <= 8'h20; 
	else
	begin
		if(errrd)
			R_SGNLCHAR2 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR2)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR2 <= 8'h29;
				else
					R_SGNLCHAR2 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 3
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR3 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR3 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR3)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR3 <= 8'h29;
				else
					R_SGNLCHAR3 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 4
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR4 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR4 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR4)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR4 <= 8'h29;
				else
					R_SGNLCHAR4 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 5
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR5 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR5 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR5)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR5 <= 8'h29;
				else
					R_SGNLCHAR5 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 6
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR6 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR6 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR6)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR6 <= 8'h29;
				else
					R_SGNLCHAR6 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 7
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR7 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR7 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR7)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR7 <= 8'h29;
				else
					R_SGNLCHAR7 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 8
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR8 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR8 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR8)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR8 <= 8'h29;
				else
					R_SGNLCHAR8 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 9
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR9 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR9 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR9)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR9 <= 8'h29;
				else
					R_SGNLCHAR9 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 10
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR10 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR10 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR10)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR10 <= 8'h29;
				else
					R_SGNLCHAR10 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 11
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR11 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR11 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR11)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR11 <= 8'h29;
				else
					R_SGNLCHAR11 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 12
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR12 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR12 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR12)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR12 <= 8'h29;
				else
					R_SGNLCHAR12 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 13
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR13 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR13 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR13)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR13 <= 8'h29;
				else
					R_SGNLCHAR13 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 14
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR14 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR14 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR14)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR14 <= 8'h29;
				else
					R_SGNLCHAR14 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 15
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR15 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR15 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR15)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR15 <= 8'h29;
				else
					R_SGNLCHAR15 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 16
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR16 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR16 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR16)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR16 <= 8'h29;
				else
					R_SGNLCHAR16 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 17
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR17 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR17 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR17)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR17 <= 8'h29;
				else
					R_SGNLCHAR17 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 18
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR18 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR18 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR18)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR18 <= 8'h29;
				else
					R_SGNLCHAR18 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 19
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR19 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR19 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR19)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR19 <= 8'h29;
				else
					R_SGNLCHAR19 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 20
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR20 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR20 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR20)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR20 <= 8'h29;
				else
					R_SGNLCHAR20 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 21
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR21 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR21 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR21)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR21 <= 8'h29;
				else
					R_SGNLCHAR21 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 22
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR22 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR22 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR22)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR22 <= 8'h29;
				else
					R_SGNLCHAR22 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 23
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR23 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR23 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR23)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR23 <= 8'h29;
				else
					R_SGNLCHAR23 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 24
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR24 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR24 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR24)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR24 <= 8'h29;
				else
					R_SGNLCHAR24 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 25
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR25 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR25 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR25)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR25 <= 8'h29;
				else
					R_SGNLCHAR25 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 26
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR26 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR26 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR26)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR26 <= 8'h29;
				else
					R_SGNLCHAR26 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 27
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR27 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR27 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR27)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR27 <= 8'h29;
				else
					R_SGNLCHAR27 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 28
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR28 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR28 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR28)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR28 <= 8'h29;
				else
					R_SGNLCHAR28 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 29
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR29 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR29 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR29)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR29 <= 8'h29;
				else
					R_SGNLCHAR29 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 30
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR30 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR30 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR30)
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_SGNLCHAR30 <= 8'h29;
				else
					R_SGNLCHAR30 <= SIGCHAR;
			end
		end
	end
end
//////////Signal name char 31
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLCHAR31 <= 8'h20;
	else
	begin
		if(errrd)
			R_SGNLCHAR31 <= 8'h20;
		else
		begin
			if(R_ST_SGNLNAME == WRITE_CHAR31)
				R_SGNLCHAR31 <= 8'h29;
		end
	end
end

/////////////////////////////SIGNAL NAME'S STATE MACHINE//////////////////////////
//////////Signal Name chars reading state machine from RAM avcheadern 
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_ST_SGNLNAME <= IDLE;
	else
	begin
		
		case(R_ST_SGNLNAME)
		
			IDLE:
			begin
				if(errrd)
					R_ST_SGNLNAME <= CHAR_READ;
			end
			
			CHAR_READ:
				R_ST_SGNLNAME <= CHAR_LAUNCH;
				
			CHAR_LAUNCH:
				R_ST_SGNLNAME <= CHAR_LATCH;
			
			CHAR_LATCH:
				R_ST_SGNLNAME <= WHITESPACE;  
				
			WHITESPACE:
				R_ST_SGNLNAME <= WRITE_CHAR0;
			
			WRITE_CHAR0:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR1;
			end
			
			WRITE_CHAR1:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR2;
			end
			
			WRITE_CHAR2:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR3;
			end
			
			WRITE_CHAR3:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR4;
			end
			
			WRITE_CHAR4:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR5;
			end
			
			WRITE_CHAR5:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR6;
			end
			
			WRITE_CHAR6:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR7;
			end
			
			WRITE_CHAR7:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR8;
			end
			
			WRITE_CHAR8:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR9;
			end
			
			WRITE_CHAR9:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR10;
			end
			
			WRITE_CHAR10:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR11;
			end
			
			WRITE_CHAR11:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR12;
			end
			
			WRITE_CHAR12:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR13;
			end
			
			WRITE_CHAR13:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR14;
			end
			
			WRITE_CHAR14:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR15;
			end
			
			WRITE_CHAR15:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR16;
			end
			
			WRITE_CHAR16:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR17;
			end
			
			WRITE_CHAR17:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR18;
			end
			
			WRITE_CHAR18:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR19;
			end
			
			WRITE_CHAR19:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR20;
			end
			
			WRITE_CHAR20:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR21;
			end
			
			WRITE_CHAR21:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR22;
			end
			
			WRITE_CHAR22:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR23;
			end
			
			WRITE_CHAR23:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR24;
			end

			WRITE_CHAR24:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR25;
			end
			
			WRITE_CHAR25:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR26;
			end

			WRITE_CHAR26:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR27;
			end

			WRITE_CHAR27:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR28;
			end

			WRITE_CHAR28:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR29;
			end

			WRITE_CHAR29:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR30;
			end

			WRITE_CHAR30:
			begin
				if(SIGCHAR == 8'h20 | SIGCHAR == 8'h00)
					R_ST_SGNLNAME <= WRITE_END;
				else
					R_ST_SGNLNAME <= WRITE_CHAR31;
			end

			WRITE_CHAR31: 
				R_ST_SGNLNAME <= WRITE_END;
		
			WRITE_END:
				R_ST_SGNLNAME <= IDLE;
			
		endcase
	end
end

endmodule 