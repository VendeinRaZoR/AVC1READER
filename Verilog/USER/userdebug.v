/*##################################################################################*/
/*######################====USER INFORMATION ON LCD 16X2===#########################*/
/*##################################################################################*/
/*Description:
This module writes user information about testing process on LCD 
(reading AVC file, writing ERCY file, no 3-state signals e.t.c.)
*/
module userdebug(
input mbrstrten, ///MBR_START state enabled
input ercywsfen, ///ERCY_WRITE_FILE or ERCY_SET_FILE state enabled
input ercywsden, ///ERCY_WRITE_DATA or ERCY_SET_DATA state enabled
input userwstrten, ///USER_WAIT_START state enabled
input userwnexten, ///USER_WAIT_NEXT state enabled
input avcgrden, ///AVC_READ_DATA or AVC_GET_DATA state enabled
input eofavcfnd, ///AVC file End-of-File found signal in packet 
input notstsgnls, ///No 3-state signals in AVC file
input [23:0] AVCFEX, ///AVC file extention "avc" string
input [7:0] AVCFNAME0, ///AVC File Name char 0
input [7:0] AVCFNAME1, ///AVC File Name char 1
input [7:0] AVCFNAME2, ///AVC File Name char 2
input [7:0] AVCFNAME3, ///AVC File Name char 3
input [7:0] AVCFNAME4, ///AVC File Name char 4
input [7:0] AVCFNAME5, ///AVC File Name char 5
input [7:0] AVCFNAME6, ///AVC File Name char 6
input [7:0] AVCFNAME7, ///AVC File Name char 7
output reg [7:0] CHAR0, ///LCD symbol ASCII char 0
output reg [7:0] CHAR1, ///LCD symbol ASCII char 1
output reg [7:0] CHAR2, ///LCD symbol ASCII char 2
output reg [7:0] CHAR3, ///LCD symbol ASCII char 3
output reg [7:0] CHAR4, ///LCD symbol ASCII char 4
output reg [7:0] CHAR5, ///LCD symbol ASCII char 5
output reg [7:0] CHAR6, ///LCD symbol ASCII char 6
output reg [7:0] CHAR7, ///LCD symbol ASCII char 7
output reg [7:0] CHAR8, ///LCD symbol ASCII char 8
output reg [7:0] CHAR9, ///LCD symbol ASCII char 9
output reg [7:0] CHAR10, ///LCD symbol ASCII char 10
output reg [7:0] CHAR11, ///LCD symbol ASCII char 11
output reg [7:0] CHAR12, ///LCD symbol ASCII char 12
output reg [7:0] CHAR13, ///LCD symbol ASCII char 13
output reg [7:0] CHAR14, ///LCD symbol ASCII char 14
output reg [7:0] CHAR15, ///LCD symbol ASCII char 15
output reg [7:0] CHAR16, ///LCD symbol ASCII char 16
output reg [7:0] CHAR17, ///LCD symbol ASCII char 17
output reg [7:0] CHAR18, ///LCD symbol ASCII char 18
output reg [7:0] CHAR19, ///LCD symbol ASCII char 19
output reg [7:0] CHAR20, ///LCD symbol ASCII char 20
output reg [7:0] CHAR21, ///LCD symbol ASCII char 21
output reg [7:0] CHAR22, ///LCD symbol ASCII char 22
output reg [7:0] CHAR23, ///LCD symbol ASCII char 23
output reg [7:0] CHAR24, ///LCD symbol ASCII char 24
output reg [7:0] CHAR25, ///LCD symbol ASCII char 25
output reg [7:0] CHAR26, ///LCD symbol ASCII char 26
output reg [7:0] CHAR27, ///LCD symbol ASCII char 27
output reg [7:0] CHAR28, ///LCD symbol ASCII char 28
output reg [7:0] CHAR29, ///LCD symbol ASCII char 29
output reg [7:0] CHAR30, ///LCD symbol ASCII char 30
output reg [7:0] CHAR31 ///LCD symbol ASCII char 31
);

/////////////////////////USER INFORMATION ON LCD BY CHARS IN ASCII SYMBOLS//////////////////////////
//////////CHAR0..31 symbols for message on 16x2 LCD
always@*
begin
	if(avcgrden & !eofavcfnd) ///Searching signals message
	begin
		CHAR0 = 8'h53; 
		CHAR1 = 8'h65;
		CHAR2 = 8'h61;
		CHAR3 = 8'h72;
		CHAR4 = 8'h63;
		CHAR5 = 8'h68;
		CHAR6 = 8'h69;
		CHAR7 = 8'h6E;
		CHAR8 = 8'h67; 
		CHAR9 = 8'h20;
		CHAR10 = 8'h66;
		CHAR11 = 8'h6F;
		CHAR12 = 8'h72;
		CHAR13 = 8'h20;
		CHAR14 = 8'h20;
		CHAR15 = 8'h20;
		CHAR16 = 8'h33;
		CHAR17 = 8'h2D;
		CHAR18 = 8'h73;
		CHAR19 = 8'h74;
		CHAR20 = 8'h61;
		CHAR21 = 8'h74;
		CHAR22 = 8'h65;
		CHAR23 = 8'h20;
		CHAR24 = 8'h73;
		CHAR25 = 8'h69;
		CHAR26 = 8'h67;
		CHAR27 = 8'h6E;
		CHAR28 = 8'h61;
		CHAR29 = 8'h6C;
		CHAR30 = 8'h73;
		CHAR31 =	8'h20;
	end
	else if(userwnexten & eofavcfnd & notstsgnls) //No 3-state signals message
	begin
		CHAR0 = 8'h4E;
		CHAR1 = 8'h6F;
		CHAR2 = 8'h20;
		CHAR3 = 8'h33;
		CHAR4 = 8'h2D;
		CHAR5 = 8'h73;
		CHAR6 = 8'h74;
		CHAR7 = 8'h61;
		CHAR8 = 8'h74;
		CHAR9 = 8'h65;
		CHAR10 = 8'h20;
		CHAR11 = 8'h73;
		CHAR12 = 8'h69;
		CHAR13 = 8'h67;
		CHAR14 = 8'h6E;
		CHAR15 = 8'h6C;
		CHAR16 = 8'h50;
		CHAR17 = 8'h72;
		CHAR18 = 8'h65;
		CHAR19 = 8'h73;
		CHAR20 = 8'h73;
		CHAR21 = 8'h20;
		CHAR22 = 8'h52;
		CHAR23 = 8'h45;
		CHAR24 = 8'h53;
		CHAR25 = 8'h45;
		CHAR26 = 8'h54;
		CHAR27 = 8'h20;
		CHAR28 = 8'h20;
		CHAR29 = 8'h20;
		CHAR30 = 8'h20;
		CHAR31 =	8'h20;
	end
	else if(userwnexten) //Done ! message
	begin
		CHAR0 = 8'h44; 
		CHAR1 = 8'h6F;
		CHAR2 = 8'h6E;
		CHAR3 = 8'h65;
		CHAR4 = 8'h21;
		CHAR5 = 8'h20;
		CHAR6 = 8'h43;
		CHAR7 = 8'h68;
		CHAR8 = 8'h65; 
		CHAR9 = 8'h63;
		CHAR10 = 8'h6B;
		CHAR11 = 8'h20;
		CHAR12 = 8'h45;
		CHAR13 = 8'h52;
		CHAR14 = 8'h43;
		CHAR15 = 8'h59;
		CHAR16 = 8'h50; 
		CHAR17 = 8'h72;
		CHAR18 = 8'h65;
		CHAR19 = 8'h73;
		CHAR20 = 8'h73;
		CHAR21 = 8'h20;
		CHAR22 = 8'h53;
		CHAR23 = 8'h54;
		CHAR24 = 8'h41;
		CHAR25 = 8'h52;
		CHAR26 = 8'h54;
		CHAR27 = 8'h20;
		CHAR28 = 8'h20;
		CHAR29 = 8'h20;
		CHAR30 = 8'h20;
		CHAR31 =	8'h20;
	end
	else if(ercywsden & eofavcfnd) //Writing ERCY file message
	begin
		CHAR0 = 8'h57; 
		CHAR1 = 8'h72;
		CHAR2 = 8'h69;
		CHAR3 = 8'h74;
		CHAR4 = 8'h69;
		CHAR5 = 8'h6E;
		CHAR6 = 8'h67;
		CHAR7 = 8'h20;
		CHAR8 = 8'h45; 
		CHAR9 = 8'h52;
		CHAR10 = 8'h43;
		CHAR11 = 8'h59;
		CHAR12 = 8'h20;
		CHAR13 = 8'h20;
		CHAR14 = 8'h20;
		CHAR15 = 8'h20;
		CHAR16 = 8'h76;
		CHAR17 = 8'h65;
		CHAR18 = 8'h63;
		CHAR19 = 8'h74;
		CHAR20 = 8'h6F;
		CHAR21 = 8'h72;
		CHAR22 = 8'h73;
		CHAR23 = 8'h2E;
		CHAR24 = 8'h2E;
		CHAR25 = 8'h2E;
		CHAR26 = 8'h20;
		CHAR27 = 8'h20;
		CHAR28 = 8'h20;
		CHAR29 = 8'h20;
		CHAR30 = 8'h20;
		CHAR31 =	8'h20;
	end
	else if(avcgrden & eofavcfnd) //Reading AVC file message
	begin
		CHAR0 = 8'h52; 
		CHAR1 = 8'h65;
		CHAR2 = 8'h61;
		CHAR3 = 8'h64;
		CHAR4 = 8'h69;
		CHAR5 = 8'h6E;
		CHAR6 = 8'h67;
		CHAR7 = 8'h20;
		CHAR8 = 8'h41; 
		CHAR9 = 8'h56;
		CHAR10 = 8'h43;
		CHAR11 = 8'h20;
		CHAR12 = 8'h66;
		CHAR13 = 8'h69;
		CHAR14 = 8'h6C;
		CHAR15 = 8'h65;
		CHAR16 = 8'h73;
		CHAR17 = 8'h69;
		CHAR18 = 8'h67;
		CHAR19 = 8'h6E;
		CHAR20 = 8'h61;
		CHAR21 = 8'h6C;
		CHAR22 = 8'h73;
		CHAR23 = 8'h2E;
		CHAR24 = 8'h2E;
		CHAR25 = 8'h2E;
		CHAR26 = 8'h20;
		CHAR27 = 8'h20;
		CHAR28 = 8'h20;
		CHAR29 = 8'h20;
		CHAR30 = 8'h20;
		CHAR31 =	8'h20;
	end
	else if(userwstrten & AVCFNAME0 != 8'h05 & AVCFNAME0 != 8'hE5 & AVCFNAME0 != 8'h00) /// AVC FileName PRESS START message
	begin
		CHAR0 = 8'h41;
		CHAR1 = 8'h56;
		CHAR2 = 8'h43;
		CHAR3 = 8'h3A;
		CHAR4 = AVCFNAME0;
		CHAR5 = AVCFNAME1;
		CHAR6 = AVCFNAME2;
		CHAR7 = AVCFNAME3;
		CHAR8 = AVCFNAME4; 
		CHAR9 = AVCFNAME5;
		CHAR10 = AVCFNAME6;
		CHAR11 = AVCFNAME7;
		CHAR12 = 8'h2E;
		CHAR13 = AVCFEX[23:16];
		CHAR14 = AVCFEX[15:8];
		CHAR15 = AVCFEX[7:0];
		CHAR16 = 8'h50;
		CHAR17 = 8'h72;
		CHAR18 = 8'h65;
		CHAR19 = 8'h73;
		CHAR20 = 8'h73;
		CHAR21 = 8'h20;
		CHAR22 = 8'h53;
		CHAR23 = 8'h54;
		CHAR24 = 8'h41;
		CHAR25 = 8'h52;
		CHAR26 = 8'h54;
		CHAR27 = 8'h20;
		CHAR28 = 8'h20;
		CHAR29 = 8'h20;
		CHAR30 = 8'h20;
		CHAR31 =	8'h20;
	end
	else if(mbrstrten) //No SD Card message
	begin
		CHAR0 = 8'h4E;
		CHAR1 = 8'h6F;
		CHAR2 = 8'h20;
		CHAR3 = 8'h53;
		CHAR4 = 8'h44;
		CHAR5 = 8'h20;
		CHAR6 = 8'h43;
		CHAR7 = 8'h61;
		CHAR8 = 8'h72;
		CHAR9 = 8'h64;
		CHAR10 = 8'h21;
		CHAR11 = 8'h20;
		CHAR12 = 8'h20;
		CHAR13 = 8'h20;
		CHAR14 = 8'h20;
		CHAR15 = 8'h20;
		CHAR16 = 8'h50;
		CHAR17 = 8'h72;
		CHAR18 = 8'h65;
		CHAR19 = 8'h73;
		CHAR20 = 8'h73;
		CHAR21 = 8'h20;
		CHAR22 = 8'h52;
		CHAR23 = 8'h45;
		CHAR24 = 8'h53;
		CHAR25 = 8'h45;
		CHAR26 = 8'h54;
		CHAR27 = 8'h20;
		CHAR28 = 8'h20;
		CHAR29 = 8'h20;
		CHAR30 = 8'h20;
		CHAR31 =	8'h20;
	end
	else  //No AVC File message
	begin
		CHAR0 = 8'h4E;
		CHAR1 = 8'h6F;
		CHAR2 = 8'h20;
		CHAR3 = 8'h41;
		CHAR4 = 8'h56;
		CHAR5 = 8'h43;
		CHAR6 = 8'h20;
		CHAR7 = 8'h46;
		CHAR8 = 8'h69;
		CHAR9 = 8'h6C;
		CHAR10 = 8'h65;
		CHAR11 = 8'h21;
		CHAR12 = 8'h20;
		CHAR13 = 8'h20;
		CHAR14 = 8'h20;
		CHAR15 = 8'h20;
		CHAR16 = 8'h50;
		CHAR17 = 8'h72;
		CHAR18 = 8'h65;
		CHAR19 = 8'h73;
		CHAR20 = 8'h73;
		CHAR21 = 8'h20;
		CHAR22 = 8'h52;
		CHAR23 = 8'h45;
		CHAR24 = 8'h53;
		CHAR25 = 8'h45;
		CHAR26 = 8'h54;
		CHAR27 = 8'h20;
		CHAR28 = 8'h20;
		CHAR29 = 8'h20;
		CHAR30 = 8'h20;
		CHAR31 =	8'h20;
	end
end



endmodule 