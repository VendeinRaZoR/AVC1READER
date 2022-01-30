/*##############################################################*/
/*####################====AVC CONTROLLER====####################*/
/*##############################################################*/
/*Description:
AVC controller drives the DAT line state machine in AVC file stage 
by parsing AVC header and AVC vectors in AVC file
Current module computes AVC file start sector and finds AVC file 
in FAT files table
*/
module avcctrl(
input clk, ///clock
input reset, ///system reset
input sbdone, //shift byte done
input endpkt, ///end of data packet (active low, CRC16 + 8'hFF byte)
input isdpkt, ///Data present on a DAT line indicator 
input avcrfen, //AVC_READ_FILE state enabled
input tcvdptdone, //Tranceive DAT packet done
input [7:0] SPCLUST, ///Sectors per cluster
input [7:0] DATASI, ///output data from input shift register from DAT line
input [15:0] PTDATAPNTR, ///DATA packet pointer on a DAT line (bytes counter in current packet)
output fnmnull, ///AVC FIle filename null
output fnme, ///AVC file filename empty (not used)
output fnminvld, ///AVC File filename invalid
output avcpktrf, //AVC_READ_FILE byte in packet indicator
output [15:0] AVCFSEC, ///AVC File start sector address
output [23:0] AVCFEX, ///AVC File extention 
output [7:0] STRNAME0, ///AVC File name char 0
output [7:0] STRNAME1, ///AVC FIle name char 1
output [7:0] STRNAME2, ///AVC FIle name char 2
output [7:0] STRNAME3, ///AVC FIle name char 3
output [7:0] STRNAME4, ///AVC FIle name char 4
output [7:0] STRNAME5, ///AVC FIle name char 5
output [7:0] STRNAME6, ///AVC FIle name char 6
output [7:0] STRNAME7 ///AVC FIle name char 7
);

reg [31:0] R_AVCFCLUST; ///AVC file start cluster
reg [15:0] R_AVCFSEC; ///AVC file start sector  

reg [11:0] R_AVCFNDCNTR; ///Find AVC file record in FAT files table counter
reg [7:0] R_STRFNAME0; ///AVC file filename char 0
reg [7:0] R_STRFNAME1; ///AVC file filename char 1
reg [7:0] R_STRFNAME2; ///AVC file filename char 2
reg [7:0] R_STRFNAME3; ///AVC file filename char 3
reg [7:0] R_STRFNAME4; ///AVC file filename char 4
reg [7:0] R_STRFNAME5; ///AVC file filename char 5
reg [7:0] R_STRFNAME6; ///AVC file filename char 6
reg [7:0] R_STRFNAME7; ///AVC file filename char 7
reg [7:0] R_AVCFTYPE; ///AVC file type (folder, simple file or system file, should be simple file)
reg [23:0] R_AVCFEX; ///AVC file file extention string

wire [15:0] AVCFSECOUT; ///AVC file start sector

reg R_AVCFF; ///AVC file found in FAT files table indicator

assign AVCFSEC = R_AVCFSEC;
assign fnmnull = R_STRFNAME0 == 8'h00;
assign fnminvld = R_STRFNAME0 != 8'h00 & R_STRFNAME0 != 8'h45;
assign avcpktrf = avcrfen & sbdone & endpkt & isdpkt;

assign AVCFEX = R_AVCFEX;
assign STRNAME0 = R_STRFNAME0;
assign STRNAME1 = R_STRFNAME1;
assign STRNAME2 = R_STRFNAME2;
assign STRNAME3 = R_STRFNAME3;
assign STRNAME4 = R_STRFNAME4;
assign STRNAME5 = R_STRFNAME5;
assign STRNAME6 = R_STRFNAME6;
assign STRNAME7 = R_STRFNAME7;

//////////////////////////////////////////ARITHMETIC////////////////////////////////////////////////////	 
/////////AVC File Sector = AVC File Cluster * Sector Per Cluster
multiply2 multavcfclust(
	.dataa(R_AVCFCLUST),
	.datab(SPCLUST),
	.result(AVCFSECOUT)
);
/////////AVC File Sector Latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFSEC <= 0;
	else
		R_AVCFSEC <= AVCFSECOUT;
end

///////////////////////////AVC FILE FINDING IN FAT FILES TABLE////////////////////////////////////////	 
/////////AVC File Found Register-Indicator
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFF <= 0;
	else
	begin
		if(sbdone & R_STRFNAME0 != 8'hE5 & R_STRFNAME0 != 8'h05 & R_AVCFTYPE == 8'h20 & R_STRFNAME0 != 8'h45 & R_AVCFEX == {8'h0,"AVC"} 
		& PTDATAPNTR == {R_AVCFNDCNTR[11:1],1'b1,4'hF} | R_STRFNAME0 == 8'h00)
			R_AVCFF <= 1; ///For 1 AVC File
	end
end  
/////////FileName (short) char 0 (if E5 - file deleted and free to rewrite)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME0 <= 8'hE5;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h01} & endpkt & avcrfen & !R_AVCFF)
			R_STRFNAME0 <= DATASI; 
	end
end
/////////FileName (short) char 1
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME1 <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h2} & endpkt & avcrfen & !R_AVCFF)
			R_STRFNAME1 <= DATASI; 
	end
end
/////////FileName (short) char 2
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME2 <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h3} & endpkt & avcrfen & !R_AVCFF)
			R_STRFNAME2 <= DATASI; 
	end
end
/////////FileName (short) char 3
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME3 <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h4} & endpkt & avcrfen & !R_AVCFF)
			R_STRFNAME3 <= DATASI; 
	end
end
/////////FileName (short) char 4
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME4 <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h5} & endpkt & avcrfen & !R_AVCFF)
			R_STRFNAME4 <= DATASI; 
	end
end
/////////FileName (short) char 5
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME5 <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h6} & endpkt & avcrfen & !R_AVCFF)
			R_STRFNAME5 <= DATASI; 
	end
end
/////////FileName (short) char 6
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME6 <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h7} & endpkt & avcrfen & !R_AVCFF)
			R_STRFNAME6 <= DATASI; 
	end
end
/////////FileName (short) char 7
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_STRFNAME7 <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h8} & endpkt & avcrfen & !R_AVCFF)
			R_STRFNAME7 <= DATASI; 
	end
end
/////////File Extension char 0
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFEX[23:16] <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'h9} & endpkt & !R_AVCFF & avcrfen)
			R_AVCFEX[23:16] <= DATASI;
	end
end
/////////File Extension char 1
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFEX[15:8] <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'hA} & endpkt & !R_AVCFF & avcrfen)
			R_AVCFEX[15:8] <= DATASI;
	end
end
/////////File Extension char 2
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFEX[7:0] <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'hB} & endpkt & !R_AVCFF & avcrfen)
			R_AVCFEX[7:0] <= DATASI;
	end
end
/////////File type (hide, system ,read only e.t.c.)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFTYPE <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR,4'hC} & endpkt & !R_AVCFF & avcrfen)
			R_AVCFTYPE <= DATASI;
	end
end
/////////First cluster number of file (Byte 0)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFCLUST[7:0] <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR[11:1],1'b1,4'hB} & endpkt & !R_AVCFF & avcrfen)
			R_AVCFCLUST[7:0] <= DATASI;
	end
end
/////////First cluster number of file (Byte 1)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFCLUST[15:8] <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR[11:1],1'b1,4'hC} & endpkt & !R_AVCFF & avcrfen)
			R_AVCFCLUST[15:8] <= DATASI;
	end
end
/////////First cluster number of file (Byte 2)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFCLUST[23:16] <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR[11:1],1'b1,4'h5} & endpkt & !R_AVCFF & avcrfen)
			R_AVCFCLUST[23:16] <= DATASI;
	end
end
/////////First cluster number of file (Byte 3)
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFCLUST[31:24] <= 8'h00;
	else
	begin
		if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR[11:1],1'b1,4'h6} & endpkt & !R_AVCFF & avcrfen)
			R_AVCFCLUST[31:24] <= DATASI;
	end
end
/////////Counter for finding AVC file record fields
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_AVCFNDCNTR <= 8'h00;
	else
	begin
		if(R_STRFNAME0 != 8'h00 & R_STRFNAME0 != 8'h45 & (tcvdptdone | sbdone & PTDATAPNTR == {R_AVCFNDCNTR[11:1],1'b1,4'hF}) & avcrfen)
		begin
			if(sbdone & PTDATAPNTR == {R_AVCFNDCNTR[11:1],1'b1,4'hF})
				R_AVCFNDCNTR <= R_AVCFNDCNTR + 12'h02;
			else 
				R_AVCFNDCNTR <= 0;
		end
	end
end

endmodule 