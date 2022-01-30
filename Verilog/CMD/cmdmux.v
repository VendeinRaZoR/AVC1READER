/*###########################################################################*/
/*########################====CMD PACKET MULTIPLEXOR====#####################*/
/*###########################################################################*/
/*Description:
CMD packets multiplexor creates CMD packets that do not stays unchangeable, their
content may be changed such as sector address and public RCA. It influences on 
CRC7 for CMD packet.
*/
module cmdmux(
input [31:0] DADDR, ///SD card sector address
input [7:0] CMDN, ///CMD packet number from specification
input [4:0] PTCMDPNTR, ///bytes counter in CMD packet
input [15:0] PUBRCA, ///Public RCA address on the line
input [7:0] CRC7, ///CRC7 generated for changeable CMD packet
output reg [7:0] MUXDADDRPKT, ///MUX output for CMD packet with sector address
output reg [7:0] MUXDPRCAPKT ///MUX output for CMD packet with Public RCA address
);

///////////////////////////MUX WITH SECTOR ADDRESS////////////////////////
//////////MUX for forming packet packet on CMD SD CARD Line with sector address
always@*
begin
	case(PTCMDPNTR)

		5'b0000: MUXDADDRPKT = CMDN;
		5'b0001: MUXDADDRPKT = DADDR[31:24];
		5'b0010: MUXDADDRPKT = DADDR[23:16];
		5'b0011: MUXDADDRPKT = DADDR[15:8];

		5'b0100: MUXDADDRPKT = DADDR[7:0];
		5'b0101: MUXDADDRPKT = {CRC7,1'b1};
		5'b0110: MUXDADDRPKT = 8'hFF;
		5'b0111: MUXDADDRPKT = 8'hFF;

	default:
		MUXDADDRPKT = 8'hFF; 

	endcase
end

///////////////////////////MUX WITH PUBLIC RCA ADDRESS////////////////////
//////////MUX for forming packet on CMD SD CARD Line with SD CARD Address on bus (RCA)
always@*
begin
	case(PTCMDPNTR)

		5'b0000: MUXDPRCAPKT = CMDN;
		5'b0001: MUXDPRCAPKT = PUBRCA[15:8];
		5'b0010: MUXDPRCAPKT = PUBRCA[7:0];
		5'b0011: MUXDPRCAPKT = 8'h00;

		5'b0100: MUXDPRCAPKT = 8'h00;
		5'b0101: MUXDPRCAPKT = {CRC7,1'b1};
		5'b0110: MUXDPRCAPKT = 8'hFF;
		5'b0111: MUXDPRCAPKT = 8'hFF;

	default:
		MUXDPRCAPKT = 8'hFF;

	endcase
end

endmodule 