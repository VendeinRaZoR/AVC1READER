/*#############################################################################*/
/*##############====USER 7-SEGMENT INDICATOR CONTROLLER===#####################*/
/*#############################################################################*/
/*Description:
This module drives 7-segment indicators by writing ERCY vectors numbers and playing
load animation on indicators  
*/
module user7seg(
input clk, ///User Clock (about 10...100 kHz)
input clkfast, ///SD card clock
input reset, ///Reset
input load, ///load NUM
input rd, ///outputs current NUM to 7-seg indicators
input [31:0] NUM, ///NUM (ERCY number of wrote vectors)
output reg [6:0] HEX0, //7-segment indicator lines 0
output reg [6:0] HEX1, //7-segment indicator lines 1
output reg [6:0] HEX2, //7-segment indicator lines 2
output reg [6:0] HEX3, //7-segment indicator lines 3
output reg [6:0] HEX4, //7-segment indicator lines 4
output reg [6:0] HEX5, //7-segment indicator lines 5
output reg [6:0] HEX6, //7-segment indicator lines 6
output reg [6:0] HEX7 //7-segment indicator lines 7
);

wire [7:0] CHAR0; //itoa output to 7-segment indicator 0 char 0
wire [7:0] CHAR1; //itoa output to 7-segment indicator 1 char 1
wire [7:0] CHAR2; //itoa output to 7-segment indicator 2 char 2
wire [7:0] CHAR3; //itoa output to 7-segment indicator 3 char 3
wire [7:0] CHAR4; //itoa output to 7-segment indicator 4 char 4
wire [7:0] CHAR5; //itoa output to 7-segment indicator 5 char 5
wire [7:0] CHAR6; //itoa output to 7-segment indicator 6 char 6
wire [7:0] CHAR7; //itoa output to 7-segment indicator 7 char 7
wire [7:0] CHAR8; //itoa output to 7-segment indicator 8 char 8
wire [7:0] CHAR9; //itoa output to 7-segment indicator 9 char 9

wire numdone; ///itoa to 7-seg done

wire ccntrdone; ///visual load effect while counting ERCY vectors enable

reg [9:0] R_COUNTCNTR; ///Divide counter for visual load effect while counting ERCY vectors

assign ccntrdone = R_COUNTCNTR == 10'h3FF;

/////////////////////ITOA FOR NUM (ERCY VECTOR NUMBER)////////////////////////
//////////Convert from input HEX number to ASCII string 
itoa32 htoa(
	.clk(clkfast),
	.reset(reset),
	.load(load),
	.NUM(NUM),
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
	.done(numdone)
);

//////////////////ERCY VECTORS COUNTING VISUAL EFFECTS FREQUENCY DIVIDER///////////////////////
//////////Visual effect while miscompare finding in progress (maybe not work)
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_COUNTCNTR <= 0;
	else
		R_COUNTCNTR <= R_COUNTCNTR + 1'b1;
end

///////////////////////////////////7-SEGMENT INDICATORS DRIVERS////////////////////////////////
//////////Segment decoder 0
always@(posedge reset or posedge clk)
begin
	if(reset)
		HEX0 <= 7'b1101111;
	else
	begin
		if(numdone & rd)
		begin
			case(CHAR0)
	
				8'h30:
					HEX0 <= 7'b1000000;
					
				8'h31:
					HEX0 <= 7'b1111001;
					
				8'h32:
					HEX0 <= 7'b0100100;
					
				8'h33:
					HEX0 <= 7'b0110000;
		
				8'h34:
					HEX0 <= 7'b0011001;
			
				8'h35:
					HEX0 <= 7'b0010010;
		
				8'h36: 
					HEX0 <= 7'b0000010;
			
				8'h37:
					HEX0 <= 7'b1111000;
		
				8'h38:
					HEX0 <= 7'b0000000;
			
				8'h39:
					HEX0 <= 7'b0010000;
			
				default:
					HEX0 <= 7'b1000000;
			
			endcase
		end
		else if(load & ccntrdone)
		begin
			if(HEX0 == 7'b1011111 | HEX0 == 7'b0111111 | HEX0 == 7'b1111111)
				HEX0 <= 7'b1111110;
			else
				HEX0 <= {HEX0[5:0],1'b1};
		end
	end
end
//////////Segment decoder 1
always@(posedge reset or posedge clk)
begin
	if(reset)
		HEX1 <= 7'b1101111;
	else
	begin
		if(numdone & rd)
		begin
			case(CHAR1)
	
				8'h30:
					HEX1 <= 7'b1000000;
					
				8'h31:
					HEX1 <= 7'b1111001;
					
				8'h32:
					HEX1 <= 7'b0100100;
					
				8'h33:
					HEX1 <= 7'b0110000;
		
				8'h34:
					HEX1 <= 7'b0011001;
			
				8'h35:
					HEX1 <= 7'b0010010;
		
				8'h36:
					HEX1 <= 7'b0000010;
			
				8'h37:
					HEX1 <= 7'b1111000;
		
				8'h38:
					HEX1 <= 7'b0000000;
			
				8'h39:
					HEX1 <= 7'b0010000;
			
				default:
					HEX1 <= 7'b1000000;
			
			endcase
		end
		else if(load & ccntrdone)
		begin
			if(HEX1 == 7'b1011111 | HEX1 == 7'b0111111 | HEX1 == 7'b1111111)
				HEX1 <= 7'b1111110;
			else
				HEX1 <= {HEX1[5:0],1'b1};
		end
	end
end
//////////Segment decoder 2
always@(posedge reset or posedge clk)
begin
	if(reset)
		HEX2 <= 7'b1101111;
	else
	begin
		if(numdone & rd)
		begin
			case(CHAR2)
	
				8'h30:
					HEX2 <= 7'b1000000;
					
				8'h31:
					HEX2 <= 7'b1111001;
					
				8'h32:
					HEX2 <= 7'b0100100;
					
				8'h33:
					HEX2 <= 7'b0110000;
		
				8'h34:
					HEX2 <= 7'b0011001;
			
				8'h35:
					HEX2 <= 7'b0010010;
		
				8'h36:
					HEX2 <= 7'b0000010;
			
				8'h37:
					HEX2 <= 7'b1111000;
		
				8'h38:
					HEX2 <= 7'b0000000;
			
				8'h39:
					HEX2 <= 7'b0010000;
			
				default:
					HEX2 <= 7'b1000000;
			
			endcase
		end
		else if(load & ccntrdone)
		begin
			if(HEX2 == 7'b1011111 | HEX2 == 7'b0111111 | HEX2 == 7'b1111111)
				HEX2 <= 7'b1111110;
			else
				HEX2 <= {HEX2[5:0],1'b1};
		end
	end
end
//////////Segment decoder 3
always@(posedge reset or posedge clk)
begin
	if(reset)
		HEX3 <= 7'b1101111;
	else
	begin
		if(numdone & rd)
		begin
			case(CHAR3)
	
				8'h30:
					HEX3 <= 7'b1000000;
					
				8'h31:
					HEX3 <= 7'b1111001;
					
				8'h32:
					HEX3 <= 7'b0100100;
					
				8'h33:
					HEX3 <= 7'b0110000;
		
				8'h34:
					HEX3 <= 7'b0011001;
			
				8'h35:
					HEX3 <= 7'b0010010;
		
				8'h36:
					HEX3 <= 7'b0000010;
			
				8'h37:
					HEX3 <= 7'b1111000;
		
				8'h38:
					HEX3 <= 7'b0000000;
			
				8'h39:
					HEX3 <= 7'b0010000;
			
				default:
					HEX3 <= 7'b1000000;
			
			endcase
		end
		else if(load & ccntrdone)
		begin
			if(HEX3 == 7'b1011111 | HEX3 == 7'b0111111 | HEX3 == 7'b1111111)
				HEX3 <= 7'b1111110;
			else
				HEX3 <= {HEX3[5:0],1'b1};
		end
	end
end
//////////Segment decoder 4
always@(posedge reset or posedge clk)
begin
	if(reset)
		HEX4 <= 7'b1101111;
	else
	begin
		if(numdone & rd)
		begin
			case(CHAR4)
	
				8'h30:
					HEX4 <= 7'b1000000;
					
				8'h31:
					HEX4 <= 7'b1111001;
					
				8'h32:
					HEX4 <= 7'b0100100;
					
				8'h33:
					HEX4 <= 7'b0110000;
		
				8'h34:
					HEX4 <= 7'b0011001;
			
				8'h35:
					HEX4 <= 7'b0010010;
		
				8'h36:
					HEX4 <= 7'b0000010;
			
				8'h37:
					HEX4 <= 7'b1111000;
		
				8'h38:
					HEX4 <= 7'b0000000;
			
				8'h39:
					HEX4 <= 7'b0010000;
			
				default:
					HEX4 <= 7'b1000000;
			
			endcase
		end
		else if(load & ccntrdone)
		begin
			if(HEX4 == 7'b1011111 | HEX4 == 7'b0111111 | HEX4 == 7'b1111111)
				HEX4 <= 7'b1111110;
			else
				HEX4 <= {HEX4[5:0],1'b1};
		end
	end
end
//////////Segment decoder 5
always@(posedge reset or posedge clk)
begin
	if(reset)
		HEX5 <= 7'b1101111;
	else
	begin
		if(numdone & rd)
		begin
			case(CHAR5)
	
				8'h30:
					HEX5 <= 7'b1000000;
					
				8'h31:
					HEX5 <= 7'b1111001;
					
				8'h32:
					HEX5 <= 7'b0100100;
					
				8'h33:
					HEX5 <= 7'b0110000;
		
				8'h34:
					HEX5 <= 7'b0011001;
			
				8'h35:
					HEX5 <= 7'b0010010;
		
				8'h36:
					HEX5 <= 7'b0000010;
			
				8'h37:
					HEX5 <= 7'b1111000;
		
				8'h38:
					HEX5 <= 7'b0000000;
			
				8'h39:
					HEX5 <= 7'b0010000;
			
				default:
					HEX5 <= 7'b1000000;
			
			endcase
		end
		else if(load & ccntrdone)
		begin
			if(HEX5 == 7'b1011111 | HEX5 == 7'b0111111 | HEX5 == 7'b1111111)
				HEX5 <= 7'b1111110;
			else
				HEX5 <= {HEX5[5:0],1'b1};
		end
	end
end
//////////Segment decoder 6
always@(posedge reset or posedge clk)
begin
	if(reset)
		HEX6 <= 7'b1101111;
	else
	begin
		if(numdone & rd)
		begin
			case(CHAR6)
	
				8'h30:
					HEX6 <= 7'b1000000;
					
				8'h31:
					HEX6 <= 7'b1111001;
					
				8'h32:
					HEX6 <= 7'b0100100;
					
				8'h33:
					HEX6 <= 7'b0110000;
		
				8'h34:
					HEX6 <= 7'b0011001;
			
				8'h35:
					HEX6 <= 7'b0010010;
		
				8'h36:
					HEX6 <= 7'b0000010;
			
				8'h37:
					HEX6 <= 7'b1111000;
		
				8'h38:
					HEX6 <= 7'b0000000;
			
				8'h39:
					HEX6 <= 7'b0010000;
			
				default:
					HEX6 <= 7'b1000000;
			
			endcase
		end
		else if(load & ccntrdone)
		begin
			if(HEX6 == 7'b1011111 | HEX6 == 7'b0111111 | HEX6 == 7'b1111111)
				HEX6 <= 7'b1111110;
			else
				HEX6 <= {HEX6[5:0],1'b1};
		end
	end
end
//////////Segment decoder 7
always@(posedge reset or posedge clk)
begin
	if(reset)
		HEX7 <= 7'b1101111;
	else
	begin
		if(numdone & rd)
		begin
			case(CHAR7)
	
				8'h30:
					HEX7 <= 7'b1000000;
					
				8'h31:
					HEX7 <= 7'b1111001;
					
				8'h32:
					HEX7 <= 7'b0100100;
					
				8'h33:
					HEX7 <= 7'b0110000;
		
				8'h34:
					HEX7 <= 7'b0011001;
			
				8'h35:
					HEX7 <= 7'b0010010;
		
				8'h36:
					HEX7 <= 7'b0000010;
			
				8'h37:
					HEX7 <= 7'b1111000;
		
				8'h38:
					HEX7 <= 7'b0000000;
			
				8'h39:
					HEX7 <= 7'b0010000;
			
				default:
					HEX7 <= 7'b1000000;
			
			endcase
		end
		else if(load & ccntrdone)
		begin
			if(HEX7 == 7'b1011111 | HEX7 == 7'b0111111 | HEX7 == 7'b1111111)
				HEX7 <= 7'b1111110;
			else
				HEX7 <= {HEX7[5:0],1'b1};
		end
	end
end

endmodule 