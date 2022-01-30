xmverilog +access+rw +gui AVC1READER.vt -v AVC1READER.v -y PLL -v CRC/crc7.v \
-v CRC/crc16.v -y DATA -y ERCY -y FAT -y FAT32 -y LINE -y MBR -y SD -y STR \
-y USER -y Arithmetic -y AVC -y CMD \
-v /home/work/cads/intelFPGA_pro/19.1/modelsim_ase/altera/verilog/src/altera_mf.v \
-v /home/work/cads/intelFPGA_pro/19.1/modelsim_ase/altera/verilog/src/220model.v \
+libext+.v +fsmdebug AVC1READER.v
