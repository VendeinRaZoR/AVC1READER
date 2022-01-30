/*#############################################################################*/
/*######################====USER BUTTONS CONTROLLER===#########################*/
/*#############################################################################*/
/*Description:
This module debounces user buttons on AVC1READER board
*/
module userctrl(
input clk, ///Clock
input breset, ///Button RESET
input bread, ///Button START
output dreset, ///Debounced RESET button
output dread ///Debounced START button
);

parameter DEBOUNCETIME = 8'h1; //time to debounce

wire wpres; ///RESET signal direct from button
wire avcread; ///START signal direct from button

reg [7:0] R_RANTIDRBZGTMR; ///debounce timer for RESET button
reg [7:0] R_ARANTIDRBZGTMR; ///debounce timer for START button

reg [1:0] R_READ; ///debounced START button triggers
reg R_RESET; ///debounced RESET button trigger

assign wpres = ~breset;
assign avcread = ~bread;
assign dreset = R_RESET;
assign dread = ~R_READ[1] & R_READ[0];

/////////////////////////////////////////////DEBOUNCE & RESET////////////////////////////////////////	
//////////Debounce timer for reset button
always@(negedge wpres or negedge clk)
begin
    if(!wpres)
        R_RANTIDRBZGTMR <= 0;
    else
    if(R_RANTIDRBZGTMR != DEBOUNCETIME)
        R_RANTIDRBZGTMR <= R_RANTIDRBZGTMR + 1'b1; 
end
//////////Reset button debouncer register
always@(negedge wpres or negedge clk)
begin
    if(!wpres)
        R_RESET <= 0;
    else
    if(R_RANTIDRBZGTMR == DEBOUNCETIME)
        R_RESET <= wpres;
end
	
/////////////////////////////////////////////DEBOUNCE & READ/////////////////////////////////////////
//////////Debounce timer for read button
always@(negedge avcread or negedge clk)
begin
    if(!avcread)
       R_ARANTIDRBZGTMR <= 0;
    else
    if(R_ARANTIDRBZGTMR != DEBOUNCETIME)
       R_ARANTIDRBZGTMR <= R_ARANTIDRBZGTMR + 1'b1; 
end
//////////Read button debouncer register
always@(negedge avcread or negedge clk)
begin
   if(!avcread)
      R_READ <= 0;
   else
	if(R_ARANTIDRBZGTMR == DEBOUNCETIME)
	begin
		R_READ[0] <= avcread;
		R_READ[1] <= R_READ[0];
	end
end
	
endmodule 