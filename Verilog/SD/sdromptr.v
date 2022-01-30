/*#############################################################################*/
/*##########################====SD PACKET ROM===###############################*/
/*#############################################################################*/
/*Description:
SD packet ROM contains fields of CMD line packets that stays unchangeable during
all transaction's time 
*/
module sdpktrom(
input clk, ///Clock
input nclk, ///Negative clock
input reset, ///Reset
input tcvcptdone, ///tranceive (transmit/receive) DATA packet done signal
input acmd41fst, ///first ACMD41 signal indicator
input sdinitlzd, ///SD initialized indicator
input pupst, ///POWER_UP state enabled
input strtinitst, ///START_INIT state enabled
input cmd0st, ///CMD0 state enabled
input cmd8st, ///CMD8 state enabled
input facmd41st, ///FIRST_ACMD41 state enabled
input cmd55st, ///CMD55 state enabled
input r3st, ///R3 state enabled
input cmd2st, ///CMD2 state enabled
input cmd3st, ///CMD3 state enabled
input cmd9st, ///CMD9 state enabled
input cmd7st, ///CMD7 state enabled
input cmd17st, ///CMD17 state enabled
input [4:0] PTCMDPNTR, ///Byte pointer from CMD SD card line
output [7:0] SDPKTDATA ///CMD line initialize never unchengeable packets data ROM output 
);

reg [7:0] R_PTROMPNTR; ///Packet ROM data pointer register

/////////////////////////////////CMD PACKETS ROM///////////////////////////////

sdcrom sdcrom(
	.address(R_PTROMPNTR + PTCMDPNTR),
	.clock(nclk),
	.q(SDPKTDATA)
);

////////////////////////////ROM ADDRESS POINTER CONTROL///////////////////////////////

always@(posedge reset or negedge clk)
begin
	if(reset)
		R_PTROMPNTR <= 0;
	else
	begin
		if(pupst)
			R_PTROMPNTR <= 0;
		else if(strtinitst)
			R_PTROMPNTR <= 0;
		else if(cmd0st)
		begin
			if(tcvcptdone)
				R_PTROMPNTR <= 8'h8; 
		end
		else if(cmd8st)
		begin
			if(tcvcptdone)
				R_PTROMPNTR <= 8'h10;
		end
		else if(facmd41st)		
		begin
			if(tcvcptdone)
				R_PTROMPNTR <= 8'h10;
		end
		else if(cmd55st)			
		begin
			if(tcvcptdone)
			begin
				if(acmd41fst)
					R_PTROMPNTR <= 8'h18;
				else
					R_PTROMPNTR <= 8'h20;
			end
		end
		else if(r3st)	
		begin
			if(tcvcptdone)
			begin
				if(sdinitlzd)
					R_PTROMPNTR <= 8'h28;
				else
					R_PTROMPNTR <= 8'h10;
			end
		end
		else if(cmd2st)	
		begin
			if(tcvcptdone)
				R_PTROMPNTR <= 8'h30;
		end
		else if(cmd3st)			
		begin
			if(tcvcptdone)
				R_PTROMPNTR <= 8'h38;
		end
		else if(cmd9st)					
		begin
			if(tcvcptdone)
				R_PTROMPNTR <= 8'h40;
		end
		else if(cmd7st)						
		begin
			if(tcvcptdone)
				R_PTROMPNTR <= 8'h48;
		end
		else if(cmd17st)						
		begin
			if(tcvcptdone)
				R_PTROMPNTR <= 8'hF8;
		end
	end
end

endmodule 