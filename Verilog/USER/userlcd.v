/*##################################################################################*/
/*######################====USER LCD 16X2 44780 CONTROLLER===#######################*/
/*##################################################################################*/
/*Description:
This module controls LCD 16X2 display on AVC1READER board that shows dialog user 
information during test
*/
module userlcd(
input clk, ///Clock 
input reset, ///Reset
input dispres, ///Display reset
input [7:0] CHAR0, ///LCD char 0
input [7:0] CHAR1, ///LCD char 1
input [7:0] CHAR2, ///LCD char 2
input [7:0] CHAR3, ///LCD char 3
input [7:0] CHAR4, ///LCD char 4
input [7:0] CHAR5, ///LCD char 5 
input [7:0] CHAR6, ///LCD char 6
input [7:0] CHAR7, ///LCD char 7
input [7:0] CHAR8, ///LCD char 8
input [7:0] CHAR9, ///LCD char 9
input [7:0] CHAR10, ///LCD char 10
input [7:0] CHAR11, ///LCD char 11
input [7:0] CHAR12, ///LCD char 12
input [7:0] CHAR13, ///LCD char 13
input [7:0] CHAR14, ///LCD char 14
input [7:0] CHAR15, ///LCD char 15
input [7:0] CHAR16, ///LCD char 16
input [7:0] CHAR17, ///LCD char 17
input [7:0] CHAR18, ///LCD char 18
input [7:0] CHAR19, ///LCD char 19
input [7:0] CHAR20, ///LCD char 20
input [7:0] CHAR21, ///LCD char 21
input [7:0] CHAR22, ///LCD char 22
input [7:0] CHAR23, ///LCD char 23
input [7:0] CHAR24, ///LCD char 24
input [7:0] CHAR25, ///LCD char 25
input [7:0] CHAR26, ///LCD char 26
input [7:0] CHAR27, ///LCD char 27
input [7:0] CHAR28, ///LCD char 28
input [7:0] CHAR29, ///LCD char 29
input [7:0] CHAR30, ///LCD char 30
input [7:0] CHAR31, ///LCD char 31
output reg [7:0] LCD_DATA, ///8 bit data lines on LCD
output LCD_BLON, ///LCD Back light on (won't work)
output LCD_EN, ///LCD strobe
output LCD_ON, ///LCD enable
output LCD_RS, ///Data/command switch
output LCD_RW ///Read/write switch
);

parameter IDLE = 8'h00; ///Initial state after system reset
parameter LCD_INIT = 8'h01; ///initial state afres dispres signal (new string load) 
parameter CLEAR_LCD = 8'h02; ///clear LCD command state
parameter SHIFT_CURSOR = 8'h03; ///shift LCD cursor command state
parameter DISPLAY_ON = 8'h04; ///display on command state
parameter NEW_LINE = 8'h05; ///go to second line command state
parameter WRITE_CHAR0 = 8'h06; ///write char 0 to LCD state
parameter WRITE_CHAR1 = 8'h07; ///write char 1 to LCD state
parameter WRITE_CHAR2 = 8'h08; ///write char 2 to LCD state
parameter WRITE_CHAR3 = 8'h09; ///write char 3 to LCD state
parameter WRITE_CHAR4 = 8'h0A; ///write char 4 to LCD state
parameter WRITE_CHAR5 = 8'h0B; ///write char 5 to LCD state
parameter WRITE_CHAR6 = 8'h0C; ///write char 6 to LCD state
parameter WRITE_CHAR7 = 8'h0D; ///write char 7 to LCD state
parameter WRITE_CHAR8 = 8'h0E; ///write char 8 to LCD state
parameter WRITE_CHAR9 = 8'h0F; ///write char 9 to LCD state
parameter WRITE_CHAR10 = 8'h10; ///write char 10 to LCD state
parameter WRITE_CHAR11 = 8'h11; ///write char 11 to LCD state
parameter WRITE_CHAR12 = 8'h12; ///write char 12 to LCD state
parameter WRITE_CHAR13 = 8'h13; ///write char 13 to LCD state
parameter WRITE_CHAR14 = 8'h14; ///write char 14 to LCD state
parameter WRITE_CHAR15 = 8'h15; ///write char 15 to LCD state
parameter WRITE_CHAR16 = 8'h16; ///write char 16 to LCD state
parameter WRITE_CHAR17 = 8'h17; ///write char 17 to LCD state
parameter WRITE_CHAR18 = 8'h18; ///write char 18 to LCD state
parameter WRITE_CHAR19 = 8'h19; ///write char 19 to LCD state
parameter WRITE_CHAR20 = 8'h1A; ///write char 20 to LCD state
parameter WRITE_CHAR21 = 8'h1B; ///write char 21 to LCD state
parameter WRITE_CHAR22 = 8'h1C; ///write char 22 to LCD state
parameter WRITE_CHAR23 = 8'h1D; ///write char 23 to LCD state
parameter WRITE_CHAR24 = 8'h1E; ///write char 24 to LCD state
parameter WRITE_CHAR25 = 8'h1F; ///write char 25 to LCD state
parameter WRITE_CHAR26 = 8'h20; ///write char 26 to LCD state
parameter WRITE_CHAR27 = 8'h21; ///write char 27 to LCD state
parameter WRITE_CHAR28 = 8'h22; ///write char 28 to LCD state
parameter WRITE_CHAR29 = 8'h23; ///write char 29 to LCD state
parameter WRITE_CHAR30 = 8'h24; ///write char 30 to LCD state
parameter WRITE_CHAR31 = 8'h25; ///write char 31 to LCD state

reg [7:0] R_ST_LCD;///LCD controller state machine

reg [7:0] R_CHAR0; ///LCD char 0 register
reg [7:0] R_CHAR1; ///LCD char 1 register
reg [7:0] R_CHAR2; ///LCD char 2 register
reg [7:0] R_CHAR3; ///LCD char 3 register
reg [7:0] R_CHAR4; ///LCD char 4 register
reg [7:0] R_CHAR5; ///LCD char 5 register
reg [7:0] R_CHAR6; ///LCD char 6 register
reg [7:0] R_CHAR7; ///LCD char 7 register
reg [7:0] R_CHAR8; ///LCD char 8 register
reg [7:0] R_CHAR9; ///LCD char 9 register
reg [7:0] R_CHAR10; ///LCD char 10 register
reg [7:0] R_CHAR11; ///LCD char 11 register
reg [7:0] R_CHAR12; ///LCD char 12 register
reg [7:0] R_CHAR13; ///LCD char 13 register
reg [7:0] R_CHAR14; ///LCD char 14 register
reg [7:0] R_CHAR15; ///LCD char 15 register
reg [7:0] R_CHAR16; ///LCD char 16 register
reg [7:0] R_CHAR17; ///LCD char 17 register
reg [7:0] R_CHAR18; ///LCD char 18 register
reg [7:0] R_CHAR19; ///LCD char 19 register
reg [7:0] R_CHAR20; ///LCD char 20 register
reg [7:0] R_CHAR21; ///LCD char 21 register
reg [7:0] R_CHAR22; ///LCD char 22 register
reg [7:0] R_CHAR23; ///LCD char 23 register
reg [7:0] R_CHAR24; ///LCD char 24 register
reg [7:0] R_CHAR25; ///LCD char 25 register
reg [7:0] R_CHAR26; ///LCD char 26 register
reg [7:0] R_CHAR27; ///LCD char 27 register
reg [7:0] R_CHAR28; ///LCD char 28 register
reg [7:0] R_CHAR29; ///LCD char 29 register
reg [7:0] R_CHAR30; ///LCD char 30 register
reg [7:0] R_CHAR31; ///LCD char 31 register

assign LCD_BLON = 1'b1;
assign LCD_ON = 1'b1;
assign LCD_RW = 1'b0;
assign LCD_EN = R_ST_LCD != IDLE ? clk : 0;
assign LCD_RS = R_ST_LCD == WRITE_CHAR0 | R_ST_LCD == WRITE_CHAR1 | R_ST_LCD == WRITE_CHAR2 | R_ST_LCD == WRITE_CHAR3 | R_ST_LCD == WRITE_CHAR4 |
R_ST_LCD == WRITE_CHAR5 | R_ST_LCD == WRITE_CHAR6 | R_ST_LCD == WRITE_CHAR7 | R_ST_LCD == WRITE_CHAR8 | R_ST_LCD == WRITE_CHAR9 |
R_ST_LCD == WRITE_CHAR10 | R_ST_LCD == WRITE_CHAR11 | R_ST_LCD == WRITE_CHAR12 | R_ST_LCD == WRITE_CHAR13 | R_ST_LCD == WRITE_CHAR14 |
R_ST_LCD == WRITE_CHAR15 | R_ST_LCD == WRITE_CHAR16 | R_ST_LCD == WRITE_CHAR17 | R_ST_LCD == WRITE_CHAR18 | R_ST_LCD == WRITE_CHAR19 |
R_ST_LCD == WRITE_CHAR20 | R_ST_LCD == WRITE_CHAR21 | R_ST_LCD == WRITE_CHAR22 | R_ST_LCD == WRITE_CHAR23 | R_ST_LCD == WRITE_CHAR24 |
R_ST_LCD == WRITE_CHAR25 | R_ST_LCD == WRITE_CHAR26 | R_ST_LCD == WRITE_CHAR27 | R_ST_LCD == WRITE_CHAR28 | R_ST_LCD == WRITE_CHAR29 |
R_ST_LCD == WRITE_CHAR30 | R_ST_LCD == WRITE_CHAR31;

/////////////////////////////LCD INPUT CHARS REGISTERS//////////////////////////////
//////////LCD Display char 0
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR0 <= 0;
	else
	begin
		if(dispres)
			R_CHAR0 <= CHAR0;
	end
end
//////////LCD Display char 1
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR1 <= 0;
	else
	begin
		if(dispres)
			R_CHAR1 <= CHAR1;
	end
end
//////////LCD Display char 2
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR2 <= 0;
	else
	begin
		if(dispres)
			R_CHAR2 <= CHAR2;
	end
end
//////////LCD Display char 3
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR3 <= 0;
	else
	begin
		if(dispres)
			R_CHAR3 <= CHAR3;
	end
end
//////////LCD Display char 4
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR4 <= 0;
	else
	begin
		if(dispres)
			R_CHAR4 <= CHAR4;
	end
end
//////////LCD Display char 5
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR5 <= 0;
	else
	begin
		if(dispres)
			R_CHAR5 <= CHAR5;
	end
end
//////////LCD Display char 6
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR6 <= 0;
	else
	begin
		if(dispres)
			R_CHAR6 <= CHAR6;
	end
end
//////////LCD Display char 7
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR7 <= 0;
	else
	begin
		if(dispres)
			R_CHAR7 <= CHAR7;
	end
end
//////////LCD Display char 8
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR8 <= 0;
	else
	begin
		if(dispres)
			R_CHAR8 <= CHAR8;
	end
end
//////////LCD Display char 9
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR9 <= 0;
	else
	begin
		if(dispres)
			R_CHAR9 <= CHAR9;
	end
end
//////////LCD Display char 10
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR10 <= 0;
	else
	begin
		if(dispres)
			R_CHAR10 <= CHAR10;
	end
end
//////////LCD Display char 11
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR11 <= 0;
	else
	begin
		if(dispres)
			R_CHAR11 <= CHAR11;
	end
end
//////////LCD Display char 12
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR12 <= 0;
	else
	begin
		if(dispres)
			R_CHAR12 <= CHAR12;
	end
end
//////////LCD Display char 13
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR13 <= 0;
	else
	begin
		if(dispres)
			R_CHAR13 <= CHAR13;
	end
end
//////////LCD Display char 14
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR14 <= 0;
	else
	begin
		if(dispres)
			R_CHAR14 <= CHAR14;
	end
end
//////////LCD Display char 15
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR15 <= 0;
	else
	begin
		if(dispres)
			R_CHAR15 <= CHAR15;
	end
end
//////////LCD Display char 16
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR16 <= 0;
	else
	begin
		if(dispres)
			R_CHAR16 <= CHAR16;
	end
end
//////////LCD Display char 17
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR17 <= 0;
	else
	begin
		if(dispres)
			R_CHAR17 <= CHAR17;
	end
end
//////////LCD Display char 18
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR18 <= 0;
	else
	begin
		if(dispres)
			R_CHAR18 <= CHAR18;
	end
end
//////////LCD Display char 19
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR19 <= 0;
	else
	begin
		if(dispres)
			R_CHAR19 <= CHAR19;
	end
end
//////////LCD Display char 20
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR20 <= 0;
	else
	begin
		if(dispres)
			R_CHAR20 <= CHAR20;
	end
end
//////////LCD Display char 21
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR21 <= 0;
	else
	begin
		if(dispres)
			R_CHAR21 <= CHAR21;
	end
end
//////////LCD Display char 22
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR22 <= 0;
	else
	begin
		if(dispres)
			R_CHAR22 <= CHAR22;
	end
end
//////////LCD Display char 23
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR23 <= 0;
	else
	begin
		if(dispres)
			R_CHAR23 <= CHAR23;
	end
end
//////////LCD Display char 24
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR24 <= 0;
	else
	begin
		if(dispres)
			R_CHAR24 <= CHAR24;
	end
end
//////////LCD Display char 25
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR25 <= 0;
	else
	begin
		if(dispres)
			R_CHAR25 <= CHAR25;
	end
end
//////////LCD Display char 26
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR26 <= 0;
	else
	begin
		if(dispres)
			R_CHAR26 <= CHAR26;
	end
end
//////////LCD Display char 27
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR27 <= 0;
	else
	begin
		if(dispres)
			R_CHAR27 <= CHAR27;
	end
end
//////////LCD Display char 28
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR28 <= 0;
	else
	begin
		if(dispres)
			R_CHAR28 <= CHAR28;
	end
end
//////////LCD Display char 29
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR29 <= 0;
	else
	begin
		if(dispres)
			R_CHAR29 <= CHAR29;
	end
end
//////////LCD Display char 30
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR30 <= 0;
	else
	begin
		if(dispres)
			R_CHAR30 <= CHAR30;
	end
end
//////////LCD Display char 31
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_CHAR31 <= 0;
	else
	begin
		if(dispres)
			R_CHAR31 <= CHAR31;
	end
end
/////////////////////////////LCD DATA STATES SEQUENCE//////////////////////////////
//////////LCD char control state machine
always@*
begin
	case(R_ST_LCD)
	
		IDLE:
			LCD_DATA <= 8'h00;
		
		LCD_INIT:
			LCD_DATA <= 8'h38;
			
		DISPLAY_ON:
			LCD_DATA <= 8'h0C;
			
		SHIFT_CURSOR:
			LCD_DATA <= 8'h06;	
			
		CLEAR_LCD:
			LCD_DATA <= 8'h02;
		
		WRITE_CHAR0:
			LCD_DATA <= R_CHAR0;
		
		WRITE_CHAR1:
			LCD_DATA <= R_CHAR1;
		
		WRITE_CHAR2:
			LCD_DATA <= R_CHAR2;

		WRITE_CHAR3:
			LCD_DATA <= R_CHAR3;
			
		WRITE_CHAR4:
			LCD_DATA <= R_CHAR4;			
			
		WRITE_CHAR5:
			LCD_DATA <= R_CHAR5;			
			
		WRITE_CHAR6:
			LCD_DATA <= R_CHAR6;			
			
		WRITE_CHAR7:
			LCD_DATA <= R_CHAR7;			
			
		WRITE_CHAR8:
			LCD_DATA <= R_CHAR8;			
			
		WRITE_CHAR9:
			LCD_DATA <= R_CHAR9;	
	
		WRITE_CHAR10:
			LCD_DATA <= R_CHAR10;

		WRITE_CHAR11:
			LCD_DATA <= R_CHAR11;

		WRITE_CHAR12:
			LCD_DATA <= R_CHAR12;

		WRITE_CHAR13:
			LCD_DATA <= R_CHAR13;

		WRITE_CHAR14:
			LCD_DATA <= R_CHAR14;

		WRITE_CHAR15:
			LCD_DATA <= R_CHAR15;
			
		NEW_LINE:
			LCD_DATA <= 8'hC0;
			
		WRITE_CHAR16:
			LCD_DATA <= R_CHAR16;
		
		WRITE_CHAR17:
			LCD_DATA <= R_CHAR17;
		
		WRITE_CHAR18:
			LCD_DATA <= R_CHAR18;

		WRITE_CHAR19:
			LCD_DATA <= R_CHAR19;
			
		WRITE_CHAR20:
			LCD_DATA <= R_CHAR20;			
			
		WRITE_CHAR21:
			LCD_DATA <= R_CHAR21;			
			
		WRITE_CHAR22:
			LCD_DATA <= R_CHAR22;			
			
		WRITE_CHAR23:
			LCD_DATA <= R_CHAR23;			
			
		WRITE_CHAR24:
			LCD_DATA <= R_CHAR24;			
			
		WRITE_CHAR25:
			LCD_DATA <= R_CHAR25;	
	
		WRITE_CHAR26:
			LCD_DATA <= R_CHAR26;

		WRITE_CHAR27:
			LCD_DATA <= R_CHAR27;

		WRITE_CHAR28:
			LCD_DATA <= R_CHAR28;

		WRITE_CHAR29:
			LCD_DATA <= R_CHAR29;

		WRITE_CHAR30:
			LCD_DATA <= R_CHAR30;

		WRITE_CHAR31:
			LCD_DATA <= R_CHAR31;
		
		default:
			LCD_DATA <= 8'h00;
			
	endcase
end

/////////////////////LCD CONTROLLER DATA STATE MACHINE//////////////////////////
//////////LCD display control state machine
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_ST_LCD <= IDLE;
	else
	begin
		
		case(R_ST_LCD)
		
			IDLE:
			begin
				if(dispres)
					R_ST_LCD <= LCD_INIT;
			end
			
			LCD_INIT:
				R_ST_LCD <= DISPLAY_ON;
				
			DISPLAY_ON:
				R_ST_LCD <= SHIFT_CURSOR;
				
			SHIFT_CURSOR:
				R_ST_LCD <= CLEAR_LCD;
				
			CLEAR_LCD:
				R_ST_LCD <= WRITE_CHAR0;
			
			WRITE_CHAR0:
				R_ST_LCD <= WRITE_CHAR1;
			
			WRITE_CHAR1:
				R_ST_LCD <= WRITE_CHAR2;
			
			WRITE_CHAR2:
				R_ST_LCD <= WRITE_CHAR3;

			WRITE_CHAR3:
				R_ST_LCD <= WRITE_CHAR4;
				
			WRITE_CHAR4:
				R_ST_LCD <= WRITE_CHAR5;			
				
			WRITE_CHAR5:
				R_ST_LCD <= WRITE_CHAR6;			
				
			WRITE_CHAR6:
				R_ST_LCD <= WRITE_CHAR7;			
				
			WRITE_CHAR7:
				R_ST_LCD <= WRITE_CHAR8;			
				
			WRITE_CHAR8:
				R_ST_LCD <= WRITE_CHAR9;			
				
			WRITE_CHAR9:
				R_ST_LCD <= WRITE_CHAR10;	
		
			WRITE_CHAR10:
				R_ST_LCD <= WRITE_CHAR11;

			WRITE_CHAR11:
				R_ST_LCD <= WRITE_CHAR12;

			WRITE_CHAR12:
				R_ST_LCD <= WRITE_CHAR13;

			WRITE_CHAR13:
				R_ST_LCD <= WRITE_CHAR14;

			WRITE_CHAR14:
				R_ST_LCD <= WRITE_CHAR15;

			WRITE_CHAR15:
				R_ST_LCD <= NEW_LINE;
				
			NEW_LINE:
				R_ST_LCD <= WRITE_CHAR16;
				
			WRITE_CHAR16:
				R_ST_LCD <= WRITE_CHAR17;
			
			WRITE_CHAR17:
				R_ST_LCD <= WRITE_CHAR18;
			
			WRITE_CHAR18:
				R_ST_LCD <= WRITE_CHAR19;

			WRITE_CHAR19:
				R_ST_LCD <= WRITE_CHAR20;
				
			WRITE_CHAR20:
				R_ST_LCD <= WRITE_CHAR21;			
				
			WRITE_CHAR21:
				R_ST_LCD <= WRITE_CHAR22;			
				
			WRITE_CHAR22:
				R_ST_LCD <= WRITE_CHAR23;			
				
			WRITE_CHAR23:
				R_ST_LCD <= WRITE_CHAR24;			
				
			WRITE_CHAR24:
				R_ST_LCD <= WRITE_CHAR25;			
				
			WRITE_CHAR25:
				R_ST_LCD <= WRITE_CHAR26;	
		
			WRITE_CHAR26:
				R_ST_LCD <= WRITE_CHAR27;

			WRITE_CHAR27:
				R_ST_LCD <= WRITE_CHAR28;

			WRITE_CHAR28:
				R_ST_LCD <= WRITE_CHAR29;

			WRITE_CHAR29:
				R_ST_LCD <= WRITE_CHAR30;

			WRITE_CHAR30:
				R_ST_LCD <= WRITE_CHAR31;

			WRITE_CHAR31:
				R_ST_LCD <= IDLE;
				
			default:
				R_ST_LCD <= IDLE;
			
		endcase
	end
end

endmodule 