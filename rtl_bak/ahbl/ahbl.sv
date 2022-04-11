module ahbl
import system_pkg::*;
(
  input   logic                    clk            ,
  input   logic                    rstn           ,
  input   logic   [ADDR_WIDTH-1:0] ahbl_haddr     ,
  input   logic   [2:0]            ahbl_hburst    ,
  input   logic                    ahbl_hmastlock ,
  input   logic   [3:0]            ahbl_hprot     ,
  input   logic   [2:0]            ahbl_hsize     ,
  input   logic   [1:0]            ahbl_htrans    ,
  input   logic   [DATA_WIDTH-1:0] ahbl_hwdata    ,
  input   logic                    ahbl_hwrite    ,
  output  logic   [DATA_WIDTH-1:0] ahbl_hrdata    ,
  output  logic                    ahbl_hready    ,
  output  logic                    ahbl_hresp     ,
  // slave port0
  output  logic   [ADDR_WIDTH-5:0] s0_haddr       ,
  output  logic   [2:0]            s0_hburst      ,
  output  logic                    s0_hmastlock   ,
  output  logic   [3:0]            s0_hprot       ,
  output  logic   [2:0]            s0_hsize       ,
  output  logic   [1:0]            s0_htrans      ,
  output  logic   [DATA_WIDTH-1:0] s0_hwdata      ,
  output  logic                    s0_hwrite      ,
  input   logic   [DATA_WIDTH-1:0] s0_hrdata      ,
  input   logic                    s0_hready      ,
  input   logic                    s0_hresp       ,
  // slave port0
  // slave port0
  // slave port0
);

endmodule:ahbl
