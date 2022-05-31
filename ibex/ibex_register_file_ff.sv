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
module ibex_register_file_ff #(
    parameter bit          RV32E             = 0,
    parameter int unsigned DataWidth         = 32,
    parameter bit          DummyInstructions = 0
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

  localparam int unsigned ADDR_WIDTH = RV32E ? 4 : 5;    // ME: RV32E 是一种格式，只支持16个通用整数寄存器
  localparam int unsigned NUM_WORDS  = 2**ADDR_WIDTH;

  logic [NUM_WORDS-1:0][DataWidth-1:0] rf_reg;
  logic [NUM_WORDS-1:1][DataWidth-1:0] rf_reg_q;
  logic [NUM_WORDS-1:1]                we_a_dec;

  // ME: purely for debug ======================================== //
  logic [DataWidth-1:0] x1;
  logic [DataWidth-1:0] x2;
  logic [DataWidth-1:0] x3;
  logic [DataWidth-1:0] x4;
  logic [DataWidth-1:0] x5;
  logic [DataWidth-1:0] x6;
  logic [DataWidth-1:0] x7;
  logic [DataWidth-1:0] x8;
  logic [DataWidth-1:0] x9;
  logic [DataWidth-1:0] x10;
  logic [DataWidth-1:0] x11;
  logic [DataWidth-1:0] x12;
  logic [DataWidth-1:0] x13;
  logic [DataWidth-1:0] x14;
  logic [DataWidth-1:0] x15;
  logic [DataWidth-1:0] x16;
  logic [DataWidth-1:0] x17;
  logic [DataWidth-1:0] x18;
  logic [DataWidth-1:0] x19;
  logic [DataWidth-1:0] x20;
  logic [DataWidth-1:0] x21;
  logic [DataWidth-1:0] x22;
  logic [DataWidth-1:0] x23;
  logic [DataWidth-1:0] x24;
  logic [DataWidth-1:0] x25;
  logic [DataWidth-1:0] x26;
  logic [DataWidth-1:0] x27;
  logic [DataWidth-1:0] x28;
  logic [DataWidth-1:0] x29;
  logic [DataWidth-1:0] x30;
  logic [DataWidth-1:0] x31;

  assign x1 = rf_reg[1];
  assign x2 = rf_reg[2];
  assign x3 = rf_reg[3];
  assign x4 = rf_reg[4];
  assign x5 = rf_reg[5]; 
  assign x6 = rf_reg[6];
  assign x7 = rf_reg[7];
  assign x8 = rf_reg[8];
  assign x9 = rf_reg[9];
  assign x10 = rf_reg[10];
  assign x11 = rf_reg[11]; 
  assign x12 = rf_reg[12];
  assign x13 = rf_reg[13];
  assign x14 = rf_reg[14];
  assign x15 = rf_reg[15]; 
  assign x16 = rf_reg[16];
  assign x17 = rf_reg[17];
  assign x18 = rf_reg[18];
  assign x19 = rf_reg[19];
  assign x20 = rf_reg[20];
  assign x21 = rf_reg[21]; 
  assign x22 = rf_reg[22];
  assign x23 = rf_reg[23];
  assign x24 = rf_reg[24];
  assign x25 = rf_reg[25]; 
  assign x26 = rf_reg[26];
  assign x27 = rf_reg[27];
  assign x28 = rf_reg[28];
  assign x29 = rf_reg[29];
  assign x30 = rf_reg[30];
  assign x31 = rf_reg[31]; 
  // ME: purely for debug ======================================== //

  always_comb begin : we_a_decoder
    for (int unsigned i = 1; i < NUM_WORDS; i++) begin
      we_a_dec[i] = (waddr_a_i == 5'(i)) ?  we_a_i : 1'b0;
    end
  end

  // No flops for R0 as it's hard-wired to 0
  for (genvar i = 1; i < NUM_WORDS; i++) begin : g_rf_flops
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rf_reg_q[i] <= '0;
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
