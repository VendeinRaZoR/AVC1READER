/*#################################################################################*/
/*#################====ATOI 3 ASCII symblos number to HEX number====###############*/
/*#################################################################################*/
/*Description:
This module converts ASCII 3-symbol number to number in HEX format
*/
module atoi3(
input clk, ///Clock
input reset, ///Reset
input sbdone,///Shift byte done
input [7:0] CHAR0, ///ASCII char 0 of digit 0
input [7:0] CHAR1, ///ASCII char 1 of digit 1
input [7:0] CHAR2, ///ASCII char 2 of digit 2
output reg [7:0] NUM ///Result number
);

wire [7:0] MCHAR0; ///Multiply on 100 output
wire [7:0] MCHAR1; ///Multiply on 10 output

/////////////////////MULTIPLY DIGIT SYMBOL CHAR 0 ON 100 FUNCTION//////////////////////////
//////////(ASCII char - 0x30) * 100
atoi3mult100 atoi3mult100(
	.dataa(CHAR0-8'h30),
	.result(MCHAR0)
);

/////////////////////MULTIPLY DIGIT SYMBOL CHAR 1 ON 10 FUNCTION//////////////////////////
//////////(ASCII char - 0x30) * 10
atoi3mult10 atoi3mult10(
	.dataa(CHAR1-8'h30),
	.result(MCHAR1)
);

////////////////////////RESULT NUMBER FROM SYMBOLS DIGITS//////////////////////////
//////////((ASCII char - 0x30) * 100) + ((ASCII char - 0x30) * 10) + ASCII char
always@(posedge reset or negedge clk)
begin
	if(reset)
		NUM <= 0;
	else
	begin
		NUM <= MCHAR0 + MCHAR1 + CHAR2;
	end
end

endmodule 