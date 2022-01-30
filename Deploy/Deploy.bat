XCOPY /Y /S /E ..\Project 
XCOPY /Y /S /E ..\SDC
COPY /Y ..\Testbench\AVC1READER.vt
XCOPY /Y /S /E ..\Verilog
XCOPY /Y /S /E /I "..\Output files" output_files
pause