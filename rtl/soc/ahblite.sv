module ahblite
import system_pkg::*;
(
  input   logic                    clk            ,
  input   logic                    rstn           ,
  // 
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
  // ahblite slave0
  ahblite_interconnection.ahblite_master           ahblite_m0     ,
  ahblite_interconnection.ahblite_master           ahblite_m1     ,
  ahblite_interconnection.ahblite_master           ahblite_m2     ,
  ahblite_interconnection.ahblite_master           ahblite_m3     ,
  ahblite_interconnection.ahblite_master           ahblite_m4     ,
  ahblite_interconnection.ahblite_master           ahblite_m5     ,
  ahblite_interconnection.ahblite_master           ahblite_m6     ,
  ahblite_interconnection.ahblite_master           ahblite_m7     ,
  ahblite_interconnection.ahblite_master           ahblite_m8     ,
  ahblite_interconnection.ahblite_master           ahblite_m9     ,
  ahblite_interconnection.ahblite_master           ahblite_m10    ,
  ahblite_interconnection.ahblite_master           ahblite_m11    ,
  ahblite_interconnection.ahblite_master           ahblite_m12    ,
  ahblite_interconnection.ahblite_master           ahblite_m13    ,
  ahblite_interconnection.ahblite_master           ahblite_m14    
);
  
  logic [1:0]  htrans     ;
  logic [3:0]  addr_high  ;
  logic [14:0] hready_in  ;
  logic [14:0] hsel       ;
  logic [14:0] hsel_D0    ;
  logic        hwrite_D0  ;
  logic        hready_out ;
  
  // ME
  // assign hsel[0] = 1'b1;
  // assign hsel_D0[0] = 1'b1;
  // ME
  assign ahbl_hready = hready_out;
  assign ahbl_hresp = 1'b1;
  assign htrans    = ahbl_htrans       ;
  assign addr_high = ahbl_haddr[31-:4] ;
  assign hready_in = { ahblite_m14.hready , ahblite_m13.hready ,
                       ahblite_m12.hready , ahblite_m11.hready ,
                       ahblite_m10.hready , ahblite_m9.hready  ,
                       ahblite_m8.hready  , ahblite_m7.hready  ,
                       ahblite_m6.hready  , ahblite_m5.hready  ,
                       ahblite_m4.hready  , ahblite_m3.hready  ,
                       ahblite_m2.hready  , ahblite_m1.hready  ,
                       ahblite_m0.hready  };

decoder x_decoder
( 
  .hclk       ( clk        ),
  .hresetn    ( rstn       ),
  .hwrite     ( ahbl_hwrite),
  .addr_high  ( addr_high  ),
  .htrans     ( htrans     ), 
  .hready_in  ( hready_in  ),
  .hready_out ( hready_out ),
  .hsel       ( hsel       ),
  .hsel_D0    ( hsel_D0    ),
  .hwrite_D0  ( hwrite_D0  )
);
  //ahblie_master0 port
  assign ahblite_m0.hsel       = hsel[0]                                 ;
  assign ahblite_m0.haddr      = hsel[0]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m0.hburst     = hsel[0]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m0.hmastlock  = 1'b0                                    ;
  assign ahblite_m0.hprot      = hsel[0]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m0.hsize      = hsel[0]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m0.htrans     = hsel[0]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m0.hwrite     = hsel[0]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m0.hwdata     = hsel_D0[0]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master1 port
  assign ahblite_m1.hsel       = hsel[1]                                 ;
  assign ahblite_m1.haddr      = hsel[1]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m1.hburst     = hsel[1]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m1.hmastlock  = 1'b0                                    ;
  assign ahblite_m1.hprot      = hsel[1]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m1.hsize      = hsel[1]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m1.htrans     = hsel[1]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m1.hwrite     = hsel[1]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m1.hwdata     = hsel_D0[1]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master2 port
  assign ahblite_m2.hsel       = hsel[2]                                 ;
  assign ahblite_m2.haddr      = hsel[2]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m2.hburst     = hsel[2]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m2.hmastlock  = 1'b0                                    ;
  assign ahblite_m2.hprot      = hsel[2]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m2.hsize      = hsel[2]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m2.htrans     = hsel[2]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m2.hwrite     = hsel[2]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m2.hwdata     = hsel_D0[2]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master3 port
  assign ahblite_m3.hsel       = hsel[3]                                 ;
  assign ahblite_m3.haddr      = hsel[3]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m3.hburst     = hsel[3]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m3.hmastlock  = 1'b0                                    ;
  assign ahblite_m3.hprot      = hsel[3]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m3.hsize      = hsel[3]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m3.htrans     = hsel[3]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m3.hwrite     = hsel[3]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m3.hwdata     = hsel_D0[3]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master4 port
  assign ahblite_m4.hsel       = hsel[4]                                 ;
  assign ahblite_m4.haddr      = hsel[4]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m4.hburst     = hsel[4]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m4.hmastlock  = 1'b0                                    ;
  assign ahblite_m4.hprot      = hsel[4]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m4.hsize      = hsel[4]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m4.htrans     = hsel[4]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m4.hwrite     = hsel[4]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m4.hwdata     = hsel_D0[4]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master5 port
  assign ahblite_m5.hsel       = hsel[5]                                 ;
  assign ahblite_m5.haddr      = hsel[5]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m5.hburst     = hsel[5]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m5.hmastlock  = 1'b0                                    ;
  assign ahblite_m5.hprot      = hsel[5]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m5.hsize      = hsel[5]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m5.htrans     = hsel[5]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m5.hwrite     = hsel[5]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m5.hwdata     = hsel_D0[5]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master6 port
  assign ahblite_m6.hsel       = hsel[6]                                 ;
  assign ahblite_m6.haddr      = hsel[6]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m6.hburst     = hsel[6]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m6.hmastlock  = 1'b0                                    ;
  assign ahblite_m6.hprot      = hsel[6]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m6.hsize      = hsel[6]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m6.htrans     = hsel[6]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m6.hwrite     = hsel[6]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m6.hwdata     = hsel_D0[6]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master7 port
  assign ahblite_m7.hsel       = hsel[7]                                 ;
  assign ahblite_m7.haddr      = hsel[7]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m7.hburst     = hsel[7]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m7.hmastlock  = 1'b0                                    ;
  assign ahblite_m7.hprot      = hsel[7]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m7.hsize      = hsel[7]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m7.htrans     = hsel[7]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m7.hwrite     = hsel[7]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m7.hwdata     = hsel_D0[7]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master8 port
  assign ahblite_m8.hsel       = hsel[8]                                 ;
  assign ahblite_m8.haddr      = hsel[8]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m8.hburst     = hsel[8]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m8.hmastlock  = 1'b0                                    ;
  assign ahblite_m8.hprot      = hsel[8]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m8.hsize      = hsel[8]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m8.htrans     = hsel[8]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m8.hwrite     = hsel[8]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m8.hwdata     = hsel_D0[8]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master9 port
  assign ahblite_m9.hsel       = hsel[9]                                 ;
  assign ahblite_m9.haddr      = hsel[9]     ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m9.hburst     = hsel[9]     ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m9.hmastlock  = 1'b0                                    ;
  assign ahblite_m9.hprot      = hsel[9]     ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m9.hsize      = hsel[9]     ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m9.htrans     = hsel[9]     ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m9.hwrite     = hsel[9]     ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m9.hwdata     = hsel_D0[9]  ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master10 port
  assign ahblite_m10.hsel      = hsel[10]                                ;
  assign ahblite_m10.haddr     = hsel[10]    ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m10.hburst    = hsel[10]    ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m10.hmastlock = 1'b0                                    ;
  assign ahblite_m10.hprot     = hsel[10]    ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m10.hsize     = hsel[10]    ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m10.htrans    = hsel[10]    ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m10.hwrite    = hsel[10]    ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m10.hwdata    = hsel_D0[10] ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master11 port
  assign ahblite_m11.hsel      = hsel[11]                                ;
  assign ahblite_m11.haddr     = hsel[11]    ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m11.hburst    = hsel[11]    ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m11.hmastlock = 1'b0                                    ;
  assign ahblite_m11.hprot     = hsel[11]    ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m11.hsize     = hsel[11]    ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m11.htrans    = hsel[11]    ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m11.hwrite    = hsel[11]    ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m11.hwdata    = hsel_D0[11] ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master12 port
  assign ahblite_m12.hsel      = hsel[12]                                ;
  assign ahblite_m12.haddr     = hsel[12]    ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m12.hburst    = hsel[12]    ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m12.hmastlock = 1'b0                                    ;
  assign ahblite_m12.hprot     = hsel[12]    ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m12.hsize     = hsel[12]    ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m12.htrans    = hsel[12]    ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m12.hwrite    = hsel[12]    ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m12.hwdata    = hsel_D0[12] ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master13 port
  assign ahblite_m13.hsel      = hsel[13]                                ;
  assign ahblite_m13.haddr     = hsel[13]    ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m13.hburst    = hsel[13]    ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m13.hmastlock = 1'b0                                    ;
  assign ahblite_m13.hprot     = hsel[13]    ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m13.hsize     = hsel[13]    ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m13.htrans    = hsel[13]    ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m13.hwrite    = hsel[13]    ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m13.hwdata    = hsel_D0[13] ? ahbl_hwdata      : 32'h0  ;
  //ahblie_master14 port
  assign ahblite_m14.hsel      = hsel[14]                                ;
  assign ahblite_m14.haddr     = hsel[14]    ? ahbl_haddr[31:0] : 32'h0  ;
  assign ahblite_m14.hburst    = hsel[14]    ? ahbl_hburst      : 3'h0   ;
  assign ahblite_m14.hmastlock = 1'b0                                    ;
  assign ahblite_m14.hprot     = hsel[14]    ? ahbl_hprot       : 4'h0   ;
  assign ahblite_m14.hsize     = hsel[14]    ? ahbl_hsize       : 3'h2   ;
  assign ahblite_m14.htrans    = hsel[14]    ? ahbl_htrans      : 2'h0   ;
  assign ahblite_m14.hwrite    = hsel[14]    ? ahbl_hwrite      : 1'h0   ;
  assign ahblite_m14.hwdata    = hsel_D0[14] ? ahbl_hwdata      : 32'h0  ;

  // hrdata
  always_comb begin
    ahbl_hrdata = 32'h0;
    if(hwrite_D0==1'b0) begin
      case(1'b1)
        hsel_D0[0]  : ahbl_hrdata = ahblite_m0.hrdata  ;
        hsel_D0[1]  : ahbl_hrdata = ahblite_m1.hrdata  ;
        hsel_D0[2]  : ahbl_hrdata = ahblite_m2.hrdata  ;
        hsel_D0[3]  : ahbl_hrdata = ahblite_m3.hrdata  ;
        hsel_D0[4]  : ahbl_hrdata = ahblite_m4.hrdata  ;
        hsel_D0[5]  : ahbl_hrdata = ahblite_m5.hrdata  ;
        hsel_D0[6]  : ahbl_hrdata = ahblite_m6.hrdata  ;
        hsel_D0[7]  : ahbl_hrdata = ahblite_m7.hrdata  ;
        hsel_D0[8]  : ahbl_hrdata = ahblite_m8.hrdata  ;
        hsel_D0[9]  : ahbl_hrdata = ahblite_m9.hrdata  ;
        hsel_D0[10] : ahbl_hrdata = ahblite_m10.hrdata ;
        hsel_D0[11] : ahbl_hrdata = ahblite_m11.hrdata ;
        hsel_D0[12] : ahbl_hrdata = ahblite_m12.hrdata ;
        hsel_D0[13] : ahbl_hrdata = ahblite_m13.hrdata ;
        hsel_D0[14] : ahbl_hrdata = ahblite_m14.hrdata ;
      endcase
    end
  end

endmodule:ahblite
