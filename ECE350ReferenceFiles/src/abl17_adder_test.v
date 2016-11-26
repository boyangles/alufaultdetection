module abl17_adder_test(a, b, cin, sum_final, ctrl_shiftamt, sll_final, sra_final, sll_error, sra_error, adder_error, wrong);
	input [31:0] a;
	input [31:0] b;
	input [4:0] ctrl_shiftamt;
	input cin;
	input wrong;
	output [31:0] sum_final, sra_final, sll_final;
	output adder_error, sll_error, sra_error;
	
	wire [31:0] sum, sll_result, sra_result;
	
	wire [1:0] cin1;
	wire [1:0] gen1;
	wire [1:0] prop1;
	
	wire [31:0] test_fault, sra_fault, sll_fault;
	
	assign test_fault = 32'b00000000000000000000000000001101;
	assign sra_fault = 32'b00000000000000000000100000001111;
	assign sll_fault = 32'b00000000000000001000000011110000;
	
	abl17_adder_16bit adder_16bit_1(.a(a[15:0]), .b(b[15:0]), .cin(cin), .gen(gen1[0]), .prop(prop1[0]), .sum(sum[15:0]));
	abl17_adder_16bit adder_16bit_2(.a(a[31:16]), .b(b[31:16]), .cin(cin1[0]), .gen(gen1[1]), .prop(prop1[1]), .sum(sum[31:16]));
	
	barrel_shifter_sll s1(.in(a), .out(sll_result), .shift(ctrl_shiftamt));
	barrel_shifter_sra s2(.in(a), .out(sra_result), .shift(ctrl_shiftamt));
	
	assign cin1[0] = gen1[0] | (prop1[0] & cin);
	assign cin1[1] = gen1[1] | (gen1[0] & prop1[1]) | (cin & prop1[0] & prop1[1]) ;
	
	adder_checker my_checker(.a(a), .b(b), .cin(cin), .sum(sum_final), .error(adder_error));
	sra_checker my_sra_checker(.a(a), .ctrl_shiftamt(ctrl_shiftamt), .sra_result(sra_final), .err(sra_error));
	sll_checker my_sll_checker(.a(a), .ctrl_shiftamt(ctrl_shiftamt), .sll_result(sll_final), .err(sll_error));
	
	assign sum_final = wrong ? test_fault : sum;
	assign sra_final = wrong ? sra_fault : sra_result;
	assign sll_final = wrong ? sll_fault : sll_result;
	
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



/*
////////////////////////////////////////////////////

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

////////////////////////////////////////////////////

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

////////////////////////////////////////////////////

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
*/

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




