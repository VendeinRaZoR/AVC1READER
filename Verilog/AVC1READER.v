/*##############################################################*/
/*#################====AVC1READER MAIN MODULE====###############*/
/*##############################################################*/
/*Description:
Main module of AVC1READER tester  
*/
module AVC1READER (
I_CLOCK_50, ///for simulation only
I_CLOCK_35, ///input CLOCK signal 50 MHz
I_CLOCK_140, ///for simulation only
I_RESET,///input RESET button 
O_SD_CLK,//CLK for SD card
SD_CMD,///CMD line for SD card
SD_DAT,///DAT line for SD card
_I_SD_WP,///WP line for SD card
SGNL_OUT,
SGNL,///128 tested signals (111 only used)
I_READ,///input READ button
O_TESTLEDR, //RED LEDS outputs
O_TESTLEDG, //GREEN LEDS outputs
O_HEX0,///7-segment indicator 0
O_HEX1,///7-segment indicator 1 
O_HEX2,///7-segment indicator 2
O_HEX3,///7-segment indicator 3
O_HEX4,///7-segment indicator 4
O_HEX5,///7-segment indicator 5
O_HEX6,///7-segment indicator 6
O_HEX7,///7-segment indicator 7
O_LCD_BLON,///LCD back light ON (not worked)
O_LCD_DATA,///LCD 8-bit data
O_LCD_EN,///LCD strobe
O_LCD_ON,///LCD enable 
O_LCD_RS,///RS = 0 - DATA/RS = 1 - COMMAND
O_LCD_RW,////LCD read/write signal 
O_LEDONE, ///Blinking LED after test done
DQ, ///SDRAM Data line
O_A, ///SDRAM Address line
O_BA, ///SDRAM Bank Adress Select
O_SDR_CLK, ///SDRAM Clock
O_CKE, ///SDRAM Clock input enabled
_O_CS, ///SDRAM Chip Select
_O_RAS, ///SDRAM Row Access Strobe 
_O_CAS, ///SDRAM Column Access Strobe
_O_WE, ///SDRAM Write Enable
O_DQM ///SDRAM DQ Data Mask
);

//CMD Line state machine states
parameter CMD0	= 8'h00;	/* GO_IDLE_STATE */ //Go SD Card controller to the IDLE state
parameter CMD2	= 8'h02; /*ALL_SEND_CID*/ //Get identification CID number state
parameter CMD3	= 8'h03; /*SEND_RELATIVE_ADDR*/ //Ask new RCA address
parameter CMD7 = 8'h07; /*SELECT/DESELECT_CARD*///Put in (select) or put out (deselect) card into transfer state
parameter CMD9 = 8'h09; /*SEND_CSD*///Send CSD register from SD card state
parameter ACMD41 = 8'h29;	/* SEND_OP_COND (SDC) *///intialization command state (HCS bit in OCR)
parameter CMD8	= 8'h08;	/*SEND_IF_COND */ //Verify SD card interface state
parameter CMD13 = 8'h0D; /*SEND_STATUS/SEND_TASK_STATUS*/
parameter CMD17 = 8'h11;	/* READ_SINGLE_BLOCK */ ///read single 512 byte (standart) block from SD card state
parameter CMD18 = 8'h12; /*READ_MULTIPLE_BLOCK*/ ///not used state in this version
parameter CMD24 =	8'h18;	/* WRITE_BLOCK */ ///not used state in this version
parameter CMD55 =	8'h37;	/* APP_CMD */ ///
parameter CMD23 = 8'h17; /*SET_BLOCK_COUNT*/ ///not used state in this version
parameter CMD12 = 8'h0C; /*STOP_TRANSMISSION*/ ///not used state in this version
parameter R7 = 8'h3B; ///48 bits response R7 from SD card state
parameter R3 = 8'h3C; ///OCR register 48 bits response from SD card state
parameter R1 = 8'h3D; ///48 bits normal response from SD card state
parameter R2 = 8'h3E; ///136 bits response CID and CSD registers from SD card state
parameter R6 = 8'h3F; /// 48 bits public RCA address response state 
parameter STAND_BY_STATE = 8'h77; ///SD card in stand by state
parameter DATA_RECEIVE_STATE = 8'h78; ///SD card in data receiving state
parameter DATA_SEND_STATE = 8'h79; ///SD card in data sending state
parameter DATA_TRANSFER_STATE = 8'h7A; ///SD card in data transfer state
parameter FIRST_ACMD41 = 8'h7B; ///First appear of ACMD41 on CMD line state
parameter EXIT = 8'h7C; ///initialization of SD card FAIL
parameter POWER_UP = 8'h7E; ///Power-up state after reset
parameter START_INIT = 8'h7F; ///Start init state after power-up 

//DATA Lines state machine states
parameter MBR_START = 5'h00; /// initial state after AVC1READER reset
parameter MBR_GET_PARAM = 5'h01; /// state after init done and card select into transfer state
parameter MBR_READ_PARAM = 5'h02; /// read MBR necessary fields in SD card state
parameter FAT32_GET_PARAM = 5'h03; ///FAT32 sector increment and CMD17 state
parameter FAT32_READ_PARAM = 5'h04; ///read FAT32 necessary fields state
parameter USER_WAIT_START = 5'h06; ///waiting user press START button state
parameter FAT_GET_PARAM = 5'h07; ///increment FAT table sector address state
parameter FAT_READ_PARAM = 5'h08; ///read full FAT table and write it last sector 
//(ended F0FFFFFF) into buffer state  
parameter FAT_WRITE_PARAM = 5'h09; ///write last changed FAT table in buffer into SD card state
parameter FAT_WRITE_ACK = 5'h0A; ///write FAT table acknowledge state
parameter FAT_SET_PARAM_P1 = 5'h0B; ///FAT table set parameters part 1
parameter FAT_SET_PARAM_P2 = 5'h0C; ///FAT table set parameters part 2
parameter AVC_GET_DATA = 5'h0D; ///increment AVC file sector address while reading it from SD card state
parameter AVC_READ_DATA = 5'h0E; ///read AVC 512 bytes (standart sector) data from SD card state
parameter AVC_GET_FILE = 5'h0F; ///increment sector address in FAT files table in SD card state
parameter AVC_READ_FILE = 5'h10; ///read FAT files table sector from SD card and find AVC file in it state
parameter AVC_SEND_VECTOR = 5'h11; ///Send strored vectors in SDRAM to output
parameter ERCY_SET_DATA = 5'h12; ///increment ERCY file sector address while writing ERCY data on SD card state
parameter ERCY_WRITE_DATA = 5'h13; ///write ERCY data from buffers on SD card sectors state
parameter ERCY_WRITE_NULL = 5'h14; ///write ERCY null last sector on SD card state
parameter ERCY_WRITE_ACK = 5'h15; ///write ERCY sectors acknowledge state 
parameter ERCY_SET_FILE = 5'h16; ///add ERCY file description strings into FAT files table in buffer state
parameter ERCY_WRITE_FILE = 5'h17; ///write changed FAT files table from buffer on SD card state
parameter USER_WAIT_NEXT = 5'h18; ///final state when all test done
parameter ERCY_GET_FILE = 5'h19; ///increment FAT address sector while finding ERCY file record state
parameter ERCY_READ_FILE = 5'h1A; ///read FAT files table sector and find ERCY file record state

parameter SECTOR_SIZE = 16'h0203; //512 bits + CRC16 + last 1 byte 

input I_CLOCK_50; ///for simulation only
input I_CLOCK_35; ///input CLOCK signal 50 MHz
input I_CLOCK_140; ///for simulation only
input I_RESET; ///input RESET button 
input I_READ; ///input RESET button 

inout SD_CMD; ///CMD line for SD card

output [15:0] SGNL_OUT; ///128 tested signals (111 only used)
inout [15:0] SGNL;
inout [3:0] SD_DAT; ///DAT line for SD card

input _I_SD_WP; ///WP line for SD card

output O_SD_CLK; //CLK for SD card
output O_LEDONE; ///Ready LED 

output [17:0] O_TESTLEDR; //RED LEDS outputs
output [7:0] O_TESTLEDG; //GREEN LEDS outputs

output [6:0] O_HEX0; ///7-segment indicator 0
output [6:0] O_HEX1; ///7-segment indicator 1
output [6:0] O_HEX2; ///7-segment indicator 2
output [6:0] O_HEX3; ///7-segment indicator 3
output [6:0] O_HEX4; ///7-segment indicator 4
output [6:0] O_HEX5; ///7-segment indicator 5
output [6:0] O_HEX6; ///7-segment indicator 6
output [6:0] O_HEX7; ///7-segment indicator 7

output O_LCD_BLON; ///LCD back light ON (not worked)
output [7:0] O_LCD_DATA; ///LCD 8-bit data
output O_LCD_EN; ///LCD strobe
output O_LCD_ON; ///LCD enable 
output O_LCD_RS; ///RS = 0 - DATA/RS = 1 - COMMAND
output O_LCD_RW; ////LCD read/write signal

inout [31:0] DQ; ///SDRAM DQ data lines
output [12:0] O_A; ///SDRAM Adress lines
output [1:0] O_BA; ///SDRAM Bank Adress Select
output O_SDR_CLK; ///SDRAM Clock
output O_CKE; ///SDRAM Clock input enabled
output _O_CS; ///SDRAM Chip Select
output _O_RAS; ///SDRAM Row Access Strobe 
output _O_CAS; ///SDRAM Column Access Strobe
output _O_WE; ///SDRAM Write Enable
output [3:0] O_DQM; ///SDRAM DQ Data Mask

wire clk,sdclk,nsdclk,sysclk,sysfclk,nsysfclk,userclk,dqfifoclk; ///mainclk, sd card clk, negative sd card clk, system clk, user blocks clk
///clk,sysclk = 20 MHz, sysfclk = 80 MHz, dqfifoclk = 160 MHz, userclk = 10 kHz
wire oecmd,oedata; ///output enable cmd line, output enable data line
wire sdroe; ///SDRAM direction of DQ bus data 
wire tcvcptdone; ///tranceive (transmit/receive) CMD packet done signal
wire tcvdptdone; ///tranceive (transmit/receive) DATA packet done signal
wire sysres; ///system reset
wire ercyfempty; ///ERCY vectors FIFO empty
wire ercyfhfull; ///ERCY vectors FIFO half-full (almost full)
wire ercyflempty; ///ERCY vectors FIFO low-empty (almost empty)
wire ercyfwr; ///ERCY vectors FIFO write
wire ercyfrd; ///ERCY vectors FIFO read
wire fatecntrd; /// signal every new sector number in FAT tables (FAT1 and FAT2)
wire usravcread; ///START button debounced
wire isdpkt; ///is the data packet on the DAT line
wire eoff; ///FAT1 and FAT2 table end indicator
wire eofercy; ///ERCY file End-Of-File indicator 
wire scmdinput; ///Serial SD card CMD Line input
wire sdatainput; ///Serial SD card DAT line input
wire usravcrduws;  //User AVC START button blocked by USER_WAIT_START signal
wire isfat2; ///Currect FAT1 or FAT2 table switch 
wire avcpktrf; //AVC_READ_FILE byte in packet indicator

wire [31:0] DADDR; ///Sector Data Address on SD card

wire [7:0] SDPKTDATA; ///CMD line initialize never unchengeable packets data ROM output 
wire [7:0] FATLSRDATA; ///FAT table buffer output data
wire [7:0] ERCYFLSRDATA; ///FAT files table output data for ERCY record

wire [6:0] CRC7OUT;  ///CRC7 output data for CMD SD card line
wire [15:0] CRC16OUT; ///CRC16 output data for DAT SD card line
wire [15:0] AVCFSEC; ///AVC file sector offset from FAT files table

wire [15:0] FATECNTR; ///FAT1 or FAT2 tables through sector which contains
//FFFFFF0F last DWORD counter (512 bytes)
wire [31:0] FATSTRTCA; ///FAT table first empty cluster address
wire [31:0] FATENDCA; ///FAT table end cluster address
wire [15:0] FATSACNTR; ///FAT sector address counter
wire [31:0] FATSIZE; ///FAT1 or FAT2 table size

wire [15:0] FROOTSEC; ///ROOT sector cluster offset from FAT files table (where first file place)

wire [31:0] AVCVECNTR; ///AVC file vectors counter
wire [127:0] AVCPSGNL; ///AVC parallel output signals that leds to SGNL array (128 signals but 16 used only) 
wire [127:0] HLPSGNL; ///is current signal is input H or L signal parallel (128 signals but 16 used only)
wire [31:0] FAT32SA; ///FAT32 start sector address
wire [15:0] FAT1SA; ///FAT1 start sector address
wire [15:0] FAT2SA; ///FAT2 start sector address
wire [7:0] DATASI; ///Serial shift register output from DAT SD card line  
wire [7:0] CMDSI; ///Serial shift register output from CMD SD card line
wire [15:0] PTDATAPNTR; ///Byte pointer (counter) in packet from DAT SD card line  
wire [4:0] PTCMDPNTR; ///Byte pointer from CMD SD card line

wire [7:0] SPCLUST; ///Sectors per cluster

wire [7:0] SDLNSTS; ///SD card line status while write acknowledge

wire [7:0] CMDN; ///CMD[N] SD card controller command number, for example CMD0, number 0

wire [31:0] ERCYVECNTR; ///ERCY vector counter
wire [7:0] ERCYFLCNTR; ///ERCY filename index counter E000000*.erc, where * - index
wire [31:0] ERCYFSEC; ///ERCY start cluster from last empty cluster
wire [7:0] ERCYNCNTR; ///ERCY null counter in last cluster

wire [31:0] PTWDSECPNTR; ///ERCY write data sector pointer

wire [7:0] MUXDADDRPKT; ///Sector address CMD command bytes MUX 
wire [7:0] MUXDPRCAPKT; ///SD card address CMD command bytes MUX

wire [7:0] MUXERCYFIFO; ///ERCY file vector bytes MUX

wire [7:0] LCDCHAR0; ///LCD char 0 
wire [7:0] LCDCHAR1; ///LCD char 1 
wire [7:0] LCDCHAR2; ///LCD char 2 
wire [7:0] LCDCHAR3; ///LCD char 3 
wire [7:0] LCDCHAR4; ///LCD char 4 
wire [7:0] LCDCHAR5; ///LCD char 5 
wire [7:0] LCDCHAR6; ///LCD char 6 
wire [7:0] LCDCHAR7; ///LCD char 7 
wire [7:0] LCDCHAR8; ///LCD char 8 
wire [7:0] LCDCHAR9; ///LCD char 9 
wire [7:0] LCDCHAR10; ///LCD char 10 
wire [7:0] LCDCHAR11; ///LCD char 11 
wire [7:0] LCDCHAR12; ///LCD char 12
wire [7:0] LCDCHAR13; ///LCD char 13
wire [7:0] LCDCHAR14; ///LCD char 14
wire [7:0] LCDCHAR15; ///LCD char 15
wire [7:0] LCDCHAR16; ///LCD char 16
wire [7:0] LCDCHAR17; ///LCD char 17
wire [7:0] LCDCHAR18; ///LCD char 18
wire [7:0] LCDCHAR19; ///LCD char 19
wire [7:0] LCDCHAR20; ///LCD char 20
wire [7:0] LCDCHAR21; ///LCD char 21
wire [7:0] LCDCHAR22; ///LCD char 22
wire [7:0] LCDCHAR23; ///LCD char 23
wire [7:0] LCDCHAR24; ///LCD char 24
wire [7:0] LCDCHAR25; ///LCD char 25
wire [7:0] LCDCHAR26; ///LCD char 26
wire [7:0] LCDCHAR27; ///LCD char 27
wire [7:0] LCDCHAR28; ///LCD char 28
wire [7:0] LCDCHAR29; ///LCD char 29
wire [7:0] LCDCHAR30; ///LCD char 30
wire [7:0] LCDCHAR31; ///LCD char 31

wire [23:0] AVCFEX; ///AVC file extention "avc" string

wire [7:0] AVCFNAME0; ///AVC File Name char 0
wire [7:0] AVCFNAME1; ///AVC File Name char 1
wire [7:0] AVCFNAME2; ///AVC File Name char 2
wire [7:0] AVCFNAME3; ///AVC File Name char 3
wire [7:0] AVCFNAME4; ///AVC File Name char 4
wire [7:0] AVCFNAME5; ///AVC File Name char 5
wire [7:0] AVCFNAME6; ///AVC File Name char 6
wire [7:0] AVCFNAME7; ///AVC File Name char 7

wire [7:0] SGNLCHAR0; ///ERCY file Signal name char 0
wire [7:0] SGNLCHAR1; ///ERCY file Signal name char 1
wire [7:0] SGNLCHAR2; ///ERCY file Signal name char 2
wire [7:0] SGNLCHAR3; ///ERCY file Signal name char 3
wire [7:0] SGNLCHAR4; ///ERCY file Signal name char 4
wire [7:0] SGNLCHAR5; ///ERCY file Signal name char 5
wire [7:0] SGNLCHAR6; ///ERCY file Signal name char 6
wire [7:0] SGNLCHAR7; ///ERCY file Signal name char 7
wire [7:0] SGNLCHAR8; ///ERCY file Signal name char 8
wire [7:0] SGNLCHAR9; ///ERCY file Signal name char 9
wire [7:0] SGNLCHAR10; ///ERCY file Signal name char 10
wire [7:0] SGNLCHAR11; ///ERCY file Signal name char 11
wire [7:0] SGNLCHAR12; ///ERCY file Signal name char 12
wire [7:0] SGNLCHAR13; ///ERCY file Signal name char 13
wire [7:0] SGNLCHAR14; ///ERCY file Signal name char 14
wire [7:0] SGNLCHAR15; ///ERCY file Signal name char 15
wire [7:0] SGNLCHAR16; ///ERCY file Signal name char 16
wire [7:0] SGNLCHAR17; ///ERCY file Signal name char 17
wire [7:0] SGNLCHAR18; ///ERCY file Signal name char 18
wire [7:0] SGNLCHAR19; ///ERCY file Signal name char 19
wire [7:0] SGNLCHAR20; ///ERCY file Signal name char 20
wire [7:0] SGNLCHAR21; ///ERCY file Signal name char 21
wire [7:0] SGNLCHAR22; ///ERCY file Signal name char 22
wire [7:0] SGNLCHAR23; ///ERCY file Signal name char 23
wire [7:0] SGNLCHAR24; ///ERCY file Signal name char 24
wire [7:0] SGNLCHAR25; ///ERCY file Signal name char 25
wire [7:0] SGNLCHAR26; ///ERCY file Signal name char 26
wire [7:0] SGNLCHAR27; ///ERCY file Signal name char 27
wire [7:0] SGNLCHAR28; ///ERCY file Signal name char 28
wire [7:0] SGNLCHAR29; ///ERCY file Signal name char 29
wire [7:0] SGNLCHAR30; ///ERCY file Signal name char 30
wire [7:0] SGNLCHAR31; ///ERCY file Signal name char 31

wire [127:0] TRSTPSGNL; ///Output enable signals for bidirectional SGNL

wire [127:0] SGNL_IN; ///Input signal buffer from SGNL

wire [15:0] WDCNTR; ///Word counter

wire [31:0] SDRDOUT; ///SDRAM DQ out

wire [31:0] SDRDIN; ///SDRAM DQ in

wire [31:0] VECTOROUT; ///AVC error vectors numbers FIFO output
wire WSGNLOUT; ///Expected signal from SNGL lines FIFO output 
wire GSGNLOUT; ///Received signal from SGNL lines FIFO output

wire [31:0] SDRPSGNL; ///SDRAM Parallel signal
wire [31:0] SDRTSGNL; ///SDRAM State signals of 3-state signals

wire [7:0] SGNLNMNUM; ///Signal name num from avchdrhdlr

wire tcvcptdnex; ///tranceive packet done extented packet from CMD SD card line (more than 48 bits)
wire csbdone; ///CMD line shift byte done 
wire cse; ///CMD line shift enable
wire tcvdptdnex; ///tranceive packet done extented packet from DAT SD card line (more than SECTOR_SIZE)
wire isdpkten; ///only data packet on DAT line, not write acknowledge low signal
wire dsbdone; ///DAT line shift byte done 
wire dswdone; ///Data DQ set word done
wire dse; ///DAT line shift enable 

wire CMDSO; ///CMD shift output register line
wire cbload; ///load new CMD packet byte
wire cmuxl; //MUX low byte output shift reg write enable on CMD line
wire cmuxh; //MUX high byte output shift reg write enable on CMD line

wire DATASO; ///output of shift output register on DAT line
wire dbload; ///load next byte in data transmit shift register on DAT line
wire dsbit; ///load start bit byte signal on output shift register on DAT line
wire dnull; ///load NULL byte on output shift transmit register on DAT line
wire crc16l; ///load CRC16 low byte on output shift on DAT line
wire crc16h; ///load CRC16 high byte on output shift on DAT line
wire ercyfifo; ///load ERCY data bytes in vectors from MUX on DAT line 
wire fatram; ///load FAT1 or FAT2 tables data from buffer on DAT line
wire ercyfram; ///load FAT files table with ERCY file record in output shift register on DAT line

wire pwuptmrstop; ///power-up timer stop signal afer reset SD card
wire cmd0null; ///SD card capacity status in OCR register == 0
wire vrngeapply; ///voltage range applyed by SD card
wire lasterr; //last error on CMD SD card transaction
wire acmd41fst; ///first ACMD41 signal indicator
wire sdinitlzd; ///SD initialized indicator
wire mstotout; ///initialize by ACMD41 timeout timer
wire endpkt; ///end data packet (8'hFF and CRC16) indicator (inverse, 0 - active) 
wire fat32valid; ///Partition type and FAT32 adress valid in MBR on SD card
wire f32fat1valid; ///FAT1 address not null
wire f32avcsvalid; ///FAT files table address not null
wire f32bpsvalid; ///FAT bytes per sector == SECTOR_SIZE - 3 (endpkt)

wire eofavc; ///AVC End-of-File signal
wire isfatend; ///32'hFFFFFF0F was found in FAT table
wire fsprmp1en; ///FAT_SET_PARAM_P1 state indicator
wire fatp1done; ///R_FATECNTR == 16'h200 
wire dlwe; ///DAT line not busy 
wire eclcntrnull; ///ERCY cluster counter == 0 

wire ercyfnmnull; /// ERCY file filename null
wire ercyfnme; ///ERCY file filename empty
wire ercyfnminvld; ///ERCY file filename invalid

wire avcfnminvld; ///AVC file filename invalid

wire cmdoe; ///CMD SD card line output enable
wire doe; ///DATA SD card line output enable

wire oen; ///output enable on DQ line for SDRAM transmitter

wire tsvec; ///current vector have 3-state signal

wire eofavcfnd; ///AVC file End-of-File found signal in packet 
 
wire resprdspntr; ///Reset AVC file sector pointer

wire notstsgnls; ///No 3-state signals in AVC file

wire nextsgnl; ///read next ERCY vector's data in FIFO
 
wire ercylstvec; ///ERCY last char data in vector 

wire cmpdone; ///End of test

reg [6:0] R_ST_INIT; ///State machine relate to CMD SD card line
reg [4:0] R_ST_FS; ///State machine relate to DAT SD card line

wire [15:0] PUBRCA; ///Public RCA SD card address on SD card bus

/////////////////////////////////////AVC SIGNAL///////////////////////////////

assign SGNL_OUT[0] = SDRPSGNL[0];////AVC signal 1
assign SGNL_OUT[1] = SDRPSGNL[1];////AVC signal 2
assign SGNL_OUT[2] = SDRPSGNL[2];////AVC signal 3
assign SGNL_OUT[3] = SDRPSGNL[3];////AVC signal 4 
assign SGNL_OUT[4] = SDRPSGNL[4];////AVC signal 5
assign SGNL_OUT[5] = SDRPSGNL[5];////AVC signal 6
assign SGNL_OUT[6] = SDRPSGNL[6];////AVC signal 7
assign SGNL_OUT[7] = SDRPSGNL[7];////AVC signal 8
assign SGNL_OUT[8] = SDRPSGNL[8];////AVC signal 9
assign SGNL_OUT[9] = SDRPSGNL[9];////AVC signal 10
assign SGNL_OUT[10] = SDRPSGNL[10];////AVC signal 11
assign SGNL_OUT[11] = SDRPSGNL[11];////AVC signal 12
assign SGNL_OUT[12] = SDRPSGNL[12];////AVC signal 13
assign SGNL_OUT[13] = SDRPSGNL[13];////AVC signal 14
assign SGNL_OUT[14] = SDRPSGNL[14];////AVC signal 15
assign SGNL_OUT[15] = SDRPSGNL[15];////AVC signal 16
assign SGNL[0] = !SDRTSGNL[16] ? SDRPSGNL[16] : 1'bz;////AVC signal 17
assign SGNL[1] = !SDRTSGNL[17] ? SDRPSGNL[17] : 1'bz;////AVC signal 18
assign SGNL[2] = !SDRTSGNL[18] ? SDRPSGNL[18] : 1'bz;////AVC signal 19
assign SGNL[3] = !SDRTSGNL[19] ? SDRPSGNL[19] : 1'bz;////AVC signal 20
assign SGNL[4] = !SDRTSGNL[20] ? SDRPSGNL[20] : 1'bz;////AVC signal 21
assign SGNL[5] = !SDRTSGNL[21] ? SDRPSGNL[21] : 1'bz;////AVC signal 22
assign SGNL[6] = !SDRTSGNL[22] ? SDRPSGNL[22] : 1'bz;////AVC signal 23
assign SGNL[7] = !SDRTSGNL[23] ? SDRPSGNL[23] : 1'bz;////AVC signal 24
assign SGNL[8] = !SDRTSGNL[24] ? SDRPSGNL[24] : 1'bz;////AVC signal 25
assign SGNL[9] = !SDRTSGNL[25] ? SDRPSGNL[25] : 1'bz;////AVC signal 26
assign SGNL[10] = !SDRTSGNL[26] ? SDRPSGNL[26] : 1'bz;////AVC signal 27
assign SGNL[11] = !SDRTSGNL[27] ? SDRPSGNL[27] : 1'bz;////AVC signal 28
assign SGNL[12] = !SDRTSGNL[28] ? SDRPSGNL[28] : 1'bz;////AVC signal 29
assign SGNL[13] = !SDRTSGNL[29] ? SDRPSGNL[29] : 1'bz;////AVC signal 30
assign SGNL[14] = !SDRTSGNL[30] ? SDRPSGNL[30] : 1'bz;////AVC signal 31
assign SGNL[15] = !SDRTSGNL[31] ? SDRPSGNL[31] : 1'bz;////AVC signal 32 

assign SDRTSGNL[0] = 1'b0;
assign SDRTSGNL[1] = 1'b0;
assign SDRTSGNL[2] = 1'b0;
assign SDRTSGNL[3] = 1'b0;
assign SDRTSGNL[4] = 1'b0;
assign SDRTSGNL[5] = 1'b0;
assign SDRTSGNL[6] = 1'b0;
assign SDRTSGNL[7] = 1'b0;
assign SDRTSGNL[8] = 1'b0;
assign SDRTSGNL[9] = 1'b0;
assign SDRTSGNL[10] = 1'b0;
assign SDRTSGNL[11] = 1'b0;
assign SDRTSGNL[12] = 1'b0;
assign SDRTSGNL[13] = 1'b0;
assign SDRTSGNL[14] = 1'b0;
assign SDRTSGNL[15] = 1'b0;

///Clock signals 
assign clk = sysclk;
assign sdclk = clk;
assign nsdclk = ~clk;
assign nsysfclk = ~sysfclk;
assign O_SD_CLK = sdclk;
//Other 3 DATA lines not used in this version
assign SD_DAT[3:1] = 3'bz;
//CMD input/output stage
assign SD_CMD = cmdoe ? CMDSO : 1'bz;
assign scmdinput = cmdoe ? 1'bz : SD_CMD;
//DATA input/output stage
assign SD_DAT[0] = doe ? DATASO : 1'bz;
assign sdatainput = doe ? 1'bz : SD_DAT[0]; 
assign DQ = sdroe ? SDRDOUT : 32'hz;
assign SDRDIN = sdroe ? 32'hz : DQ;
///DATA end packet and is packet enable indicators
assign endpkt = PTDATAPNTR != SECTOR_SIZE & PTDATAPNTR != SECTOR_SIZE-1 & PTDATAPNTR != SECTOR_SIZE-2;
assign isdpkten = R_ST_FS != ERCY_WRITE_ACK & R_ST_FS != FAT_WRITE_ACK;
///DATA tx write enable signals
assign dsbit = (R_ST_FS == ERCY_WRITE_DATA | R_ST_FS == ERCY_WRITE_NULL) & PTDATAPNTR == 16'h00; //Start bit of packet (FE byte) output reg wr enable
assign dnull = (R_ST_FS == ERCY_WRITE_DATA | R_ST_FS == ERCY_WRITE_NULL) & (ercyfempty & ercylstvec) & endpkt; //Null byte output reg wr enable
assign crc16h = (R_ST_FS == ERCY_WRITE_DATA | R_ST_FS == ERCY_WRITE_NULL | R_ST_FS == FAT_WRITE_PARAM 
| R_ST_FS == ERCY_WRITE_FILE) & PTDATAPNTR == SECTOR_SIZE-2; //CRC16 high byte output reg wr enable
assign crc16l = (R_ST_FS == ERCY_WRITE_DATA | R_ST_FS == ERCY_WRITE_NULL 
| R_ST_FS == FAT_WRITE_PARAM | R_ST_FS == ERCY_WRITE_FILE) & PTDATAPNTR == SECTOR_SIZE-1; //CRC16 low byte output reg wr enable
assign fatram = (R_ST_FS == FAT_WRITE_PARAM) & endpkt; //FAT table RAM output reg wr enable
///CMD tx write enable signals
assign cmuxl = R_ST_INIT == CMD17 | R_ST_INIT == CMD18 | R_ST_INIT == CMD24; //MUX low byte output reg wr enable
assign cmuxh = R_ST_INIT == CMD7 | R_ST_INIT == CMD13; //MUX high byte output reg wr enable
///Transmit/receive done signals (for extended packets)
assign tcvdptdnex = (R_ST_FS == ERCY_WRITE_DATA | R_ST_FS == ERCY_WRITE_NULL | R_ST_FS == FAT_WRITE_PARAM | R_ST_FS == ERCY_WRITE_FILE); //DATA extended packet
assign tcvcptdnex = (R_ST_INIT == R2); //CMD extended packet
///DATA & CMD shift enable signals
assign dse = R_ST_FS == MBR_READ_PARAM | R_ST_FS == FAT32_READ_PARAM | R_ST_FS == FAT_READ_PARAM | R_ST_FS == AVC_READ_DATA |
R_ST_FS == AVC_READ_FILE | R_ST_FS == ERCY_WRITE_DATA | R_ST_FS == ERCY_WRITE_NULL | R_ST_FS == FAT_WRITE_PARAM | 
R_ST_FS == ERCY_WRITE_FILE | R_ST_FS == ERCY_READ_FILE; 
assign cse = R_ST_INIT != START_INIT & R_ST_INIT != POWER_UP; 

assign usravcrduws = usravcread & R_ST_FS == USER_WAIT_START; /* read button is blocked after start, 
	reset button is only working
	it is only for future multiple (more than 1) AVC files*/
///DATA tx ERCY data write enable signals
assign ercyfifo = R_ST_FS == ERCY_WRITE_DATA & !(ercyfempty & ercylstvec) & endpkt; //ERCY DATA FIFO output reg wr enable
assign ercyfram = (R_ST_FS == ERCY_WRITE_FILE) & endpkt; //ERCY FAT file table RAM output reg wr enable
//ERCY rd enable DATA FIFO

////////////////////////////////////////STATE LEDS/////////////////////////////////////////////

assign O_TESTLEDR[0] = R_ST_INIT == CMD0; ///LEDR0
assign O_TESTLEDR[1] = R_ST_INIT == CMD8; ///LEDR1
assign O_TESTLEDR[2] = R_ST_INIT == ACMD41; ///LEDR2
assign O_TESTLEDR[3] = R_ST_INIT == CMD55; ///LEDR3
assign O_TESTLEDR[4] = R_ST_INIT == R7; ///LEDR4
assign O_TESTLEDR[5] = R_ST_INIT == R1; ///LEDR5
assign O_TESTLEDR[6] = R_ST_INIT == START_INIT; ///LEDR6
assign O_TESTLEDR[7] = R_ST_INIT == CMD7; ///LEDR7
assign O_TESTLEDR[8] = R_ST_INIT == EXIT; ///LEDR8

assign O_TESTLEDR[9] = R_ST_FS == FAT_WRITE_PARAM; ///LEDR9
assign O_TESTLEDR[10] = R_ST_FS == FAT_WRITE_ACK; ///LEDR10
assign O_TESTLEDR[11] = R_ST_FS == FAT_SET_PARAM_P1; ///LEDR11
assign O_TESTLEDR[12] = R_ST_FS == FAT_SET_PARAM_P2; ///LEDR12
assign O_TESTLEDR[13] = R_ST_FS == AVC_GET_DATA; ///LEDR13
assign O_TESTLEDR[14] = R_ST_FS == AVC_READ_DATA; ///LEDR14
assign O_TESTLEDR[15] = R_ST_FS == AVC_GET_FILE; ///LEDR15
assign O_TESTLEDR[16] = R_ST_FS == AVC_READ_FILE; ///LEDR16
assign O_TESTLEDR[17] = R_ST_FS == ERCY_SET_DATA; ///LEDR17

assign O_TESTLEDG[0] = R_ST_FS == ERCY_WRITE_DATA; ///LEDG0
assign O_TESTLEDG[1] = R_ST_FS == ERCY_WRITE_NULL; ///LEDG1
assign O_TESTLEDG[2] = R_ST_FS == ERCY_WRITE_ACK; ///LEDG2
assign O_TESTLEDG[3] = R_ST_FS == ERCY_SET_FILE; ///LEDG3
assign O_TESTLEDG[4] = R_ST_FS == ERCY_WRITE_FILE; ///LEDG4
assign O_TESTLEDG[5] = R_ST_FS == USER_WAIT_NEXT; ///LEDG5
assign O_TESTLEDG[6] = R_ST_FS == ERCY_GET_FILE; ///LEDG6
assign O_TESTLEDG[7] = R_ST_FS == ERCY_READ_FILE; ///LEDG7

//////////////////////////////////////////PLL////////////////////////////////////////////////////	 

///Generated PLL optional, for frequency lower than input
altpll1 avcpll(
	.inclk0(I_CLOCK_50),
	.c0(sysclk),
	.c1(sysfclk),
	.c2(userclk),
	.c3(dqfifoclk)
); 

/*//For RTL simulation
assign sysclk = I_CLOCK_35;
assign sysfclk = I_CLOCK_140;
assign nsysfclk = ~I_CLOCK_140;*/
/*sdrclkout_iobuf_out_40t sdrclkout(
	.datain(sysfclk),
	.dataout(O_SDR_CLK)
);*/
assign O_SDR_CLK = sysfclk;
//////////////////////////////////////////CRC////////////////////////////////////////////////////	 
//////////CRC7 for CMD packets on CMD line 
CRC7 crc7calc(
	.RESET(sysres),
	.BITVAL(CMDSO),
	.BITSTRB(sdclk),
	.CLEAR(PTCMDPNTR == 5'b00000),
	.CRC7OUT(CRC7OUT)
);  
//////////CRC16 for DATA packets on DAT line
CRC16 crc16calc(
	.RESET(sysres),
	.BITVAL(DATASO),
	.BITSTRB(sdclk),
	.CLEAR(PTDATAPNTR == 16'h0001),
	.CRC16OUT(CRC16OUT)
);  

//////////////////////////////////////////TS BUFFER CONTROL////////////////////////////////////////////////////
//////////3-state buffer controller for CMD and DAT SD card lines
tsctrl tsctrl(
	.clk(sdclk),
	.reset(sysres),
	.cmdtsen(R_ST_INIT == CMD0 | R_ST_INIT == CMD7 | R_ST_INIT == CMD8 
	| R_ST_INIT == FIRST_ACMD41 | R_ST_INIT == ACMD41 | R_ST_INIT == CMD55 | R_ST_INIT == CMD2 | R_ST_INIT == CMD3 
	| R_ST_INIT == CMD9 | R_ST_INIT == CMD12 | R_ST_INIT == CMD13 | R_ST_INIT == CMD17 | R_ST_INIT == CMD18 
	| R_ST_INIT == CMD23 | R_ST_INIT == CMD24),
	.dtsen(R_ST_FS == ERCY_WRITE_DATA | R_ST_FS == ERCY_WRITE_NULL | R_ST_FS == FAT_WRITE_PARAM 
	| R_ST_FS == ERCY_WRITE_FILE),
	.tcvcptdone(tcvcptdone),
	.tcvdptdone(tcvdptdone),
	.cmdoe(cmdoe),
	.doe(doe)
);

//////////////////////////////////////////SD MEMORY ADDRESS CONTROL///////////////////////////////////////////
//////////SD card memory sector address controller
sdmemaddr sdmemaddr(
	.clk(sdclk),
	.reset(sysres),
	.ureset(usravcrduws),
	.avcrfen(R_ST_FS == AVC_READ_FILE),
	.ercyrfen(R_ST_FS == ERCY_READ_FILE),
	.avcrden(R_ST_FS == AVC_READ_DATA),
	.ercywden(R_ST_FS == ERCY_WRITE_DATA),
	.eofercy(eofercy),
	.resprdspntr(resprdspntr),
	.f32gprmen(R_ST_FS == FAT32_GET_PARAM),
	.fgprmen(R_ST_FS == FAT_GET_PARAM),
	.ercygfen(R_ST_FS == ERCY_GET_FILE),
	.avcgfen(R_ST_FS == AVC_GET_FILE),
	.fsprmp1en(R_ST_FS == FAT_SET_PARAM_P1),
	.avcgden(R_ST_FS == AVC_GET_DATA),
	.ercysden(R_ST_FS == ERCY_SET_DATA),
	.ercysfen(R_ST_FS == ERCY_SET_FILE),
	.ercywnullen(R_ST_FS == ERCY_WRITE_NULL),
	.isfat2(isfat2),
	.tcvdptdone(tcvdptdone),
	.FAT32SA(FAT32SA),
	.FAT1SA(FAT1SA),
	.FAT2SA(FAT2SA),
	.FATSACNTR(FATSACNTR),
	.FATSIZE(FATSIZE),
	.AVCFSEC(AVCFSEC),
	.FROOTSEC(FROOTSEC),
	.ERCYFSEC(ERCYFSEC),
	.DADDR(DADDR),
	.PTNULLCNTR(ERCYNCNTR),
	.PTWDSECPNTR(PTWDSECPNTR)
);

//////////////////////////////////////////SD PACKET ROM MEMORY////////////////////////////////////////////	 
//////////CMD unchengeable packets bytes ROM
sdpktrom sdpktrom(
	.clk(sdclk),
	.nclk(nsdclk),
	.reset(sysres),
	.tcvcptdone(tcvcptdone),
	.acmd41fst(acmd41fst),
	.sdinitlzd(sdinitlzd),
	.pupst(R_ST_INIT == POWER_UP),
	.strtinitst(R_ST_INIT == START_INIT),
	.cmd0st(R_ST_INIT == CMD0),
	.cmd8st(R_ST_INIT == CMD8),
	.facmd41st(R_ST_INIT == FIRST_ACMD41),
	.cmd55st(R_ST_INIT == CMD55),
	.r3st(R_ST_INIT == R3),
	.cmd2st(R_ST_INIT == CMD2),
	.cmd3st(R_ST_INIT == CMD3),
	.cmd9st(R_ST_INIT == CMD9),
	.cmd7st(R_ST_INIT == CMD7),
	.cmd17st(R_ST_INIT == CMD17),
	.PTCMDPNTR(PTCMDPNTR),
	.SDPKTDATA(SDPKTDATA)
);

//////////////////////////////////////////USER////////////////////////////////////////////////////	 
//////////user button debouncer 
userctrl userctrl(
	.clk(sdclk),
	.breset(I_RESET),
	.bread(I_READ),
	.dreset(sysres),
	.dread(usravcread)
);

//////////7-seg indicator controller
user7seg user7seg(
	.clk(userclk),
	.clkfast(sdclk),
	.reset(sysres),
	.load(R_ST_FS == ERCY_WRITE_DATA),
	.rd(R_ST_FS == USER_WAIT_NEXT),
	.NUM(ERCYVECNTR),
	.HEX0(O_HEX0),
	.HEX1(O_HEX1),
	.HEX2(O_HEX2),
	.HEX3(O_HEX3),
	.HEX4(O_HEX4),
	.HEX5(O_HEX5),
	.HEX6(O_HEX6),
	.HEX7(O_HEX7)
);

//////////LCD display controller
userlcd userlcd(
	.clk(userclk),
	.reset(sysres),
	.dispres(R_ST_FS == MBR_START | R_ST_FS == USER_WAIT_START | R_ST_FS == AVC_GET_DATA | R_ST_FS == ERCY_SET_DATA |
	R_ST_FS == ERCY_SET_FILE | R_ST_FS == USER_WAIT_NEXT | R_ST_FS == AVC_GET_FILE),
	.CHAR0(LCDCHAR0),
	.CHAR1(LCDCHAR1),
	.CHAR2(LCDCHAR2),
	.CHAR3(LCDCHAR3),
	.CHAR4(LCDCHAR4),
	.CHAR5(LCDCHAR5),
	.CHAR6(LCDCHAR6),
	.CHAR7(LCDCHAR7),
	.CHAR8(LCDCHAR8),
	.CHAR9(LCDCHAR9),
	.CHAR10(LCDCHAR10),
	.CHAR11(LCDCHAR11),
	.CHAR12(LCDCHAR12),
	.CHAR13(LCDCHAR13),
	.CHAR14(LCDCHAR14),
	.CHAR15(LCDCHAR15),
	.CHAR16(LCDCHAR16),
	.CHAR17(LCDCHAR17),
	.CHAR18(LCDCHAR18),
	.CHAR19(LCDCHAR19),
	.CHAR20(LCDCHAR20),
	.CHAR21(LCDCHAR21),
	.CHAR22(LCDCHAR22),
	.CHAR23(LCDCHAR23),
	.CHAR24(LCDCHAR24),
	.CHAR25(LCDCHAR25),
	.CHAR26(LCDCHAR26),
	.CHAR27(LCDCHAR27),
	.CHAR28(LCDCHAR28),
	.CHAR29(LCDCHAR29),
	.CHAR30(LCDCHAR30),
	.CHAR31(LCDCHAR31),
	.LCD_DATA(O_LCD_DATA),
	.LCD_BLON(O_LCD_BLON),
	.LCD_EN(O_LCD_EN),
	.LCD_ON(O_LCD_ON),
	.LCD_RS(O_LCD_RS),
	.LCD_RW(O_LCD_RW)
);

//////////Ready LED controller
userled userled(
	.clk(userclk),
	.reset(sysres),
	.en(R_ST_FS == USER_WAIT_NEXT),
	.ULED(O_LEDONE)
);

//////////Information on LCD
userdebug userdebug(
	.mbrstrten(R_ST_FS == MBR_START),
	.ercywsfen(R_ST_FS == ERCY_WRITE_FILE | R_ST_FS == ERCY_SET_FILE),
	.ercywsden(R_ST_FS == ERCY_WRITE_DATA | R_ST_FS == ERCY_SET_DATA),
	.userwstrten(R_ST_FS == USER_WAIT_START),
	.userwnexten(R_ST_FS == USER_WAIT_NEXT),
	.avcgrden(R_ST_FS == AVC_READ_DATA | R_ST_FS == AVC_GET_DATA),
	.eofavcfnd(eofavcfnd),
	.notstsgnls(notstsgnls),
	.AVCFEX(AVCFEX),
	.AVCFNAME0(AVCFNAME0),
	.AVCFNAME1(AVCFNAME1),
	.AVCFNAME2(AVCFNAME2),
	.AVCFNAME3(AVCFNAME3),
	.AVCFNAME4(AVCFNAME4),
	.AVCFNAME5(AVCFNAME5),
	.AVCFNAME6(AVCFNAME6),
	.AVCFNAME7(AVCFNAME7),
	.CHAR0(LCDCHAR0),
	.CHAR1(LCDCHAR1),
	.CHAR2(LCDCHAR2),
	.CHAR3(LCDCHAR3),
	.CHAR4(LCDCHAR4),
	.CHAR5(LCDCHAR5),
	.CHAR6(LCDCHAR6),
	.CHAR7(LCDCHAR7),
	.CHAR8(LCDCHAR8),
	.CHAR9(LCDCHAR9),
	.CHAR10(LCDCHAR10),
	.CHAR11(LCDCHAR11),
	.CHAR12(LCDCHAR12),
	.CHAR13(LCDCHAR13),
	.CHAR14(LCDCHAR14),
	.CHAR15(LCDCHAR15),
	.CHAR16(LCDCHAR16),
	.CHAR17(LCDCHAR17),
	.CHAR18(LCDCHAR18),
	.CHAR19(LCDCHAR19),
	.CHAR20(LCDCHAR20),
	.CHAR21(LCDCHAR21),
	.CHAR22(LCDCHAR22),
	.CHAR23(LCDCHAR23),
	.CHAR24(LCDCHAR24),
	.CHAR25(LCDCHAR25),
	.CHAR26(LCDCHAR26),
	.CHAR27(LCDCHAR27),
	.CHAR28(LCDCHAR28),
	.CHAR29(LCDCHAR29),
	.CHAR30(LCDCHAR30),
	.CHAR31(LCDCHAR31)
); 

//////////////////////////////////////////CMD LINE////////////////////////////////////////////////////	
//////////MUX for changeable CMD packets 
cmdmux cmdmux(
	.DADDR(DADDR),
	.CMDN(CMDN),
	.PTCMDPNTR(PTCMDPNTR),
	.PUBRCA(PUBRCA),
	.CRC7(CRC7OUT),
	.MUXDADDRPKT(MUXDADDRPKT),
	.MUXDPRCAPKT(MUXDPRCAPKT)
); 

//////////CMD line controller, cmdtx & cmdrx driver
cmdctrl cmdctrl(
	.clk(sdclk),
	.reset(sysres),
	.oe(cmdoe), 
	.se(cse),
	.cmdin(SD_CMD),
	.tcvcptdnex(tcvcptdnex),
	.tcvcptdone(tcvcptdone),
	.sbdone(csbdone),
	.bload(cbload),
	.PTCMDPNTR(PTCMDPNTR)
);

//////////CMD input stage (input shift register)
cmdrx cmdrx(
	.clk(sdclk),
	.reset(sysres),
	.oe(cmdoe),
	.scmdin(scmdinput),
	.CMDSI(CMDSI)
);

//////////CMD output stage (output shift register)
cmdtx cmdtx(
	.clk(sdclk),
	.reset(sysres),
	.oe(cmdoe),
	.load(cbload),
	.MUXL(MUXDADDRPKT),
	.MUXH(MUXDPRCAPKT),
	.romdata(SDPKTDATA),
	.muxl(cmuxl),
	.muxh(cmuxh),
	.CMDSO(CMDSO)
);

//////////////////////////////////////////CMD NUMBER//////////////////////////////////////////////////
//////////CMD packet number (CMDn, where n = 0,1,2 ...) from SD specification
cmdnum cmdnum(
	.clk(sdclk),
	.reset(sysres),
	.cmd7st(R_ST_INIT == CMD7),
	.cmd12st(R_ST_INIT == CMD12),
	.cmd13st(R_ST_INIT == CMD13),
	.cmd17st(R_ST_INIT == CMD17),
	.cmd18st(R_ST_INIT == CMD18),
	.cmd23st(R_ST_INIT == CMD23),
	.cmd24st(R_ST_INIT == CMD24),
	.CMDN(CMDN)
);

//////////////////////////////////////////DATA LINE////////////////////////////////////////////////////	 
//////////DATA line contoller, datarx & datatx driver
datactrl #(SECTOR_SIZE) datactrl(
	.clk(sdclk),
	.reset(sysres),
	.oe(doe),
	.datain(sdatainput),
	.se(dse),
	.tcvdptdnex(tcvdptdnex),
	.isdpkten(isdpkten),
	.SDLNSTS(SDLNSTS),
	.tcvdptdone(tcvdptdone), 
	.sbdone(dsbdone),
	.bload(dbload),
	.isdpkt(isdpkt),
	.lwe(dlwe),
	.PTDATAPNTR(PTDATAPNTR)
);

//////////DATA input stage (input shift register)
datarx datarx(
	.clk(sdclk),
	.reset(sysres),
	.oe(doe),
	.sdatain(sdatainput),
	.DATASI(DATASI)
);

//////////DATA output stage (output shift register)
datatx datatx(
	.clk(sdclk),
	.reset(sysres),
	.oe(doe),
	.load(dbload),
	.sbit(dsbit),
	.null(dnull),
	.crc16l(crc16l),
	.crc16h(crc16h),
	.fifo(ercyfifo),
	.ram1(fatram),
	.ram2(ercyfram),
	.CRC16(CRC16OUT),
	.FIFODATA(MUXERCYFIFO),
	.RAM1DATA(FATLSRDATA),
	.RAM2DATA(ERCYFLSRDATA),
	.DATASO(DATASO)
);

//////////////////////////////////////////SDRAM MEMORY LINE////////////////////////////////////////////
//////////SDRAM Transmitter from SD CARD to SDRAM
sdramtx sdramtx(
	.reset(sysres),
	.clk(sysfclk),
	.we(DATASI == 8'h0A & dsbdone & (R_ST_FS == AVC_READ_DATA) & endpkt & isdpkt & eofavcfnd & AVCVECNTR != 0),
	.oen(oen),
	.WDCNTR(WDCNTR),
	.DATAIN0(AVCPSGNL[15:0]),
	.DATAIN1(AVCPSGNL[31:16]),
	.DATAIN2(TRSTPSGNL[31:16]),
	.DATAOUT(SDRDOUT)
);
//////////SDRAM Receiver from SDRAM to Signals on IDE Connector
sdramrx sdramrx(
	.clk(sysfclk),
	.dqfifoclk(dqfifoclk),
	.reset(sysres),
	.rdbstdrdy(rdbstdrdy),
	.WDCNTR(WDCNTR),
	.DATAIN(SDRDIN),
	.swdone(dswdone),
	.PARDOUT0(SDRPSGNL), 
	.PARDOUT1(SDRTSGNL[31:16])
);
//////////SDRAM Controller 
sdramctrl sdramctrl(
	.reset(sysres),
	.clk(sysfclk),
	.eofavc(eofavc),
	.eofavcfnd(eofavcfnd),
	.we(DATASI == 8'h0A & dsbdone & (R_ST_FS == AVC_READ_DATA) & endpkt & isdpkt & eofavcfnd & AVCVECNTR != 0),
	.tcvdptdone(tcvdptdone),
	.avcrden(R_ST_FS == AVC_READ_DATA),
	.avcsndvec(R_ST_FS == AVC_SEND_VECTOR),
	.rdbstdrdy(rdbstdrdy),
	.cke(O_CKE),
	._cs(_O_CS),
	._ras(_O_RAS),
	._cas(_O_CAS),
	._we(_O_WE),
	.oen(oen),
	.oe(sdroe),
	.A(O_A),
	.BA(O_BA),
	.WDCNTR(WDCNTR),
	.DQM(O_DQM)
); 

//////////////////////////////////////////AVC PARSER////////////////////////////////////////////////////	 
//////////Parse signals from AVC file on SD CARD and brings them into parallel output form
avcparser avcparser(
	.clk(sdclk),
	.ureset(usravcrduws),
	.sbdone(dsbdone),
	.endpkt(endpkt),
	.isdpkt(isdpkt),
	.avcrden(R_ST_FS == AVC_READ_DATA),
	.DATASI(DATASI),
	.AVCVECNTR(AVCVECNTR),
	.AVCPSGNL(AVCPSGNL),
	.TRSTPSGNL(TRSTPSGNL),
	.HLPSGNL(HLPSGNL),
	.eofavc(eofavc),
	.eofavcfnd(eofavcfnd),
	.resprdspntr(resprdspntr),
	.notstsgnls(notstsgnls)
);

//////////////////////////////////////////AVC COMPARE////////////////////////////////////////////////////	 
//////////Compare signals from AVC file on SD CARD with signals on IDE connector from tested device
avcompare avcompare(
	.clk(sdclk),
	.nclk(nsdclk),
	.fclk(sysfclk),
	.nfclk(nsysfclk),
	.ureset(usravcrduws),
	.sbdone(dsbdone),
	.endpkt(endpkt),
	.isdpkt(isdpkt),
	.avcrden(R_ST_FS == AVC_READ_DATA),
	.avcsndvec(R_ST_FS == AVC_SEND_VECTOR),
	.errrd(nextsgnl),
	.nextfvec(rdbstdrdy),
	.nextsvec(dswdone),
	.eofavcfnd(eofavcfnd),
	.DATASI(DATASI),
	.SGNL(SGNL),
	.SDRPSGNL(SDRPSGNL),
	.SDRTSGNL(SDRTSGNL),
	.AVCVECNTR(AVCVECNTR),
	.HLPSGNL(HLPSGNL),
	.outempty(ercyfempty),
	.cmpdone(cmpdone),
	.VECTOROUT(VECTOROUT),
	.WSSGNLOUT(WSGNLOUT),
	.GSSGNLOUT(GSGNLOUT),
	.SGNLNMNUM(SGNLNMNUM)
);

/////////////////////////////AVC HEADER HANDLER (PARSER)//////////////////////////
//////////Parsing the header of AVC file and separate it on signal names
avchdrhdlr avchdrhdlr(
	.clk(sdclk),
	.nclk(nsdclk),
	.ureset(usravcrduws),
	.sbdone(dsbdone),
	.endpkt(endpkt),
	.isdpkt(isdpkt),
	.avcrden(R_ST_FS == AVC_READ_DATA),
	.eofavcfnd(eofavcfnd),
	.errrd(nextsgnl),
	.DATASI(DATASI),
	.AVCVECNTR(AVCVECNTR),
	.SGNLNMNUM(SGNLNMNUM),
	.SGNLCHAR0(SGNLCHAR0),
	.SGNLCHAR1(SGNLCHAR1),
	.SGNLCHAR2(SGNLCHAR2),
	.SGNLCHAR3(SGNLCHAR3),
	.SGNLCHAR4(SGNLCHAR4),
	.SGNLCHAR5(SGNLCHAR5),
	.SGNLCHAR6(SGNLCHAR6),
	.SGNLCHAR7(SGNLCHAR7),
	.SGNLCHAR8(SGNLCHAR8),
	.SGNLCHAR9(SGNLCHAR9),
	.SGNLCHAR10(SGNLCHAR10),
	.SGNLCHAR11(SGNLCHAR11),
	.SGNLCHAR12(SGNLCHAR12),
	.SGNLCHAR13(SGNLCHAR13),
	.SGNLCHAR14(SGNLCHAR14),
	.SGNLCHAR15(SGNLCHAR15),
	.SGNLCHAR16(SGNLCHAR16),
	.SGNLCHAR17(SGNLCHAR17),
	.SGNLCHAR18(SGNLCHAR18),
	.SGNLCHAR19(SGNLCHAR19),
	.SGNLCHAR20(SGNLCHAR20),
	.SGNLCHAR21(SGNLCHAR21),
	.SGNLCHAR22(SGNLCHAR22),
	.SGNLCHAR23(SGNLCHAR23),
	.SGNLCHAR24(SGNLCHAR24),
	.SGNLCHAR25(SGNLCHAR25),
	.SGNLCHAR26(SGNLCHAR26),
	.SGNLCHAR27(SGNLCHAR27),
	.SGNLCHAR28(SGNLCHAR28),
	.SGNLCHAR29(SGNLCHAR29),
	.SGNLCHAR30(SGNLCHAR30),
	.SGNLCHAR31(SGNLCHAR31)
);

//////////////////////////////////////////STATE MACHINE CONTROLS///////////////////////////////////////
//////////CMD line packets state machine controller
sdctrl sdsmctrl(
	.clk(sdclk),
	.reset(sysres),
	.sbdone(csbdone),
	.pwruptmren(R_ST_INIT == POWER_UP),
	.crdvtgrngewe(R_ST_INIT == R7),
	.pubrcast(R_ST_INIT == R6),
	.lasterrwe(R_ST_INIT == R7),
	.sdlnstswe(R_ST_INIT == R1),
	.sdcapstwe(R_ST_INIT == R3),
	.acmd41fstwe(R_ST_INIT == R3),
	.mstotmren(R_ST_INIT == ACMD41),
	.CMDSI(CMDSI),
	.PTCMDPNTR(PTCMDPNTR),
	.pwuptmrstop(pwuptmrstop),
	.cmd0null(cmd0null),
	.vrngeapply(vrngeapply),
	.lasterr(lasterr),
	.acmd41fst(acmd41fst),
	.sdinitlzd(sdinitlzd),
	.mstotout(mstotout),
	.tcvcptdone(tcvcptdone),
	.SDLNSTS(SDLNSTS),
	.PUBRCA(PUBRCA)
);

//////////MBR stage handler state machine controller
mbrctrl mbrsmctrl(
	.clk(sdclk),
	.reset(sysres),
	.sbdone(dsbdone),
	.mbrprmwe(R_ST_FS == MBR_READ_PARAM),
	.DATASI(DATASI),
	.PTDATAPNTR(PTDATAPNTR),
	.fat32valid(fat32valid),
	.FAT32SA(FAT32SA)
);

//////////FAT32 stage handler state machine controller
fat32ctrl #(SECTOR_SIZE) fat32smctrl(
	.clk(sdclk),
	.reset(sysres),
	.sbdone(dsbdone),
	.f32rprmen(R_ST_FS == FAT32_READ_PARAM),
	.DATASI(DATASI),
	.PTDATAPNTR(PTDATAPNTR),
	.f32bpsvalid(f32bpsvalid),
	.f32avcsvalid(f32avcsvalid),
	.f32fat1valid(f32fat1valid),
	.FAT1SA(FAT1SA),
	.FAT2SA(FAT2SA),
	.SPCLUST(SPCLUST),
	.FROOTSEC(FROOTSEC),
	.FATSIZE(FATSIZE)
);

//////////FAT tables (FAT1 and FAT2) stages controller
fatctrl fatsmctrl(
	.clk(sdclk),
	.nclk(nsdclk),
	.reset(sysres),
	.ureset(usravcrduws),
	.sbdone(dsbdone),
	.endpkt(endpkt),
	.isdpkt(isdpkt),
	.frprmen(R_ST_FS == FAT_READ_PARAM),
	.fsprmp1en(R_ST_FS == FAT_SET_PARAM_P1),
	.fwprm(R_ST_FS == FAT_WRITE_PARAM),
	.eoffwe(eclcntrnull),
	.fsprmp2en(R_ST_FS == FAT_SET_PARAM_P2),
	.fwacken(R_ST_FS == FAT_WRITE_ACK),
	.tcvdptdone(tcvdptdone),
	.lwe(dlwe),
	.tcvcptdoner1(R_ST_INIT == R1 & tcvcptdone),
	.DATASI(DATASI),
	.PTDATAPNTR(PTDATAPNTR),
	.isfatend(isfatend),
	.isfat2(isfat2),
	.fatp1done(fatp1done),
	.eoff(eoff),
	.fatecntrd(fatecntrd),
	.FATSTRTCA(FATSTRTCA),
	.FATSACNTR(FATSACNTR),
	.FATLSRDATA(FATLSRDATA)
);

//////////AVC file data stage state machine controller
avcctrl avcsmctrl(
	.clk(sdclk),
	.reset(sysres),
	.sbdone(dsbdone),
	.endpkt(endpkt),
	.isdpkt(isdpkt),
	.avcrfen(R_ST_FS == AVC_READ_FILE),
	.tcvdptdone(tcvdptdone),
	.SPCLUST(SPCLUST),
	.DATASI(DATASI),
	.PTDATAPNTR(PTDATAPNTR),
	.fnminvld(avcfnminvld), 
	.avcpktrf(avcpktrf),
	.AVCFSEC(AVCFSEC),
	.AVCFEX(AVCFEX),
	.STRNAME0(AVCFNAME0),
	.STRNAME1(AVCFNAME1),
	.STRNAME2(AVCFNAME2),
	.STRNAME3(AVCFNAME3),
	.STRNAME4(AVCFNAME4),
	.STRNAME5(AVCFNAME5),
	.STRNAME6(AVCFNAME6),
	.STRNAME7(AVCFNAME7)
);

//////////ERCY file data stage state machine controller
ercyctrl ercysmctrl(
	.clk(sdclk),
	.nclk(nsdclk),
	.reset(sysres),
	.ureset(usravcrduws),
	.sbdone(dsbdone),
	.bload(dbload),
	.isdpkt(isdpkt),
	.ercyrfen(R_ST_FS == ERCY_READ_FILE),
	.endpkt(endpkt),
	.ercywacken(R_ST_FS == ERCY_WRITE_ACK),
	.ercywnullen(R_ST_FS == ERCY_WRITE_NULL),
	.ercysdataen(R_ST_FS == ERCY_SET_DATA),
	.ercywdataen(R_ST_FS == ERCY_WRITE_DATA),
	.ercysfen(R_ST_FS == ERCY_SET_FILE),
	.ercyfwr(ercyfwr),
	.tcvdptdone(tcvdptdone),
	.tsvec(tsvec),
	.fatecntrd(fatecntrd),
	.fatp1done(fatp1done),
	.isfat2(isfat2),
	.fsprmp1en(R_ST_FS == FAT_SET_PARAM_P1),
	.ercyfsrr(avcpktrf),
	.ercyfempty(ercyfempty),
	.DATASI(DATASI),
	.PTDATAPNTR(PTDATAPNTR),
	.FATSTRTCA(FATSTRTCA),
	.SPCLUST(SPCLUST),
	.PTWDSECPNTR(PTWDSECPNTR),
	.VECTOROUT(VECTOROUT),
	.SGNLCHAR0(SGNLCHAR0),
	.SGNLCHAR1(SGNLCHAR1),
	.SGNLCHAR2(SGNLCHAR2),
	.SGNLCHAR3(SGNLCHAR3),
	.SGNLCHAR4(SGNLCHAR4),
	.SGNLCHAR5(SGNLCHAR5),
	.SGNLCHAR6(SGNLCHAR6),
	.SGNLCHAR7(SGNLCHAR7),
	.SGNLCHAR8(SGNLCHAR8),
	.SGNLCHAR9(SGNLCHAR9),
	.SGNLCHAR10(SGNLCHAR10),
	.SGNLCHAR11(SGNLCHAR11),
	.SGNLCHAR12(SGNLCHAR12),
	.SGNLCHAR13(SGNLCHAR13),
	.SGNLCHAR14(SGNLCHAR14),
	.SGNLCHAR15(SGNLCHAR15),
	.SGNLCHAR16(SGNLCHAR16),
	.SGNLCHAR17(SGNLCHAR17),
	.SGNLCHAR18(SGNLCHAR18),
	.SGNLCHAR19(SGNLCHAR19),
	.SGNLCHAR20(SGNLCHAR20),
	.SGNLCHAR21(SGNLCHAR21),
	.SGNLCHAR22(SGNLCHAR22),
	.SGNLCHAR23(SGNLCHAR23),
	.SGNLCHAR24(SGNLCHAR24),
	.SGNLCHAR25(SGNLCHAR25),
	.SGNLCHAR26(SGNLCHAR26),
	.SGNLCHAR27(SGNLCHAR27),
	.SGNLCHAR28(SGNLCHAR28),
	.SGNLCHAR29(SGNLCHAR29),
	.SGNLCHAR30(SGNLCHAR30),
	.SGNLCHAR31(SGNLCHAR31),
	.WSGNLOUT(WSGNLOUT),
	.GSGNLOUT(GSGNLOUT),
	.eclcntrnull(eclcntrnull),
	.eofercy(eofercy),
	.fnmnull(ercyfnmnull),
	.fnme(ercyfnme),
	.fnminvld(ercyfnminvld),
	.nextsgnl(nextsgnl),
	.ercylstvec(ercylstvec),
	.ERCYVECNTR(ERCYVECNTR),
	.ERCYFSEC(ERCYFSEC),
	.ERCYFLSRDATA(ERCYFLSRDATA),
	.MUXERCYFIFO(MUXERCYFIFO)
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////SD STATE MACHINE////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////CMD line state machine
always@(posedge sysres or negedge sdclk)
begin
	if(sysres)
		R_ST_INIT <= POWER_UP;
	else
	begin
	 
		case(R_ST_INIT)

			POWER_UP: 
         begin
				if(pwuptmrstop)
					R_ST_INIT <= START_INIT;
         end
				
			START_INIT:
				R_ST_INIT <= CMD0; 

         STAND_BY_STATE: 
				R_ST_INIT <= CMD7;
			  
			DATA_TRANSFER_STATE:
			begin
				
				case(R_ST_FS)
				
					MBR_GET_PARAM:
						R_ST_INIT <= CMD17;
				
					FAT32_GET_PARAM:
						R_ST_INIT <= CMD17;
						
					FAT_GET_PARAM:
						R_ST_INIT <= CMD17;
						
					FAT_SET_PARAM_P2:
						R_ST_INIT <= CMD24;
						
					ERCY_GET_FILE:
						R_ST_INIT <= CMD17;
						
					ERCY_SET_FILE:
						R_ST_INIT <= CMD24;
						
					AVC_GET_FILE:
						R_ST_INIT <= CMD17;
					
					AVC_GET_DATA:
						R_ST_INIT <= CMD17;
						
					ERCY_SET_DATA:
						R_ST_INIT <= CMD24;
						
					ERCY_WRITE_DATA:
						R_ST_INIT <= CMD13;
						
					ERCY_WRITE_NULL:
						R_ST_INIT <= CMD13;
						
					FAT_WRITE_PARAM:
						R_ST_INIT <= CMD13;
						
					FAT_WRITE_ACK:
						R_ST_INIT <= CMD13;
						
					ERCY_WRITE_ACK:
						R_ST_INIT <= CMD13;
					
				endcase
			end

			CMD0:
			begin
				if(tcvcptdone & cmd0null)
					R_ST_INIT <= CMD8;
			end
				
			CMD7:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R1;
			end

			CMD8:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R7;
			end

			R7:
			begin
				if(tcvcptdone)
				begin
					if(!lasterr & vrngeapply)
						R_ST_INIT <= CMD55;
					else 
						R_ST_INIT <= START_INIT;
					end
			end
			  
			CMD55:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R1;
			end
			  	  
			R1:
			begin
				if(tcvcptdone)
				begin
					if(PUBRCA == 0)
						R_ST_INIT <= acmd41fst ? FIRST_ACMD41 : ACMD41;
					else
						R_ST_INIT <= DATA_TRANSFER_STATE;
				end
			end
			  
			FIRST_ACMD41:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R3;
			end

			ACMD41:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R3;
			end

			R3:
			begin
				if(tcvcptdone)
				begin
					if(sdinitlzd)
						R_ST_INIT <= CMD2; 
					else
						R_ST_INIT <= mstotout ? EXIT : CMD55;
				end
			end

			CMD2:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R2;
			end
			  
			R2:
			begin
				if(tcvcptdone)
					R_ST_INIT <= (PUBRCA == 0) ? CMD3 : STAND_BY_STATE;
			end

			CMD3:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R6;
			end
			  
			R6:
			begin
				if(tcvcptdone & !(PUBRCA == 0))
					R_ST_INIT <= CMD9;
			end
			
			CMD9:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R2;
			end
			  
			CMD13:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R1;
			end
			  
			CMD17:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R1;
			end
			  
			CMD18:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R1;
			end
			  
			CMD23:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R1;
			end
			  
			CMD24:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R1;
			end
			  
			CMD12:
			begin
				if(tcvcptdone)
					R_ST_INIT <= R1;
			end
			
			EXIT:
				R_ST_INIT = EXIT;

			default:
				R_ST_INIT <= START_INIT;

        endcase
    end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////FILESYSTEM STATE MACHINE////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////DAT line state machine	
always@(posedge sysres or negedge sdclk)
begin
	if(sysres)
		R_ST_FS <= MBR_START;
	else
	begin
		case(R_ST_FS)
		  
			MBR_START:
			begin
				if(R_ST_INIT == DATA_TRANSFER_STATE)
					R_ST_FS <= MBR_GET_PARAM;
			end
		  
			MBR_GET_PARAM:
				R_ST_FS <= MBR_READ_PARAM;
		  
			MBR_READ_PARAM:
			begin
				if(tcvdptdone & fat32valid)
					R_ST_FS <= FAT32_GET_PARAM;
			end
		  
			FAT32_GET_PARAM:
			begin
				if(R_ST_INIT == R1 & tcvcptdone)
					R_ST_FS <= FAT32_READ_PARAM;
			end
		  
			FAT32_READ_PARAM:
			begin
				if(tcvdptdone & f32fat1valid & f32avcsvalid & f32bpsvalid)
					R_ST_FS <= ERCY_GET_FILE;
			end
					
			ERCY_GET_FILE:
			begin
				if(R_ST_INIT == R1 & tcvcptdone)
					R_ST_FS <= ERCY_READ_FILE;
			end
					
			ERCY_READ_FILE:
			begin	
				if(tcvdptdone)
				begin
					if(ercyfnme | ercyfnmnull)
						R_ST_FS <= AVC_GET_FILE; 
					else if(!ercyfnme)
						R_ST_FS <= ERCY_GET_FILE;
				end		
			end
					
			AVC_GET_FILE:
			begin
				if(R_ST_INIT == R1 & tcvcptdone)
					R_ST_FS <= AVC_READ_FILE; 
			end
					
			AVC_READ_FILE:
			begin
				if(tcvdptdone)
					R_ST_FS <= avcfnminvld ? USER_WAIT_START : AVC_GET_FILE;
			end
			
			USER_WAIT_START:
			begin
				if(usravcrduws)
					R_ST_FS <= FAT_GET_PARAM;
			end
			
			FAT_GET_PARAM:
			begin
				if(R_ST_INIT == R1 & tcvcptdone)
					R_ST_FS <= FAT_READ_PARAM;
			end
		
			FAT_READ_PARAM:
			begin
				if(tcvdptdone)
					R_ST_FS <= isfatend ? FAT_GET_PARAM : AVC_GET_DATA;
			end
		  
			AVC_GET_DATA:
			begin
				if(R_ST_INIT == R1 & tcvcptdone)
					R_ST_FS <= AVC_READ_DATA;
			end
		  
			AVC_READ_DATA:
			begin
				if(tcvdptdone)
				begin
					if(eofavc & eofavcfnd)
						R_ST_FS <= AVC_SEND_VECTOR;
					else
					begin
						if(notstsgnls & eofavcfnd)
							R_ST_FS <= USER_WAIT_NEXT;
						else
							R_ST_FS <= AVC_GET_DATA;
					end
				end
			end
			
			AVC_SEND_VECTOR:
			begin
				if(cmpdone)
					R_ST_FS <= ERCY_SET_DATA;
			end
					
			ERCY_SET_DATA:
			begin
				if(R_ST_INIT == R1 & tcvcptdone)
				begin
					if(!ercyfempty)
						R_ST_FS <= ERCY_WRITE_DATA;
					else
						R_ST_FS <= ERCY_WRITE_NULL;
				end
			end
					
			ERCY_WRITE_DATA:
			begin
				if(tcvdptdone)
					R_ST_FS <= ERCY_WRITE_ACK;
			end
					
			ERCY_WRITE_ACK:
			begin
				if(dlwe & R_ST_INIT == R1 & tcvcptdone)
				begin
					if(eofavc)
					begin
						if(eofercy & ERCYNCNTR == (SPCLUST + SPCLUST))
							R_ST_FS <= FAT_SET_PARAM_P1;
						else
							R_ST_FS <= ERCY_SET_DATA;
					end
					else
					begin
						if(ercyflempty)
							R_ST_FS <= AVC_GET_DATA;
						else
							R_ST_FS <= ERCY_SET_DATA;
					end
				end
			end
					
			ERCY_WRITE_NULL:
			begin
				if(tcvdptdone)
					R_ST_FS <= ERCY_WRITE_ACK;
			end
					
			FAT_SET_PARAM_P1:
			begin
				if(fatp1done)
					R_ST_FS <= FAT_SET_PARAM_P2; 
			end
					
			FAT_SET_PARAM_P2:
			begin
				if(R_ST_INIT == R1 & tcvcptdone)
					R_ST_FS <= FAT_WRITE_PARAM;
			end
					
			FAT_WRITE_PARAM:
			begin
				if(tcvdptdone)
					R_ST_FS <= FAT_WRITE_ACK;
			end
					
			FAT_WRITE_ACK:
			begin
				if(dlwe & R_ST_INIT == R1 & tcvcptdone)
				begin
					if(eoff)
						R_ST_FS <= ERCY_SET_FILE; 
					else
						R_ST_FS <= FAT_SET_PARAM_P1;
				end
			end
					
			ERCY_SET_FILE:
			begin
				if(R_ST_INIT == R1 & tcvcptdone)
					R_ST_FS <= ERCY_WRITE_FILE;
			end
					
			ERCY_WRITE_FILE:
			begin
				if(tcvdptdone)
					R_ST_FS <= USER_WAIT_NEXT;	
			end
		  
			USER_WAIT_NEXT:
				R_ST_FS <= USER_WAIT_NEXT;
				
			default:
				R_ST_FS <= MBR_START;
					
		endcase
	end
end

endmodule 