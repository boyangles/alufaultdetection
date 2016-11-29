module abl17_alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan);
	input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
   output [31:0] data_result;
   output isNotEqual, isLessThan;
	
	assign data_result = 32'b0;
	assign isNotEqual = 1'b0;
	assign isLessThan = 1'b0;

endmodule

module abl17_alu_fault(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, ctrl_adder_flip1, ctrl_adder_flip2, ctrl_shift_flip, data_result, isNotEqual, isLessThan);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
	input ctrl_adder_flip1, ctrl_adder_flip2, ctrl_shift_flip;
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
	
	// FIRST LEVEL Gs and Ps respectively
//	wire [31:0] and_AB_result;
//	assign and_AB_result = data_operandA & notB_mux_result;
//	
//	wire [31:0] or_AB_result;
//	assign or_AB_result = data_operandA | notB_mux_result;
	
	wire[31:0] adder_result;
	abl17_adder_32bit_fault adder1(.a(data_operandA), .b(notB_mux_result), .cin(subOpcode_cin), .ctrl_flip_16(ctrl_adder_flip1), .ctrl_flip_4(ctrl_adder_flip2), .sum(adder_result));
	
	wire [31:0] and_result;
	assign and_result = data_operandA & data_operandB;
	
	wire [31:0] or_result;
	assign or_result = data_operandA | data_operandB;
	
	wire [3:0] flip_shiftamt;
	flip_bit fault_ho(.currVal(ctrl_shiftamt[0]), .ctrl(ctrl_shift_flip), .outVal(flip_shiftamt[0]));
	assign flip_shiftamt[3:1] = ctrl_shiftamt[3:1];

	wire[31:0] sll_result;
	barrel_sll_32bit barrel_sll(.in(data_operandA), .shamt(flip_shiftamt), .out(sll_result)); // SLL for A!!!
	
	wire[31:0] sra_result;
	barrel_sra_32bit barrel_sra(.in(data_operandA), .shamt(flip_shiftamt), .out(sra_result)); // SRA for A!!!
	
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
	
endmodule

////////////////////////////////////////////////////
////////////////////////////////////////////////////