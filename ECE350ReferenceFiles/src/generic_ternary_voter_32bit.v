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
	assign invalidOutput = a_nequals_b & b_nequals_c & a_nequals_c;
	
	assign out = (a & b) | (b & c) | (a & c);
endmodule