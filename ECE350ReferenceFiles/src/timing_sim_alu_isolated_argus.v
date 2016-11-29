module timing_sim_alu_isolated_argus(
inA,
inB, 
ctrl_ALUopcode, 
ctrl_shiftamt,
data_result,
adder_has_error, 
sra_has_error, 
sll_has_error
);
	input [31:0] inA, inB;
	input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
	output data_result; assign data_result = data_result1;
	output adder_has_error, sra_has_error, sll_has_error;
	
	wire [31:0] data_result1;
	wire isNotEqual1;
	wire isLessThan1;
	
	abl17_alu alu1(
		.data_operandA(inA), 
		.data_operandB(inB), 
		.ctrl_ALUopcode(ctrl_ALUopcode), 
		.ctrl_shiftamt(ctrl_shiftamt), 
		.data_result(data_result1), 
		.isNotEqual(isNotEqual1), 
		.isLessThan(isLessThan1),
		.adder_has_error(adder_has_error), 
		.sra_has_error(sra_has_error), 
		.sll_has_error(sll_has_error)
	);
endmodule

/*
,						adder_checker_is_enabled
,						shift_checker_is_enabled
,						adder_has_error
,						sra_has_error
,						sll_has_error
*/

module abl17_alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan, adder_has_error, sra_has_error, sll_has_error);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
   output [31:0] data_result;
   output isNotEqual, isLessThan;
	output adder_has_error, sra_has_error, sll_has_error;
	
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
	
	// FIRST LEVEL Gs and Ps respectively
//	wire [31:0] and_AB_result;
//	assign and_AB_result = data_operandA & notB_mux_result;
//	
//	wire [31:0] or_AB_result;
//	assign or_AB_result = data_operandA | notB_mux_result;
	
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
	
//	assign isNotEqual =
//			adder_result == (32'b0) ? (1'b0) :
//			(1'b1); //adderResult != 0
	assign isNotEqual = |(adder_result);
			
	assign isLessThan = (data_operandA[31] & !(data_operandB[31])) | 
								(adder_result[31] & !(data_operandA[31]) & !(data_operandB[31])) |
								(adder_result[31] & data_operandA[31] & data_operandB[31]); //Look at MSB because like... 2's complement
								
								
	/* ECE 554 Checkers Here */
	
	wire adder_error, sra_error, sll_error;
	assign adder_has_error = adder_error;
	assign sra_has_error = sra_error;
	assign sll_has_error = sll_error;
	
	adder_checker my_checker(.a(data_operandA), .b(notB_mux_result), .cin(subOpcode_cin), .sum(adder_result), .error(adder_error));
	sra_checker my_sra_checker(.a(data_operandA), .ctrl_shiftamt(ctrl_shiftamt), .sra_result(sra_result), .err(sra_error));
	sll_checker my_sll_checker(.a(data_operandA), .ctrl_shiftamt(ctrl_shiftamt), .sll_result(sll_result), .err(sll_error));

	
	
	
endmodule

// Add/Subtract/SRA/SLL Subcheckers
module adder_checker(a, b, cin, sum, error);
	input[31:0] a;
	input[31:0] b;
	input cin;
	input[31:0] sum;
	
	output error;
	
	wire cout[31:0];
	wire[31:0] and_gate_inputs;
	// first element
	one_bit_subchecker one_bit_subchecker_0(.a(a[0]), .b(b[0]), .cin(cin), .s(sum[0]), .cout(cout[0]), .err(and_gate_inputs[0]));
	
	// loop
	genvar i;
	generate
	for (i=1; i<32; i=i+1) begin: loop1
		one_bit_subchecker one_bit_subchecker_i(.a(a[i]), .b(b[i]), .cin(cout[i-1]), .s(sum[i]), .cout(cout[i]), .err(and_gate_inputs[i]));
	end
	endgenerate
	
	assign error = |and_gate_inputs;
	
endmodule

module one_bit_subchecker(a, b, cin, s, cout, err);
	input a;
	input b;
	input cin;
	input s;
	output cout;
	output err;
	
	wire xor1, xor2;
	assign xor1 = a^b;
	assign xor2 = xor1^s;
	assign err = xor2^cin;
	assign cout = xor1 ? xor2 : b;
endmodule


module sra_checker(a, ctrl_shiftamt, sra_result, err);
	input [31:0] a, sra_result;
	input [4:0] ctrl_shiftamt;
	output err;
	
	wire[31:0] shifted_input;
	wire[31:0] temp;
	
	assign temp = a >>> ctrl_shiftamt;
	assign err = |(temp^sra_result);
endmodule

module sll_checker(a, ctrl_shiftamt, sll_result, err);
	input [31:0] a, sll_result;
	input [4:0] ctrl_shiftamt;
	output err;
	
	wire[31:0] shifted_input;
	wire[31:0] temp, mask, mask_shifted, masked_result;
	
	assign temp = sll_result >>> ctrl_shiftamt;
	
	// mask shiftamt bits
	assign mask = 32'b11111111111111111111111111111111 >> ctrl_shiftamt;
	assign masked_result = mask & a;
	
	assign err = |(temp^masked_result);
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