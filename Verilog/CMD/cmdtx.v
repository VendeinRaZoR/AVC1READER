/*###########################################################################*/
/*#################====CMD SD CARD LINE TRANSMITTER====######################*/
/*###########################################################################*/
/*Description:
CMD SD card line transmitter shifts input data to SD CMD line 
*/
module cmdtx(
input clk, //Clock
input reset, //Reset
input oe, ///output enable for CMD line
input load, ///load in shift register signal
input [7:0] MUXL, ///first MUX output that writes in shift output register
input [7:0] MUXH, ///second MUX output that writes in shift output register
input [7:0] romdata, ///ROM packet data output that writes in shift output register
input muxl, ///write first MUX in output shift register signal
input muxh, ///write second MUX in output shift register signal
output CMDSO ///output on CMD SD card line
);

reg [7:0] R_CMDSO; ///Output shift register on CMD SD card line

assign CMDSO = R_CMDSO[7]; //Shift output

///////////////////CMD SD CARD LINE OUTPUT SHIFT REGISTER////////////////////////
//////////Simple output shift register with selective load (ROM or MUX) on CMD SD CARD Line
always@(posedge reset or negedge clk)
begin
    if(reset)
    begin 
        R_CMDSO <= 8'hFF;
    end
    else
    begin
        if(oe)
        begin
            if(load)
            begin
               if(muxl)
						R_CMDSO <= MUXL;
					else if(muxh)
						R_CMDSO <= MUXH;
					else
						R_CMDSO <= romdata;		
            end
            else
            begin
               R_CMDSO <= {R_CMDSO[6:0],1'b1};
            end
        end
    end
end

endmodule 