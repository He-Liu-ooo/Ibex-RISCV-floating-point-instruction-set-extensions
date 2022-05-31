debImport "-2001" "-sverilog" "-f" "file.f"
debLoadSimResult /home/eda/work/AHBL_SOC_IBEX/uart_single_test/tb_uart.fsdb
wvCreateWindow
srcHBSelect "tb.APB" -win $_nTrace1
srcHBSelect "tb.uart.rx0" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcSetOptions -win $_nTrace1 -annotate off
schSetOptions -win $_nSchema1 -annotate off
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcSetOptions -win $_nTrace1 -annotate off
schSetOptions -win $_nSchema1 -annotate off
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcSetOptions -win $_nTrace1 -annotate off
schSetOptions -win $_nSchema1 -annotate off
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcSetOptions -win $_nTrace1 -annotate off
schSetOptions -win $_nSchema1 -annotate off
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcSetOptions -win $_nTrace1 -annotate off
schSetOptions -win $_nSchema1 -annotate off
srcHBSelect "tb.uart.rx0" -win $_nTrace1
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 1468628930.817610 -snap {("rx0" 7)}
wvSetCursor -win $_nWave2 522150943.396226 -snap {("rx0" 9)}
debExit
