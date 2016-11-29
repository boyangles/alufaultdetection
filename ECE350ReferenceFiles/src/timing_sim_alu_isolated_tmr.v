module timing_sim_alu_isolated_tmr(
inA1, 
inA2, 
inA3, 
inB1, 
inB2, 
inB3, 
ctrl_ALUopcode, 
ctrl_shiftamt,
 
errorDetected_result, 
invalidOutput_result, 
out_result,

errorDetected_isNotEqual,
invalidOutput_isNotEqual,
out_isNotEqual,

errorDetected_isLessThan,
invalidOutput_isLessThan,
out_isLessThan
);
	input [31:0] inA1, inA2, inA3, inB1, inB2, inB3;
	input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
	
	output errorDetected_result, invalidOutput_result;
	output [31:0] out_result;
	
	output errorDetected_isNotEqual, invalidOutput_isNotEqual;
	output out_isNotEqual;
	
	output errorDetected_isLessThan, invalidOutput_isLessThan;
	output out_isLessThan;
	
	wire [31:0] data_result1, data_result2, data_result3;
	wire isNotEqual1, isNotEqual2, isNotEqual3;
	wire isLessThan1, isLessThan2, isLessThan3;
	
	abl17_alu alu1(
		.data_operandA(inA1), 
		.data_operandB(inB1), 
		.ctrl_ALUopcode(ctrl_ALUopcode), 
		.ctrl_shiftamt(ctrl_shiftamt), 
		.data_result(data_result1), 
		.isNotEqual(isNotEqual1), 
		.isLessThan(isLessThan1)
	);
	
	abl17_alu alu2(
		.data_operandA(inA2), 
		.data_operandB(inB2), 
		.ctrl_ALUopcode(ctrl_ALUopcode), 
		.ctrl_shiftamt(ctrl_shiftamt), 
		.data_result(data_result2), 
		.isNotEqual(isNotEqual2), 
		.isLessThan(isLessThan2)
	);
	
	abl17_alu alu3(
		.data_operandA(inA3), 
		.data_operandB(inB3), 
		.ctrl_ALUopcode(ctrl_ALUopcode), 
		.ctrl_shiftamt(ctrl_shiftamt), 
		.data_result(data_result3), 
		.isNotEqual(isNotEqual3), 
		.isLessThan(isLessThan3)
	);
	
	generic_ternary_voter_32bit result_voter(
		.a(data_result1), 
		.b(data_result2), 
		.c(data_result3), 
		.errorDetected(errorDetected_result), 
		.invalidOutput(invalidOutput_result), 
		.out(out_result)
	);
	
	generic_ternary_voter_1bit isNotEqual_voter(
		.a(isNotEqual1), 
		.b(isNotEqual2), 
		.c(isNotEqual3), 
		.errorDetected(errorDetected_isNotEqual), 
		.invalidOutput(invalidOutput_isNotEqual), 
		.out(out_isNotEqual)	
	);
	
	generic_ternary_voter_1bit isLessThan_voter(
		.a(isLessThan1), 
		.b(isLessThan2), 
		.c(isLessThan3), 
		.errorDetected(errorDetected_isLessThan), 
		.invalidOutput(invalidOutput_isLessThan), 
		.out(out_isLessThan)	
	);
endmodule

module generic_ternary_voter_32bit(a, b, c, errorDetected, invalidOutput, out);
	input [31:0] a, b, c;
	output [31:0] out;
	output errorDetected;
	output invalidOutput;
	
	wire [31:0] a_equals_b_32_bits; 
	wire [31:0] b_equals_c_32_bits;
	wire [31:0] a_equals_c_32_bits;
	
	assign a_equals_b_32_bits = a ^ b;
	assign b_equals_c_32_bits = b ^ c;
	assign a_equals_c_32_bits = a ^ c;
	
	wire a_nequals_b;
	wire b_nequals_c;
	wire a_nequals_c;
	
	assign a_nequals_b = |a_equals_b_32_bits;
	assign b_nequals_c = |b_equals_c_32_bits;
	assign a_nequals_c = |a_equals_c_32_bits;
	
	assign errorDetected = a_nequals_b | b_nequals_c | a_nequals_c;
	assign invalidOutput = (a_nequals_b & b_nequals_c) | (a_nequals_b & a_nequals_c) | (b_nequals_c & a_nequals_c);
	
	assign out = (a & b) | (b & c) | (a & c);
endmodule

module generic_ternary_voter_1bit(a, b, c, errorDetected, invalidOutput, out);
	input a, b, c;
	output out;
	output errorDetected;
	output invalidOutput;
	
	wire a_equals_b_1_bits; 
	wire b_equals_c_1_bits;
	wire a_equals_c_1_bits;
	
	assign a_equals_b_1_bits = a ^ b;
	assign b_equals_c_1_bits = b ^ c;
	assign a_equals_c_1_bits = a ^ c;
	
	wire a_nequals_b;
	wire b_nequals_c;
	wire a_nequals_c;
	
	assign a_nequals_b = |a_equals_b_1_bits;
	assign b_nequals_c = |b_equals_c_1_bits;
	assign a_nequals_c = |a_equals_c_1_bits;
	
	assign errorDetected = a_nequals_b | b_nequals_c | a_nequals_c;
	assign invalidOutput = (a_nequals_b & b_nequals_c) | (a_nequals_b & a_nequals_c) | (b_nequals_c & a_nequals_c);
	
	assign out = (a & b) | (b & c) | (a & c);
endmodule

/**
*	Helper Modules (includes ALU, generic_ternary_voter_32bit, etc.)
*	Modules Needed:
	- abl17_alu (+)
	- mux_2to1 (+)
	- abl17_adder_32bit (+)
		- abl17_adder_16bit (+)
			- abl17_adder_4bit (+)
				- abl17_adder_1bit (+)
	- barrel_sll_32bit (+)
		- barrel_sll (+)
	- barrel_sra_32bit (+)
		- barrel_sra (+)
	- decoder1 (+)
	- tristate (+)
*/

module abl17_alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
   output [31:0] data_result;
   output isNotEqual, isLessThan;
	
	// OPCODES:
	// ADD: 00000
	// SUBTRACT: 00001
	// AND: 00010
	// OR: 00011
	// SLL: 00100
	// SRA: 00101
	
	parameter add_opcode = 0;
	parameter subtract_opcode = 1;
	parameter and_opcode = 2;
	parameter or_opcode = 3;
	parameter sll_opcode = 4;
	parameter sra_opcode = 5;
	
	wire [31:0] negateB;
	assign negateB = ~data_operandB;

	wire subOpcode_cin;
	assign subOpcode_cin =
			ctrl_ALUopcode == subtract_opcode ? 1'b1 : //Subtraction
			1'b0; //Not Subtraction
			
	wire [31:0] notB_mux_result;
	mux_2to1 notB_mux(.in0(data_operandB), .in1(negateB), .select(subOpcode_cin), .out(notB_mux_result));
	
	wire[31:0] adder_result;
	abl17_adder_32bit adder1(.a(data_operandA), .b(notB_mux_result), .cin(subOpcode_cin), .sum(adder_result));
	
	wire [31:0] and_result;
	assign and_result = data_operandA & data_operandB;
	
	wire [31:0] or_result;
	assign or_result = data_operandA | data_operandB;
	
	wire[31:0] sll_result;
	barrel_sll_32bit barrel_sll(.in(data_operandA), .shamt(ctrl_shiftamt), .out(sll_result)); // SLL for A!!!
	
	wire[31:0] sra_result;
	barrel_sra_32bit barrel_sra(.in(data_operandA), .shamt(ctrl_shiftamt), .out(sra_result)); // SRA for A!!!
	
	wire [31:0] decoder_output;
	decoder1 myDecoder(.inputBin(ctrl_ALUopcode), .outputHot(decoder_output));
	
	wire [31:0] tristate_input [31:0];
	
	assign tristate_input[0] = adder_result;
	assign tristate_input[1] = adder_result;
	assign tristate_input[2] = and_result;
	assign tristate_input[3] = or_result;
	assign tristate_input[4] = sll_result;
	assign tristate_input[5] = sra_result;
	
	genvar j3;
	generate
		for (j3 = 0; j3 < 32; j3 = j3 + 1) begin: loop1j3
			tristate myTristate(.in(tristate_input[j3]), .oe(decoder_output[j3]), .out(data_result));
		end 
	endgenerate
	
	assign isNotEqual = |(adder_result);
			
	assign isLessThan = (data_operandA[31] & !(data_operandB[31])) | 
								(adder_result[31] & !(data_operandA[31]) & !(data_operandB[31])) |
								(adder_result[31] & data_operandA[31] & data_operandB[31]); //Look at MSB because like... 2's complement
	
endmodule

module mux_2to1(in0, in1, select, out);
	input [31:0] in0;
	input [31:0] in1;
	input select;
	output [31:0] out;
	
	assign out = select ? in1 : in0;
endmodule

module abl17_adder_32bit(a, b, cin, sum);
	input [31:0] a;
	input [31:0] b;
	input cin;
	output [31:0] sum;
	
	wire [1:0] cin1;
	wire [1:0] gen1;
	wire [1:0] prop1;
	
	abl17_adder_16bit adder_16bit_1(.a(a[15:0]), .b(b[15:0]), .cin(cin), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[15:0]));
	abl17_adder_16bit adder_16bit_2(.a(a[31:16]), .b(b[31:16]), .cin(cin1[0]), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[31:16]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
endmodule

module abl17_adder_16bit(a, b, cin, gen, prop, sum);
	input [15:0] a;
	input [15:0] b;
	input cin;
	output gen;
	output prop;
	output [15:0] sum;
	
	wire [3:0] cin1;
	wire [3:0] gen1;
	wire [3:0] prop1;
	
	abl17_adder_4bit adder_4bit_1(.a(a[3:0]), .b(b[3:0]), .cin(cin), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[3:0]));
	abl17_adder_4bit adder_4bit_2(.a(a[7:4]), .b(b[7:4]), .cin(cin1[0]), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[7:4]));
	abl17_adder_4bit adder_4bit_3(.a(a[11:8]), .b(b[11:8]), .cin(cin1[1]), .gen(gen1[2]), .prop(prop1[2]), .sum(sum[11:8]));
	abl17_adder_4bit adder_4bit_4(.a(a[15:12]), .b(b[15:12]), .cin(cin1[2]), .gen(gen1[3]), .prop(prop1[3]), .sum(sum[15:12]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
	assign cin1[2] = gen1[2] | (gen1[1] & prop1[2]) | (gen1[0] & prop1[1] & prop1[2]) | (cin & prop1[0] & prop1[1] & prop1[2]);
	assign cin1[3] = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[2] & prop1[3]) | (gen1[0] & prop1[1] & prop1[2] & prop1[3]) | (cin & prop1[0] & prop1[1] & prop1[2] & prop1[3]);
	
	assign gen = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[3] & prop1[2]) | (gen1[0] & prop1[3] & prop1[2] & prop1[1]);
	assign prop = prop1[0] & prop1[1] & prop1[2] & prop1[3];
endmodule

module abl17_adder_4bit(a, b, cin, gen, prop, sum);
	input [3:0] a;
	input [3:0] b;
	input cin;
	output gen;
	output prop;
	output [3:0] sum;
	
	wire [3:0] cin1, gen1, prop1;
	
	abl17_adder_1bit adder1(.a(a[0]), .b(b[0]), .cin(cin), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[0]));
	abl17_adder_1bit adder2(.a(a[1]), .b(b[1]), .cin(cin1[0]), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[1]));
	abl17_adder_1bit adder3(.a(a[2]), .b(b[2]), .cin(cin1[1]), .gen(gen1[2]), .prop(prop1[2]), .sum(sum[2]));
	abl17_adder_1bit adder4(.a(a[3]), .b(b[3]), .cin(cin1[2]), .gen(gen1[3]), .prop(prop1[3]), .sum(sum[3]));

	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
	assign cin1[2] = gen1[2] | (gen1[1] & prop1[2]) | (gen1[0] & prop1[1] & prop1[2]) | (cin & prop1[0] & prop1[1] & prop1[2]);
	assign cin1[3] = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[2] & prop1[3]) | (gen1[0] & prop1[1] & prop1[2] & prop1[3]) | (cin & prop1[0] & prop1[1] & prop1[2] & prop1[3]);
	
	assign gen = gen1[3] | (gen1[2] & prop1[3]) | (gen1[1] & prop1[3] & prop1[2]) | (gen1[0] & prop1[3] & prop1[2] & prop1[1]);
	assign prop = prop1[0] & prop1[1] & prop1[2] & prop1[3];
	
endmodule

module abl17_adder_1bit(a, b, cin, gen, prop, sum);
	input a;
	input b;
	input cin;
	output gen;
	output prop;
	output sum;
	
	assign gen = a & b;
	assign prop = a | b;
	assign sum = (~a & ~b & cin) | (~a & b & ~cin) | (a & ~b & ~cin) | (a & b & cin);
endmodule

module barrel_sll_32bit(in, shamt, out);
	input [31:0] in;
	input [4:0] shamt;
	output [31:0] out;
	
	wire [31:0] barIn [5:0];
	wire [31:0] shiftResult [4:0];
	
	assign barIn[5] = in;
	
	genvar i4;
	generate
		for (i4 = 4; i4 >= 0; i4 = i4 - 1) begin: loop0i4
			barrel_sll myBarrel(.in(barIn[i4+1]), .shamt(2**i4), .out(shiftResult[i4]));
			mux_2to1 myMux(.in0(barIn[i4+1]), .in1(shiftResult[i4]), .select(shamt[i4]), .out(barIn[i4]));
		end
	endgenerate

	assign out = barIn[0];
endmodule

module barrel_sll(in, shamt, out);
	input [31:0] in;
	input [4:0] shamt;
	output [31:0] out;
	
	assign out = (in << shamt);
endmodule

module barrel_sra_32bit(in, shamt, out);
	input [31:0] in;
	input [4:0] shamt;
	output [31:0] out;
	
	wire [31:0] barIn [5:0];
	wire [31:0] shiftResult [4:0];
	
	assign barIn[5] = in;
	
	genvar i5;
	generate
		for (i5 = 4; i5 >= 0; i5 = i5 - 1) begin: loop0i5
			barrel_sra myBarrel(.in(barIn[i5+1]), .shamt(2**i5), .out(shiftResult[i5]));
			mux_2to1 myMux(.in0(barIn[i5+1]), .in1(shiftResult[i5]), .select(shamt[i5]), .out(barIn[i5]));
		end
	endgenerate

	assign out = barIn[0];
endmodule

module barrel_sra(in, shamt, out);
	input signed [31:0] in;
	input [4:0] shamt;
	output signed [31:0] out;
	
	assign out = (in >>> shamt);
endmodule

module decoder1(inputBin, outputHot);
	input [4:0] inputBin;
	output [31:0] outputHot;
	
	wire [31:0] outputHot;
	assign outputHot = (1 << inputBin);
	
endmodule

module tristate(in, oe, out);
	input [31:0] in;
	input oe;
	output [31:0] out;
	
	assign out = oe ? in : 32'bz;
endmodule