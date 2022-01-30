/*##################################################################################*/
/*#############################====USER READY LED===################################*/
/*##################################################################################*/
/*Description:
This module controls the user ready LED LEDG8 on board that indicates that all 
procedures of testing done
*/
module userled(
input clk, ///Clock
input reset, ///Reset
input en, ///LED enable
output reg ULED ///user led output
);

reg [9:0] R_COUNTCNTR; ///divide counter for blinked LED

assign ccntrdone = R_COUNTCNTR == 10'h3FF;

//////////////////////////////DIVIDE COUNTER FOR BLINKING LED///////////////////////////////
//////////Counter for LED to blink after testing done
always@(posedge reset or posedge clk)
begin
	if(reset)
		R_COUNTCNTR <= 0;
	else
		R_COUNTCNTR <= R_COUNTCNTR + 1'b1;
end

////////////////////////////////////////BLINKING LED////////////////////////////////////////
//////////Green blinking led after all testing/comparing process done
always@(posedge reset or posedge clk)
begin
	if(reset)
		ULED <= 0;
	else
	begin
		if(en & ccntrdone)
			ULED <= ~ULED;
	end
end

endmodule 