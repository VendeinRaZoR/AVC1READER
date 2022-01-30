/*###########################################################################*/
/*#######################====CRC7 CALCULATE MODULE====#######################*/
/*###########################################################################*/
/*Description:
CRC7 module calculates CRC7 for CMD packets on CMD SD card line
*/
module CRC7(RESET, BITVAL, BITSTRB, CLEAR, CRC7OUT);
input         RESET;										 //System reset
input         BITVAL;                            // Bit stream
input         BITSTRB;                           // Clock
input         CLEAR;                             // Clear to initital CRC value
output [6:0] CRC7OUT;                            // Current output CRC value

reg    [6:0] CRC;                               // CRC7 output register
wire          inv;										//input XOR

assign inv = BITVAL ^ CRC[6];                  
    
assign CRC7OUT[0] = inv;
assign CRC7OUT[1] = CRC[0];
assign CRC7OUT[2] = CRC[1];
assign CRC7OUT[3] = CRC[2] ^ inv;
assign CRC7OUT[4] = CRC[3];
assign CRC7OUT[5] = CRC[4];
assign CRC7OUT[6] = CRC[5];
//////////CRC7 calculation shift register (polynom  x7 + x3 + 1)
always @(negedge BITSTRB or posedge RESET) 
    begin
  if (RESET) 
	    begin
      CRC <= 0;                                   // Init before calculation
  end
  else 
	    begin
		    if(CLEAR)
			    CRC <= 0; 
		    else
		    begin
			    CRC[6] <= CRC[5];
			    CRC[5] <= CRC[4];
			    CRC[4] <= CRC[3];
			    CRC[3] <= CRC[2] ^ inv;
			    CRC[2] <= CRC[1];
			    CRC[1] <= CRC[0];
			    CRC[0] <= inv;
		    end
  end
end
   
endmodule

