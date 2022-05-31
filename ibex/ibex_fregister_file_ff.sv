// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * RISC-V register file
 *
 * Register file with 31 or 15x 32 bit wide registers. Register 0 is fixed to 0.
 * This register file is based on flip flops. Use this register file when
 * targeting FPGA synthesis or Verilator simulation.
 */
module ibex_fregister_file_ff #(
    //parameter bit          RV32E             = 0,
    parameter int unsigned DataWidth         = 32,
    parameter bit          DummyInstructions = 0,
    parameter int unsigned ADDR_WIDTH        = 5
) (
    // Clock and Reset
    input  logic                 clk_i,
    input  logic                 rst_ni,

    input  logic                 test_en_i,
    input  logic                 dummy_instr_id_i,

    //Read port R1
    input  logic [4:0]           raddr_a_i,
    output logic [DataWidth-1:0] rdata_a_o,

    //Read port R2
    input  logic [4:0]           raddr_b_i,
    output logic [DataWidth-1:0] rdata_b_o,

    //Read port R3
    input  logic [4:0]           raddr_c_i,
    output logic [DataWidth-1:0] rdata_c_o,


    // Write port W1
    input  logic [4:0]           waddr_a_i,
    input  logic [DataWidth-1:0] wdata_a_i,
    input  logic                 we_a_i

);

  //localparam int unsigned ADDR_WIDTH = RV32E ? 4 : 5;    // ME: RV32E 是一种格式，只支持16个通用整数寄存器
  localparam int unsigned NUM_WORDS  = 2**ADDR_WIDTH;      // ME： 浮点寄存器有32个

  logic [NUM_WORDS-1:0][DataWidth-1:0] rf_reg;
  logic [NUM_WORDS-1:1][DataWidth-1:0] rf_reg_q;
  logic [NUM_WORDS-1:1]                we_a_dec;
            
  // ME: purely for debug ======================================== //
  logic [DataWidth-1:0] fx1;
  logic [DataWidth-1:0] fx2;
  logic [DataWidth-1:0] fx3;
  logic [DataWidth-1:0] fx4;
  logic [DataWidth-1:0] fx5;
  logic [DataWidth-1:0] fx6;
  logic [DataWidth-1:0] fx7;
  logic [DataWidth-1:0] fx8;
  logic [DataWidth-1:0] fx9;
  logic [DataWidth-1:0] fx10;
  logic [DataWidth-1:0] fx11;
  logic [DataWidth-1:0] fx12;
  logic [DataWidth-1:0] fx13;
  logic [DataWidth-1:0] fx14;
  logic [DataWidth-1:0] fx15;
  logic [DataWidth-1:0] fx16;
  logic [DataWidth-1:0] fx17;
  logic [DataWidth-1:0] fx18;
  logic [DataWidth-1:0] fx19;
  logic [DataWidth-1:0] fx20;
  logic [DataWidth-1:0] fx21;
  logic [DataWidth-1:0] fx22;
  logic [DataWidth-1:0] fx23;
  logic [DataWidth-1:0] fx24;
  logic [DataWidth-1:0] fx25;
  logic [DataWidth-1:0] fx26;
  logic [DataWidth-1:0] fx27;
  logic [DataWidth-1:0] fx28;
  logic [DataWidth-1:0] fx29;
  logic [DataWidth-1:0] fx30;
  logic [DataWidth-1:0] fx31;

  assign fx1 = rf_reg[1];
  assign fx2 = rf_reg[2];
  assign fx3 = rf_reg[3];
  assign fx4 = rf_reg[4];
  assign fx5 = rf_reg[5]; 
  assign fx6 = rf_reg[6];
  assign fx7 = rf_reg[7];
  assign fx8 = rf_reg[8];
  assign fx9 = rf_reg[9];
  assign fx10 = rf_reg[10];
  assign fx11 = rf_reg[11]; 
  assign fx12 = rf_reg[12];
  assign fx13 = rf_reg[13];
  assign fx14 = rf_reg[14];
  assign fx15 = rf_reg[15]; 
  assign fx16 = rf_reg[16];
  assign fx17 = rf_reg[17];
  assign fx18 = rf_reg[18];
  assign fx19 = rf_reg[19];
  assign fx20 = rf_reg[20];
  assign fx21 = rf_reg[21]; 
  assign fx22 = rf_reg[22];
  assign fx23 = rf_reg[23];
  assign fx24 = rf_reg[24];
  assign fx25 = rf_reg[25]; 
  assign fx26 = rf_reg[26];
  assign fx27 = rf_reg[27];
  assign fx28 = rf_reg[28];
  assign fx29 = rf_reg[29];
  assign fx30 = rf_reg[30];
  assign fx31 = rf_reg[31]; 
  // ME: purely for debug ======================================== //

  // ME: traverse all registers to set the enable bit
  always_comb begin : we_a_decoder
    for (int unsigned i = 1; i < NUM_WORDS; i++) begin
      we_a_dec[i] = (waddr_a_i == 5'(i)) ?  we_a_i : 1'b0;
    end
  end

  // No flops for R0 as it's hard-wired to 0
  // ME: traverse every register
  for (genvar i = 1; i < NUM_WORDS; i++) begin : g_rf_flops
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        if(i!=0 && i!=8 && i!=9)
          rf_reg_q[i] <= '0;
        else if(i==0) 
          rf_reg_q[0] <= 32'h0;
        else if(i==8)
          rf_reg_q[8] <= 32'h40000000;
        else 
          rf_reg_q[9] <= 32'h3ecccccc;
      end else if(we_a_dec[i]) begin
        rf_reg_q[i] <= wdata_a_i;
      end
    end
  end

  // With dummy instructions enabled, R0 behaves as a real register but will always return 0 for
  // real instructions.
  if (DummyInstructions) begin : g_dummy_r0
    logic                 we_r0_dummy;
    logic [DataWidth-1:0] rf_r0_q;

    // Write enable for dummy R0 register (waddr_a_i will always be 0 for dummy instructions)
    assign we_r0_dummy = we_a_i & dummy_instr_id_i;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rf_r0_q <= '0;
      end else if (we_r0_dummy) begin
        rf_r0_q <= wdata_a_i;
      end
    end

    // Output the dummy data for dummy instructions, otherwise R0 reads as zero
    assign rf_reg[0] = dummy_instr_id_i ? rf_r0_q : '0;

  end else begin : g_normal_r0
    logic unused_dummy_instr_id;
    assign unused_dummy_instr_id = dummy_instr_id_i;

    // R0 is nil
    assign rf_reg[0] = '0;
  end

  assign rf_reg[NUM_WORDS-1:1] = rf_reg_q[NUM_WORDS-1:1];

  assign rdata_a_o = rf_reg[raddr_a_i];
  assign rdata_b_o = rf_reg[raddr_b_i];
  assign rdata_c_o = rf_reg[raddr_c_i];

  // Signal not used in FF register file
  logic unused_test_en;
  assign unused_test_en = test_en_i;

endmodule
