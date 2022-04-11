module soc
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

dsram_ahbl x_dsram_ahbl
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
  .ahbl_hresp        ( dahbl_hresp     )
);
endmodule
