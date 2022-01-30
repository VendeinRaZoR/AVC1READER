/*###########################################################################*/
/*####################====CMD SD CARD LINE RECEIVER====######################*/
/*###########################################################################*/
/*Description:
CMD SD Card line receiver receive data from SD CMD line in input shift regiser
*/
module cmdrx(
input clk, ///Clock
input reset, //Reset
input oe, ///output enable signal for bidirectional CMD line
input scmdin, ///CMD line input
output [7:0] CMDSI ///CMD serial input shift register output
);

reg [7:0] R_CMDSI; ///CMD serial input shift register

assign CMDSI = R_CMDSI;

///////////////////CMD SD CARD LINE INPUT SHIFT REGISTER////////////////////////
//////////Simple shift register from serial to parallel on CMD SD CARD Line
always@(posedge reset or negedge clk)
begin
    if(reset) 
        R_CMDSI <= 8'hFF;
    else
    begin
		if (!oe)
			R_CMDSI <= {R_CMDSI[6:0],scmdin};
    end
end

endmodule 