module data_sram
import system_pkg::*;
(
  input   logic                          clk            ,
  input   logic                          rstn           ,
  ahblite_interconnection.ahblite_slave  slave0
);

  logic        ahbl_hsel_d0   ;
  logic [2:0]  ahbl_hsize_d0  ;
  logic        ahbl_hwrite_d0 ;
  logic [27:0] ahbl_haddr_d0  ;
  logic        ahbl_htrans_d0 ;
  assign slave0.hready = 1'b1 ;
  assign slave0.hresp  = 1'b0 ;

  logic        SRAM_RD_EN,SRAM_WR_EN;
  logic        CEN0,CEN1,CEN2,CEN3;
  logic        WEN0,WEN1,WEN2,WEN3;
  logic [31:0]  D;
  logic [31:0]  Q;
  logic [9:0]  SRAM_RD_ADDR;
  logic [9:0]  SRAM_WR_ADDR;
  logic [9:0]  ADDR;

  always_ff@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      ahbl_hsel_d0   <= 1'b0;
      ahbl_hsize_d0  <= 3'b010;
      ahbl_hwrite_d0 <= 1'b0;
      ahbl_haddr_d0  <= 28'h0;
      ahbl_htrans_d0 <= 1'b0;
    end else if(slave0.hready==1'b1) begin
      ahbl_hsel_d0   <= slave0.hsel;
      ahbl_hsize_d0  <= slave0.hsize;
      ahbl_hwrite_d0 <= slave0.hwrite;
      ahbl_haddr_d0  <= slave0.haddr;
      ahbl_htrans_d0 <= slave0.htrans[1];
    end
  end
  
  assign SRAM_RD_EN   = ~slave0.htrans[1] || ~slave0.hready || slave0.hwrite || ~slave0.hsel;
  assign SRAM_WR_EN   = ~ahbl_htrans_d0 || ~slave0.hready || ~ahbl_hwrite_d0 || ~ahbl_hsel_d0;
  assign SRAM_RD_ADDR = slave0.haddr[11:2];
  assign SRAM_WR_ADDR = ahbl_haddr_d0[11:2];

  // CEN0-3
  assign CEN = SRAM_RD_EN && SRAM_WR_EN;

  // WEN0-3
  assign WEN = CEN || ~ahbl_hwrite_d0;
  
  // ADDR
  assign ADDR = SRAM_WR_EN ? SRAM_RD_ADDR : SRAM_WR_ADDR;
  // DATA
  assign D = slave0.hwdata;

  // instance of data sram
sram_32x1024 i_sram_block
(
  .CLK ( clk  ),
  .RSTN( rstn ),
  .CEN ( CEN  ),
  .WEN ( WEN  ),
  .A   ( ADDR ),
  .D   ( D    ),
  .Q   ( Q    )
);

  assign slave0.hrdata = Q;

endmodule:data_sram

