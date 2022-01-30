/*#############################################################################*/
/*#######################====INTEGER (HEX) TO CHAR===##########################*/
/*#############################################################################*/
/*Description:
Integer to char converts input integer value in HEX format to chars (string) of
symbols (bytes) in ASCII format 
*/
module itoa32(
clk, ///Clock
reset, //Reset
load, ///Load (user reset)
NUM,  ////input number (HEX format integer)
CHAR0, ///ASCII format char 0
CHAR1, ///ASCII format char 1
CHAR2, ///ASCII format char 2
CHAR3, ///ASCII format char 3
CHAR4, ///ASCII format char 4
CHAR5, ///ASCII format char 5
CHAR6, ///ASCII format char 6
CHAR7, ///ASCII format char 7
CHAR8, ///ASCII format char 8
CHAR9, ///ASCII format char 9
done ///ITOA operation done signal
);

input clk;
input reset;
input load;
input [31:0] NUM;
output reg [7:0] CHAR0;
output reg [7:0] CHAR1;
output reg [7:0] CHAR2;
output reg [7:0] CHAR3;
output reg [7:0] CHAR4;
output reg [7:0] CHAR5;
output reg [7:0] CHAR6;
output reg [7:0] CHAR7;
output reg [7:0] CHAR8;
output reg [7:0] CHAR9;  
output done;

reg [4:0] R_DIGCNTR; ///digit counter
reg [4:0] R_DIGADDR; ///digit address in atoi ROM memory of decades
reg [31:0] R_NUM; ///current number value during itoa operation

reg R_NXTNUM; ///itoa need next decade from atoi ROM

wire [31:0] DIGOUT; ///itoa decades ROM output

assign done = (R_DIGADDR == 5'h0A) & !R_NXTNUM; ///itoa done condition

/////////////////////ITOA DECADES ROM////////////////////////
//////////1,10,100,1000 e.t.c. ROM from HEX file
itoarom decrom(
	.address(R_DIGADDR),
	.clock(clk),
	.q(DIGOUT)
);
/////////////////////ITOA OPERATION////////////////////////
//////////Convert from HEX number to ASCII string CHAR0..9
always@(posedge reset or posedge clk)
begin
	if(reset)
	begin
		CHAR0 <= 0;
		CHAR1 <= 0;
		CHAR2 <= 0;
		CHAR3 <= 0;
		CHAR4 <= 0;
		CHAR5 <= 0;
		CHAR6 <= 0;
		CHAR7 <= 0;
		CHAR8 <= 0;
		CHAR9 <= 0;
	end
	else
	begin
		if(load)
		begin
			CHAR0 <= 0;
			CHAR1 <= 0;
			CHAR2 <= 0;
			CHAR3 <= 0;
			CHAR4 <= 0;
			CHAR5 <= 0;
			CHAR6 <= 0;
			CHAR7 <= 0;
			CHAR8 <= 0;
			CHAR9 <= 0;
		end
		else if(R_NUM < DIGOUT)
		begin
			case(R_DIGADDR)
				0: 	CHAR9 <= R_DIGCNTR + 8'h30;
				1:	CHAR8 <= R_DIGCNTR + 8'h30;
				2:	CHAR7 <= R_DIGCNTR + 8'h30;
				3:	CHAR6 <= R_DIGCNTR + 8'h30;	
				4:	CHAR5 <= R_DIGCNTR + 8'h30;
				5:	CHAR4 <= R_DIGCNTR + 8'h30;
				6:	CHAR3 <= R_DIGCNTR + 8'h30;
				7:	CHAR2 <= R_DIGCNTR + 8'h30;
				8:	CHAR1 <= R_DIGCNTR + 8'h30;
				9:	CHAR0 <= R_DIGCNTR + 8'h30;
			endcase
		end
	end
end
//////////Digit counter
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_DIGCNTR <= 0;
	else
	begin
		if(load)
			R_DIGCNTR <= 0;
		else if(R_NUM >= DIGOUT)
			R_DIGCNTR <= R_DIGCNTR + 1'b1;
		else
			R_DIGCNTR <= 0;
	end
end
//////////Get the next decade from itoa ROM
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_NXTNUM <= 0;
	else 
	begin
		if(load)
			R_NXTNUM <= 0;
		else if(R_NUM < DIGOUT)
			R_NXTNUM <= !R_NXTNUM;
	end
end
//////////Current number value during itoa operation register
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_NUM <= NUM;
	else
	begin
		if(load)
			R_NUM <= NUM;
		else if(R_NUM >= DIGOUT)
			R_NUM <= R_NUM - DIGOUT;
	end
end
//////////Digit address in itoa memory of decades
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_DIGADDR <= 0;
	else
	begin
		if(load)
			R_DIGADDR <= 0;
		else if(R_NUM < DIGOUT & !R_NXTNUM)
			R_DIGADDR <= R_DIGADDR + 1'b1;
	end
end

endmodule
