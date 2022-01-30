 /*#########################################################*/
/*###################====AVC COMPARE====#####################*/
/*##########################################################*/
/*Description:
AVC parser finds errors in received signals
and brings them into serial form for SD CARD ERCY file
*/
module avcompare(
input clk, //Clock
input nclk, ///Negative clock
input fclk, //Clock fast
input nfclk, ///Negative clock fast
input ureset, ///User reset (by START button)
input sbdone, /// shift byte done
input endpkt, ///end of DATA packet
input isdpkt, ///is DATA packet on DAT line 
input avcrden,///AVC_READ_DATA state enabled
input avcsndvec, ///AVC_SEND_VECTOR state enabled
input errrd, ///Read ERCY data from FIFO
input nextfvec, ///next fast vector
input nextsvec, ///next slow vector
input eofavcfnd, ///found End-of-File in AVC file
input [7:0] DATASI, ///Data serial input SD CARD shift register output
input [15:0] SGNL, ///Signals on IDE connector
input [31:0] SDRPSGNL, ///AVC parallel signals (vectors) from SDRAM
input [31:0] SDRTSGNL, ///AVC parallel 3-states of bidirectional signals from SDRAM 
input [31:0] AVCVECNTR, ///AVC file vector counter while reading from SD CARD
input [127:0] HLPSGNL, ///is current signal is input H or L signal parallel (128 signals but 16 used only)
output outempty, ///ERCY vectors FIFO low-empty (almost empty)
output cmpdone, ///end of all operations
output [31:0] VECTOROUT, ///Error vectors number FIFO output for ERCY file
output WSSGNLOUT, ///Expected signal from SNGL lines FIFO output 
output GSSGNLOUT,  ///Received signal from SGNL lines FIFO output
output [7:0] SGNLNMNUM ///Signal name number in AVC header's ROM
);

wire [7:0] SGNLBUSLEN; ///Signal bus length in AVC file header
wire [31:0] HLVECS; ///H & L signals vectors numbers FIFO output (slow)
wire [31:0] HLMSKS; ///H & L masks for vectors FIFO output (slow)

wire [31:0] VECTORBUF; ///Miscompared vector's numbers FIFO output
wire WSSGNLBUF; ///Expected signals (slow) FIFO output
wire GSSGNLBUF; ///Received signals (slow) FIFO output
wire TSSGNLBUF; ///Directions of signals (slow) FIFO output

wire hlfulls; ///HL masks FIFO full (slow)
wire hlvecfulls; ///HL masks FIFO full (slow)
wire vecemptys; ///Mismatch vector number FIFO empty (slow)
wire vecfulls; ///Mismatch vector number FIFO full (slow)
wire gsemptys; ///Received signals FIFO empty (slow)
wire gsfulls; ///Received signals FIFO full (slow)
wire wsemptys; ///Expected signals FIFO empty (slow)
wire wsfulls; ///Expected signals FIFO full (slow)
wire tsfulls; ///3-state signals FIFO full (slow)

wire svecemptys; ///Mismatch vector number FIFO-serializer empty (slow)
wire svecfulls; ///Mismatch vector number FIFO-serializer full (slow)
wire sgsemptys; ///Received signals FIFO-serializer empty (slow) 
wire sgsfulls; ///Received signals FIFO-serializer full (slow)
wire swsemptys; ///Expected signals FIFO-serializer empty (slow)
wire swsfulls; ///Expected signals FIFO-serializer full (slow)

reg [31:0] R_SGNLFVECNTR; ///Fast signals vector counter
reg [31:0] R_SGNLSVECNTR; ///Slow signals vector counter 
reg [7:0] R_SGNLSCNTR; ///Slow signals counter (16 slow signals)
reg [6:0] R_AVCHRCNTR; ///AVC char (bits) counter in AVC vector
reg [7:0] R_AVCSGNLCNTR; ///AVC signals counter in header 

reg R_CMPDONE; ///Read vectors from AVC done and from SDCARD done (end of all operaions)

reg R_ERRSRD; ///Read errors from FIFO for ERCY records (slow)

assign outempty = svecemptys & sgsemptys & swsemptys;

assign cmpdone = R_CMPDONE;

/////////////////////////////FIFO'S FOR ERROR VECTORS DETECTION (SLOW)//////////////////////////
//////////H & L signals from AVC file masks FIFO
paralsfifo hlmasks(
	.aclr(ureset),
	.data(HLPSGNL[31:16]),
	.rdclk(nfclk),
	.rdreq(R_SGNLSVECNTR == HLVECS & eofavcfnd),
	.wrclk(nclk),
	.wrreq(DATASI == 8'h0A & sbdone & avcrden & endpkt & isdpkt & !eofavcfnd & HLPSGNL[31:16] != 0 & !hlfulls),
	.q(HLMSKS),
	.wrfull(hlfulls)
); 					
//////////Vectors FIFO where H & L signals appear
paralsfifo hlvecbufs(
	.aclr(ureset),
	.data(AVCVECNTR), 
	.rdclk(nfclk),
	.rdreq(R_SGNLSVECNTR == HLVECS & eofavcfnd), 
	.wrclk(nclk),
	.wrreq(DATASI == 8'h0A & sbdone & avcrden & endpkt & isdpkt & !eofavcfnd & HLPSGNL[31:16] != 0 & !hlvecfulls),
	.q(HLVECS),
	.wrfull(hlvecfulls)
); 					
//////////Miscompared vector's numbers FIFO 
paralsfifo errvec(
	.aclr(ureset),
	.data(R_SGNLSVECNTR),
	.rdclk(nclk),
	.rdreq(!vecemptys & R_SGNLSCNTR == 8'h10),
	.wrclk(nfclk),
	.wrreq(R_SGNLSVECNTR == HLVECS & SGNL[15:0] != SDRPSGNL[31:16] & avcsndvec & !vecfulls),
	.q(VECTORBUF),
	.rdempty(vecemptys),
	.wrfull(vecfulls)
); 		
//////////Signals directions FIFO-serializer
parserfifo errtsgnl(
	.aclr(ureset),
	.data(SDRTSGNL[31:16]),
	.rdclk(nclk),
	.rdreq(R_ERRSRD),
	.wrclk(nfclk),
	.wrreq(R_SGNLSVECNTR == HLVECS & SGNL[15:0] != SDRPSGNL[31:16] & avcsndvec & !tsfulls),
	.q(TSSGNLBUF),
	.rdfull(tsfulls)
); 			
//////////Expected signals FIFO-serializer
parserfifo errgsgnl(
	.aclr(ureset),
	.data(SGNL[15:0] & HLMSKS[15:0]),
	.rdclk(nclk),
	.rdreq(R_ERRSRD),
	.wrclk(nfclk),
	.wrreq(R_SGNLSVECNTR == HLVECS & SGNL[15:0] != SDRPSGNL[31:16] & avcsndvec & !gsfulls),
	.q(GSSGNLBUF),
	.rdempty(gsemptys),
	.rdfull(gsfulls)
); 				
//////////Expected signals FIFO-serializer
parserfifo errwsgnl(
	.aclr(ureset),
	.data(SDRPSGNL[31:16]),
	.rdclk(nclk),
	.rdreq(R_ERRSRD),
	.wrclk(nfclk),
	.wrreq(R_SGNLSVECNTR == HLVECS & SGNL[15:0] != SDRPSGNL[31:16] & avcsndvec & !wsfulls),
	.q(WSSGNLBUF),
	.rdempty(wsemptys),
	.rdfull(wsfulls)
); 		
//////////Signal name number for AVC Header Handler (avchdrhdlr)
signnum sgnlnmnum(
	.sclr(ureset),
	.aclr(ureset),
	.clock(nclk),
	.data(R_AVCSGNLCNTR),
	.rdreq(errrd),
	.wrreq((GSSGNLBUF != WSSGNLBUF) & TSSGNLBUF & R_ERRSRD),
	.q(SGNLNMNUM)
);                   
//////////Miscompared vectors numbers FIFO for SD CARD reading
servecfifo serrvec(
	.aclr(ureset),
	.data(VECTORBUF + 1'b1), 
	.clock(nclk),
	.rdreq(errrd),
	.wrreq((GSSGNLBUF != WSSGNLBUF) & TSSGNLBUF & R_ERRSRD), 
	.q(VECTOROUT),
	.empty(svecemptys),
	.full(svecfulls)
); 		
//////////Received signals FIFO for SD CARD reading
sersgnlfifo serrgsgnl(
	.aclr(ureset),
	.data(GSSGNLBUF),
	.clock(nclk),
	.rdreq(errrd),
	.wrreq((GSSGNLBUF != WSSGNLBUF) & TSSGNLBUF & R_ERRSRD),
	.q(GSSGNLOUT),
	.empty(sgsemptys), 
	.full(sgsfulls)
); 				
//////////Expected signals FIFO for SD CARD reading
sersgnlfifo serrwsgnl(
	.aclr(ureset),
	.data(WSSGNLBUF),
	.clock(nclk),
	.rdreq(errrd),
	.wrreq((GSSGNLBUF != WSSGNLBUF) & TSSGNLBUF & R_ERRSRD),
	.q(WSSGNLOUT),
	.empty(swsemptys),
	.full(swsfulls)
); 	
/////////////////////////////ERROR VECTORS DETECTION STAGE/////////////////////////
//////////Fast signals vectors counter
always@(posedge ureset or negedge fclk)
begin
	if(ureset)
		R_SGNLFVECNTR <= 32'h0000_0000;
	else
	begin
		if(nextfvec)
			R_SGNLFVECNTR <= R_SGNLFVECNTR + 32'h0000_0001; 
	end
end
//////////End of all comparing operations
always@(posedge ureset or negedge fclk)
begin
	if(ureset)
		R_CMPDONE <= 0;
	else
	begin
		if((R_SGNLSVECNTR == AVCVECNTR) & avcsndvec)
			R_CMPDONE <= 1;
	end
end	
//////////Slow signals vectors counter
always@(posedge ureset or posedge fclk)
begin
	if(ureset)
		R_SGNLSVECNTR <= 32'h0000_0000;
	else
	begin
		if(nextsvec)
			R_SGNLSVECNTR <= R_SGNLSVECNTR + 32'h0000_0001; 
	end
end
//////////Read errors from FIFO for ERCY records register
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_ERRSRD <= 0;
	else
	begin
		if(!gsemptys & !wsemptys & !svecfulls & !sgsfulls & !swsfulls)
			R_ERRSRD <= ~R_ERRSRD; 
		else if(gsemptys | wsemptys | svecfulls | sgsfulls | swsfulls)
			R_ERRSRD <= 0;
	end
end
//////////Slow signals counter (16 signals only)
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_SGNLSCNTR <= 8'h10;
	else
	begin
		if(!vecemptys & R_SGNLSCNTR == 8'h10)
			R_SGNLSCNTR <= 0;
		else if(R_ERRSRD)
			R_SGNLSCNTR <= R_SGNLSCNTR + 8'h01; 
	end
end
//////////AVC Signal counter counts signal's name number in AVC header
always@(posedge ureset or negedge clk)
begin
	if(ureset)
		R_AVCSGNLCNTR <= 8'h0F;
	else
	begin
		if(R_AVCSGNLCNTR == 8'h1F)
			R_AVCSGNLCNTR <= 8'h0F; 
		else if(R_ERRSRD)
			R_AVCSGNLCNTR <= R_AVCSGNLCNTR + 1'b1;
	end
end

endmodule 