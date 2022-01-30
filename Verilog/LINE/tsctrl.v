/*#############################################################################*/
/*###############====3-STATE OUTPUT BUFFERS CONTROLLER===######################*/
/*#############################################################################*/
/*Description:
3-state output buffer controller is used to drive CMD and DAT SD card lines in
appropriate time 
*/
module tsctrl(
input clk, ///Clock
input reset, ///Reset
input cmdtsen, ///CMD 3-state enable
input dtsen, ///DATA 3-state enable
input tcvcptdone, ///tranceive CMD packet done
input tcvdptdone, ///tranceive DATA packet done
output cmdoe, ///CMD line output enable
output doe ///DAT line output enable
);

reg R_TRNSMT_CMD; ///Transmit data to CMD line register
reg R_TRNSMT_DATA; ///Transmit data to DAT line register

assign cmdoe = R_TRNSMT_CMD;
assign doe = R_TRNSMT_DATA;

/////////////////////DRIVE SD CARD CMD 3-STATE LINE REGISTER////////////////////////
//////////Direction control register of CMD SD CARD Line
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_TRNSMT_CMD <= 0;
	else
	begin
		if(cmdtsen)
		begin
			if(tcvcptdone)
				R_TRNSMT_CMD <= 0;
			else
				R_TRNSMT_CMD <= 1;
		end
	end
end

/////////////////////DRIVE SD CARD DAT 3-STATE LINE REGISTER////////////////////////
//////////Direction control register of DAT0 SD CARD Line
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_TRNSMT_DATA <= 0;
	else
	begin
		if(dtsen)
		begin
			if(tcvdptdone)
				R_TRNSMT_DATA <= 0;
			else
				R_TRNSMT_DATA <= 1;
		end
	end
end


endmodule 