/*##################################################################################*/
/*#######################====DAT SD CARD LINE CONTROLLER====########################*/
/*##################################################################################*/
/*Description:
DAT SD card line controller detects data packets on DAT line, counts bytes in 
packet and counts shifted bits from DAT line
*/
module datactrl(
input clk, ///Clock
input reset, ///Reset
input oe, ///output enable 
input datain, //input DAT line signal
input se, ///shift enable signal
input tcvdptdnex, //tranceive extended data packet (differ from SECTOR_SIZE) done
input isdpkten, ///only data packet on DAT line, not write acknowledge low signal
input [7:0] SDLNSTS, ///SD card line status while write acknowledge
output tcvdptdone, ///tranceive data packet done
output sbdone, ///input/output shift byte done
output bload, ///load new byte signal
output isdpkt, ///data packet on DAT line indicator
output lwe, ///DAT line not busy 
output [15:0] PTDATAPNTR ///Bytes counter on DAT line
);

parameter SECTOR_SIZE = 16'h0203; //512 bit + CRC16 + 1 byte 

wire dpkt; ///low level on DAT line indicator

reg R_ISDPKT; ///data packet on DAT line indicator indicator
reg R_FDATA; ///input DAT line latch register
reg [15:0] R_PTDATAPNTR; //bytes counter from DAT line register
reg [2:0] R_DATASCNTR; ///shift bits counter register

assign isdpkt = R_ISDPKT;
assign sbdone = R_DATASCNTR == 3'b111;
assign bload = R_DATASCNTR == 3'b0;
assign tcvdptdone = R_PTDATAPNTR == SECTOR_SIZE + tcvdptdnex;
assign lwe = SDLNSTS == 8'h09 & datain;

assign dpkt = !R_FDATA & !oe & isdpkten;

assign PTDATAPNTR = R_PTDATAPNTR;

//////////////////////////PACKET DETECTION ON DAT SD CARD LINE////////////////////////////
//////////Fetching data stream in 1 bit register
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FDATA <= 1'b1;
	else 
	begin
		R_FDATA <= datain;
	end
end
//////////Data packet indicator on DAT0 SD CARD Line 
always@(posedge dpkt or negedge clk)
begin
	if(dpkt)
		R_ISDPKT <= 1; 
	else
		if(tcvdptdone | reset)
			R_ISDPKT <= 0;
end

//////////////////////////BYTES COUNTER IN PACKETS ON DAT LINE////////////////////////////
//////////Counter of data byte on DAT0 SD CARD Line
always@(posedge reset or negedge clk)
begin
   if(reset)
   begin
		R_PTDATAPNTR <= 0;
   end
   else
   begin
		if(se)
		begin
			if(tcvdptdone)
			begin
				R_PTDATAPNTR <= 0;
			end
			else
			begin
				if(R_DATASCNTR == 3'b0)
				R_PTDATAPNTR <= R_PTDATAPNTR + 1'b1;
			end
		end
   end
end	

//////////////////////////SHIFT BITS COUNTER FROM DAT LINE////////////////////////////
//////////Counter that counts shifted bits on DAT0 SD CARD Line
always@(posedge reset or negedge clk)
begin
   if(reset)
   begin 
		R_DATASCNTR <= 3'b111;
	end
   else
	begin
		if(oe | R_ISDPKT)
		begin
			if(R_DATASCNTR == 3'b0 | tcvdptdone)
				R_DATASCNTR <= 3'b111;
			else
			R_DATASCNTR <= R_DATASCNTR - 1'b1;
		end
   end
end

endmodule 