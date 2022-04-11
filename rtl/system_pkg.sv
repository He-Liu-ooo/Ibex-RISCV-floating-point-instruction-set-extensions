package system_pkg;
  parameter ADDR_WIDTH     = 32;
  parameter DATA_WIDTH     = 32;
endpackage

package addr_map_pkg;
  parameter INST_START     = 32'h0000_0000 ;
  parameter INST_TAIL      = 32'h0fff_ffff ;// 256MByte
  parameter DATA_START     = 32'h1000_0000 ;
  parameter DATA_TAIL      = 32'hffff_ffff ;
  parameter DATA_S00_HIT   = 4'h1          ;// AHB-Lite Slave00 256MByte
  parameter DATA_S01_HIT   = 4'h2          ;// AHB-Lite Slave01 256MByte
  parameter DATA_S02_HIT   = 4'h3          ;// AHB-Lite Slave02 256MByte
  parameter DATA_S03_HIT   = 4'h4          ;// AHB-Lite Slave03 256MByte
  parameter DATA_S04_HIT   = 4'h5          ;// AHB-Lite Slave04 256MByte
  parameter DATA_S05_HIT   = 4'h6          ;// AHB-Lite Slave05 256MByte
  parameter DATA_S06_HIT   = 4'h7          ;// AHB-Lite Slave06 256MByte
  parameter DATA_S07_HIT   = 4'h8          ;// AHB-Lite Slave07 256MByte
  parameter DATA_S08_HIT   = 4'h9          ;// AHB-Lite Slave08 256MByte
  parameter DATA_S09_HIT   = 4'ha          ;// AHB-Lite Slave09 256MByte
  parameter DATA_S10_HIT   = 4'hb          ;// AHB-Lite Slave10 256MByte
  parameter DATA_S11_HIT   = 4'hc          ;// AHB-Lite Slave11 256MByte
  parameter DATA_S12_HIT   = 4'hd          ;// AHB-Lite Slave12 256MByte
  parameter DATA_S13_HIT   = 4'he          ;// AHB-Lite Slave13 256MByte
  parameter DATA_S14_HIT   = 4'hf          ;// AHB-Lite Slave14 256MByte
endpackage

