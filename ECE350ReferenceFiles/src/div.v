module div(data_operandA, data_operandB, result, clock, datainput_ready, dataoutput_ready, outputRemainder);
	input signed [31:0] data_operandA;
	input signed [15:0] data_operandB;
	input clock;
	output signed [31:0] result;
	output datainput_ready, dataoutput_ready;
	output [31:0] outputRemainder; assign outputRemainder = remainder[0];

	wire[32:0] dff_array;
	// wire that is nor of all dffs
	wire nor_wire = ~|dff_array;
	
	// ready state
//	assign datainput_ready = nor_wire;
	assign datainput_ready = 1'b1;
	
	// first dff
	my_dff dff0(.d(nor_wire), .aclr(1'b0), .clk(clock), .q(dff_array[32]));
	
//	genvar i, j;
//	generate
//	for (j=0; j<30; j=j+1) begin: loop1
//		my_dff dff(.d(dff_array[j]), .aclr(1'b0), .clk(clock), .q(dff_array[j+1]));
//	end
//	
	// last dff

	// Make divisor 32 bits
	wire[31:0] denominator;
	assign denominator[15:0] = data_operandB[15:0];
	assign denominator[31:16] = data_operandB >>> 16;

	
	// Change sign of numerator
	wire[31:0] converted_denominator;
	convert conv(.in(denominator), .out(converted_denominator));
	
	// Take the changed sign if originally was negative
	wire[31:0] positive_denominator;
	assign positive_denominator = denominator[31] ? converted_denominator : denominator;
	
	// Change sign of denominator
	wire[31:0] converted_numerator;
	convert conv2(.in(data_operandA), .out(converted_numerator));
	
	// Take the changed sign if originally was negative
	wire[31:0] positive_numerator;
	assign positive_numerator = data_operandA[31] ? converted_numerator : data_operandA;

	
	wire[31:0] remainder[32:0];
	wire[31:0] quotient;
	assign remainder[32] = 32'b0;
	wire isNotEqual[31:0];
	wire isLessThan[31:0];
	wire[31:0] alu_result_wire[31:0];
	wire[31:0] temp_wire[31:0];
	wire[31:0] temp_wire2[31:0];
	genvar i;
   generate
	for (i=31; i>=0; i=i-1) begin: loop2
		assign temp_wire2[i] = (remainder[i+1]<<1);
		assign temp_wire[i][31:1] = temp_wire2[i][31:1];
		assign temp_wire[i][0] = positive_numerator[i];
		thirtytwo_bit_adder ba1(.A(temp_wire[i]), 
										.B(~positive_denominator), 
										.C_in(1'b1), 
										.S(alu_result_wire[i]));
		assign isLessThan[i] = ((temp_wire[i][31] & ~positive_denominator[31])|
								(alu_result_wire[i][31] & ~temp_wire[i][31] & ~positive_denominator[31]) |
								(alu_result_wire[i][31] & temp_wire[i][31] & positive_denominator[31]));
		
		assign remainder[i] = isLessThan[i] ? temp_wire[i] : alu_result_wire[i];
		assign quotient[i] = isLessThan[i] ? 1'b0 : 1'b1;
		my_dff dff(.d(dff_array[i+1]), .aclr(1'b0), .clk(clock), .q(dff_array[i]));
		
	end
	endgenerate
	wire blah;
	
	my_dff dff32(.d(dff_array[0]), .aclr(1'b0), .clk(clock), .q(blah));
	assign dataoutput_ready = 1'b1;
	
	
	wire quotient_sign;
	wire[31:0] converted_quotient;
	assign quotient_sign = (denominator[31] ^ data_operandA[31]);
	convert conv3(.in(quotient), .out(converted_quotient));
	assign result = quotient_sign ? converted_quotient : quotient;
endmodule

// DFF with asynchroneous clear
module my_dff(d, aclr, clk, q);
	input d, aclr, clk;
	output q;
	reg q;
	always @(posedge clk or
			posedge aclr) begin
		if(aclr) begin
			q = 1'b0;
		end 
		else begin
			q = d;
		end
	end
endmodule

module convert(in, out);
	input signed[31:0] in;
	output signed[31:0] out;
	wire signed[31:0] in_negated;
	wire [31:0] one;
	assign in_negated = ~in;
	assign one[31:1] = 0;
	assign one[0] = 1;
	thirtytwo_bit_adder adder(.A(in_negated), .B(one), .C_in(1'b0), .S(out));
endmodule

module thirtytwo_bit_adder(A, B, C_in, S);
	input signed [31:0] A, B;
	input C_in;
	output signed [31:0] S;
	
	wire p0, g0, p1, g1, c1;
	sixteen_bit_adder sba1(.A(A[15:0]), .B(B[15:0]), .C_in(C_in), .S(S[15:0]), .PG(p0), .GG(g0));
	assign c1 = (g0 | (p0 & C_in));
	sixteen_bit_adder sba2(.A(A[31:16]), .B(B[31:16]), .C_in(c1), .S(S[31:16]), .PG(p1), .GG(g1));
	//assign overflow = A[31] & 
	//assign C_out = (g1 | (p1 & c1));
endmodule

module sixteen_bit_adder(A, B, C_in, S, PG, GG);
	input signed [15:0] A, B;
	input C_in;
	output signed [15:0] S;
	output PG, GG;
	
	wire p0, g0, p1, g1, p2, g2, p3, g3, c1, c2, c3;
	four_bit_adder fba1(.A(A[3:0]), .B(B[3:0]), .C_in(C_in), .S(S[3:0]), .PG(p0), .GG(g0));
	assign c1 = (g0 | (p0 & C_in));
	four_bit_adder fba2(.A(A[7:4]), .B(B[7:4]), .C_in(c1), .S(S[7:4]), .PG(p1), .GG(g1));
	assign c2 = (g1 | (p1 & c1));
	four_bit_adder fba3(.A(A[11:8]), .B(B[11:8]), .C_in(c2), .S(S[11:8]), .PG(p2), .GG(g2));
	assign c3 = (g2 | (p2 & c2));
	four_bit_adder fba4(.A(A[15:12]), .B(B[15:12]), .C_in(c3), .S(S[15:12]), .PG(p3), .GG(g3));
	//assign C_out = (g3 | (p3 & c3));
	assign PG = (p0 & p1 & p2 & p3);
	assign GG = (g3 | (g2 & p3) | (g1 & p3 & p2) | (g0 & p3 & p2 & p1));
endmodule

module one_bit_adder(A, B, C_in, S, P, G);
	input A, B, C_in;
	output S, P, G;
	assign P = (A | B);
	assign G = (A & B);
	assign S = (A ^ B ^ C_in);
endmodule

module four_bit_adder(A, B, C_in, S, PG, GG);
	input signed [3:0] A, B;
	input C_in;
	output signed [3:0] S;
	output PG, GG;
	
	wire p0, g0, p1, g1, p2, g2, p3, g3, c1, c2, c3;
	one_bit_adder oba1(.A(A[0]), .B(B[0]), .C_in(C_in), .S(S[0]), .P(p0), .G(g0));
	assign c1 = (g0 | (p0 & C_in));
	one_bit_adder oba2(.A(A[1]), .B(B[1]), .C_in(c1), .S(S[1]), .P(p1), .G(g1));
	assign c2 = (g1 | (p1 & c1));
	one_bit_adder oba3(.A(A[2]), .B(B[2]), .C_in(c2), .S(S[2]), .P(p2), .G(g2));
	assign c3 = (g2 | (p2 & c2));
	one_bit_adder oba4(.A(A[3]), .B(B[3]), .C_in(c3), .S(S[3]), .P(p3), .G(g3));
	//assign C_out = (g3 | (p3 & c3));
	assign PG = (p0 & p1 & p2 & p3);
	assign GG = (g3 | (g2 & p3) | (g1 & p3 & p2) | (g0 & p3 & p2 & p1));
endmodule