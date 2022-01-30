/*###########################################################################*/
/*###################====CMD SD CARD LINE CONTROLLER====#####################*/
/*###########################################################################*/
/*Description:
CMD SD card line controller counts bytes in packet, indicate packet on the line
and counts bits in input or output shift registers  
*/
module cmdctrl(
input clk, ///Clock
input reset, ///System reset
input oe, ///Output enable on CMD line
input se, ///shift register enable input
input cmdin, ///CMD line input
input tcvcptdnex, ///tranceive extended (more than 48 bits) CMD packet done
output tcvcptdone, ///tranceive CMD packet done
output sbdone, ///Input/output shift byte done signal 
output bload, ///byte load signal
output iscpkt, ///CMD packet on CMD line indicator
output [4:0] PTCMDPNTR ///CMD packet pointer (bytes in packet counter)
);

wire cpkt; ///low logic level on CMD line indicator

reg R_ISCPKT; ///CMD packet on CMD line indicator register
reg [4:0] R_PTCMDPNTR; ///CMD packet pointer (bytes in packet counter) register
reg [2:0] R_CMDSCNTR; ///CMD line serial shift bits counter

assign sbdone = R_CMDSCNTR == 3'b111;
assign bload = R_CMDSCNTR == 3'b0;
assign tcvcptdone = R_PTCMDPNTR == {tcvcptdnex,tcvcptdnex,3'h7};
assign PTCMDPNTR = R_PTCMDPNTR;
assign cpkt = !cmdin & !oe;
assign iscpkt = R_ISCPKT;

///////////////////////////CMD PACKET ON CMD LINE INDICATOR/////////////////////////////////////////	
//////////Register indicates that CMD packet on CMD SD CARD Line
always@(posedge cpkt or negedge clk)
begin
	if(cpkt)
		R_ISCPKT <= 1;
	else
		if(tcvcptdone | reset)
			R_ISCPKT <= 0;
end

///////////////////////////CMD BYTES IN PACKET POINTER/////////////////////////////////////////	
//////////CMD SD CARD Line pointer counts bytes in a packet
always@(posedge reset or negedge clk)
begin
   if(reset)
   begin
		R_PTCMDPNTR <= 0;
   end
   else
   begin
		if(se)
		begin
			if(tcvcptdone)
			begin
				R_PTCMDPNTR <= 0;
			end
			else
			begin
				if(R_CMDSCNTR == 3'b0)
					R_PTCMDPNTR <= R_PTCMDPNTR + 1'b1;
			end
		end
   end
end	

///////////////////////////CMD SHIFT BITS COUNTER/////////////////////////////////////////	
//////////Counter that counts bits that serial out on CMD SD CARD Line
always@(posedge reset or negedge clk)
begin
    if(reset)
    begin 
        R_CMDSCNTR <= 3'b111;
    end
    else
    begin
		  if((se & oe) | R_ISCPKT)
		  begin
				if(R_CMDSCNTR == 3'b0 | tcvcptdone)
                R_CMDSCNTR <= 3'b111;
            else
                R_CMDSCNTR <= R_CMDSCNTR - 1'b1; 
        end
    end
end

endmodule 