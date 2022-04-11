module inst_sram
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
  output  logic                    ahbl_hresp
);

  logic [2:0]  ahbl_hsize_d0;
  logic        ahbl_hwrite_d0;
  logic [31:0] ahbl_haddr_d0;
  logic        ahbl_htrans_d0;
  assign ahbl_hready = 1'b1;
  assign ahbl_hresp  = 1'b0;

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
      ahbl_hsize_d0  <= 3'b010;
      ahbl_hwrite_d0 <= 1'b0;
      ahbl_haddr_d0  <= 32'h0;
      ahbl_htrans_d0 <= 1'b0;
    end else if(ahbl_hready==1'b1) begin
      ahbl_hsize_d0  <= ahbl_hsize;
      ahbl_hwrite_d0 <= ahbl_hwrite;
      ahbl_haddr_d0  <= ahbl_haddr;
      ahbl_htrans_d0 <= ahbl_htrans;
    end
  end
  
  assign SRAM_RD_EN   = ~ahbl_htrans[1] || ~ahbl_hready || ahbl_hwrite;
  assign SRAM_WR_EN   = ~ahbl_htrans_d0[1] || ~ahbl_hready || ~ahbl_hwrite_d0;
  assign SRAM_RD_ADDR = ahbl_haddr[11:2];
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

  assign ahbl_hrdata = {Q3,Q2,Q1,Q0};

endmodule:inst_sram
