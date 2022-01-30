/*###########################################################################*/
/*##########################====CMD NUMBER MODULE====########################*/
/*###########################################################################*/
/*Description:
This module gets the CMD packet number from approptiate state in CMD state
machine
*/
module cmdnum(
input clk, ///Clock
input reset, ///System reset
input cmd7st, ///CMD7 state
input cmd12st, ///CMD12 state
input cmd13st, ///CMD13 state
input cmd17st, ///CMD17 state
input cmd18st, ///CMD18 state
input cmd23st, ///CMD23 state
input cmd24st, ///CMD24 state
output [7:0] CMDN ///Result CMDn number
);

reg [7:0] R_CMDN; ///CMDn number register (0x40 + CMDn) 

assign CMDN = R_CMDN;

///////////////////////////GET CMD NUMBER FROM STATE////////////////////////
//////////CMD number (0x40 + CMDn) on CMD SD CARD Line from SD CARD Specification (CMDn)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_CMDN <= 0;
	else
	begin
		if(cmd7st)
			R_CMDN <= 8'h47; ///CMD7
		else if(cmd12st)
			R_CMDN <= 8'h4C; ///CMD12
		else if(cmd13st)
			R_CMDN <= 8'h4D; ///CMD13
		else if(cmd17st)
			R_CMDN <= 8'h51; ///CMD17
		else if(cmd18st)
			R_CMDN <= 8'h52; ///CMD18
		else if(cmd23st)
			R_CMDN <= 8'h57; ///CMD23
		else if(cmd24st)
			R_CMDN <= 8'h58; ///CMD24
	end
end

endmodule 