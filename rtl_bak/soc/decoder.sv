module decoder
( 
  input  logic         hclk       ,
  input  logic         hresetn    ,
  input  logic  [3:0]  addr_high  ,
  input  logic  [1:0]  htrans     ,
  input  logic  [14:0] hready_in  ,
  output logic         hready_out ,
  output logic  [14:0] hsel       ,
  output logic  [14:0] hsel_D0
);

  always_comb begin
    if(htrans[1]==1'b1) begin
      case(addr_high)
        DATA_S00_HIT : hsel  = 15'h0001 ;
        DATA_S01_HIT : hsel  = 15'h0002 ;
        DATA_S02_HIT : hsel  = 15'h0004 ;
        DATA_S03_HIT : hsel  = 15'h0008 ;
        DATA_S04_HIT : hsel  = 15'h0010 ;
        DATA_S05_HIT : hsel  = 15'h0020 ;
        DATA_S06_HIT : hsel  = 15'h0040 ;
        DATA_S07_HIT : hsel  = 15'h0080 ;
        DATA_S08_HIT : hsel  = 15'h0100 ;
        DATA_S09_HIT : hsel  = 15'h0200 ;
        DATA_S10_HIT : hsel  = 15'h0400 ;
        DATA_S11_HIT : hsel  = 15'h0800 ;
        DATA_S12_HIT : hsel  = 15'h1000 ;
        DATA_S13_HIT : hsel  = 15'h2000 ;
        DATA_S14_HIT : hsel  = 15'h4000 ;
        default      : hsel  = 15'h0000 ;
      endcase
    end else
      hsel = 15'h0000;
  end

  always_ff@(posedge hclk or negedge hresetn) begin
    if(!hresetn)
      hsel_D0 <= 15'h0;
    else if(hready_out)
      hsel_D0 <= hsel;
  end

  always_comb begin
    hready_out = 1'b1;
    case(1'b1)
      hsel_D0[0]  : hready_out = hready_in[0]  ;
      hsel_D0[1]  : hready_out = hready_in[1]  ;
      hsel_D0[2]  : hready_out = hready_in[2]  ;
      hsel_D0[3]  : hready_out = hready_in[3]  ;
      hsel_D0[4]  : hready_out = hready_in[4]  ;
      hsel_D0[5]  : hready_out = hready_in[5]  ;
      hsel_D0[6]  : hready_out = hready_in[6]  ;
      hsel_D0[7]  : hready_out = hready_in[7]  ;
      hsel_D0[8]  : hready_out = hready_in[8]  ;
      hsel_D0[9]  : hready_out = hready_in[9]  ;
      hsel_D0[10] : hready_out = hready_in[10] ;
      hsel_D0[11] : hready_out = hready_in[11] ;
      hsel_D0[12] : hready_out = hready_in[12] ;
      hsel_D0[13] : hready_out = hready_in[13] ;
      hsel_D0[14] : hready_out = hready_in[14] ;
    endcase
  end

endmodule:decoder
