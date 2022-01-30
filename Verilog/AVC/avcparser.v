 /*#########################################################*/
/*###################====AVC PARSER====#####################*/
/*##########################################################*/
/*Description:
AVC parser finds 3-state and input signals in AVC file 
and brings them into parallel form for SDRAM
*/
module avcparser(
input clk, //Clock
input ureset, ///User reset (by START button)
input sbdone, /// shift byte done
input endpkt, ///end of DATA packet
input isdpkt, ///is DATA packet on DAT line 
input avcrden,///AVC_READ_DATA state enabled
input [7:0] DATASI, ///Data serial input SD CARD shift register output
output [31:0] AVCVECNTR, ///AVC file vector counter while reading from SD CARD
output [127:0] AVCPSGNL, ///AVC files signals in parallel form for output on IDE connector 
output [127:0] TRSTPSGNL, ///output enable signals for output signals on IDE connector
output [127:0] HLPSGNL, ///is current signal is input H or L signal parallel (128 signals but 16 used only)
output eofavc, ///End-of-File AVC file
output eofavcfnd, ///found End-of-File in AVC file
output resprdspntr, ///Reset AVC file sector pointer
output notstsgnls ///No 3-state signals
);

reg R_EOFAVC; ///End-of-File AVC register
reg R_EOFAVCFND; ///End-of-File AVC found register
reg [127:0] R_HLVEC; ///3-state control for output signals on IDE connector (128 signals but 16 used only)
reg [31:0] R_AVCVECNTR; ///AVC vector counter
reg [127:0] R_AVCPSGNL; ///AVC vector signals in parallel form (128 signals but 16 used only)
reg [127:0] R_TRSTPSGNL; ///Direction of signals in parallel form (128 signals but 16 used only) 
reg [6:0] R_AVCHRCNTR; ///AVC char (bits) counter in AVC vector
reg [127:0] R_HLPSGNL; ///is current signal is input H or L signal parallel (128 signals but 16 used only)
reg [127:0] R_TSSGNLNUM; ///shift AVC signal type register (input or output) (128 signals but 16 used only)

assign TRSTPSGNL = R_TRSTPSGNL;

assign eofavc = R_EOFAVC;
assign eofavcfnd = R_EOFAVCFND;
assign AVCPSGNL = R_AVCPSGNL;

assign AVCVECNTR = R_AVCVECNTR;

assign resprdspntr = R_AVCVECNTR == 0;

assign notstsgnls = R_HLVEC == 0;

assign HLPSGNL = R_HLPSGNL;

/////////////////////////////AVC FILE PARSER STAGE/////////////////////////
//////////End-Of-File AVC indicator
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_EOFAVC <= 0;
	else
	begin
		if(sbdone & avcrden & endpkt & isdpkt & eofavcfnd & DATASI == 8'h00 & R_AVCVECNTR != 0)
			R_EOFAVC <= 1;
	end
end
//////////End-Of-File AVC already found indicator
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_EOFAVCFND <= 0;
	else
	begin
		if(sbdone & avcrden & endpkt & isdpkt & DATASI == 8'h00)
			R_EOFAVCFND <= 1;
	end
end

//////////AVC File Vector counter
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_AVCVECNTR <= 32'h0000_0000;
	else
	begin
		if(sbdone & avcrden & endpkt & isdpkt & !eofavcfnd & DATASI == 8'h00)
			R_AVCVECNTR <= 32'h0000_0000;
		else if(sbdone & avcrden & endpkt & isdpkt & DATASI == 8'h0A)
			R_AVCVECNTR <= R_AVCVECNTR + 32'h0000_0001;   
	end
end
//////////AVC Char counter counts signals in 1 vector
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_AVCHRCNTR <= 7'h00;
	else
	begin
		if(sbdone & avcrden & endpkt & isdpkt & R_AVCVECNTR != 32'h0)
		begin
		
			case(DATASI)
		
				8'h0A:
					R_AVCHRCNTR <= 7'h00;
				
				8'h00:
					R_AVCHRCNTR <= 7'h00;
					
				8'h30:
					R_AVCHRCNTR <= R_AVCHRCNTR + 1'b1;
					
				8'h31:
					R_AVCHRCNTR <= R_AVCHRCNTR + 1'b1;
				
				8'h78:
					R_AVCHRCNTR <= R_AVCHRCNTR + 1'b1;
					
				8'h7A:
					R_AVCHRCNTR <= R_AVCHRCNTR + 1'b1;
					
				8'h48:
					R_AVCHRCNTR <= R_AVCHRCNTR + 1'b1;
				
				8'h4C:
					R_AVCHRCNTR <= R_AVCHRCNTR + 1'b1;
					
			endcase
		end
	end
end
//////////fetch register containing H & L signals of vector in parallel form when reach End-Of-Line
always@(posedge ureset or negedge clk)
begin
	if(ureset)
	begin
		R_HLVEC <= 0;
	end
	else
	begin
		if(sbdone & avcrden & endpkt & isdpkt & !eofavcfnd & DATASI == 8'h0A & R_AVCVECNTR != 0)
			R_HLVEC <= R_HLVEC | R_HLPSGNL;
	end
end
//////////AVC vector in parallel form composed from particular signals
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_AVCPSGNL <= 0;
	else
	begin
		if(sbdone & avcrden & endpkt & isdpkt & eofavcfnd & R_AVCVECNTR != 0)
		begin
			if(DATASI == 8'h30 | DATASI == 8'h31 | DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C)
			begin
				case(R_AVCHRCNTR)
				
				0: R_AVCPSGNL[127] <= 0; 
				1: R_AVCPSGNL[0] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				2: R_AVCPSGNL[1] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				3: R_AVCPSGNL[2] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				4: R_AVCPSGNL[3] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				5: R_AVCPSGNL[4] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				6: R_AVCPSGNL[5] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				7: R_AVCPSGNL[6] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				8: R_AVCPSGNL[7] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				9: R_AVCPSGNL[8] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				10: R_AVCPSGNL[9] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				11: R_AVCPSGNL[10] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				12: R_AVCPSGNL[11] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				13: R_AVCPSGNL[12] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				14: R_AVCPSGNL[13] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				15: R_AVCPSGNL[14] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				16: R_AVCPSGNL[15] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				17: R_AVCPSGNL[16] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				18: R_AVCPSGNL[17] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				19: R_AVCPSGNL[18] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				20: R_AVCPSGNL[19] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				21: R_AVCPSGNL[20] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				22: R_AVCPSGNL[21] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				23: R_AVCPSGNL[22] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				24: R_AVCPSGNL[23] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				25: R_AVCPSGNL[24] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				26: R_AVCPSGNL[25] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				27: R_AVCPSGNL[26] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				28: R_AVCPSGNL[27] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				29: R_AVCPSGNL[28] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				30: R_AVCPSGNL[29] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				31: R_AVCPSGNL[30] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				32: R_AVCPSGNL[31] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				33: R_AVCPSGNL[32] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				34: R_AVCPSGNL[33] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				35: R_AVCPSGNL[34] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				36: R_AVCPSGNL[35] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				37: R_AVCPSGNL[36] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				38: R_AVCPSGNL[37] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				39: R_AVCPSGNL[38] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				40: R_AVCPSGNL[39] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				41: R_AVCPSGNL[40] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				42: R_AVCPSGNL[41] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				43: R_AVCPSGNL[42] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				44: R_AVCPSGNL[43] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				45: R_AVCPSGNL[44] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				46: R_AVCPSGNL[45] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				47: R_AVCPSGNL[46] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				48: R_AVCPSGNL[47] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				49: R_AVCPSGNL[48] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				50: R_AVCPSGNL[49] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				51: R_AVCPSGNL[50] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				52: R_AVCPSGNL[51] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				53: R_AVCPSGNL[52] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				54: R_AVCPSGNL[53] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				55: R_AVCPSGNL[54] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				56: R_AVCPSGNL[55] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				57: R_AVCPSGNL[56] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				58: R_AVCPSGNL[57] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				59: R_AVCPSGNL[58] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				60: R_AVCPSGNL[59] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				61: R_AVCPSGNL[60] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				62: R_AVCPSGNL[61] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				63: R_AVCPSGNL[62] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				64: R_AVCPSGNL[63] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				65: R_AVCPSGNL[64] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				66: R_AVCPSGNL[65] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				67: R_AVCPSGNL[66] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				68: R_AVCPSGNL[67] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				69: R_AVCPSGNL[68] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				70: R_AVCPSGNL[69] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				71: R_AVCPSGNL[70] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				72: R_AVCPSGNL[71] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				73: R_AVCPSGNL[72] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				74: R_AVCPSGNL[73] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				75: R_AVCPSGNL[74] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				76: R_AVCPSGNL[75] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				77: R_AVCPSGNL[76] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				78: R_AVCPSGNL[77] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				79: R_AVCPSGNL[78] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				80: R_AVCPSGNL[79] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				81: R_AVCPSGNL[80] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				82: R_AVCPSGNL[81] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				83: R_AVCPSGNL[82] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				84: R_AVCPSGNL[83] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				85: R_AVCPSGNL[84] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				86: R_AVCPSGNL[85] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				87: R_AVCPSGNL[86] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				88: R_AVCPSGNL[87] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				89: R_AVCPSGNL[88] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				90: R_AVCPSGNL[89] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				91: R_AVCPSGNL[90] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				92: R_AVCPSGNL[91] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				93: R_AVCPSGNL[92] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				94: R_AVCPSGNL[93] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				95: R_AVCPSGNL[94] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				96: R_AVCPSGNL[95] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				97: R_AVCPSGNL[96] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				98: R_AVCPSGNL[97] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				99: R_AVCPSGNL[98] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				100: R_AVCPSGNL[99] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				101: R_AVCPSGNL[100] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				102: R_AVCPSGNL[101] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				103: R_AVCPSGNL[102] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				104: R_AVCPSGNL[103] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				105: R_AVCPSGNL[104] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				106: R_AVCPSGNL[105] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				107: R_AVCPSGNL[106] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				108: R_AVCPSGNL[107] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				109: R_AVCPSGNL[108] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				110: R_AVCPSGNL[109] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				111: R_AVCPSGNL[110] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				112: R_AVCPSGNL[111] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				113: R_AVCPSGNL[112] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				114: R_AVCPSGNL[113] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				115: R_AVCPSGNL[114] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				116: R_AVCPSGNL[115] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				117: R_AVCPSGNL[116] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				118: R_AVCPSGNL[117] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				119: R_AVCPSGNL[118] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				120: R_AVCPSGNL[119] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				121: R_AVCPSGNL[120] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				122: R_AVCPSGNL[121] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				123: R_AVCPSGNL[122] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				124: R_AVCPSGNL[123] <= (DATASI == 8'h31 | DATASI == 8'h48);  
				125: R_AVCPSGNL[124] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				126: R_AVCPSGNL[125] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				127: R_AVCPSGNL[126] <= (DATASI == 8'h31 | DATASI == 8'h48); 
				
				endcase
			end
			else if(DATASI == 8'h0A | DATASI == 8'h00)
				R_AVCPSGNL <= 0;
		end
	end
end
//////////Signal's directoins in parallel form received from AVC file on SD CARD
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_TRSTPSGNL <= 0;
	else
	begin
		if(sbdone & avcrden & endpkt & isdpkt & eofavcfnd & R_AVCVECNTR != 0)
		begin
			if(DATASI == 8'h30 | DATASI == 8'h31 | DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C)
			begin
				case(R_AVCHRCNTR)
				
				0: R_TRSTPSGNL[127] <= 0;
				1: R_TRSTPSGNL[0] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				2: R_TRSTPSGNL[1] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				3: R_TRSTPSGNL[2] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				4: R_TRSTPSGNL[3] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				5: R_TRSTPSGNL[4] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				6: R_TRSTPSGNL[5] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				7: R_TRSTPSGNL[6] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				8: R_TRSTPSGNL[7] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				9: R_TRSTPSGNL[8] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				10: R_TRSTPSGNL[9] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				11: R_TRSTPSGNL[10] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				12: R_TRSTPSGNL[11] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				13: R_TRSTPSGNL[12] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				14: R_TRSTPSGNL[13] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				15: R_TRSTPSGNL[14] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				16: R_TRSTPSGNL[15] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				17: R_TRSTPSGNL[16] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				18: R_TRSTPSGNL[17] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				19: R_TRSTPSGNL[18] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				20: R_TRSTPSGNL[19] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				21: R_TRSTPSGNL[20] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				22: R_TRSTPSGNL[21] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				23: R_TRSTPSGNL[22] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				24: R_TRSTPSGNL[23] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				25: R_TRSTPSGNL[24] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				26: R_TRSTPSGNL[25] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				27: R_TRSTPSGNL[26] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				28: R_TRSTPSGNL[27] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				29: R_TRSTPSGNL[28] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				30: R_TRSTPSGNL[29] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				31: R_TRSTPSGNL[30] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				32: R_TRSTPSGNL[31] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				33: R_TRSTPSGNL[32] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				34: R_TRSTPSGNL[33] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				35: R_TRSTPSGNL[34] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				36: R_TRSTPSGNL[35] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				37: R_TRSTPSGNL[36] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				38: R_TRSTPSGNL[37] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				39: R_TRSTPSGNL[38] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				40: R_TRSTPSGNL[39] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				41: R_TRSTPSGNL[40] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				42: R_TRSTPSGNL[41] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				43: R_TRSTPSGNL[42] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				44: R_TRSTPSGNL[43] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				45: R_TRSTPSGNL[44] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				46: R_TRSTPSGNL[45] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				47: R_TRSTPSGNL[46] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				48: R_TRSTPSGNL[47] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				49: R_TRSTPSGNL[48] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				50: R_TRSTPSGNL[49] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				51: R_TRSTPSGNL[50] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				52: R_TRSTPSGNL[51] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				53: R_TRSTPSGNL[52] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				54: R_TRSTPSGNL[53] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				55: R_TRSTPSGNL[54] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				56: R_TRSTPSGNL[55] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				57: R_TRSTPSGNL[56] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				58: R_TRSTPSGNL[57] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				59: R_TRSTPSGNL[58] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				60: R_TRSTPSGNL[59] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				61: R_TRSTPSGNL[60] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				62: R_TRSTPSGNL[61] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				63: R_TRSTPSGNL[62] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				64: R_TRSTPSGNL[63] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				65: R_TRSTPSGNL[64] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				66: R_TRSTPSGNL[65] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				67: R_TRSTPSGNL[66] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				68: R_TRSTPSGNL[67] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				69: R_TRSTPSGNL[68] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				70: R_TRSTPSGNL[69] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				71: R_TRSTPSGNL[70] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				72: R_TRSTPSGNL[71] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				73: R_TRSTPSGNL[72] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				74: R_TRSTPSGNL[73] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				75: R_TRSTPSGNL[74] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				76: R_TRSTPSGNL[75] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				77: R_TRSTPSGNL[76] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				78: R_TRSTPSGNL[77] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				79: R_TRSTPSGNL[78] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				80: R_TRSTPSGNL[79] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				81: R_TRSTPSGNL[80] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				82: R_TRSTPSGNL[81] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				83: R_TRSTPSGNL[82] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				84: R_TRSTPSGNL[83] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				85: R_TRSTPSGNL[84] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				86: R_TRSTPSGNL[85] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				87: R_TRSTPSGNL[86] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				88: R_TRSTPSGNL[87] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				89: R_TRSTPSGNL[88] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				90: R_TRSTPSGNL[89] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				91: R_TRSTPSGNL[90] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				92: R_TRSTPSGNL[91] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				93: R_TRSTPSGNL[92] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				94: R_TRSTPSGNL[93] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				95: R_TRSTPSGNL[94] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				96: R_TRSTPSGNL[95] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				97: R_TRSTPSGNL[96] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				98: R_TRSTPSGNL[97] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				99: R_TRSTPSGNL[98] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				100: R_TRSTPSGNL[99] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				101: R_TRSTPSGNL[100] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				102: R_TRSTPSGNL[101] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				103: R_TRSTPSGNL[102] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				104: R_TRSTPSGNL[103] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				105: R_TRSTPSGNL[104] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				106: R_TRSTPSGNL[105] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				107: R_TRSTPSGNL[106] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				108: R_TRSTPSGNL[107] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				109: R_TRSTPSGNL[108] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				110: R_TRSTPSGNL[109] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				111: R_TRSTPSGNL[110] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				112: R_TRSTPSGNL[111] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				113: R_TRSTPSGNL[112] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				114: R_TRSTPSGNL[113] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				115: R_TRSTPSGNL[114] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				116: R_TRSTPSGNL[115] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				117: R_TRSTPSGNL[116] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				118: R_TRSTPSGNL[117] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				119: R_TRSTPSGNL[118] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				120: R_TRSTPSGNL[119] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				121: R_TRSTPSGNL[120] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				122: R_TRSTPSGNL[121] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				123: R_TRSTPSGNL[122] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				124: R_TRSTPSGNL[123] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C);  
				125: R_TRSTPSGNL[124] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				126: R_TRSTPSGNL[125] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				127: R_TRSTPSGNL[126] <= (DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C); 
				
				endcase
			end
			else if(DATASI == 8'h0A | DATASI == 8'h00)
				R_TRSTPSGNL <= 0;
		end
	end
end
//////////H & L signals in parallel form detected from AVC file on SD card 
always@(posedge ureset or negedge clk)
begin
	if(ureset)
	R_HLPSGNL <= 0;
	else
	begin
		if(sbdone & avcrden & endpkt & isdpkt & R_AVCVECNTR != 0 & !eofavcfnd)
		begin
			if(DATASI == 8'h30 | DATASI == 8'h31 | DATASI == 8'h78 | DATASI == 8'h7A | DATASI == 8'h48 | DATASI == 8'h4C)
			begin 			
				case(R_AVCHRCNTR)

				0: R_HLPSGNL[127] <= 0; 
				1: R_HLPSGNL[0] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				2: R_HLPSGNL[1] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				3: R_HLPSGNL[2] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				4: R_HLPSGNL[3] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				5: R_HLPSGNL[4] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				6: R_HLPSGNL[5] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				7: R_HLPSGNL[6] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				8: R_HLPSGNL[7] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				9: R_HLPSGNL[8] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				10: R_HLPSGNL[9] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				11: R_HLPSGNL[10] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				12: R_HLPSGNL[11] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				13: R_HLPSGNL[12] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				14: R_HLPSGNL[13] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				15: R_HLPSGNL[14] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				16: R_HLPSGNL[15] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				17: R_HLPSGNL[16] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				18: R_HLPSGNL[17] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				19: R_HLPSGNL[18] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				20: R_HLPSGNL[19] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				21: R_HLPSGNL[20] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				22: R_HLPSGNL[21] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				23: R_HLPSGNL[22] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				24: R_HLPSGNL[23] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				25: R_HLPSGNL[24] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				26: R_HLPSGNL[25] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				27: R_HLPSGNL[26] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				28: R_HLPSGNL[27] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				29: R_HLPSGNL[28] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				30: R_HLPSGNL[29] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				31: R_HLPSGNL[30] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				32: R_HLPSGNL[31] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				33: R_HLPSGNL[32] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				34: R_HLPSGNL[33] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				35: R_HLPSGNL[34] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				36: R_HLPSGNL[35] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				37: R_HLPSGNL[36] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				38: R_HLPSGNL[37] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				39: R_HLPSGNL[38] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				40: R_HLPSGNL[39] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				41: R_HLPSGNL[40] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				42: R_HLPSGNL[41] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				43: R_HLPSGNL[42] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				44: R_HLPSGNL[43] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				45: R_HLPSGNL[44] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				46: R_HLPSGNL[45] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				47: R_HLPSGNL[46] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				48: R_HLPSGNL[47] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				49: R_HLPSGNL[48] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				50: R_HLPSGNL[49] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				51: R_HLPSGNL[50] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				52: R_HLPSGNL[51] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				53: R_HLPSGNL[52] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				54: R_HLPSGNL[53] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				55: R_HLPSGNL[54] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				56: R_HLPSGNL[55] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				57: R_HLPSGNL[56] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				58: R_HLPSGNL[57] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				59: R_HLPSGNL[58] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				60: R_HLPSGNL[59] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				61: R_HLPSGNL[60] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				62: R_HLPSGNL[61] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				63: R_HLPSGNL[62] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				64: R_HLPSGNL[63] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				65: R_HLPSGNL[64] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				66: R_HLPSGNL[65] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				67: R_HLPSGNL[66] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				68: R_HLPSGNL[67] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				69: R_HLPSGNL[68] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				70: R_HLPSGNL[69] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				71: R_HLPSGNL[70] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				72: R_HLPSGNL[71] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				73: R_HLPSGNL[72] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				74: R_HLPSGNL[73] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				75: R_HLPSGNL[74] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				76: R_HLPSGNL[75] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				77: R_HLPSGNL[76] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				78: R_HLPSGNL[77] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				79: R_HLPSGNL[78] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				80: R_HLPSGNL[79] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				81: R_HLPSGNL[80] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				82: R_HLPSGNL[81] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				83: R_HLPSGNL[82] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				84: R_HLPSGNL[83] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				85: R_HLPSGNL[84] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				86: R_HLPSGNL[85] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				87: R_HLPSGNL[86] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				88: R_HLPSGNL[87] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				89: R_HLPSGNL[88] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				90: R_HLPSGNL[89] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				91: R_HLPSGNL[90] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				92: R_HLPSGNL[91] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				93: R_HLPSGNL[92] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				94: R_HLPSGNL[93] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				95: R_HLPSGNL[94] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				96: R_HLPSGNL[95] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				97: R_HLPSGNL[96] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				98: R_HLPSGNL[97] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				99: R_HLPSGNL[98] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				100: R_HLPSGNL[99] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				101: R_HLPSGNL[100] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				102: R_HLPSGNL[101] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				103: R_HLPSGNL[102] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				104: R_HLPSGNL[103] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				105: R_HLPSGNL[104] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				106: R_HLPSGNL[105] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				107: R_HLPSGNL[106] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				108: R_HLPSGNL[107] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				109: R_HLPSGNL[108] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				110: R_HLPSGNL[109] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				111: R_HLPSGNL[110] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				112: R_HLPSGNL[111] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				113: R_HLPSGNL[112] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				114: R_HLPSGNL[113] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				115: R_HLPSGNL[114] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				116: R_HLPSGNL[115] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				117: R_HLPSGNL[116] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				118: R_HLPSGNL[117] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				119: R_HLPSGNL[118] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				120: R_HLPSGNL[119] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				121: R_HLPSGNL[120] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				122: R_HLPSGNL[121] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				123: R_HLPSGNL[122] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				124: R_HLPSGNL[123] <= (DATASI == 8'h4C | DATASI == 8'h48);  
				125: R_HLPSGNL[124] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				126: R_HLPSGNL[125] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				127: R_HLPSGNL[126] <= (DATASI == 8'h4C | DATASI == 8'h48); 
				
				endcase
			end
			else if(DATASI == 8'h0A | DATASI == 8'h00)
				R_HLPSGNL <= 0;
		end
	end
end

endmodule 