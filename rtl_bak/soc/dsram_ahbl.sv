module dsram_ahbl
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

  logic [7:0]  sram_block0 [4095:0];
  logic [7:0]  sram_block1 [4095:0];
  logic [7:0]  sram_block2 [4095:0];
  logic [7:0]  sram_block3 [4095:0];
  logic [2:0]  ahbl_hsize_d0;
  logic        ahbl_hwrite_d0;
  logic [31:0] ahbl_haddr_d0;
  logic        ahbl_htrans_d0;
  logic [3:0]  dsram_be;
  assign ahbl_hready = 1'b1;
  assign ahbl_hresp  = 1'b0;
  integer idx;

  logic        sram_rd_en;
  logic        sram_wr_en;
  logic        sram_data_valid;
  logic [9:0]  sram_rd_addr;
  logic [9:0]  sram_wr_addr;
  assign sram_rd_addr = ahbl_haddr[11:2];
  assign sram_wr_addr = ahbl_haddr_d0[11:2];

  assign dsram_be[0] = ahbl_haddr_d0[1:0]==2'b00;
  assign dsram_be[1] = ((ahbl_hsize_d0[2:0]==3'b000)&&(ahbl_haddr_d0[1:0]==2'b01))||((ahbl_hsize_d0==3'b001)&&(ahbl_haddr_d0==2'b00))||((ahbl_hsize_d0[2:0]==3'b010)&&(ahbl_haddr_d0[1:0]==2'b00));
  assign dsram_be[2] = ((ahbl_hsize_d0[2:1]==2'b00)&&(ahbl_haddr_d0[1:0]==2'b10))||((ahbl_hsize_d0[2:1]==2'b01)&&(ahbl_haddr_d0[1:0]==2'b00));
  assign dsram_be[3] = ((ahbl_hsize_d0[2:0]==3'b000)&&(ahbl_haddr_d0[1:0]==2'b11))||((ahbl_hsize_d0[2:0]==3'b001)&&(ahbl_haddr_d0[1:0]==2'b10))||((ahbl_hsize_d0[2:0]==3'b010)&&(ahbl_haddr_d0[1:0]==2'b00));

  always_ff@(posedge clk or negedge rstn) begin
    if(!rstn) begin
      ahbl_hsize_d0 <= 3'b010;
      ahbl_hwrite_d0 <= 1'b0;
      ahbl_haddr_d0 <= 32'h0;
      ahbl_htrans_d0 <= 1'b0;
    end else if(ahbl_hready==1'b1) begin
      ahbl_hsize_d0 <= ahbl_hsize;
      ahbl_hwrite_d0 <= ahbl_hwrite;
      ahbl_haddr_d0 <= ahbl_haddr;
      ahbl_htrans_d0 <= ahbl_htrans[1];
    end
  end
  
  assign sram_rd_en = ~ahbl_hwrite && ahbl_htrans && ahbl_hready;
  assign sram_wr_en =  ahbl_hwrite_d0 && ahbl_htrans_d0 && ahbl_hready;
  always_ff@(posedge clk or negedge rstn) begin
    if(!rstn)
      ahbl_hrdata <= 32'h0;
    else if(sram_rd_en)
      ahbl_hrdata <= {{{8{dsram_be[3]}}&sram_block3[sram_rd_addr]},{{8{dsram_be[2]}}&sram_block2[sram_rd_addr]},{{8{dsram_be[1]}}&sram_block1[sram_rd_addr]},{{8{dsram_be[0]}}&sram_block0[sram_rd_addr]}};
  end

  always_ff@(posedge clk) begin
    if(sram_wr_en&&dsram_be[0])
      sram_block0[sram_wr_addr] <= ahbl_hwdata[7:0];
  end
  always_ff@(posedge clk) begin
    if(sram_wr_en&&dsram_be[1])
      sram_block1[sram_wr_addr] <= ahbl_hwdata[15:8];
  end
  always_ff@(posedge clk) begin
    if(sram_wr_en&&dsram_be[2])
      sram_block2[sram_wr_addr] <= ahbl_hwdata[23:16];
  end
  always_ff@(posedge clk) begin
    if(sram_wr_en&&dsram_be[3])
      sram_block3[sram_wr_addr] <= ahbl_hwdata[31:24];
  end
  
endmodule:dsram_ahbl
