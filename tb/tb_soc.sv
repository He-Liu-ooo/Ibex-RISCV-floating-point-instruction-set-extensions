// minimalistic simulation top module with clock gen and initial reset
`timescale 1ns/100ps
module tb_soc
(
//   input  logic          sysclk,
//   input  logic          BTNU,
//   input  logic [4:0]    gpio_reg_i,
//   output logic [7:0]    gpio_reg_data_o
//    TEST
//   output logic [7:0]   xx6
//    TEST
);
    logic sysclk;
    logic BTNU;
    logic [4:0] gpio_reg_i; 
    logic [7:0] gpio_reg_data_o;
//    // logic [7:0] xx6;
    assign gpio_reg_i = 'd4;
    
    logic rstn;
    logic clk;
    logic uart_rx;
    logic uart_tx;
    assign rstn = ~ BTNU;
    
//    // TEST
//    logic [31:0] x0;
//    logic [31:0] x1;
//    logic [31:0] x2;
//    logic [31:0] f0;
//    logic [31:0] f1;
//    logic [31:0] f2;
//    logic [31:0] f3;
//    logic [31:0] f4;
//    logic [31:0] f5;
//    logic [31:0] f6;
//    logic [31:0] f7;
//    logic [31:0] f8;
//    always_ff @(posedge clk or negedge rstn) begin
//        if (!rstn) begin
//           xx6 = 8'b1111_1111;
//        end
//        else begin
//            if (gpio_reg_i==5'b00001) begin
//                xx6 <= x0[7:0];
//            end else if (gpio_reg_i==5'b00010) begin
//                xx6 <= x1[7:0];
//            end else if (gpio_reg_i==5'b00011) begin
//                xx6 <= x2[7:0];
//            end else if (gpio_reg_i==5'b00100) begin
//                //xx6 <= f0[23:16];
//                xx6 <= f0[7:0];
//            end else if (gpio_reg_i==5'b00101) begin
//                //xx6 <= f1[23:16];
//                xx6 <= f1[7:0];
//            end else if (gpio_reg_i==5'b00110) begin
//                //xx6 <= f2[23:16];
//                xx6 <= f2[7:0];
//            end else if (gpio_reg_i==5'b00111) begin
//                //xx6 <= f3[23:16];
//                xx6 <= f3[7:0];
//            end else if (gpio_reg_i==5'b01000) begin
//                //xx6 <= f4[23:16];
//                xx6 <= f4[7:0];
//            end else if (gpio_reg_i==5'b01001) begin
//                //xx6 <= f5[23:16];
//                xx6 <= f5[7:0];
//            end else if (gpio_reg_i==5'b01010) begin
//                //xx6 <= f6[23:16];
//                xx6 <= f6[7:0];
//            end else if (gpio_reg_i==5'b01011) begin
//                //xx6 <= f7[23:16];
//                xx6 <= f7[7:0];
//            end else if (gpio_reg_i==5'b01100) begin
//                //xx6 <= f8[23:16];
//                xx6 <= f8[7:0];
//            end else begin
//                xx6 <= 8'b0000_0000;
//            end
            
//        end
//    end
    // TEST 
    
clk_10MHz x_clk_10MHz(
    .clk_i   (sysclk   ),
    .rstn_i  (rstn     ),
    .clk_o   (clk      )  
); 

soc_ahblite x_soc
(
  .clk               ( clk          ),
  .rstn              ( rstn            ),

  .uart_rx           ( uart_rx         ),
  .uart_tx           ( uart_tx         ),
  
  //.ADDR              ( ADDR            ),
  .gpio_reg_i        ( gpio_reg_i      ),
  .gpio_reg_data_o   ( gpio_reg_data_o )
//  // TEST
//  .x0(x0),
//  .x1(x1),
//  .x2(x2),
//  .f0(f0),
//  .f1(f1),
//  .f2(f2),
//  .f3(f3),
//  .f4(f4),
//  .f5(f5),
//  .f6(f6),
//  .f7(f7),
//  .f8(f8)
//  // TEST
);

initial begin
    BTNU = 1'b1;
    # 200
    BTNU = 1'b0;
    # 350000
    $finish(2);
end

always begin
    sysclk = 1'b0;
    #2;
    sysclk = 1'b1;
    #2;
end

//    initial begin
//        uart_rx = 1'b1;
//        # 1650000
//        // 001011       鍋? right
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b1;
//        # 20832
//        uart_rx = 1'b1;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b1;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b1;   // parity
//        # 20832
//        uart_rx = 1'b1;

//        // 3789169
//        # 100000

//        // 4189169
//        // 000101
//        uart_rx = 1'b0; 
//        # 20832
//        uart_rx = 1'b1;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b1;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b1;    // parity wrong
//        # 20832
//        uart_rx = 1'b1;

//        // 4918388

//        # 100000
//        // 010011 

//        // 5318388
//        uart_rx = 1'b0; 
//        # 20832
//        uart_rx = 1'b1;
//        # 20832
//        uart_rx = 1'b1;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b1;
//        # 20832
//        uart_rx = 1'b0;
//        # 20832
//        uart_rx = 1'b1;   // parity correct
//        # 20832
//        uart_rx = 1'b1;
        
//    end


    

initial begin

    $display("*****start to load program*****");
    $readmemh("../sw/uart/NMS.vmem",x_soc.x_isram_ahbl.sram_mem);
//    //$readmemh("../sw/uart/NMS_DATA.vmem",)
//    //$readmemh("../sw/uart/test_FLOAD_FSTORE.vmem",x_soc.x_isram_ahbl.sram_mem);
//    //$readmemh("../sw/uart/test_lwsw.vmem",x_soc.x_isram_ahbl.sram_mem);
//    //$readmemh("../sw/led/led.vmem",x_soc.x_isram_ahbl.sram_mem);

end

  initial begin
    $fsdbDumpfile("tb_soc.fsdb");
    $fsdbDumpvars();
  end

endmodule

