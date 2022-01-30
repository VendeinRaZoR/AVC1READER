/*#############################################################################*/
/*###############====SD CARD INITIALIZATION CONTROLLER===######################*/
/*#############################################################################*/
/*Description:
SD card controller drives the CMD line state machine on SD card initialization
stage by reading and comparing SD card initialization status information 
*/
module sdctrl(
input clk, ///Clock
input reset, ///Reset
input sbdone, ///Shift byte done
input pwruptmren, ///POWER_UP state enabled
input crdvtgrngewe, //Detected voltage range write enable signal
input pubrcast, ///Public RCA writing state
input lasterrwe, //Last error write enable signal
input sdlnstswe, //SD line status write enalbe signal
input sdcapstwe, //SD capacity status write enable signal
input acmd41fstwe, ///ACMD41 first write enalbe signal
input mstotmren, ///time out timer enable count signal
input tcvcptdone, ///tranceive/receive CMD packet done
input [7:0] CMDSI, ///CMD serial input shift register output
input [4:0] PTCMDPNTR, ///CMD packet pointer (bytes in packet counter)
output pwuptmrstop, ///power up timer stop signal
output cmd0null, ///SD card capacity status in OCR register == 0
output vrngeapply, ///voltage range applyed by SD card
output lasterr, //last error on CMD SD card transaction
output acmd41fst, ///first ACMD41 signal indicator
output sdinitlzd, ///SD initialized indicator
output mstotout, ///initialize by ACMD41 timeout timer
output [7:0] SDLNSTS, ///SD card line status while write acknowledge
output [15:0] PUBRCA
);

reg [15:0] R_MSTOTMR;///ACMD41 timeout timer 

reg [7:0] R_PWRUPTMR; ///Power-up timer
reg [7:0] R_SDCAPST; ///SD card capacity status register
reg [7:0] R_CRDVTGRNGE; ///SD card voltage range register

reg [7:0] R_SDLNSTS; ///SD line status register

reg [15:0] R_PUBRCA; ///Public RCA SD card address on SD card bus

reg R_PWRUPTMRSTOP; ///Power-up timer stop latch
reg R_LASTWRNG; ///Last warning trigger
reg R_ACMD41FST; ///ACMD41 first packet indicator

assign pwuptmrstop = R_PWRUPTMRSTOP;
assign cmd0null = R_SDCAPST == 0;
assign vrngeapply = R_CRDVTGRNGE == 8'h01;
assign sdinitlzd = R_SDCAPST != 0 & R_SDCAPST[0] == 0;
assign mstotout = R_MSTOTMR == 16'hFFFF;
assign lasterr = R_LASTWRNG;
assign acmd41fst = R_ACMD41FST;
assign SDLNSTS = R_SDLNSTS;
assign PUBRCA = R_PUBRCA;

/////////////////////SD CARD INITIALIZATION REGISTERS & COUNTERS////////////////////////
//////////Power-up timer before initialization SD CARD
always@(posedge reset or negedge clk)
begin
	if(reset)	
	begin
		R_PWRUPTMRSTOP <= 0;
		R_PWRUPTMR <= 0;
	end
	else
	begin
		if(pwruptmren)
			{R_PWRUPTMRSTOP,R_PWRUPTMR} <= R_PWRUPTMR + 1;
	end
end
//////////SD CARD voltage range register (from specification)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_CRDVTGRNGE <= 0;
	else
	begin
		if(PTCMDPNTR == 4 & sbdone & crdvtgrngewe)
			R_CRDVTGRNGE <= CMDSI;
	end
end
//////////Last error in transactions between SD CARD
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_LASTWRNG <= 0;
	else
	begin
		if(PTCMDPNTR == 5 & CMDSI != 8'hAA & sbdone & lasterrwe)
			R_LASTWRNG <= 1;
	end
end
//////////Line status while SD CARD operations
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_SDLNSTS <= 0;
	else
	begin
		if(PTCMDPNTR == 4 & sbdone & sdlnstswe)
			R_SDLNSTS <= CMDSI;
	end
end
//////////SD CARD capacity status (from specification)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_SDCAPST <= 0;
	else
	begin
		if(PTCMDPNTR == 2 & sbdone & CMDSI[7] == 1'b1 & sdcapstwe)
			R_SDCAPST <= CMDSI;
	end
end
//////////ACMD41 first or not indicator
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_ACMD41FST <= 1;
	else
	begin
		if(acmd41fstwe)
			R_ACMD41FST <= 0;
	end
end
//////////ACMD41 timeout timer
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_MSTOTMR <= 0;
	else
	begin
		if(mstotmren & tcvcptdone)
			R_MSTOTMR <= R_MSTOTMR + 1'b1;
	end
end
//////////Public RCA Adress on SDCARD's bus
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_PUBRCA[15:8] <= 0;
	else
	begin
		if(PTCMDPNTR == 2 & sbdone & pubrcast)
			R_PUBRCA[15:8] <= CMDSI;
	end
end
//////////Public RCA Adress on SDCARD's bus
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_PUBRCA[7:0] <= 0;
	else
	begin
		if(PTCMDPNTR == 3 & sbdone & pubrcast)
			R_PUBRCA[7:0] <= CMDSI;
	end
end

endmodule 