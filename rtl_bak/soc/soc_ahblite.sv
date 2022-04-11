module soc_ahblite
import system_pkg::*;
(
  input  logic clk,
  input  logic rstn
);

  logic                    sys_clk         ;
  logic                    sys_rstn        ;
  logic   [ADDR_WIDTH-1:0] iahbl_haddr     ;
  logic   [2:0]            iahbl_hburst    ;
  logic                    iahbl_hmastlock ;
  logic   [3:0]            iahbl_hprot     ;
  logic   [2:0]            iahbl_hsize     ; 
  logic   [1:0]            iahbl_htrans    ; 
  logic   [DATA_WIDTH-1:0] iahbl_hwdata    ; 
  logic                    iahbl_hwrite    ; 
  logic   [DATA_WIDTH-1:0] iahbl_hrdata    ; 
  logic                    iahbl_hready    ; 
  logic                    iahbl_hresp     ; 
  logic   [ADDR_WIDTH-1:0] dahbl_haddr     ; 
  logic   [2:0]            dahbl_hburst    ; 
  logic                    dahbl_hmastlock ; 
  logic   [3:0]            dahbl_hprot     ; 
  logic   [2:0]            dahbl_hsize     ; 
  logic   [1:0]            dahbl_htrans    ; 
  logic   [DATA_WIDTH-1:0] dahbl_hwdata    ; 
  logic                    dahbl_hwrite    ; 
  logic   [DATA_WIDTH-1:0] dahbl_hrdata    ; 
  logic                    dahbl_hready    ; 
  logic                    dahbl_hresp     ; 


sub_system x_sub_system
(
  .sys_clk_i         ( clk             ),
  .sys_rstn_i        ( rstn            ),
  
  .iahbl_haddr_o     ( iahbl_haddr     ),
  .iahbl_hburst_o    ( iahbl_hburst    ),
  .iahbl_hmastlock_o ( iahbl_hmastlock ),
  .iahbl_hprot_o     ( iahbl_hprot     ),
  .iahbl_hsize_o     ( iahbl_hsize     ),
  .iahbl_htrans_o    ( iahbl_htrans    ),
  .iahbl_hwdata_o    ( iahbl_hwdata    ),
  .iahbl_hwrite_o    ( iahbl_hwrite    ),
  .iahbl_hrdata_i    ( iahbl_hrdata    ),
  .iahbl_hready_i    ( iahbl_hready    ),
  .iahbl_hresp_i     ( iahbl_hresp     ),
  
  .dahbl_haddr_o     ( dahbl_haddr     ),
  .dahbl_hburst_o    ( dahbl_hburst    ),
  .dahbl_hmastlock_o ( dahbl_hmastlock ),
  .dahbl_hprot_o     ( dahbl_hprot     ),
  .dahbl_hsize_o     ( dahbl_hsize     ),
  .dahbl_htrans_o    ( dahbl_htrans    ),
  .dahbl_hwdata_o    ( dahbl_hwdata    ),
  .dahbl_hwrite_o    ( dahbl_hwrite    ),
  .dahbl_hrdata_i    ( dahbl_hrdata    ),
  .dahbl_hready_i    ( dahbl_hready    ),
  .dahbl_hresp_i     ( dahbl_hresp     )     
);

isram_ahbl x_isram_ahbl
(
  .clk               ( clk             ),
  .rstn              ( rstn            ),
  .ahbl_haddr        ( iahbl_haddr     ),
  .ahbl_hburst       ( iahbl_hburst    ),
  .ahbl_hmastlock    ( iahbl_hmastlock ),
  .ahbl_hprot        ( iahbl_hprot     ),
  .ahbl_hsize        ( iahbl_hsize     ),
  .ahbl_htrans       ( iahbl_htrans    ),
  .ahbl_hwdata       ( iahbl_hwdata    ),
  .ahbl_hwrite       ( iahbl_hwrite    ),
  .ahbl_hrdata       ( iahbl_hrdata    ),
  .ahbl_hready       ( iahbl_hready    ),
  .ahbl_hresp        ( iahbl_hresp     )
);

  ahblite_interconnection ahbl_ic0  ;
  ahblite_interconnection ahbl_ic1  ;
  ahblite_interconnection ahbl_ic2  ;
  ahblite_interconnection ahbl_ic3  ;
  ahblite_interconnection ahbl_ic4  ;
  ahblite_interconnection ahbl_ic5  ;
  ahblite_interconnection ahbl_ic6  ;
  ahblite_interconnection ahbl_ic7  ;
  ahblite_interconnection ahbl_ic8  ;
  ahblite_interconnection ahbl_ic9  ;
  ahblite_interconnection ahbl_ic10 ;
  ahblite_interconnection ahbl_ic11 ;
  ahblite_interconnection ahbl_ic12 ;
  ahblite_interconnection ahbl_ic13 ;
  ahblite_interconnection ahbl_ic14 ;

ahblite x_data_fabric
(
  .clk               ( clk             ),
  .rstn              ( rstn            ),
  .ahbl_haddr        ( dahbl_haddr     ),
  .ahbl_hburst       ( dahbl_hburst    ),
  .ahbl_hmastlock    ( dahbl_hmastlock ),
  .ahbl_hprot        ( dahbl_hprot     ),
  .ahbl_hsize        ( dahbl_hsize     ),
  .ahbl_htrans       ( dahbl_htrans    ),
  .ahbl_hwdata       ( dahbl_hwdata    ),
  .ahbl_hwrite       ( dahbl_hwrite    ),
  .ahbl_hrdata       ( dahbl_hrdata    ),
  .ahbl_hready       ( dahbl_hready    ),
  .ahbl_hresp        ( dahbl_hresp     ),
  .ahblite_m0        ( ahbl_ic0        ),
  .ahblite_m1        ( ahbl_ic1        ),
  .ahblite_m2        ( ahbl_ic2        ),
  .ahblite_m3        ( ahbl_ic3        ),
  .ahblite_m4        ( ahbl_ic4        ),
  .ahblite_m5        ( ahbl_ic5        ),
  .ahblite_m6        ( ahbl_ic6        ),
  .ahblite_m7        ( ahbl_ic7        ),
  .ahblite_m8        ( ahbl_ic8        ),
  .ahblite_m9        ( ahbl_ic9        ),
  .ahblite_m10       ( ahbl_ic10       ),
  .ahblite_m11       ( ahbl_ic11       ),
  .ahblite_m12       ( ahbl_ic12       ),
  .ahblite_m13       ( ahbl_ic13       ),
  .ahblite_m14       ( ahbl_ic14       )
);

endmodule:soc_ahblite
