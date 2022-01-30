/*##################################################################################*/
/*#######################====DAT LINE SD CARD RECEIVER===###########################*/
/*##################################################################################*/
/*Description:
DAT SD card line receiver shifts data from SD card DAT line to output 8-bit shift
register
*/
module datarx(
input clk, //Clock
input reset, //Reset
input oe, ///output enable
input sdatain, //serial data input fromm SD card DAT line
output [7:0] DATASI ///Data serial input shift register output
);

reg [7:0] R_DATASI;///Data serial input shift register 

assign DATASI = R_DATASI;

///////////////DATA SHIFT INPUT REGISTER FROM DAT SD CARD LINE//////////////////////
//////////Simple shift register with serial input and parallel output on DAT0 SD CARD Line
always@(posedge reset or negedge clk)
begin
    if(reset)
    begin 
        R_DATASI <= 8'hFF;
    end
    else
    begin
        if(!oe)
            R_DATASI <= {R_DATASI[6:0],sdatain};
    end
end

endmodule 