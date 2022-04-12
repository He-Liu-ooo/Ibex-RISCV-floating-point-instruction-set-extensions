module isram_ahbl
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

  logic [31:0] sram_mem    [127:0];
  logic [2:0]  ahbl_hsize_d0;
  logic        ahbl_hwrite_d0;
  logic [31:0] ahbl_haddr_d0;
  logic        ahbl_htrans_d0;
  assign ahbl_hready = 1'b1;
  assign ahbl_hresp  = 1'b0;
  integer idx;

  logic        sram_rd_en;
  logic        sram_data_valid;
  logic [6:0]  sram_rd_addr;
  assign sram_rd_addr = ahbl_haddr[8:2];

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
      ahbl_htrans_d0 <= ahbl_htrans;
    end
  end
  
  assign sram_rd_en = ~ahbl_hwrite && ahbl_htrans;
  
  always_ff@(posedge clk or negedge rstn) begin
    if(!rstn)
      ahbl_hrdata <= 32'h0;
    else if(sram_rd_en)
      ahbl_hrdata <= sram_mem[sram_rd_addr];
  end

  
endmodule:isram_ahbl
