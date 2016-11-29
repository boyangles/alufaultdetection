/**
*
*
*
*
*
*
*
*
* 			Andrew's MultDiv Code:
*
*
*
*
*
*
*
*/

module multdiv_fault(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, ctrl_flip_mult, ctrl_flip_div, data_result, out_remainder, data_exception, data_inputRDY, data_resultRDY);
   input signed [31:0] data_operandA;
   input signed [15:0] data_operandB;
   input ctrl_MULT, ctrl_DIV, clock;
	input ctrl_flip_mult, ctrl_flip_div;
   output signed [31:0] data_result; 
	output [31:0] out_remainder;
   output data_exception, data_inputRDY, data_resultRDY;
	wire [2:0] datainput_readys, dataresult_readys;
	wire signed [31:0] results[2:0];
	wire [1:0] enable;
	wire[31:0]my_tristates[3:0];
	wire my_tristates2[3:0];
	wire my_tristates3[3:0];
	wire [3:0] decoder_result;
	
	genvar i;
	generate
	for (i=0; i<4; i=i+1) begin: loop1
		tristate my_tristate(.in(my_tristates[i]), .oe(decoder_result[i]), .out(data_result));
		tristate1 my_tristate2(.in(my_tristates2[i]), .enable(decoder_result[i]), .out(data_inputRDY));
		tristate1 my_tristate3(.in(my_tristates3[i]), .enable(decoder_result[i]), .out(data_resultRDY));
	end
	endgenerate
	
	assign my_tristates[0] = 32'b0;
	assign my_tristates2[0] = 1'b1;
	assign my_tristates3[0] = 1'b0;
	
	assign enable[0] = ctrl_MULT;
	assign enable[1] = ctrl_DIV;
	
	// 0 = do nothing, 1 = mult, 2 = div
	decoder8 mydecoder(enable, decoder_result);
	
	wire mult_exception;
	mult_fault mult1(data_operandA, data_operandB, my_tristates[1], mult_exception, clock, ctrl_flip_mult, my_tristates2[1], my_tristates3[1]);
	// Get result
	//assign mult_result = initial_data;
	div_fault div1(data_operandA, data_operandB, my_tristates[2], clock, ctrl_flip_div, my_tristates2[2], my_tristates3[2], out_remainder);
	
	assign data_exception = ((~|data_operandB[15:0] & ctrl_DIV) | (mult_exception & ctrl_MULT));
//	assign data_inputRDY = 1'b1;
//	assign data_resultRDY = 1'b1;
	//assign data_result[31:0] = results[2];
endmodule