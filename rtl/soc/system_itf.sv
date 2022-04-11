interface ahblite_interconnection
import system_pkg::*;
(
);

  logic                    hsel      ;
  logic   [ADDR_WIDTH-5:0] haddr     ;
  logic   [2:0]            hburst    ;
  logic                    hmastlock ;
  logic   [3:0]            hprot     ;
  logic   [2:0]            hsize     ;
  logic   [1:0]            htrans    ;
  logic   [DATA_WIDTH-1:0] hwdata    ;
  logic                    hwrite    ;

  logic   [DATA_WIDTH-1:0] hrdata    ;
  logic                    hready    ;
  logic                    hresp     ;

  modport ahblite_master
  (
    output hsel      ,
    output haddr     ,
    output hburst    ,
    output hmastlock ,
    output hprot     ,
    output hsize     ,
    output htrans    ,
    output hwdata    ,
    output hwrite    ,
    input  hrdata    ,
    input  hready    ,
    input  hresp
  );
  modport ahblite_slave
  (
    input  hsel      ,
    input  haddr     ,
    input  hburst    ,
    input  hmastlock ,
    input  hprot     ,
    input  hsize     ,
    input  htrans    ,
    input  hwdata    ,
    input  hwrite    ,
    output hrdata    ,
    output hready    ,
    output hresp
  );
endinterface:ahblite_interconnection
