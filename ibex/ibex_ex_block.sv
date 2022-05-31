// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Execution stage
 *
 * Execution block: Hosts ALU and MUL/DIV unit
 */
module ibex_ex_block #(
    parameter ibex_pkg::rv32m_e RV32M           = ibex_pkg::RV32MFast,
    parameter ibex_pkg::rv32b_e RV32B           = ibex_pkg::RV32BNone,
    parameter bit               BranchTargetALU = 0
) (
    input  logic                  clk_i,
    input  logic                  rst_ni,

    // ALU
    input  ibex_pkg::alu_op_e     alu_operator_i,   // ME: 哪个ALU操作，比如 ALU_ADD
    input  logic [31:0]           alu_operand_a_i,
    input  logic [31:0]           alu_operand_b_i,
    input  logic [31:0]           alu_operand_c_i,  // RV32F
    input  logic                  alu_instr_first_cycle_i,
    // RV32F =========================================== //
    input  ibex_pkg::rounding_mode_e falu_rounding_mode_i,
    // RV32F =========================================== //

    // Branch Target ALU
    // All of these signals are unusued when BranchTargetALU == 0
    input  logic [31:0]           bt_a_operand_i,
    input  logic [31:0]           bt_b_operand_i,

    // Multiplier/Divider
    input  ibex_pkg::md_op_e      multdiv_operator_i,
    input  logic                  mult_en_i,             // dynamic enable signal, for FSM control
    input  logic                  div_en_i,              // dynamic enable signal, for FSM control
    // RV32F =================================== //
    input  logic                  fdiv_en_i,
    input  logic                  convert_en_i,
    // RV32F =================================== //
    input  logic                  mult_sel_i,            // static decoder output, for data muxes
    input  logic                  div_sel_i,             // static decoder output, for data muxes
    input  logic  [1:0]           multdiv_signed_mode_i,
    input  logic [31:0]           multdiv_operand_a_i,
    input  logic [31:0]           multdiv_operand_b_i,
    input  logic                  multdiv_ready_id_i,
    input  logic                  data_ind_timing_i,

    // intermediate val reg
    output logic [1:0]            imd_val_we_o,
    output logic [33:0]           imd_val_d_o[2],
    input  logic [33:0]           imd_val_q_i[2],

    // Outputs
    output logic [31:0]           alu_adder_result_ex_o, // to LSU
    output logic [31:0]           result_ex_o,           // NOTE  track where this is going
    output logic [31:0]           branch_target_o,       // to IF
    output logic                  branch_decision_o,     // to ID   NOTE if there's a branch, this signal will inform the ID stage

    output logic                  ex_valid_o             // EX has valid output
);

  import ibex_pkg::*;

  logic [31:0] alu_result, multdiv_result;

  logic [32:0] multdiv_alu_operand_b, multdiv_alu_operand_a;
  logic [33:0] alu_adder_result_ext;
  logic        alu_cmp_result, alu_is_equal_result;
  logic        multdiv_valid;
  logic        multdiv_sel;
  logic [31:0] alu_imd_val_q[2];
  logic [31:0] alu_imd_val_d[2];
  logic [ 1:0] alu_imd_val_we;
  logic [33:0] multdiv_imd_val_d[2];
  logic [ 1:0] multdiv_imd_val_we;

  /*
    The multdiv_i output is never selected if RV32M=RV32MNone
    At synthesis time, all the combinational and sequential logic
    from the multdiv_i module are eliminated
  */
  if (RV32M != RV32MNone) begin : gen_multdiv_m
    assign multdiv_sel = mult_sel_i | div_sel_i;
  end else begin : gen_multdiv_no_m
    assign multdiv_sel = 1'b0;
  end

  // Intermediate Value Register Mux
  assign imd_val_d_o[0] = multdiv_sel ? multdiv_imd_val_d[0] : {2'b0, alu_imd_val_d[0]};
  assign imd_val_d_o[1] = multdiv_sel ? multdiv_imd_val_d[1] : {2'b0, alu_imd_val_d[1]};
  assign imd_val_we_o   = multdiv_sel ? multdiv_imd_val_we : alu_imd_val_we;

  assign alu_imd_val_q = '{imd_val_q_i[0][31:0], imd_val_q_i[1][31:0]};


  // branch handling
  assign branch_decision_o  = alu_cmp_result;

  if (BranchTargetALU) begin : g_branch_target_alu
    logic [32:0] bt_alu_result;
    logic        unused_bt_carry;

    assign bt_alu_result   = bt_a_operand_i + bt_b_operand_i;

    assign unused_bt_carry = bt_alu_result[32];
    assign branch_target_o = bt_alu_result[31:0];
  end else begin : g_no_branch_target_alu
    // Unused bt_operand signals cause lint errors, this avoids them
    logic [31:0] unused_bt_a_operand, unused_bt_b_operand;

    assign unused_bt_a_operand = bt_a_operand_i;
    assign unused_bt_b_operand = bt_b_operand_i;

    assign branch_target_o = alu_adder_result_ex_o;
  end

  /////////
  // ALU //
  /////////

  ibex_alu #(
    .RV32B(RV32B)
  ) alu_i                  (
      .operator_i          ( alu_operator_i          ),
      .operand_a_i         ( alu_operand_a_i         ),
      .operand_b_i         ( alu_operand_b_i         ),
      .operand_c_i         ( alu_operand_c_i         ),   // RV32F   this can be a float or an integer
      .instr_first_cycle_i ( alu_instr_first_cycle_i ),   // ME: indicate whether this is the inst's first cycle in id stage
      .imd_val_q_i         ( alu_imd_val_q           ),
      .imd_val_we_o        ( alu_imd_val_we          ),
      .imd_val_d_o         ( alu_imd_val_d           ),
      .multdiv_operand_a_i ( multdiv_alu_operand_a   ),
      .multdiv_operand_b_i ( multdiv_alu_operand_b   ),
      .multdiv_sel_i       ( multdiv_sel             ),
      // RV32F =========================================== //
      .falu_rounding_mode_i( falu_rounding_mode_i    ),
      // RV32F =========================================== //
      .adder_result_o      ( alu_adder_result_ex_o   ),   // 操作数a与b相加的结果，无论 operator 是什么，因此在 ADD 的情况下，此值与 result_o 一样
      .adder_result_ext_o  ( alu_adder_result_ext    ),
      .result_o            ( alu_result              ),   // 浮点数比较的结果以 alu_result 的形式输出  NOTE
      .comparison_result_o ( alu_cmp_result          ),   // 仅仅是整数比较的结果                     NOTE   track this two
      .is_equal_result_o   ( alu_is_equal_result     )
  );

  ////////////////
  // Multiplier //
  ////////////////

  if (RV32M == RV32MSlow) begin : gen_multdiv_slow
    ibex_multdiv_slow multdiv_i (
        .clk_i              ( clk_i                 ),
        .rst_ni             ( rst_ni                ),
        .mult_en_i          ( mult_en_i             ),
        .div_en_i           ( div_en_i              ),
        .mult_sel_i         ( mult_sel_i            ),
        .div_sel_i          ( div_sel_i             ),
        .operator_i         ( multdiv_operator_i    ),
        .signed_mode_i      ( multdiv_signed_mode_i ),
        .op_a_i             ( multdiv_operand_a_i   ),
        .op_b_i             ( multdiv_operand_b_i   ),
        .alu_adder_ext_i    ( alu_adder_result_ext  ),
        .alu_adder_i        ( alu_adder_result_ex_o ),
        .equal_to_zero_i    ( alu_is_equal_result   ),
        .data_ind_timing_i  ( data_ind_timing_i     ),
        .valid_o            ( multdiv_valid         ),
        .alu_operand_a_o    ( multdiv_alu_operand_a ),
        .alu_operand_b_o    ( multdiv_alu_operand_b ),
        .imd_val_q_i        ( imd_val_q_i           ),
        .imd_val_d_o        ( multdiv_imd_val_d     ),
        .imd_val_we_o       ( multdiv_imd_val_we    ),
        .multdiv_ready_id_i ( multdiv_ready_id_i    ),
        .multdiv_result_o   ( multdiv_result        )
    );
  end else if (RV32M == RV32MFast || RV32M == RV32MSingleCycle) begin : gen_multdiv_fast
    ibex_multdiv_fast #     (
        .RV32M ( RV32M )
    ) multdiv_i             (
        .clk_i              ( clk_i                 ),
        .rst_ni             ( rst_ni                ),
        .mult_en_i          ( mult_en_i             ),  // 1
        .div_en_i           ( div_en_i              ),
        .mult_sel_i         ( mult_sel_i            ),  // 1
        .div_sel_i          ( div_sel_i             ),
        .operator_i         ( multdiv_operator_i    ),  // MD_OP_MULL
        .signed_mode_i      ( multdiv_signed_mode_i ),
        .op_a_i             ( multdiv_operand_a_i   ),
        .op_b_i             ( multdiv_operand_b_i   ),
        .alu_operand_a_o    ( multdiv_alu_operand_a ),
        .alu_operand_b_o    ( multdiv_alu_operand_b ),
        .alu_adder_ext_i    ( alu_adder_result_ext  ),  // from alu
        .alu_adder_i        ( alu_adder_result_ex_o ),  // from alu
        .equal_to_zero_i    ( alu_is_equal_result   ),  // from alu
        .data_ind_timing_i  ( data_ind_timing_i     ),
        .imd_val_q_i        ( imd_val_q_i           ),
        .imd_val_d_o        ( multdiv_imd_val_d     ),
        .imd_val_we_o       ( multdiv_imd_val_we    ),
        .multdiv_ready_id_i ( multdiv_ready_id_i    ),
        .valid_o            ( multdiv_valid         ),
        .multdiv_result_o   ( multdiv_result        )
    );
  end

  ///////////////////
  // Float divider //
  ///////////////////
  

  // for fdiv

  logic fdiv_valid;
  logic [31:0] fdiv_result;

  ibex_float_divider fdivider_i0(
    .clk_i                  ( clk_i                 ),
    .rst_i                  ( rst_ni                ),
    .input_a_i              ( alu_operand_a_i       ),
    .input_b_i              ( alu_operand_b_i       ),
    .fdiv_en_i              ( fdiv_en_i             ),
    .output_z_o             ( fdiv_result           ),
    .fdiv_valid_o           ( fdiv_valid            )
  );
  
  // for fadddiv

  logic fadddiv_valid;
  logic [31:0] fadddiv_result;

  ibex_float_divider fdivider_i1(
    .clk_i                  ( clk_i                 ),
    .rst_i                  ( rst_ni                ),
    .input_a_i              ( alu_result            ),
    .input_b_i              ( alu_operand_c_i       ),
    .fdiv_en_i              ( fdiv_en_i             ),
    .output_z_o             ( fadddiv_result        ),
    .fdiv_valid_o           ( fadddiv_valid         )
  );

  /////////////////////////
  // Int2float converter //
  /////////////////////////
  
  logic convert_valid;
  logic [31:0] int2float_result;

  ibex_int2float int2float_i(
    .clk_i                  ( clk_i                 ),
    .rst_i                  ( rst_ni                ),
    .input_a_i              ( alu_operand_a_i       ),
    .convert_en_i           ( convert_en_i          ),
    .output_z_o             ( int2float_result      ),
    .convert_valid_o        ( convert_valid         )
  );

  ibex_pkg::arithmetic_sel_e arithmetic_sel;

  logic [32:0] adder_in_a, adder_in_b;
  logic [33:0] adder_res_temp;

  always_comb begin
    if (alu_operator_i == ALU_FDIV) begin
      arithmetic_sel = F_DIV;
      result_ex_o = fdiv_result;
    end 
    else if (alu_operator_i == ALU_FADDDIV) begin
      arithmetic_sel = F_ADDDIV;
      result_ex_o = fadddiv_result;
    end
    else if (alu_operator_i == ALU_FCVTSW) begin
      arithmetic_sel = INT2FLOAT32;
      result_ex_o = int2float_result;
    end 
    else if (alu_operator_i == ALU_MADD) begin
      arithmetic_sel = I_MULDIV;
      adder_in_a = {multdiv_result,1'b1};
      adder_in_b = {alu_operand_c_i,1'b0};
      adder_res_temp = $unsigned(adder_in_a) + $unsigned(adder_in_b);
      result_ex_o = adder_res_temp[32:1];
    end
    else if (multdiv_sel) begin    // 对于整数的三目运算，multdiv_sel的值为1
      arithmetic_sel = I_MULDIV;
      result_ex_o = multdiv_result;
    end
    else begin
      arithmetic_sel = I_ALU;
      result_ex_o = alu_result;
    end
  end

  // assign result_ex_o  = multdiv_sel ? multdiv_result : alu_result;

  // Multiplier/divider may require multiple cycles. The ALU output is valid in the same cycle
  // unless the intermediate result register is being written (which indicates this isn't the
  // final cycle of ALU operation).
  always_comb begin
    unique case(arithmetic_sel)
      F_DIV: ex_valid_o = fdiv_valid;
      F_ADDDIV: ex_valid_o = fadddiv_valid;
      INT2FLOAT32: ex_valid_o = convert_valid;
      I_MULDIV: ex_valid_o = multdiv_valid;
      I_ALU: ex_valid_o = ~(|alu_imd_val_we);
    endcase 
  end

  // assign ex_valid_o = multdiv_sel ? multdiv_valid : ~(|alu_imd_val_we);   // alu_imd_val_we must be all zero to make ex_valid_o valid

endmodule
