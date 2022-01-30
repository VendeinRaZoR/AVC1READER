/*###########################################################################*/
/*#######################====CRC16 CALCULATE MODULE====#######################*/
/*###########################################################################*/
/*Description:
CRC16 module calculates CRC16 for DATA packets on DAT SD card line
*/
module CRC16(RESET, BITVAL, BITSTRB, CLEAR, CRC16OUT);
input         RESET;										 //Reset
input         BITVAL;                            // Bit stream
input         BITSTRB;                           // Clock
input         CLEAR;                             // clear to initial value
output [15:0] CRC16OUT;                               // Current output CRC value

reg    [15:0] CRC;                               // output CRC16 register
wire          inv;										 //input XOR

assign inv = BITVAL ^ CRC[15];                   

assign CRC16OUT[0] = inv;
assign CRC16OUT[1] = CRC[0];
assign CRC16OUT[2] = CRC[1];
assign CRC16OUT[3] = CRC[2];
assign CRC16OUT[4] = CRC[3];
assign CRC16OUT[5] = CRC[4] ^ inv;
assign CRC16OUT[6] = CRC[5];
assign CRC16OUT[7] = CRC[6];
assign CRC16OUT[8] = CRC[7];
assign CRC16OUT[9] = CRC[8];
assign CRC16OUT[10] = CRC[9];
assign CRC16OUT[11] = CRC[10];
assign CRC16OUT[12] = CRC[11] ^ inv;
assign CRC16OUT[13] = CRC[12];
assign CRC16OUT[14] = CRC[13];
assign CRC16OUT[15] = CRC[14];
//////////CRC16 calculation shift register (polynom x^16 + x^12 + x^5 + 1)
always @(negedge BITSTRB or posedge RESET) 
begin
if (RESET) 
	begin
  CRC <= 0;                                  // Init before calculation
end
else 
	begin
		if(CLEAR)
			CRC <= 0;
		else
		begin
			CRC[15] = CRC[14];
			CRC[14] = CRC[13];
			CRC[13] = CRC[12];
			CRC[12] = CRC[11] ^ inv;
			CRC[11] = CRC[10];
			CRC[10] = CRC[9];
			CRC[9] = CRC[8];
			CRC[8] = CRC[7];
			CRC[7] = CRC[6];
			CRC[6] = CRC[5];
			CRC[5] = CRC[4] ^ inv;
			CRC[4] = CRC[3];
			CRC[3] = CRC[2];
			CRC[2] = CRC[1];
			CRC[1] = CRC[0];
			CRC[0] = inv;
		end
end
end
   
endmodule

