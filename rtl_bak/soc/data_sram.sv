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
  logic [7:0]  D0,D1,D2,D3;
  logic [7:0]  Q0,Q1,Q2,Q3;
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
      ahbl_htrans_d0 <= slave0.htrans;
    end
  end
  
  assign SRAM_RD_EN   = ~slave0.htrans[1] || ~slave0.hready || slave0.hwrite || ~slave0.hsel;
  assign SRAM_WR_EN   = ~ahbl_htrans_d0[1] || ~ahbl_hready || ~ahbl_hwrite_d0 || ~ahbl_hsel_d0;
  assign SRAM_RD_ADDR = slave0.haddr[11:2];
  assign SRAM_WR_ADDR = ahbl_haddr_d0[11:2];

  // CEN0-3
  assign CEN0 = SRAM_RD_EN && (SRAM_WR_EN || ~(ahbl_haddr_d0[1:0]==2'b00));
  assign CEN1 = SRAM_RD_EN && (SRAM_WR_EN || ~(((ahbl_haddr_d0[1:0]==2'b01)&&(ahbl_hsize_d0==3'b000))||((ahbl_haddr_d0[1:0]==2'b00)&&(ahbl_hsize_d0!=3'b000))));
  assign CEN2 = SRAM_RD_EN && (SRAM_WR_EN || ~(((ahbl_haddr_d0[1:0]==2'b10)&&(ahbl_hsize_d0[2:1]==2'b00))||((ahbl_haddr_d0[1:0]==2'b00)&&(ahbl_hsize_d0==3'b010))));
  assign CEN3 = SRAM_RD_EN && (SRAM_WR_EN || ~(((ahbl_haddr_d0[1:0]==2'b11)&&(ahbl_hsize_d0==3'b000))||((ahbl_haddr_d0[1:0]==2'b10)&&(ahbl_hsize_d0==3'b001))||((ahbl_haddr_d0[1:0]==2'b00)&&(ahbl_hsize_d0==3'b010))));

  // WEN0-3
  assign WEN0 = CEN0 || ~ahbl_hwrite_d0;
  assign WEN1 = CEN1 || ~ahbl_hwrite_d0;
  assign WEN2 = CEN2 || ~ahbl_hwrite_d0;
  assign WEN3 = CEN3 || ~ahbl_hwrite_d0;
  
  // ADDR
  assign ADDR = SRAM_WR_EN ? SRAM_WR_ADDR : SRAM_RD_ADDR;

sram_8x1024 i_sram_block0
(
  .CLK ( clk  ),
  .CEN ( CEN0 ),
  .WEN ( WEN0 ),
  .A   ( ADDR ),
  .D   ( D0   ),
  .Q   ( Q0   )
);
sram_8x1024 i_sram_block1
(
  .CLK ( clk  ),
  .CEN ( CEN1 ),
  .WEN ( WEN1 ),
  .A   ( ADDR ),
  .D   ( D1   ),
  .Q   ( Q1   )
);
sram_8x1024 i_sram_block2
(
  .CLK ( clk  ),
  .CEN ( CEN2 ),
  .WEN ( WEN2 ),
  .A   ( ADDR ),
  .D   ( D2   ),
  .Q   ( Q2   )
);  
sram_8x1024 i_sram_block3
(
  .CLK ( clk  ),
  .CEN ( CEN3 ),
  .WEN ( WEN3 ),
  .A   ( ADDR ),
  .D   ( D3   ),
  .Q   ( Q3   )
);

  assign slave0.hrdata = {Q3,Q2,Q1,Q0};

endmodule:data_sram
