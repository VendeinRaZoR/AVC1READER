/*##################################################################################*/
/*#######################====DAT LINE SD CARD TRANSMITTER===###########################*/
/*##################################################################################*/
/*Description:
DAT SD card line transmitter shifts input 8-bit data to output DAT SD card line
*/
module datatx(
input clk,///Clock
input reset,///Reset
input oe, //output enable DAT line signal
input load, ///load byte
input sbit, ///start bit byte write to output shift signal
input null, ///null byte write to output shift signal
input crc16l, ///CRC16 low byte write to output shift signal
input crc16h, ///CRC16 high byte write to output shift signal
input fifo, ///FIFODATA write to output shift signal
input ram1, ///RAM1DATA write to output shift signal
input ram2, ///RAM2DATA write to output shift signal
input [15:0] CRC16, ///CRC16 bytes to output shift register
input [7:0] FIFODATA, ///ERCY data MUX output
input [7:0] RAM1DATA, ///FAT table sector buffer output
input [7:0] RAM2DATA, ///ERCY file record FAT files table sector output
output DATASO ///serial output signal on DAT line
);

reg [7:0] R_DATASO; ///shift to output register

reg [7:0] R_CRC16LB; ///CRC16 low byte storing

assign DATASO = R_DATASO[7]; ///output shift DAT line

////////////////////CRC16 LOW BYTE TEMPORARY LATCH////////////////////////
////////Latching low byte of CRC16 on output DAT0 SD CARD Line
always@(posedge reset or negedge clk)
begin
	if(reset)
		R_CRC16LB <= 0;
	else
	begin
		if(crc16h & load & oe)
			R_CRC16LB <= CRC16[7:0];
	end
end

//////////////////////DATA SHIFT OUTPUT REGISTER//////////////////////////
////////Simple shift register with parallel selectable load and serial output on DAT0 SD CARD Line
always@(posedge reset or negedge clk)
begin
    if(reset) 
        R_DATASO <= 8'hFF;
    else
    begin
        if(oe)
        begin
				if(load)
				begin
					if(sbit)
						R_DATASO <= 8'hFE; //START BIT byte
					else if(null)
						R_DATASO <= 8'h00; //null byte
					else if(crc16h)
						R_DATASO <= CRC16[15:8];
					else if(crc16l)
						R_DATASO <= R_CRC16LB;
					else if(fifo)
						R_DATASO <= FIFODATA;
					else if(ram1)	
						R_DATASO <= RAM1DATA;
					else if(ram2)	
						R_DATASO <= RAM2DATA;
				end
				else
					R_DATASO <= {R_DATASO[6:0],1'b1};
        end
    end
end

endmodule 