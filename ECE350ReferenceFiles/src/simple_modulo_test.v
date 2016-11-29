module simple_modulo_test(in1, in2, in3, in4, outError, mult_result, add_result);
	input [31:0] in1, in2, in3, in4;
	output outError;
	output [31:0] mult_result, add_result;
	
	/**
	* Based on Figure 4 in Argus paper:
	*	- mod1 refers to leftmost modM
	* 	- mod2 refers to first from left modM
	* 	- mod3 refers to second from left modM
	*	- mod4 refers to rightmost modM
	*/
	wire [31:0] mersenne_5;						assign mersenne_5 = 32'b00000000000000000000000000011111;
	
	wire [31:0] mod1, mod2, mod3, mod4;
	assign mod1 = in1 % mersenne_5;
	assign mod2 = in2 % mersenne_5;
	assign mod3 = in3 % mersenne_5;
	assign mod4 = in4 % mersenne_5;
	
	assign mult_result = mod1 * mod2; //TODO: Change this
	assign add_result = mod3 + mod4; //TODO: change this
	
	wire[31:0] final_candidate_1, final_candidate_2;
	assign final_candidate_1 = in1 % mersenne_5;
	assign final_candidate_2 = in3 % mersenne_5;
	assign outError = ~&(final_candidate_2 ~^ final_candidate_1);
endmodule