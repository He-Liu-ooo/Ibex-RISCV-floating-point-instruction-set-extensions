module ibex_fpu
  (
    input  logic [31:0]               A_i, 
    input  logic [31:0]               B_i, 
    input  logic [31:0]               C_i,
    input  ibex_pkg::alu_op_e         opcode_i, 
    input  ibex_pkg::rounding_mode_e  rounding_mode_i,
    
    output logic [31:0]               result_o,
    output logic                      comparison_result_o,     // for flt
    //output logic                      is_equal_result_o        // for feq
    output logic                      exception_flag_o
  );
    import ibex_pkg::*;
	
	//wire [31:0] result_o;
	wire [7:0] a_exponent;
	wire [23:0] a_mantissa;
	wire [7:0] b_exponent;
	wire [23:0] b_mantissa;
	wire [7:0] c_exponent; //
	wire [23:0] c_mantissa; //


	reg        o_sign;
	reg [7:0]  o_exponent;
	reg [24:0] o_mantissa;


	reg [31:0] adder_a_in;
	reg [31:0] adder_b_in;
	reg [31:0] adder_c_in; //
	wire [31:0] adder_out;
	wire [31:0] madder_out; //

	reg [31:0] multiplier_a_in;
	reg [31:0] multiplier_b_in;
	wire [31:0] multiplier_out;

	reg [31:0] less_a_in;
	reg [31:0] less_b_in;
	wire less_out;

	reg [31:0] eq_a_in;
	reg [31:0] eq_b_in;
	wire eq_out;

	assign result_o[31] = o_sign;
	assign result_o[30:23] = o_exponent;
	assign result_o[22:0] = o_mantissa[22:0];

	assign a_sign = A_i[31];
	assign a_exponent[7:0] = A_i[30:23];
	assign a_mantissa[23:0] = {1'b1, A_i[22:0]};

	assign b_sign = B_i[31];
	assign b_exponent[7:0] = B_i[30:23];
	assign b_mantissa[23:0] = {1'b1, B_i[22:0]};

	assign c_sign = C_i[31];                      //
	assign c_exponent[7:0] = C_i[30:23];          //
	assign c_mantissa[23:0] = {1'b1, C_i[22:0]};  // 

	assign ADD = opcode_i == ALU_FADD || opcode_i == ALU_FADDDIV;
	assign SUB = opcode_i == ALU_FSUB;
	//assign DIV = opcode_i == ALU_FDIV;
	assign MUL = opcode_i == ALU_FMUL;
	assign MADD = opcode_i == ALU_FMADD;
	assign MSUB = opcode_i == ALU_FMSUB;
	assign NMSUB = opcode_i == ALU_FNMSUB;
	assign NMADD = opcode_i == ALU_FNMADD;
	assign EQ = opcode_i == ALU_FEQ;
	assign LT = opcode_i == ALU_FLT;
	assign SUBABS = opcode_i == ALU_FSUBABS;
	//assign ADDDIV = opcode_i == ALU_FADDDIV;

	adder A1
	(
		.a(adder_a_in),
		.b(adder_b_in),
		.out(adder_out)
	);

	adder A2
	(
		.a(multiplier_out),
		.b(adder_c_in),
		.out(madder_out)
	);

	multiplier M1
	(
		.a(multiplier_a_in),
		.b(multiplier_b_in),
		.out(multiplier_out)
	);

	fless L1
	( 
		.a(less_a_in),
		.b(less_b_in),
		.c(less_out)
	);

	feq E1
	(
		.a(eq_a_in),
		.b(eq_b_in),
		.c(eq_out)
	);

	// divider D1
	// (
	// 	.a(divider_a_in),
	// 	.b(divider_b_in),
	// 	.out(divider_out)
	// );

	always @ (*) begin
		exception_flag_o = 1'b0;

		if (ADD) begin
			//If a is NaN or b is zero return a
			if ((a_exponent == 255 && a_mantissa != 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
				o_sign = a_sign;
				o_exponent = a_exponent;
				o_mantissa = a_mantissa;
			//If b is NaN or a is zero return b
			end else if ((b_exponent == 255 && b_mantissa != 0) || (a_exponent == 0) && (a_mantissa == 0)) begin
				o_sign = b_sign;
				o_exponent = b_exponent;
				o_mantissa = b_mantissa;
			//if a or b is inf return inf
			end else if ((a_exponent == 255) || (b_exponent == 255)) begin
				o_sign = a_sign ^ b_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin // Passed all corner cases
				adder_a_in = A_i;
				adder_b_in = B_i;
				o_sign = adder_out[31];
				o_exponent = adder_out[30:23];
				o_mantissa = adder_out[22:0];
			end
		end else if (SUB) begin
			//If a is NaN or b is zero return a
			if ((a_exponent == 255 && a_mantissa != 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
				o_sign = a_sign;
				o_exponent = a_exponent;
				o_mantissa = a_mantissa;
			//If b is NaN or a is zero return b
			end else if ((b_exponent == 255 && b_mantissa != 0) || (a_exponent == 0) && (a_mantissa == 0)) begin
				o_sign = b_sign;
				o_exponent = b_exponent;
				o_mantissa = b_mantissa;
			//if a or b is inf return inf
			end else if ((a_exponent == 255) || (b_exponent == 255)) begin
				o_sign = a_sign ^ b_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (A_i == B_i) begin  // equal numbers subtraction
				o_sign = 1'b0;
                                o_exponent = 8'h0;
				o_mantissa = 23'h0;
                        end else begin // Passed all corner cases
				adder_a_in = A_i;
				adder_b_in = {~B_i[31], B_i[30:0]};
				o_sign = adder_out[31];
				o_exponent = adder_out[30:23];
				o_mantissa = adder_out[22:0];
			end
		end else if (MUL) begin //Multiplication
			//If a is NaN return NaN
			if (a_exponent == 255 && a_mantissa != 0) begin
				o_sign = a_sign;
				o_exponent = 255;
				o_mantissa = a_mantissa;
			//If b is NaN return NaN
			end else if (b_exponent == 255 && b_mantissa != 0) begin
				o_sign = b_sign;
				o_exponent = 255;
				o_mantissa = b_mantissa;
			//If a or b is 0 return 0
			end else if ((a_exponent == 0) && (a_mantissa == 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
				o_sign = a_sign ^ b_sign;
				o_exponent = 0;
				o_mantissa = 0;
			//if a or b is inf return inf
			end else if ((a_exponent == 255) || (b_exponent == 255)) begin
				o_sign = a_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin // Passed all corner cases
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31];
				o_exponent = multiplier_out[30:23];
				o_mantissa = multiplier_out[22:0];
			end
		end else if (SUBABS) begin
			//If a is NaN or b is zero return a
			if ((a_exponent == 255 && a_mantissa != 0) || (b_exponent == 0) && (b_mantissa == 0)) begin
				o_sign = 1'b0;
				o_exponent = a_exponent;
				o_mantissa = a_mantissa;
			//If b is NaN or a is zero return b
			end else if ((b_exponent == 255 && b_mantissa != 0) || (a_exponent == 0) && (a_mantissa == 0)) begin
				o_sign = 1'b0;
				o_exponent = b_exponent;
				o_mantissa = b_mantissa;
			//if a or b is inf return inf
			end else if ((a_exponent == 255) || (b_exponent == 255)) begin
				o_sign = 1'b0;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (A_i == B_i) begin  // equal numbers subtraction
				o_sign = 1'b0;
                                o_exponent = 8'h0;
				o_mantissa = 23'h0;
                        end else begin // Passed all corner cases
				adder_a_in = A_i;
				adder_b_in = {~B_i[31], B_i[30:0]};
				o_sign = 1'b0;
				o_exponent = adder_out[30:23];
				o_mantissa = adder_out[22:0];
			end
		end
		else if (MADD) begin   // FIXME the corner cases need to be reconsidered 
		    // if a is NaN return NaN
			if (a_exponent == 255 && a_mantissa != 0) begin
				o_sign = a_sign;
				o_exponent = 255;
				o_mantissa = a_mantissa;  // if b is NaN return NaN
			end else if (b_exponent == 255 && b_mantissa != 0) begin
				o_sign = b_sign;
				o_exponent = 255;
				o_mantissa = b_mantissa;  // if c is 0 return a*b
			end else if ((c_exponent == 0) && (c_mantissa == 0)) begin
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31];
				o_exponent = multiplier_out[30:23];
				o_mantissa = multiplier_out[22:0];    //If a is 0 or b is 0 or c is NaN return c 
			end else if ((b_exponent == 0 && b_mantissa == 0) || (a_exponent == 0) && (a_mantissa == 0) || (c_exponent == 255 && c_mantissa != 0)) begin
				o_sign = c_sign;
				o_exponent = c_exponent;
				o_mantissa = c_mantissa;
			//if a is inf or b is inf or c is inf return inf
			end else if (a_exponent == 255) begin
				o_sign = a_sign ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (b_exponent == 255) begin
				o_sign = b_sign ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (c_exponent == 255) begin
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31] ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin 
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				adder_c_in = C_i;
				o_sign = madder_out[31];
				o_exponent = madder_out[30:23];
				o_mantissa = madder_out[22:0];
			end
		end else if (MSUB) begin
			// if a is NaN return NaN
			if (a_exponent == 255 && a_mantissa != 0) begin
				o_sign = a_sign;
				o_exponent = 255;
				o_mantissa = a_mantissa;  // if b is NaN return NaN
			end else if (b_exponent == 255 && b_mantissa != 0) begin
				o_sign = b_sign;
				o_exponent = 255;
				o_mantissa = b_mantissa;  // if c is 0 return a*b
			end else if ((c_exponent == 0) && (c_mantissa == 0)) begin
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31];
				o_exponent = multiplier_out[30:23];
				o_mantissa = multiplier_out[22:0];    //If a is 0 or b is 0 or c is NaN return c 
			end else if ((b_exponent == 0 && b_mantissa == 0) || (a_exponent == 0) && (a_mantissa == 0) || (c_exponent == 255 && c_mantissa != 0)) begin
				o_sign = c_sign;
				o_exponent = c_exponent;
				o_mantissa = c_mantissa;
			//if a is inf or b is inf or c is inf return inf
			end else if (a_exponent == 255) begin
				o_sign = a_sign ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (b_exponent == 255) begin
				o_sign = b_sign ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (c_exponent == 255) begin
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31] ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin // Passed all corner cases
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				adder_c_in = {~C_i[31],C_i[30:0]};
				o_sign = madder_out[31];
				o_exponent = madder_out[30:23];
				o_mantissa = madder_out[22:0];
			end
		end else if (NMADD) begin 
			// if a is NaN return NaN
			if (a_exponent == 255 && a_mantissa != 0) begin
				o_sign = a_sign;
				o_exponent = 255;
				o_mantissa = a_mantissa;  // if b is NaN return NaN
			end else if (b_exponent == 255 && b_mantissa != 0) begin
				o_sign = b_sign;
				o_exponent = 255;
				o_mantissa = b_mantissa;  // if c is 0 return a*b
			end else if ((c_exponent == 0) && (c_mantissa == 0)) begin
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31];
				o_exponent = multiplier_out[30:23];
				o_mantissa = multiplier_out[22:0];    //If a is 0 or b is 0 or c is NaN return c 
			end else if ((b_exponent == 0 && b_mantissa == 0) || (a_exponent == 0) && (a_mantissa == 0) || (c_exponent == 255 && c_mantissa != 0)) begin
				o_sign = c_sign;
				o_exponent = c_exponent;
				o_mantissa = c_mantissa;
			//if a is inf or b is inf or c is inf return inf
			end else if (a_exponent == 255) begin
				o_sign = a_sign ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (b_exponent == 255) begin
				o_sign = b_sign ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (c_exponent == 255) begin
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31] ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin // Passed all corner cases
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				adder_c_in = C_i;
				o_sign = ~madder_out[31];
				o_exponent = madder_out[30:23];
				o_mantissa = madder_out[22:0];
			end
		end else if (NMSUB) begin //NMSUB
			// if a is NaN return NaN
			if (a_exponent == 255 && a_mantissa != 0) begin
				o_sign = a_sign;
				o_exponent = 255;
				o_mantissa = a_mantissa;  // if b is NaN return NaN
			end else if (b_exponent == 255 && b_mantissa != 0) begin
				o_sign = b_sign;
				o_exponent = 255;
				o_mantissa = b_mantissa;  // if c is 0 return a*b
			end else if ((c_exponent == 0) && (c_mantissa == 0)) begin
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31];
				o_exponent = multiplier_out[30:23];
				o_mantissa = multiplier_out[22:0];    //If a is 0 or b is 0 or c is NaN return c 
			end else if ((b_exponent == 0 && b_mantissa == 0) || (a_exponent == 0) && (a_mantissa == 0) || (c_exponent == 255 && c_mantissa != 0)) begin
				o_sign = c_sign;
				o_exponent = c_exponent;
				o_mantissa = c_mantissa;
			//if a is inf or b is inf or c is inf return inf
			end else if (a_exponent == 255) begin
				o_sign = a_sign ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (b_exponent == 255) begin
				o_sign = b_sign ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else if (c_exponent == 255) begin
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				o_sign = multiplier_out[31] ^ c_sign;
				o_exponent = 255;
				o_mantissa = 0;
			end else begin // Passed all corner cases
				multiplier_a_in = A_i;
				multiplier_b_in = B_i;
				adder_c_in = {~C_i[31],C_i[30:0]};
				o_sign = ~madder_out[31];
				o_exponent = madder_out[30:23];
				o_mantissa = madder_out[22:0];
			end
		end else if (EQ) begin  
		    // if either a or b is NaN
			if ((a_exponent == 255 && a_mantissa != 0) || (b_exponent == 255) && (b_mantissa != 0)) begin
				exception_flag_o = 1'b1;
				comparison_result_o = 1'b0;
			end
			else begin
				eq_a_in = A_i;
				eq_b_in = B_i;
				comparison_result_o = eq_out;
			end
		end else begin        // LT
			if ((a_exponent == 255 && a_mantissa != 0) || (b_exponent == 255) && (b_mantissa != 0)) begin
				exception_flag_o = 1'b1;
				comparison_result_o = 1'b0;
			end
			else begin
				less_a_in = A_i;
				less_b_in = B_i;
				comparison_result_o = less_out;
			end
		end

	end 
endmodule


module adder(a, b, out);
  input  [31:0] a, b;
  output [31:0] out;

  wire [31:0] out;
  reg a_sign;
  reg [7:0] a_exponent;
  reg [23:0] a_mantissa;
  reg b_sign;
  reg [7:0] b_exponent;
  reg [23:0] b_mantissa;

  reg o_sign;
  reg [7:0] o_exponent;
  reg [24:0] o_mantissa;

  reg [7:0] diff;
  reg [23:0] tmp_mantissa;
  reg [7:0] tmp_exponent;


  reg  [7:0] i_e;
  reg  [24:0] i_m;
  wire [7:0] o_e;
  wire [24:0] o_m;

  addition_normaliser norm1
  (
    .in_e(i_e),
    .in_m(i_m),
    .out_e(o_e),
    .out_m(o_m)
  );

  assign out[31] = o_sign;
  assign out[30:23] = o_exponent;
  assign out[22:0] = o_mantissa[22:0];

  always_comb begin
		a_sign = a[31];
		if(a[30:23] == 0) begin
			a_exponent = 8'b00000001;        // 若阶数为0，则让a阶数+1，位数右移一位
			a_mantissa = {1'b0, a[22:0]};
		end else begin
			a_exponent = a[30:23];
			a_mantissa = {1'b1, a[22:0]};    // CONFUESD 不是很懂这个1是什么意思
		end
		b_sign = b[31];
		if(b[30:23] == 0) begin
			b_exponent = 8'b00000001;
			b_mantissa = {1'b0, b[22:0]};
		end else begin
			b_exponent = b[30:23];
			b_mantissa = {1'b1, b[22:0]};
		end
    if (a_exponent == b_exponent) begin // Equal exponents
      o_exponent = a_exponent;
      if (a_sign == b_sign) begin // Equal signs = add
        o_mantissa = a_mantissa + b_mantissa;   // 尾数设计多出一位是为了尾数相加溢出时可以知道确实溢出了
        //Signify to shift
        o_mantissa[24] = 1;                     // CONFUSED
        o_sign = a_sign;
      end else begin // result_opposite signs = subtract
        if(a_mantissa > b_mantissa) begin
          o_mantissa = a_mantissa - b_mantissa;
          o_sign = a_sign;
        end else begin
          o_mantissa = b_mantissa - a_mantissa;
          o_sign = b_sign;
        end
      end
    end else begin //Unequal exponents
      if (a_exponent > b_exponent) begin // A_i is bigger
        o_exponent = a_exponent;
        o_sign = a_sign;
	    diff = a_exponent - b_exponent;
        tmp_mantissa = b_mantissa >> diff;
        if (a_sign == b_sign)
          o_mantissa = a_mantissa + tmp_mantissa;
        else
          o_mantissa = a_mantissa - tmp_mantissa;
      end else if (a_exponent < b_exponent) begin // B_i is bigger
        o_exponent = b_exponent;
        o_sign = b_sign;
        diff = b_exponent - a_exponent;
        tmp_mantissa = a_mantissa >> diff;
        if (a_sign == b_sign) begin
          o_mantissa = b_mantissa + tmp_mantissa;
        end else begin
					o_mantissa = b_mantissa - tmp_mantissa;
        end
      end
    end
    if(o_mantissa[24] == 1) begin
      o_exponent = o_exponent + 1;
      o_mantissa = o_mantissa >> 1;
    end else if((o_mantissa[23] != 1) && (o_exponent != 0)) begin
      i_e = o_exponent;
      i_m = o_mantissa;
      o_exponent = o_e;
      o_mantissa = o_m;
    end
  end
endmodule

module multiplier(a, b, out);
  input  [31:0] a, b;
  output [31:0] out;

  wire [31:0] out;
	reg a_sign;
  reg [7:0] a_exponent;
  reg [23:0] a_mantissa;
	reg b_sign;
  reg [7:0] b_exponent;
  reg [23:0] b_mantissa;

  reg o_sign;
  reg [7:0] o_exponent;
  reg [24:0] o_mantissa;

	reg [47:0] product;

  assign out[31] = o_sign;
  assign out[30:23] = o_exponent;
  assign out[22:0] = o_mantissa[22:0];

	reg  [7:0] i_e;
	reg  [47:0] i_m;
	wire [7:0] o_e;
	wire [47:0] o_m;

	multiplication_normaliser norm1
	(
		.in_e(i_e),
		.in_m(i_m),
		.out_e(o_e),
		.out_m(o_m)
	);


  always @ ( * ) begin
		a_sign = a[31];
		if(a[30:23] == 0) begin
			a_exponent = 8'b00000001;
			a_mantissa = {1'b0, a[22:0]};
		end else begin
			a_exponent = a[30:23];
			a_mantissa = {1'b1, a[22:0]};
		end
		b_sign = b[31];
		if(b[30:23] == 0) begin
			b_exponent = 8'b00000001;
			b_mantissa = {1'b0, b[22:0]};
		end else begin
			b_exponent = b[30:23];
			b_mantissa = {1'b1, b[22:0]};
		end
    o_sign = a_sign ^ b_sign;
    o_exponent = a_exponent + b_exponent - 127;
    product = a_mantissa * b_mantissa;
		// Normalization
    if(product[47] == 1) begin
      o_exponent = o_exponent + 1;
      product = product >> 1;
    end else if((product[46] != 1) && (o_exponent != 0)) begin
      i_e = o_exponent;
      i_m = product;
      o_exponent = o_e;
      product = o_m;
    end
		o_mantissa = product[46:23];
	end
endmodule

module addition_normaliser(in_e, in_m, out_e, out_m);
  input [7:0] in_e;
  input [24:0] in_m;
  output [7:0] out_e;
  output [24:0] out_m;

  wire [7:0] in_e;
  wire [24:0] in_m;
  reg [7:0] out_e;
  reg [24:0] out_m;

  always @ ( * ) begin
		if (in_m[23:3] == 21'b000000000000000000001) begin
			out_e = in_e - 20;
			out_m = in_m << 20;
		end else if (in_m[23:4] == 20'b00000000000000000001) begin
			out_e = in_e - 19;
			out_m = in_m << 19;
		end else if (in_m[23:5] == 19'b0000000000000000001) begin
			out_e = in_e - 18;
			out_m = in_m << 18;
		end else if (in_m[23:6] == 18'b000000000000000001) begin
			out_e = in_e - 17;
			out_m = in_m << 17;
		end else if (in_m[23:7] == 17'b00000000000000001) begin
			out_e = in_e - 16;
			out_m = in_m << 16;
		end else if (in_m[23:8] == 16'b0000000000000001) begin
			out_e = in_e - 15;
			out_m = in_m << 15;
		end else if (in_m[23:9] == 15'b000000000000001) begin
			out_e = in_e - 14;
			out_m = in_m << 14;
		end else if (in_m[23:10] == 14'b00000000000001) begin
			out_e = in_e - 13;
			out_m = in_m << 13;
		end else if (in_m[23:11] == 13'b0000000000001) begin
			out_e = in_e - 12;
			out_m = in_m << 12;
		end else if (in_m[23:12] == 12'b000000000001) begin
			out_e = in_e - 11;
			out_m = in_m << 11;
		end else if (in_m[23:13] == 11'b00000000001) begin
			out_e = in_e - 10;
			out_m = in_m << 10;
		end else if (in_m[23:14] == 10'b0000000001) begin
			out_e = in_e - 9;
			out_m = in_m << 9;
		end else if (in_m[23:15] == 9'b000000001) begin
			out_e = in_e - 8;
			out_m = in_m << 8;
		end else if (in_m[23:16] == 8'b00000001) begin
			out_e = in_e - 7;
			out_m = in_m << 7;
		end else if (in_m[23:17] == 7'b0000001) begin
			out_e = in_e - 6;
			out_m = in_m << 6;
		end else if (in_m[23:18] == 6'b000001) begin
			out_e = in_e - 5;
			out_m = in_m << 5;
		end else if (in_m[23:19] == 5'b00001) begin
			out_e = in_e - 4;
			out_m = in_m << 4;
		end else if (in_m[23:20] == 4'b0001) begin
			out_e = in_e - 3;
			out_m = in_m << 3;
		end else if (in_m[23:21] == 3'b001) begin
			out_e = in_e - 2;
			out_m = in_m << 2;
		end else if (in_m[23:22] == 2'b01) begin
			out_e = in_e - 1;
			out_m = in_m << 1;
		end
  end
endmodule

module multiplication_normaliser(in_e, in_m, out_e, out_m);
  input [7:0] in_e;
  input [47:0] in_m;
  output [7:0] out_e;
  output [47:0] out_m;

  wire [7:0] in_e;
  wire [47:0] in_m;
  reg [7:0] out_e;
  reg [47:0] out_m;

  always @ ( * ) begin
	  if (in_m[46:41] == 6'b000001) begin
			out_e = in_e - 5;
			out_m = in_m << 5;
		end else if (in_m[46:42] == 5'b00001) begin
			out_e = in_e - 4;
			out_m = in_m << 4;
		end else if (in_m[46:43] == 4'b0001) begin
			out_e = in_e - 3;
			out_m = in_m << 3;
		end else if (in_m[46:44] == 3'b001) begin
			out_e = in_e - 2;
			out_m = in_m << 2;
		end else if (in_m[46:45] == 2'b01) begin
			out_e = in_e - 1;
			out_m = in_m << 1;
		end
  end
endmodule

module fless(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire c
    );
    wire s_a = a[31];
    wire s_b = b[31];
    wire [7:0] e_a = a[30:23];
    wire [7:0] e_b = b[30:23];
    wire [22:0] m_a = a[22:0];
    wire [22:0] m_b = b[22:0];
    
    wire [1:0] sel_s = 
    (~s_a & s_b) ? 0 : 
    (s_a & ~s_b) ? 1 :
    (s_a & s_b) ? 2: 3;
    
    assign c = 
    (a == 32'h80000000 && b == 32'h00000000) ? 0 :
    (sel_s == 1) ? 1 : 
    (sel_s == 2 && e_a > e_b) ? 1 :
    (sel_s == 3 && e_a < e_b) ? 1 :
    (sel_s == 2 && e_a == e_b && m_a > m_b) ? 1 :
    (sel_s == 3 && e_a == e_b && m_a < m_b) ? 1 : 0;
endmodule


module feq(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire c
    );
    assign c = 
    (a == 32'h80000000 && b == 32'h00000000) ? 1 :
    (a == 32'h00000000 && b == 32'h80000000) ? 1 :
    a == b ? 1 :
    0;
endmodule
