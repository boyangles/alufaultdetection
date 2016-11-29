module mult_fault(data_operandA, data_operandB, result, mult_exception, clock, ctrl_flip, datainput_ready, dataoutput_ready);
	input signed [31:0] data_operandA;
   input signed [15:0] data_operandB;
	input clock;
	input ctrl_flip;
	output signed [31:0] result;
	output datainput_ready, dataoutput_ready;
	output mult_exception;
	wire [15:0] exception;	
	wire signed [48:0] initial_data[8:0], temp_wire[7:0]; // Initialize
	wire signed [31:0] shift_wire[7:0], alu_result_wire[7:0]; // Shift result and ALU result
	wire signed [7:0] ctrl_shift, ctrl_alu, alu_enable; // enable and ctrl bits
	
	// Create the initial block
	assign initial_data[0][48:17] = 1'b0; // initial 32 bits = 0
	assign initial_data[0][16:1]  = data_operandB; // next 16 bits = multiplier
	assign initial_data[0][0] = 1'b0; // add the trailing 0
	
	wire[9:0] dff_array;
	//assign dff_array[8:0] = 0;
	
	// wire that is nor of all dffs
	wire nor_wire = ~|dff_array;
	
//	assign datainput_ready = nor_wire;
	assign datainput_ready = 1'b1;

	
	my_dff dff5(.d(nor_wire), .aclr(1'b0), .clk(clock), .q(dff_array[0]));
	genvar i, j, k, l;
	generate
	for (i=0; i<8; i=i+1) begin: loop1
		// Takes the last 3 bits and sends them to control
		multdiv_control mdc1(.sel(initial_data[i][2:0]), 
									.ctrl_shift(ctrl_shift[i]), 
									.ctrl_alu(ctrl_alu[i]), 
									.alu_enable(alu_enable[i]));
									
		// Perform shift if necessary
		assign shift_wire[i] = ctrl_shift[i] ? (data_operandA << 1) : data_operandA;
		
		// Perform alu op if necessary
		multdiv_alu alu(.alu_enable(alu_enable[i]), 
						.ctrl_alu(ctrl_alu[i]), 
						.inA(initial_data[i][48:17]), 
						.inB(shift_wire[i]), 
						.out(alu_result_wire[i]));
						
		// replace first 32 bits with alu result
		for (j=48; j>16; j=j-1) begin: loop2
			assign temp_wire[i][j] = alu_result_wire[i][j-17];
		end
		
		for (k=16; k>-1; k=k-1) begin: loop3
			assign temp_wire[i][k] = initial_data[i][k];
		end
		// Shift by 2
		assign initial_data[i+1] = temp_wire[i]>>>2;
		my_dff dff6(.d(dff_array[i]), .aclr(1'b0), .clk(clock), .q(dff_array[i+1]));
	end
	my_dff dff7(.d(dff_array[8]), .aclr(1'b0), .clk(clock), .q(dff_array[9]));
//	assign dataoutput_ready = dff_array[9];
	assign dataoutput_ready = 1'b1;
	assign result[31:8] = initial_data[8][32:9];
	assign result[6:0] = initial_data[8][7:1];
	flip_bit fault5(.currVal(initial_data[8][8]), .ctrl(ctrl_flip), .outVal(result[7]));
	
	wire [15:0] exception_wire;
	for (l=32; l<48; l=l+1) begin: loop4
		assign exception_wire[l-32] = initial_data[8][l] ^ (data_operandA[31] ^ data_operandB[15]);
	end
	assign mult_exception = |exception_wire;
	//assign mult_exception = &(initial_data[8][47:32]) & (data_operandA[31] ^ data_operandB[15]));
	
	endgenerate
endmodule

module div_fault(data_operandA, data_operandB, result, clock, ctrl_flip, datainput_ready, dataoutput_ready, outputRemainder);
	input signed [31:0] data_operandA;
	input signed [15:0] data_operandB;
	input clock, ctrl_flip;
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
	assign result[31:3] = quotient_sign ? converted_quotient[31:3] : quotient[31:3];
	assign result[1:0] = quotient_sign ? converted_quotient[1:0] : quotient[1:0];
	wire temp;
	assign temp = quotient_sign ? converted_quotient[2] : quotient[2];
	
	flip_bit fault6(.currVal(temp), .ctrl(ctrl_flip), .outVal(result[2]));
	
endmodule