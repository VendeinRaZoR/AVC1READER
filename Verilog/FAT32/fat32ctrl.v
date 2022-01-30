/*#############################################################################*/
/*##########################====FAT32 CONTROLLER===#############################*/
/*#############################################################################*/
/*Description:
FAT32 controller drives the DAT line state machine in FAT32 stage 
by finding and recording appropriate FAT32 structure fields in registers
*/
module fat32ctrl(
input clk, ///Clock
input reset, ///Reset
input sbdone, ///Shift byte done
input f32rprmen, ///FAT32_READ_PARAM state enabled
input [7:0] DATASI, ///output data from input shift register from DAT line
input [15:0] PTDATAPNTR, ///Bytes pointer (counter) in packet from DAT SD card line
output f32bpsvalid, ///FAT bytes per sector == SECTOR_SIZE - 3 (endpkt)
output f32avcsvalid, ///FAT files table address not null
output f32fat1valid, ///FAT1 address not null
output [15:0] FAT1SA, ///FAT1 start sector address
output [15:0] FAT2SA, ///FAT2 start sector addres
output [7:0] SPCLUST, ///Sectors per cluster
output [15:0] FROOTSEC, ///ROOT sector cluster offset from FAT files table (where first file place)
output [31:0] FATSIZE ///FAT1 or FAT2 table size
);

parameter SECTOR_SIZE = 515; ///512 bits + CRC16 + last 1 byte 

reg [15:0] R_FAT1ADDR; ///FAT1 address record in FAT32 structure
reg [15:0] R_FAT2ADDR; ///FAT2 address record in FAT32 structure
reg [31:0] R_FAT1SIZE; ///FAT1 size in FAT32 structure
reg [15:0] R_FATRCLUST; ///Root cluster from FAT files table record in FAT32 structure
reg [15:0] R_FROOTSEC; ///Root sector from FAT files table record in FAT32 structure
reg [7:0] R_SPCLUST; //Sectors per cluster record in FAT32 structure
reg [15:0] R_BPSEC; ///Bytes per sector record in FAT32 structure

wire [15:0] FROOTSECOUT; ///Root sector output 

assign f32avcsvalid = R_FROOTSEC != 0; 
assign f32bpsvalid = R_BPSEC == SECTOR_SIZE-3;
assign f32fat1valid = R_FAT1ADDR != 0;
assign FAT1SA = R_FAT1ADDR;
assign FAT2SA = R_FAT2ADDR;
assign SPCLUST = R_SPCLUST;
assign FROOTSEC = R_FROOTSEC;
assign FATSIZE = R_FAT1SIZE;

//////////////////////////////////////////ARITHMETIC////////////////////////////////////////////////////	 
//////////FAT files root table address = FAT files table cluster * Sectors Per Cluster
multiply2 multrootclust(
	.dataa(R_FATRCLUST),
	.datab(SPCLUST),
	.result(FROOTSECOUT)
);

//////////////////////////////////FAT32 STRUCT FIELDS REGISTERS//////////////////////////////////////	 
//////////Root sector latch
always@(posedge reset or negedge clk)
begin
if(reset)
	R_FROOTSEC <= 0;
else
	R_FROOTSEC <= FROOTSECOUT;
end
//////////Bytes per sector record in FAT32 header
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_BPSEC[7:0]  <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h000C & sbdone & f32rprmen)
			R_BPSEC[7:0] <= DATASI;
	end
end
//////////Bytes per sector record in FAT32 header
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_BPSEC[15:8] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h000D & sbdone & f32rprmen)
			R_BPSEC[15:8] <= DATASI;
	end
end
//////////Sectors per cluster register
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_SPCLUST <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h000E & sbdone & f32rprmen)
			R_SPCLUST <= DATASI;
	end
end
//////////FAT1 table address latch						
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT1ADDR[7:0] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h000F & sbdone & f32rprmen)
			R_FAT1ADDR[7:0] <= DATASI;
	end
end
//////////FAT1 table address latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT1ADDR[15:8] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h0010 & sbdone & f32rprmen)
			R_FAT1ADDR[15:8] <= DATASI;
	end
end
//////////FAT1 table size latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT1SIZE[7:0] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h0025 & sbdone & f32rprmen)
			R_FAT1SIZE[7:0] <= DATASI;
	end
end
//////////FAT1 table size latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT1SIZE[15:8] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h0026 & sbdone & f32rprmen)
			R_FAT1SIZE[15:8] <= DATASI;
	end
end
//////////FAT1 table size latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT1SIZE[23:16] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h0027 & sbdone & f32rprmen)
			R_FAT1SIZE[23:16] <= DATASI;
	end
end
//////////FAT1 table size latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT1SIZE[31:24] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h0028 & sbdone & f32rprmen)
			R_FAT1SIZE[31:24] <= DATASI;
	end
end
//////////FAT2 table address latch
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FAT2ADDR <= 0;
	else
	begin
		if(f32rprmen)
			R_FAT2ADDR <= R_FAT1SIZE + R_FAT1ADDR;
	end
end
//////////FAT root start cluster with FAT files table
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FATRCLUST[7:0] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h002D & sbdone & f32rprmen)
			R_FATRCLUST[7:0] <= DATASI;
	end
end
//////////FAT root start cluster with FAT files table
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_FATRCLUST[15:8] <= 0;
	else
	begin
		if(PTDATAPNTR == 16'h002E & sbdone & f32rprmen)
			R_FATRCLUST[15:8] <= DATASI;
	end
end

endmodule 