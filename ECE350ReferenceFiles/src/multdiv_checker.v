module multdiv_checker(inA, inB, inMultDivResult, inOpcode, inRemainder, outError);
	/**
	* Refer to Figure 4. Multiplier/Divider Sub-Checker in Argus paper
	* TODO: Modulo operation currently uses Verilog's built in operand %. Need to implement using combinational logic.
	*/
	
	input signed [31:0] inA;
	input signed [15:0] inB;
	// Opcodes:
		// Mult -- 00110
		// Div  -- 00111
	input [4:0] inOpcode;
	input signed [31:0] inMultDivResult;
	input [31:0] inRemainder;		// TODO: determine if signed or unsigned
	output outError;
	
	// Constants:
	wire [31:0] zero_32bit;						assign zero_32bit = 32'b00000000000000000000000000000000;
	wire [31:0] mersenne_5;						assign mersenne_5 = 32'b00000000000000000000000000011111;
	wire [31:0] negate_Remainder;				assign negate_Remainder = ~inRemainder;
	wire [31:0] negative_Remainder;			abl17_adder_32bit negativeRemainderAdder(.a(negate_Remainder), 
																											  .b(zero_32bit), 
																											  .cin(is_instruction_division), 
																											  .sum(negative_Remainder)
														);
	
	// Multiplication Opcode
	wire [4:0] opcode_mult;						assign opcode_mult = 5'b00110;
	// Division Opcode
	wire [4:0] opcode_div;						assign opcode_div = 5'b00111;
	
	// &([] ~^ []) determines whether two values are exactly equal
	wire is_instruction_multiplication;		assign is_instruction_multiplication = &(inOpcode ~^ opcode_mult);
	wire is_instruction_division;				assign is_instruction_division = &(inOpcode ~^ opcode_div);
	
	// Determine whether to enable the output of the checker. In other words, if opcodes are neither 00110 nor 00111, disable.
	wire outErrorEnableBit = is_instruction_multiplication | is_instruction_division;
	
	/**
	* Based on Figure 4 in Argus paper:
	*	- mux1 refers to leftmost mux
	*	- mux2 refers to middle mux
	*	- mux3 refers to rightmost mux
	*
	* In each of these implementations, select bits are:
	*  - 0 represents multiplication
	*  - 1 represents division
	*/
	wire [31:0] mux1_output, mux2_output, mux3_output;
	mux_2to1 mux1(			.in0(inA), 
								.in1(inMultDivResult), 
								.select(is_instruction_division), 
								.out(mux1_output)
	);
	mux_2to1 mux2(			.in0(inMultDivResult), 
								.in1(inA), 
								.select(is_instruction_division),
								.out(mux2_output)
	);
	mux_2to1 mux3(			.in0(zero_32bit), 
								.in1(negate_Remainder), 
								.select(is_instruction_division), 
								.out(mux3_output)
	);
	
	/**
	* Based on Figure 4 in Argus paper:
	*	- mod1 refers to leftmost modM
	* 	- mod2 refers to first from left modM
	* 	- mod3 refers to second from left modM
	*	- mod4 refers to rightmost modM
	*/
	wire [31:0] mod1, mod2, mod3, mod4;
	assign mod1 = mux1_output % mersenne_5;
	assign mod2 = inB % mersenne_5;
	assign mod3 = mux2_output % mersenne_5;
	assign mod4 = mux3_output % mersenne_5;
	
	wire[31:0] mult_result, add_result;
	assign mult_result = mod1 * mod2; //TODO: Change this
	assign add_result = mod3 + mod4; //TODO: change this
	
	wire[31:0] final_candidate_1, final_candidate_2;
	assign final_candidate_1 = mult_result % mersenne_5;
	assign final_candidate_2 = add_result % mersenne_5;
	assign outError = ~&(final_candidate_2 ~^ final_candidate_1);
endmodule

/**
* ##########################
* #                        #
* #                        #
* #     Helper Modules     #
* ##########################
*
*/

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