module processor_argus(button_drop_in, button_cycle_in, clock, reset, ps2_key_pressed, ps2_out/*, lcd_write, lcd_data, debug_data, debug_addr, out1, out2*/
/* Fetch outputs */
//,						inPC_F_output 						// Output to the PC latch for the next instruction [31:0]
//,						stall_ctrl_output					// Describes whether to stall on a data hazard
//,						outPC_F_output 					// Output from the PC into the instruction memory [31:0]
//,						inAddress_imem_F_output 		// Input to the address for imem [11:0]
//,						outInsn_imem_F_output			//	Output instruction from the imem [31:0]
//,						pcPlusOne_F_output				// PC+1 for the fetch stage [31:0]
/* FD pipeRegister outputs */
//,						branchRecovery_ctrl_output		// Branch Recovery bit
//,						insn_select_F_output				// Output from NOP mux for branch recovery for Fetch part
//,						pcPlusOne_D_output				// Output of PC+1 from FD pipeRegister
//,						insn_D_output						// Output of insn from FD pipeRegister
/* Stalling Logic outputs */
//,						RSEqRD_Stall_DX_output			// Is RS (from D stage) = RD (from X stage)?
//,						RTEqRD_Stall_DX_output			// Is RT (from D stage) = RD (from X stage)?
//,						RDEqRD_Stall_DX_output			// Is RD (from D stage) = RD (from X stage)?
//,						opcodeForRS_Stall_D_output		// Is opcode = 00000 | 00101 | 00010 | 00110 | 01000 for Decode Stage?
//,						opcodeForRD_Stall_D_output		// Is opcode = 00010 | 00100 | 00110 for Decode Stage?
//,						opcodeForRT_Stall_D_output		// Is opcode = 00000 for Decode stage?
//,						opcodeForLoad_Stall_X_output  // Is opcode = 01000 for Execute stage?
//,						stall_ctrl_D_output				// Output for stall ctrl bit
/* Decode stage outputs */
//,						regDst_ctrl_D_output				// RegDst control for D
//,						writeReg_select_output			// Register that is written to regFile... Rd or R31
//,						readReg2_select_output			// Register that correspond to B input/output of regFile
//,						regFileOutputA_D_output			// Register read value A for regFile
//,						regFileOutputB_D_output			// Register read value B for regFile
/* DX pipeRegister outputs */
//,						insn_select_D_output				// Output from NOP mux for branch recovery for Decode part
//, 						stall_select_D_output			// output from stall mux for Stall logic for Decode stage
//,						pcPlusOne_X_output				// Output from pipeRegister into X stage for PC+1
//,						insn_X_output						// Output from pipeRegister into X stage for insn X
//,						dataApre_X_output					// Data for read register A into X stage before selection
//,						dataBpre_X_output					// Data for read register B into X stage before selection
/* AMWX Bypassing outputs */
//,						RSEqRD_AMX_XM_output				// Is RS (from X stage) = RD (from M stage)?
//,						opcodeCheck_AMX_M_output		// Is opcode = 00000 | 00101 for Memory stage?
//,						AMX_ctrl_output					// AMX control bit for MX bypassing mux
//,						RSEqRD_AWX_XW_output				// Is RS (from X stage) = RD (from W stage)?
//,						opcodeCheck_AWX_W_output		// Is opcode = 00000 | 00101 for Writeback stage?
//,						AWX_ctrl_output					// AWX control bit for MX bypassing mux
/* BMWX Bypassing outputs */
//,						BMX_ctrl_output					// BMX control bit for MX bypassing mux
//,						BWX_ctrl_output					// BWX control bit for MX bypassing mux
/* Actual AMWX Bypassing outputs */
//,						dataA_X_output						// Output after bypassing from DX pipeRegister to X stage for A
//,						dataB_X_output						// Output after bypassing from DX pipeRegister to X stage for B
/* Execute stage outputs */
//,						N_val_J1_X_output
//,						imm_SE_X_output
//,						pcPlusOnePlusN_X_output
//,						aluSrc_select_X_output
//,						aluOpcode_final_X_output
//,						alu_result_X_output
//,						b_lt_a_X_output
//,						jump_select_X_output
/* XM pipeRegister outputs */
//,						insn_M_output
//,						dataO_M_output
//,						dataMpre_M_output
/* WM Bypassing outputs */
//,						WM_ctrl_output
/* Actual WM Bypassing outputs */
//,						dataM_M_output
/* Memory stage outputs */
//,						readFromMemory_output
/* MW pipeRegister outputs */
//,						insn_W_output
//,						dataO_W_output
//,						dataD_W_output
/* Write stage outputs */
,						regFile_data_W_output
,						regFile_register_W_output
/* Status output */
//,						status_output
/* R16 to R24 outputs for Connect 4 */
,						reg16_output
,						reg17_output
,						reg18_output
,						reg19_output
,						reg20_output
,						reg21_output
,						reg22_output
,						reg23_output
,						reg24_output


/**
* ECE 554 FINAL PROJECT Outputs:
*/
,						multdiv_remainder
,						multdiv_output_has_error
,						multdiv_checker_is_enabled
,						adder_has_error
,						sra_has_error
,						sll_has_error

/* Output for all registers of regFile */
,						reg1_output
/*,						reg2_output
,						reg3_output
,						reg4_output
,						reg5_output
,						reg6_output
,						reg7_output
,						reg8_output
,						reg9_output
,						reg10_output
,						reg11_output
,						reg12_output
,						reg13_output
,						reg14_output
,						reg15_output

,						reg25_output
,						reg26_output
,						reg27_output
,						reg28_output
,						reg29_output
,						reg30_output
,						reg31_output*/
);

	input				button_drop_in, button_cycle_in;
	input 			clock, reset, ps2_key_pressed;
	input 	[7:0]	ps2_out;
	
	/*
	output 			lcd_write;
	output 	[31:0] 	lcd_data;
	
	// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
	output 	[31:0] 	debug_data;
	output	[11:0]	debug_addr;
	
	output [31:0] out1, out2;
	*/
	wire 			lcd_write;
	wire 	[31:0] 	lcd_data;
	
	// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
	wire 	[31:0] 	debug_data;
	wire	[11:0]	debug_addr;
	
	wire [31:0] out1, out2;
	
	//
	//
	//			THESE ARE DEBUGGING OUTPUTS!!!!!
	//
	//
	/* Fetch outputs */
//	output [31:0] inPC_F_output;							assign inPC_F_output = jump_select_X;
//	output stall_ctrl_output;								assign stall_ctrl_output = stall_ctrl;
//	output [31:0] outPC_F_output;							assign outPC_F_output = outPC_F;
//	output [11:0] inAddress_imem_F_output;				assign inAddress_imem_F_output = pc_F[11:0];
//	output [31:0] outInsn_imem_F_output;				assign outInsn_imem_F_output = insn_F;
//	output [31:0] pcPlusOne_F_output;					assign pcPlusOne_F_output = pcPlusOne_F;
	/* FD pipeRegister outputs */
//	output branchRecovery_ctrl_output;					assign branchRecovery_ctrl_output = branchRecovery_ctrl;
//	output [31:0] insn_select_F_output;					assign insn_select_F_output = insn_select_F;
//	output [31:0] pcPlusOne_D_output;					assign pcPlusOne_D_output = pcPlusOne_D;
//	output [31:0] insn_D_output;							assign insn_D_output = insn_D;
	/* Stalling Logic outputs */
//	output RSEqRD_Stall_DX_output;						assign RSEqRD_Stall_DX_output = RSEqRD_Stall;
//	output RTEqRD_Stall_DX_output;						assign RTEqRD_Stall_DX_output = RTEqRD_Stall;
//	output RDEqRD_Stall_DX_output;						assign RDEqRD_Stall_DX_output = RDEqRD_Stall;
//	output opcodeForRS_Stall_D_output;					assign opcodeForRS_Stall_D_output = opcodeCheck_Stall_FD0;
//	output opcodeForRD_Stall_D_output;					assign opcodeForRD_Stall_D_output = opcodeCheck_Stall_FD2;
//	output opcodeForRT_Stall_D_output;					assign opcodeForRT_Stall_D_output = opcodeCheck_Stall_FD;
//	output opcodeForLoad_Stall_X_output;				assign opcodeForLoad_Stall_X_output = opcodeCheck_Stall_DX;
//	output stall_ctrl_D_output;							assign stall_ctrl_D_output = stall_ctrl;
	/* Decode stage outputs */
//	output regDst_ctrl_D_output;							assign regDst_ctrl_D_output = regDst_ctrl_D;
//	output [4:0] writeReg_select_output;				assign writeReg_select_output = writeReg_select;
//	output [4:0] readReg2_select_output;				assign readReg2_select_output = readReg2_select;
//	output [31:0] regFileOutputA_D_output;				assign regFileOutputA_D_output = regFileOutputA_D;
//	output [31:0] regFileOutputB_D_output;				assign regFileOutputB_D_output = regFileOutputB_D;
	/* DX pipeRegister outputs */
//	output [31:0] insn_select_D_output;					assign insn_select_D_output = insn_select_D;
//	output [31:0] stall_select_D_output;				assign stall_select_D_output = stall_select_D;
//	output [31:0] pcPlusOne_X_output;					assign pcPlusOne_X_output = pcPlusOne_X;
//	output [31:0] insn_X_output;							assign insn_X_output = insn_X;
//	output [31:0] dataApre_X_output;						assign dataApre_X_output = dataApre_X;
//	output [31:0] dataBpre_X_output;						assign dataBpre_X_output = dataBpre_X;
	/* AMWX Bypassing outputs */
//	output RSEqRD_AMX_XM_output;							assign RSEqRD_AMX_XM_output = RSEqRD_AMX;
//	output opcodeCheck_AMX_M_output;						assign opcodeCheck_AMX_M_output = opcodeCheck_AMX;
//	output AMX_ctrl_output;									assign AMX_ctrl_output = AMX_ctrl;
//	output RSEqRD_AWX_XW_output;							assign RSEqRD_AWX_XW_output = RSEqRD_AWX;
//	output opcodeCheck_AWX_W_output;						assign opcodeCheck_AWX_W_output = opcodeCheck_AWX;
//	output AWX_ctrl_output;									assign AWX_ctrl_output = AWX_ctrl;
	/* BMWX Bypassing outputs */
//	output BMX_ctrl_output;									assign BMX_ctrl_output = BMX_ctrl;
//	output BWX_ctrl_output;									assign BWX_ctrl_output = BWX_ctrl;
	/* Actual AMWX Bypassing outputs */
//	output [31:0] dataA_X_output;							assign dataA_X_output = dataA_X;
//	output [31:0] dataB_X_output;							assign dataB_X_output = dataB_X;
	/* Execute stage outputs */
//	output [31:0] N_val_J1_X_output;						assign N_val_J1_X_output = N_val_X;
//	output [31:0] imm_SE_X_output;						assign imm_SE_X_output = imm_SE_X;
//	output [31:0] pcPlusOnePlusN_X_output;				assign pcPlusOnePlusN_X_output = pcPlusOnePlusN_X;
//	output [31:0] aluSrc_select_X_output;				assign aluSrc_select_X_output = aluSrc_select_X;
//	output [31:0] aluOpcode_final_X_output;			assign aluOpcode_final_X_output = aluOpcodeBranch_select_X;
//	output [31:0] alu_result_X_output;					assign alu_result_X_output = alu_result_X;
//	output b_lt_a_X_output; 								assign b_lt_a_X_output = b_lt_a_X;
//	output [31:0] jump_select_X_output;					assign jump_select_X_output = jump_select_X;
	/* XM pipeRegister outputs */
//	output [31:0] insn_M_output; 							assign insn_M_output = insn_M;
//	output [31:0] dataO_M_output;							assign dataO_M_output = dataO_M;
//	output [31:0] dataMpre_M_output;						assign dataMpre_M_output = dataMpre_M;
	/* WM Bypassing outputs */
//	output WM_ctrl_output;									assign WM_ctrl_output = WM_ctrl;
	/* Actual WM Bypassing outputs */
//	output [31:0] dataM_M_output;							assign dataM_M_output = dataM_M;
	/* Memory stage outputs */
//	output [31:0] readFromMemory_output; 				assign readFromMemory_output = readData_M;
	/* MW pipeRegister outputs */
//	output [31:0] insn_W_output;							assign insn_W_output = insn_W;
//	output [31:0] dataO_W_output;							assign dataO_W_output = dataO_W;
//	output [31:0] dataD_W_output;							assign dataD_W_output = dataD_W;
	/* Write stage outputs */
	output [31:0] regFile_data_W_output;				assign regFile_data_W_output = jump_select_W;
	output [4:0] regFile_register_W_output;			assign regFile_register_W_output = writeReg_select;
	/* Status outputs */
//	output [31:0] status_output;							assign status_output = status_F;
	/* R16 to R24 outputs for Connect 4 */
	output [31:0] reg16_output;							assign reg16_output = regFileOutput16_D;
	output [31:0] reg17_output;							assign reg17_output = regFileOutput17_D;
	output [31:0] reg18_output;							assign reg18_output = regFileOutput18_D;
	output [31:0] reg19_output;							assign reg19_output = regFileOutput19_D;
	output [31:0] reg20_output;							assign reg20_output = regFileOutput20_D;
	output [31:0] reg21_output;							assign reg21_output = regFileOutput21_D;
	output [31:0] reg22_output;							assign reg22_output = regFileOutput22_D;
	output [31:0] reg23_output;							assign reg23_output = regFileOutput23_D;
	output [31:0] reg24_output;							assign reg24_output = regFileOutput24_D;
	
	/**
	*	ECE 554 Final Project Outputs:
	*/
	output [31:0] multdiv_remainder;						assign multdiv_remainder = multDiv_remainder_X;
	output multdiv_output_has_error;						assign multdiv_output_has_error = multdiv_output_has_error_X;
	output multdiv_checker_is_enabled;					assign multdiv_checker_is_enabled = multdiv_checker_is_enabled_X;
	output adder_has_error; 								assign adder_has_error = adder_has_error_X;
	output sra_has_error;									assign sra_has_error = sra_has_error_X;
	output sll_has_error;									assign sll_has_error = sll_has_error_X;
	
	/*Register outputs for all registers in the regFile*/
	output [31:0] reg1_output;							assign reg1_output = regFileOutput1_D;
	/*output [31:0] reg2_output;							assign reg2_output = regFileOutput2_D;
	output [31:0] reg3_output;							assign reg3_output = regFileOutput3_D;
	output [31:0] reg4_output;							assign reg4_output = regFileOutput4_D;
	output [31:0] reg5_output;							assign reg5_output = regFileOutput5_D;
	output [31:0] reg6_output;							assign reg6_output = regFileOutput6_D;
	output [31:0] reg7_output;							assign reg7_output = regFileOutput7_D;
	output [31:0] reg8_output;							assign reg8_output = regFileOutput8_D;
	output [31:0] reg9_output;							assign reg9_output = regFileOutput9_D;
	output [31:0] reg10_output;						assign reg10_output = regFileOutput10_D;
	output [31:0] reg11_output;						assign reg11_output = regFileOutput11_D;
	output [31:0] reg12_output;						assign reg12_output = regFileOutput12_D;
	output [31:0] reg13_output;						assign reg13_output = regFileOutput13_D;
	output [31:0] reg14_output;						assign reg14_output = regFileOutput14_D;
	output [31:0] reg15_output;						assign reg15_output = regFileOutput15_D;
	output [31:0] reg25_output;						assign reg25_output = regFileOutput25_D;
	output [31:0] reg26_output;						assign reg26_output = regFileOutput26_D;
	output [31:0] reg27_output;						assign reg27_output = regFileOutput27_D;
	output [31:0] reg28_output;						assign reg28_output = regFileOutput28_D;
	output [31:0] reg29_output;						assign reg29_output = regFileOutput29_D;
	output [31:0] reg30_output;						assign reg30_output = regFileOutput30_D;
	output [31:0] reg31_output;						assign reg31_output = regFileOutput31_D;*/
	
	
//	assign lcd_write = ps2_key_pressed & reset;
//	assign lcd_data[7:0] = ps2_out;
//	assign lcd_data[31:8] = 24'b0;
	
	// your processor here
//	abl17_processor myprocessor(.clock(clock), .reset(reset), .debug_data(debug_data), .debug_addr(debug_addr));
	
//	//////////////////////////////////////
//	////// THIS IS REQUIRED FOR GRADING
//	// CHANGE THIS TO ASSIGN YOUR DMEM WRITE ADDRESS ALSO TO debug_addr
//	assign debug_addr = (12'b000000000001);
//	// CHANGE THIS TO ASSIGN YOUR DMEM DATA INPUT (TO BE WRITTEN) ALSO TO debug_data
//	assign debug_data = (12'b000000000001);
//	////////////////////////////////////////////////////////////
//	
//		
//	// You'll need to change where the dmem and imem read and write...
//	dmem mydmem(	.address	(debug_addr),
//					.clock		(clock),
//					.data		(debug_data),
//					.wren		(1'b1) //,	//need to fix this!
//					//.q			(wherever_you_want) // change where output q goes...
//	);
//	
//	imem myimem(	.address 	(12'b000000000000),
//					.clken		(1'b1),
//					.clock		(clock) //,
//					//.q			(wherever_you_want) // change where output q goes...
//	); 
	
//endmodule

					////////////////////////////////////////////////////
					////////////////////////////////////////////////////


					/* 
					*
					*
					*
					*					BEGINNING OF MY PROCESSOR 
					*
					*
					*
					*/

					//module abl17_processor(clock, reset, debug_data, debug_addr);
					//
					//input clock, reset;
					//// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
					//output 	[31:0] 	debug_data;
					//output	[11:0]	debug_addr;

/* 
*
*
*
*					Fetch Stage 
*
*
*
*/

wire [31:0] outPC_F;
wire [31:0] outStatus_F;

//wire [31:0] pc_stall_select_X; 
//mux_2to1 pc_stall_F(	.in0(jump_select_X), 
//							.in1(pc_F), 
//							.select(stall_ctrl), 
//							.out(pc_stall_select_X)
//);

register register_PC_F(		.dataInput(bex_select_X /*pc_stall_select_X*/), 
									.clk(~clock), 
									.clr(reset), 
									.inEnable(~stall_ctrl), 
									.regOutput(outPC_F)
);

register register_status_F(	.dataInput(status_select_X), 
										.clk(~clock), 
										.clr(reset), 
										.inEnable(~stall_ctrl), 
										.regOutput(outStatus_F)
);

wire [31:0] pc_F; 						assign pc_F = outPC_F;
wire [31:0] status_F;					assign status_F = outStatus_F;

wire [31:0] pcPlusOne_F;

// PC + 1
abl17_adder_32bit adder_PC_F(		.a(pc_F), 
											.b(32'b00000000000000000000000000000000), 
											.cin(1'b1), 
											.sum(pcPlusOne_F)
);

wire [31:0] insn_F;

// Instruction Memory
imem myimem(	.address 	(pc_F[11:0]),
					.clken		(1'b1),
					.clock		(clock),
					.q			(out1) // change where output q goes...
);

assign insn_F = out1;

/* 
*
*
*
*					pipeRegister between Fetch and Decode Stages 
*
*
*
*/

wire [31:0] pcPlusOne_D, insn_D;
wire [31:0] nop_F;					assign nop_F = 32'b11111000000000000000000000000000;
wire [31:0] insn_select_F;

mux_2to1 nop_mux_F(	.in0(insn_F), 
							.in1(nop_F), 
							.select(branchRecovery_ctrl), 
							.out(insn_select_F)
);

//wire [31:0] fdRegister_stall_select_X; 
//mux_2to1 fdRegister_stall_F(	.in0(insn_select_F), 
//										.in1(insn_D), 
//										.select(stall_ctrl), 
//										.out(fdRegister_stall_select_X)
//);


pipeRegister pipeRegister_FD(		.enable(~stall_ctrl),
											.clock(~clock), 
											.clear(reset), 
											.pcPlusOne_in(pcPlusOne_F), 
											.insn_in(insn_select_F /*fdRegister_stall_select_X*/), 
											.in1(32'b00000000000000000000000000000000), 
											.in2(32'b00000000000000000000000000000000), 
											.pcPlusOne_out(pcPlusOne_D), 
											.insn_out(insn_D)  //, 
//											.out1(		),				/* UNUSED */
//											.out2(		) 				/* UNUSED */
);

/* 
*
*
*
*					Stalling Logic
*
*
*
*/
//wire [4:0] RSEqRDBits_Stall;		genvar j12;
//											generate
//											for (j12 = 0; j12<5; j12=j12+1) begin: loop_Stall_ctrl_12j
//												assign RSEqRDBits_Stall[j12] = (insn_D[17+j12] & insn_X[22+j12]) | (~insn_D[17+j12] & ~insn_X[22+j12]);
//											end
//											endgenerate
//											
//wire RSEqRD_Stall;					assign RSEqRD_Stall = &(RSEqRDBits_Stall);
//
//wire [4:0] RTEqRDBits_Stall;		genvar i13;
//											generate
//											for (i13 = 0; i13<5; i13=i13+1) begin: loop_Stall_ctrl_13
//												assign RTEqRDBits_Stall[i13] = (insn_D[12+i13] & insn_X[22+i13]) | (~insn_D[12+i13] & ~insn_X[22+i13]);
//											end
//											endgenerate
//											
//wire RTEqRD_Stall;					assign RTEqRD_Stall = &(RTEqRDBits_Stall);
//
//wire [4:0] RDEqRDBits_Stall;		genvar j13;
//											generate
//											for (j13 = 0; j13<5; j13=j13+1) begin: loop_Stall_ctrl_13j
//												assign RDEqRDBits_Stall[j13] = (insn_D[22+j13] & insn_X[22+j13]) | (~insn_D[22+j13] & ~insn_X[22+j13]);
//											end
//											endgenerate
//											
//wire RDEqRD_Stall;					assign RDEqRD_Stall = &(RDEqRDBits_Stall);
//
//wire [4:0] opcodeCheckBits_Stall0_FD2;
//wire [4:0] opcodeCheckBits_Stall1_FD2;
//wire [4:0] opcodeCheckBits_Stall2_FD2;		genvar j14;
//															generate
//													for (j14 = 0; j14<5; j14=j14+1) begin: loop_Stall_ctrl_14j
//														assign opcodeCheckBits_Stall0_FD2[j14] = (opcode_D[j14] & opcode_00010[j14]) | (~opcode_D[j14] & ~opcode_00010[j14]);
//														assign opcodeCheckBits_Stall1_FD2[j14] = (opcode_D[j14] & opcode_00100[j14]) | (~opcode_D[j14] & ~opcode_00100[j14]);
//														assign opcodeCheckBits_Stall2_FD2[j14] = (opcode_D[j14] & opcode_00110[j14]) | (~opcode_D[j14] & ~opcode_00110[j14]);
//													end
//													endgenerate
//											
//wire opcodeCheck_Stall0_FD2;				assign opcodeCheck_Stall0_FD2 = &(opcodeCheckBits_Stall0_FD2);
//wire opcodeCheck_Stall1_FD2;				assign opcodeCheck_Stall1_FD2 = &(opcodeCheckBits_Stall1_FD2);
//wire opcodeCheck_Stall2_FD2;				assign opcodeCheck_Stall2_FD2 = &(opcodeCheckBits_Stall2_FD2);
//
//wire opcodeCheck_Stall_FD2;				assign opcodeCheck_Stall_FD2 = opcodeCheck_Stall0_FD2 | opcodeCheck_Stall1_FD2 | opcodeCheck_Stall2_FD2;
//
//wire [4:0] opcodeCheckBits_Stall0_FD;	genvar i14;
//													generate
//													for (i14 = 0; i14<5; i14=i14+1) begin: loop_Stall_ctrl_14
//														assign opcodeCheckBits_Stall0_FD[i14] = (opcode_D[i14] & opcode_00000[i14]) | (~opcode_D[i14] & ~opcode_00000[i14]);
//													end
//													endgenerate
//
//wire opcodeCheck_Stall_FD;					assign opcodeCheck_Stall_FD = &(opcodeCheckBits_Stall0_FD);
//
wire [4:0] opcodeCheckBits_Stall0_DX;	genvar i15;
													generate
													for (i15 = 0; i15<5; i15=i15+1) begin: loop_Stall_ctrl_15
														assign opcodeCheckBits_Stall0_DX[i15] = (opcode_X[i15] & opcode_01000[i15]) | (~opcode_X[i15] & ~opcode_01000[i15]);
													end
													endgenerate

wire opcodeCheck_Stall_DX;					assign opcodeCheck_Stall_DX = &(opcodeCheckBits_Stall0_DX);
//
//wire [4:0] opcodeCheckBits_Stall0_FD0;
//wire [4:0] opcodeCheckBits_Stall1_FD0;
//wire [4:0] opcodeCheckBits_Stall2_FD0;
//wire [4:0] opcodeCheckBits_Stall3_FD0;
//wire [4:0] opcodeCheckBits_Stall4_FD0;	genvar i16;
//													generate
//													for (i16 = 0; i16<5; i16=i16+1) begin: loop_Stall_ctrl_16
//														assign opcodeCheckBits_Stall0_FD0[i16] = (opcode_D[i16] & opcode_00000[i16]) | (~opcode_D[i16] & ~opcode_00000[i16]);
//														assign opcodeCheckBits_Stall1_FD0[i16] = (opcode_D[i16] & opcode_00101[i16]) | (~opcode_D[i16] & ~opcode_00101[i16]);
//														assign opcodeCheckBits_Stall2_FD0[i16] = (opcode_D[i16] & opcode_00010[i16]) | (~opcode_D[i16] & ~opcode_00010[i16]);
//														assign opcodeCheckBits_Stall3_FD0[i16] = (opcode_D[i16] & opcode_00110[i16]) | (~opcode_D[i16] & ~opcode_00110[i16]);
//														assign opcodeCheckBits_Stall4_FD0[i16] = (opcode_D[i16] & opcode_01000[i16]) | (~opcode_D[i16] & ~opcode_01000[i16]);
//													end
//													endgenerate
//
//wire opcodeCheck_Stall0_FD0;				assign opcodeCheck_Stall0_FD0 = &(opcodeCheckBits_Stall0_FD0);
//wire opcodeCheck_Stall1_FD0;				assign opcodeCheck_Stall1_FD0 = &(opcodeCheckBits_Stall1_FD0);
//wire opcodeCheck_Stall2_FD0;				assign opcodeCheck_Stall2_FD0 = &(opcodeCheckBits_Stall2_FD0);
//wire opcodeCheck_Stall3_FD0;				assign opcodeCheck_Stall3_FD0 = &(opcodeCheckBits_Stall3_FD0);
//wire opcodeCheck_Stall4_FD0;				assign opcodeCheck_Stall4_FD0 = &(opcodeCheckBits_Stall4_FD0);
//
//wire opcodeCheck_Stall_FD0;				assign opcodeCheck_Stall_FD0 = opcodeCheck_Stall0_FD0 | opcodeCheck_Stall1_FD0 | 
//																								opcodeCheck_Stall2_FD0 | opcodeCheck_Stall3_FD0 | opcodeCheck_Stall4_FD0;									
//
//wire stall_ctrl;								assign stall_ctrl = opcodeCheck_Stall_DX &
//														(			(opcodeCheck_Stall_FD0 & RSEqRD_Stall) | 
//																	((RTEqRD_Stall & opcodeCheck_Stall_FD) | (RDEqRD_Stall & opcodeCheck_Stall_FD2))
//														);

wire inseq1; assign inseq1 = &(opcode_D ~^ opcode_00010);
wire inseq2; assign inseq2 = &(opcode_D ~^ opcode_00100);
wire inseq3; assign inseq3 = &(opcode_D ~^ opcode_00110);
wire inseq4; assign inseq4 = &(opcode_D ~^ opcode_00111);

wire [4:0] fd_rs2; assign fd_rs2 = (inseq1 | inseq2 | inseq3 | inseq4) ? insn_D[26:22] : insn_D[16:12];
wire equal_rs2_rd; assign equal_rs2_rd = &(fd_rs2 ~^ insn_X[26:22]);
wire equal_rs1_rd; assign equal_rs1_rd = &(insn_D[21:17] ~^ insn_X[26:22]);

wire stall_ctrl; assign stall_ctrl = (opcodeCheck_Stall_DX) & ((equal_rs1_rd) | (equal_rs2_rd & ~(&(insn_D[31:27] ~^ opcode_00111))));

/* 
*
*
*
*					Decode Stage 
*
*
*
*/

wire [4:0] opcode_D;					assign opcode_D = insn_D[31:27];
wire [4:0] rd_D;						assign rd_D = insn_D[26:22];
wire [4:0] rs_D;						assign rs_D = insn_D[21:17];
wire [4:0] rt_D;						assign rt_D = insn_D[16:12];
wire [4:0] r31_D;						assign r31_D = 5'b11111;

wire regDst_ctrl_D;

control_FD mycontrol_FD(	.in(opcode_D), 
									.regDst(regDst_ctrl_D)
);

wire [4:0] writeReg_select, readReg2_select;

mux_2to1_5bit writeReg_mux_D(	.in0(rd_W), 
									.in1(r31_D), 
									.select(jump_ctrl_W), 
									.out(writeReg_select)
);

mux_2to1_5bit readReg2_mux_D(	.in0(rt_D), 
									.in1(rd_D), 
									.select(regDst_ctrl_D), 
									.out(readReg2_select)
);

wire [31:0] regFileOutputA_D;
wire [31:0] regFileOutputB_D;
wire [31:0] regFileOutput16_D, regFileOutput17_D, regFileOutput18_D, 
				regFileOutput19_D, regFileOutput20_D, regFileOutput21_D, 
				regFileOutput22_D, regFileOutput23_D, regFileOutput24_D;

/*554 extension:*/
wire [31:0] regFileOutput1_D, regFileOutput2_D, regFileOutput3_D, 
				regFileOutput4_D, regFileOutput5_D, regFileOutput6_D, 
				regFileOutput7_D, regFileOutput8_D, regFileOutput9_D,
				regFileOutput10_D, regFileOutput11_D, regFileOutput12_D, 
				regFileOutput13_D, regFileOutput14_D, regFileOutput15_D, 
				regFileOutput25_D, regFileOutput26_D, regFileOutput27_D,
				regFileOutput28_D, regFileOutput29_D, regFileOutput30_D,
				regFileOutput31_D;

regFile regFile_D(		.clock(clock), 
								.ctrl_writeEnable(regWrite_ctrl_W), 
								.ctrl_reset(reset), 
								.ctrl_writeReg(writeReg_select), 
								.ctrl_readRegA(rs_D), 
								.ctrl_readRegB(readReg2_select), 
								.data_writeReg(jump_select_W), 
								.data_readRegA(regFileOutputA_D), 
								.data_readRegB(regFileOutputB_D), 
								.data_readReg16(regFileOutput16_D), 
								.data_readReg17(regFileOutput17_D), 
								.data_readReg18(regFileOutput18_D), 
								.data_readReg19(regFileOutput19_D), 
								.data_readReg20(regFileOutput20_D), 
								.data_readReg21(regFileOutput21_D), 
								.data_readReg22(regFileOutput22_D), 
								.data_readReg23(regFileOutput23_D), 
								.data_readReg24(regFileOutput24_D),
								
								.data_readReg1(regFileOutput1_D),
								.data_readReg2(regFileOutput2_D),
								.data_readReg3(regFileOutput3_D),
								.data_readReg4(regFileOutput4_D),
								.data_readReg5(regFileOutput5_D),
								.data_readReg6(regFileOutput6_D),
								.data_readReg7(regFileOutput7_D),
								.data_readReg8(regFileOutput8_D),
								.data_readReg9(regFileOutput9_D),
								.data_readReg10(regFileOutput10_D),
								.data_readReg11(regFileOutput11_D),
								.data_readReg12(regFileOutput12_D),
								.data_readReg13(regFileOutput13_D),
								.data_readReg14(regFileOutput14_D),
								.data_readReg15(regFileOutput15_D),
								.data_readReg25(regFileOutput25_D),
								.data_readReg26(regFileOutput26_D),
								.data_readReg27(regFileOutput27_D),
								.data_readReg28(regFileOutput28_D),
								.data_readReg29(regFileOutput29_D),
								.data_readReg30(regFileOutput30_D),
								.data_readReg31(regFileOutput31_D)
);

/* 
*
*
*
*					pipeRegister between Decode and Execute Stages 
*
*
*
*/

wire [31:0] pcPlusOne_X, insn_X, dataApre_X, dataBpre_X;
wire [31:0] nop_D;					assign nop_D = 32'b11111000000000000000000000000000;
wire [31:0] insn_select_D, stall_select_D;

wire [31:0] reg16_X, reg17_X, reg18_X, 
				reg19_X, reg20_X, reg21_X, 
				reg22_X, reg23_X, reg24_X;

mux_2to1 nop_mux_D(	.in0(insn_D), 
							.in1(nop_D), 
							.select(branchRecovery_ctrl), 
							.out(insn_select_D)
);

mux_2to1 stall_mux_D(	.in0(insn_select_D), 
								.in1(nop_D), 
								.select(stall_ctrl), 
								.out(stall_select_D)
);

pipeRegister_DXX pipeRegister_DX(.enable(1'b1),
											.clock(~clock), 
											.clear(reset), 
											.pcPlusOne_in(pcPlusOne_D), 
											.insn_in(stall_select_D), 
											.in1(regFileOutputA_D), 
											.in2(regFileOutputB_D), 
											.pcPlusOne_out(pcPlusOne_X), 
											.insn_out(insn_X), 
											.out1(dataApre_X),
											.out2(dataBpre_X),
											.in_Reg16(regFileOutput16_D), 
											.in_Reg17(regFileOutput17_D), 
											.in_Reg18(regFileOutput18_D), 
											.in_Reg19(regFileOutput19_D), 
											.in_Reg20(regFileOutput20_D), 
											.in_Reg21(regFileOutput21_D), 
											.in_Reg22(regFileOutput22_D), 
											.in_Reg23(regFileOutput23_D), 
											.in_Reg24(regFileOutput24_D),
											.out_Reg16(reg16_X), 
											.out_Reg17(reg17_X), 
											.out_Reg18(reg18_X), 
											.out_Reg19(reg19_X), 
											.out_Reg20(reg20_X), 
											.out_Reg21(reg21_X), 
											.out_Reg22(reg22_X), 
											.out_Reg23(reg23_X), 
											.out_Reg24(reg24_X)
);

/* 
*
*
*
*					AMWX Bypassing
*
*
*
*/

/* Determining AMX_ctrl */

wire AMX_ctrl;
wire [4:0] RSEqRDBits_AMX;			genvar j5;
											generate
											for (j5 = 0; j5<5; j5=j5+1) begin: loop_AMX_ctrl_5j
												assign RSEqRDBits_AMX[j5] = (insn_X[17+j5] & insn_M[22+j5]) | (~insn_X[17+j5] & ~insn_M[22+j5]);
											end
											endgenerate
											
wire RSEqRD_AMX;						assign RSEqRD_AMX = &(RSEqRDBits_AMX);

wire [4:0] opcode_00000;					assign opcode_00000 = 5'b00000;
wire [4:0] opcode_00101;					assign opcode_00101 = 5'b00101;

wire [4:0] opcodeCheckBits_AMX0;
wire [4:0] opcodeCheckBits_AMX1;	genvar j6;
											generate
											for (j6 = 0; j6<5; j6=j6+1) begin: loop_AMX_ctrl_6j
												assign opcodeCheckBits_AMX0[j6] = (opcode_M[j6] & opcode_00000[j6]) | (~opcode_M[j6] & ~opcode_00000[j6]);
												assign opcodeCheckBits_AMX1[j6] = (opcode_M[j6] & opcode_00101[j6]) | (~opcode_M[j6] & ~opcode_00101[j6]);
											end
											endgenerate
											
wire opcodeCheck_AMX0;				assign opcodeCheck_AMX0 = &(opcodeCheckBits_AMX0);
wire opcodeCheck_AMX1;				assign opcodeCheck_AMX1 = &(opcodeCheckBits_AMX1);

wire opcodeCheck_AMX;				assign opcodeCheck_AMX = opcodeCheck_AMX0 | opcodeCheck_AMX1;

assign AMX_ctrl = RSEqRD_AMX & opcodeCheck_AMX;

/* Determining AWX_ctrl */

wire AWX_ctrl;
wire [4:0] RSEqRDBits_AWX;			genvar i7;
											generate
											for (i7 = 0; i7<5; i7=i7+1) begin: loop_AWX_ctrl_7
												assign RSEqRDBits_AWX[i7] = (insn_X[17+i7] & insn_W[22+i7]) | (~insn_X[17+i7] & ~insn_W[22+i7]);
											end
											endgenerate
											
wire RSEqRD_AWX;						assign RSEqRD_AWX = &(RSEqRDBits_AWX);

wire [4:0] opcodeCheckBits_AWX0;
wire [4:0] opcodeCheckBits_AWX1;
wire [4:0] opcodeCheckBits_AWX2;	genvar i8;
											generate
											for (i8 = 0; i8<5; i8=i8+1) begin: loop_AWX_ctrl_8
												assign opcodeCheckBits_AWX0[i8] = (opcode_W[i8] & opcode_00000[i8]) | (~opcode_W[i8] & ~opcode_00000[i8]);
												assign opcodeCheckBits_AWX1[i8] = (opcode_W[i8] & opcode_00101[i8]) | (~opcode_W[i8] & ~opcode_00101[i8]);
												assign opcodeCheckBits_AWX2[i8] = (opcode_W[i8] & opcode_01000[i8]) | (~opcode_W[i8] & ~opcode_01000[i8]);
											end
											endgenerate
											
wire opcodeCheck_AWX0;				assign opcodeCheck_AWX0 = &(opcodeCheckBits_AWX0);
wire opcodeCheck_AWX1;				assign opcodeCheck_AWX1 = &(opcodeCheckBits_AWX1);
wire opcodeCheck_AWX2;				assign opcodeCheck_AWX2 = &(opcodeCheckBits_AWX2);

wire opcodeCheck_AWX;				assign opcodeCheck_AWX = opcodeCheck_AWX0 | opcodeCheck_AWX1 | opcodeCheck_AWX2;

assign AWX_ctrl = RSEqRD_AWX & opcodeCheck_AWX;

/* 
*
*
*
*					BMWX Bypassing
*
*
*
*/

/* Determining BMX_ctrl */

wire BMX_ctrl;
wire [4:0] RTEqRDBits_BMX;			genvar j7;
											generate
											for (j7 = 0; j7<5; j7=j7+1) begin: loop_BMX_ctrl_7j
												assign RTEqRDBits_BMX[j7] = (insn_X[12+j7] & insn_M[22+j7]) | (~insn_X[12+j7] & ~insn_M[22+j7]);
											end
											endgenerate
											
wire RTEqRD_BMX;						assign RTEqRD_BMX = &(RTEqRDBits_BMX);

wire [4:0] RDEqRDBits_BMX;			genvar j9;
											generate
											for (j9 = 0; j9<5; j9=j9+1) begin: loop_BMX_ctrl_9j
												assign RDEqRDBits_BMX[j9] = (insn_X[22+j9] & insn_M[22+j9]) | (~insn_X[22+j9] & ~insn_M[22+j9]);
											end
											endgenerate
											
wire RDEqRD_BMX;						assign RDEqRD_BMX = &(RDEqRDBits_BMX);

wire [4:0] opcode_00010;			assign opcode_00010 = 5'b00010;
wire [4:0] opcode_00100;			assign opcode_00100 = 5'b00100;
wire [4:0] opcode_00110;			assign opcode_00110 = 5'b00110;
wire [4:0] opcode_00111;			assign opcode_00111 = 5'b00111;

wire [4:0] opcodeCheckBits_BMX0_DX;
wire [4:0] opcodeCheckBits_BMX1_DX;
wire [4:0] opcodeCheckBits_BMX2_DX;
wire [4:0] opcodeCheckBits_BMX3_DX;		genvar j8;
													generate
													for (j8 = 0; j8<5; j8=j8+1) begin: loop_BMX_ctrl_8j
														assign opcodeCheckBits_BMX0_DX[j8] = (opcode_X[j8] & opcode_00010[j8]) | (~opcode_X[j8] & ~opcode_00010[j8]);
														assign opcodeCheckBits_BMX1_DX[j8] = (opcode_X[j8] & opcode_00100[j8]) | (~opcode_X[j8] & ~opcode_00100[j8]);
														assign opcodeCheckBits_BMX2_DX[j8] = (opcode_X[j8] & opcode_00110[j8]) | (~opcode_X[j8] & ~opcode_00110[j8]);
														assign opcodeCheckBits_BMX3_DX[j8] = (opcode_X[j8] & opcode_00111[j8]) | (~opcode_X[j8] & ~opcode_00111[j8]);
													end
													endgenerate
											
wire opcodeCheck_BMX0_DX;				assign opcodeCheck_BMX0_DX = &(opcodeCheckBits_BMX0_DX);
wire opcodeCheck_BMX1_DX;				assign opcodeCheck_BMX1_DX = &(opcodeCheckBits_BMX1_DX);
wire opcodeCheck_BMX2_DX;				assign opcodeCheck_BMX2_DX = &(opcodeCheckBits_BMX2_DX);
wire opcodeCheck_BMX3_DX;				assign opcodeCheck_BMX3_DX = &(opcodeCheckBits_BMX3_DX);

wire opcodeCheck_BMX_DX;				assign opcodeCheck_BMX_DX = opcodeCheck_BMX0_DX | opcodeCheck_BMX1_DX | opcodeCheck_BMX2_DX | opcodeCheck_BMX3_DX;

wire [4:0] opcodeCheckBits_BMX0_DX2;	genvar i9;
													generate
													for (i9 = 0; i9<5; i9=i9+1) begin: loop_BMX_ctrl_9
														assign opcodeCheckBits_BMX0_DX2[i9] = (opcode_X[i9] & opcode_00000[i9]) | (~opcode_X[i9] & ~opcode_00000[i9]);
													end
													endgenerate

wire opcodeCheck_BMX_DX2;				assign opcodeCheck_BMX_DX2 = &(opcodeCheckBits_BMX0_DX2);
													
assign BMX_ctrl = (opcodeCheck_BMX_DX2 & RTEqRD_BMX & opcodeCheck_AMX) |
						(opcodeCheck_BMX_DX & RDEqRD_BMX & opcodeCheck_AMX);
											
/* Determining BWX_ctrl */

wire BWX_ctrl;
wire [4:0] RTEqRDBits_BWX;			genvar i10;
											generate
											for (i10 = 0; i10<5; i10=i10+1) begin: loop_BWX_ctrl_10
												assign RTEqRDBits_BWX[i10] = (insn_X[12+i10] & insn_W[22+i10]) | (~insn_X[12+i10] & ~insn_W[22+i10]);
											end
											endgenerate
											
wire RTEqRD_BWX;						assign RTEqRD_BWX = &(RTEqRDBits_BWX);

wire [4:0] RDEqRDBits_BWX;			genvar j10;
											generate
											for (j10 = 0; j10<5; j10=j10+1) begin: loop_BWX_ctrl_10j
												assign RDEqRDBits_BWX[j10] = (insn_X[22+j10] & insn_W[22+j10]) | (~insn_X[22+j10] & ~insn_W[22+j10]);
											end
											endgenerate
											
wire RDEqRD_BWX;						assign RDEqRD_BWX = &(RDEqRDBits_BWX);
											
													
assign BWX_ctrl = (opcodeCheck_BMX_DX2 & RTEqRD_BWX & opcodeCheck_AWX) |
						(opcodeCheck_BMX_DX & RDEqRD_BWX & opcodeCheck_AWX);
						
/* 
*
*
*
*					Actual AMWX and BMWX bypassing 
*
*
*
*/

wire [31:0] dataA_X, dataB_X;
wire [31:0] AWX_select, BWX_select;

mux_2to1 AWX_mux_X(		.in0(dataApre_X), 
								.in1(memToReg_select_W), 
								.select(AWX_ctrl), 
								.out(AWX_select)
);

mux_2to1 AMX_mux_X(		.in0(AWX_select), 
								.in1(dataO_M), 
								.select(AMX_ctrl), 
								.out(dataA_X)
);

mux_2to1 BWX_mux_X(		.in0(dataBpre_X), 
								.in1(memToReg_select_W), 
								.select(BWX_ctrl), 
								.out(BWX_select)
);

mux_2to1 BMX_mux_X(		.in0(BWX_select), 
								.in1(dataO_M), 
								.select(BMX_ctrl), 
								.out(dataB_X)
);


/* 
*
*
*
*					Execute Stage 
*
*
*
*/

wire [4:0] opcode_X;					assign opcode_X = insn_X[31:27];
wire [4:0] aluOpcode_X;				assign aluOpcode_X = insn_X[6:2];
wire [16:0] imm_X;					assign imm_X = insn_X[16:0];
wire [26:0] target_X;				assign target_X = insn_X[26:0];
wire [4:0] shamt_X;					assign shamt_X = insn_X[11:7];

/* Getting the N value */
wire [31:0] N_val_X;					genvar i1;
											generate
											for (i1 = 0; i1<=26; i1=i1+1) begin: loop_Nval_1
												assign N_val_X[i1] = target_X[i1];
											end
											endgenerate
											
											genvar j1;
											generate
											for (j1 = 27; j1<=31; j1=j1+1) begin: loop_Nval_2
												assign N_val_X[j1] = pcPlusOne_X[j1];
											end
											endgenerate

										
/* Getting the PC+1+N value for J type instructions, e.g. bex */
wire [31:0] pcPlusOnePlusN_J1_X;

abl17_adder_32bit adder_PCPlusOnePlusN_J1_X(		.a(pcPlusOne_X), 
																.b(N_val_X), 
																.cin(1'b0), 
																.sum(pcPlusOnePlusN_J1_X)
);		
		
/* Getting the PC+1+N value for bne, blt */
// Note that PC+1+N value comes from I type instructions. Therefore, N --> imm_SE_X
wire [31:0] pcPlusOnePlusN_X;	

abl17_adder_32bit adder_PCPlusOnePlusN_X(		.a(pcPlusOne_X), 
															.b(imm_SE_X), 
															.cin(1'b0), 
															.sum(pcPlusOnePlusN_X)
);	

/* Sign-Extend the immediate value */
wire [31:0] imm_SE_X;				genvar i2;
											generate
											for (i2 = 0; i2<=16; i2=i2+1) begin: loop_SE_1
												assign imm_SE_X[i2] = imm_X[i2];
											end
											endgenerate
											
											genvar j2;
											generate
											for (j2 = 17; j2<=31; j2=j2+1) begin: loop_SE_2
												assign imm_SE_X[j2] = imm_X[16];
											end
											endgenerate

wire setx_ctrl_X, bex_ctrl_X, jump_ctrl_X, jr_ctrl_X, blt_ctrl_X, bne_ctrl_X, aluSrc_ctrl_X, aluOp_ctrl_X, aluOpBranch_ctrl_X;

control_DX mycontrol_DX(		.in(opcode_X),
										.setx(setx_ctrl_X),
										.bex(bex_ctrl_X),
										.jump(jump_ctrl_X), 
										.jr(jr_ctrl_X), 
										.blt(blt_ctrl_X), 
										.bne(bne_ctrl_X), 
										.aluSrc(aluSrc_ctrl_X), 
										.aluOp(aluOp_ctrl_X),
										.aluOpBranch(aluOpBranch_ctrl_X)
);

/* Compute aluSrc_select_X bits */
wire [31:0] aluSrc_select_X;

mux_2to1 aluSrc_mux_X(		.in0(dataB_X), 
									.in1(imm_SE_X), 
									.select(aluSrc_ctrl_X), 
									.out(aluSrc_select_X)
);


/* Compute aluOpcode_select bits */
wire [4:0] aluOpcode_add_X;		assign aluOpcode_add_X = 5'b00000;
wire [4:0] aluOpcode_select_X;

mux_2to1_5bit aluOpcode_mux_X(	.in0(aluOpcode_add_X), 
									.in1(aluOpcode_X), 
									.select(aluOp_ctrl_X), 
									.out(aluOpcode_select_X)
);

/* Compute aluOpcodeBranch_select bits */
wire [4:0] aluOpcode_sub_X;		assign aluOpcode_sub_X = 5'b00001;
wire [4:0] aluOpcodeBranch_select_X;

mux_2to1_5bit aluOpcodeBranch_mux_X(	.in0(aluOpcode_select_X), 
											.in1(aluOpcode_sub_X), 
											.select(aluOpBranch_ctrl_X), 
											.out(aluOpcodeBranch_select_X)
);

/* Compute mult_ctrl_X and div_ctrl_X */
wire [4:0] opcodeALU_00110;		assign opcodeALU_00110 = 5'b00110; 	// Opcode for mult
wire [4:0] opcodeALU_00111;		assign opcodeALU_00111 = 5'b00111;	// Opcode for div

wire [4:0] opcodeALUMultCheckBits_X;	genvar i17;
													generate
													for (i17 = 0; i17<5; i17=i17+1) begin: loop_Mult_ctrl_17
														assign opcodeALUMultCheckBits_X[i17] = (aluOpcode_X[i17] & opcodeALU_00110[i17]) | (~aluOpcode_X[i17] & ~opcodeALU_00110[i17]);
													end
													endgenerate
													
wire [4:0] opcodeALUDivCheckBits_X;		genvar i18;
													generate
													for (i18 = 0; i18<5; i18=i18+1) begin: loop_Div_ctrl_18
														assign opcodeALUDivCheckBits_X[i18] = (aluOpcode_X[i18] & opcodeALU_00111[i18]) | (~aluOpcode_X[i18] & ~opcodeALU_00111[i18]);
													end
													endgenerate

wire opcodeALUMultCheck_X;					assign opcodeALUMultCheck_X = &(opcodeALUMultCheckBits_X);
wire opcodeALUDivCheck_X;					assign opcodeALUDivCheck_X = &(opcodeALUDivCheckBits_X);

wire mult_ctrl_X;						assign mult_ctrl_X = aluOp_ctrl_X & opcodeALUMultCheck_X;
wire div_ctrl_X;						assign div_ctrl_X = aluOp_ctrl_X & opcodeALUDivCheck_X;

/* Compute cyc_ctrl_X, drop_ctrl_X, cwc_ctrl_X, chb_ctrl_X, rdin_ctrl_X */
wire [4:0] opcodeALU_01000;		assign opcodeALU_01000 = 5'b01000;	//Opcode for cyc
wire [4:0] opcodeALU_01001;		assign opcodeALU_01001 = 5'b01001;	//Opcode for drop
wire [4:0] opcodeALU_01010;		assign opcodeALU_01010 = 5'b01010;	//Opcode for cwc
wire [4:0] opcodeALU_01011;		assign opcodeALU_01011 = 5'b01011;	//Opcode for chb
wire [4:0] opcodeALU_01100;		assign opcodeALU_01100 = 5'b01100;	//Opcode for rdin

wire [4:0] opcodeALUCycCheckBits_X;		genvar i20;
													generate
													for (i20 = 0; i20<5; i20=i20+1) begin: loop_Cyc_ctrl_20
														assign opcodeALUCycCheckBits_X[i20] = (aluOpcode_X[i20] & opcodeALU_01000[i20]) | (~aluOpcode_X[i20] & ~opcodeALU_01000[i20]);
													end
													endgenerate
													
wire [4:0] opcodeALUDropCheckBits_X;	genvar i21;
													generate
													for (i21 = 0; i21<5; i21=i21+1) begin: loop_Drop_ctrl_21
														assign opcodeALUDropCheckBits_X[i21] = (aluOpcode_X[i21] & opcodeALU_01001[i21]) | (~aluOpcode_X[i21] & ~opcodeALU_01001[i21]);
													end
													endgenerate
													
wire [4:0] opcodeALUCwcCheckBits_X;		genvar i22;
													generate
													for (i22 = 0; i22<5; i22=i22+1) begin: loop_Cwc_ctrl_22
														assign opcodeALUCwcCheckBits_X[i22] = (aluOpcode_X[i22] & opcodeALU_01010[i22]) | (~aluOpcode_X[i22] & ~opcodeALU_01010[i22]);
													end
													endgenerate
													
wire [4:0] opcodeALUChbCheckBits_X;		genvar i23;
													generate
													for (i23 = 0; i23<5; i23=i23+1) begin: loop_Chb_ctrl_23
														assign opcodeALUChbCheckBits_X[i23] = (aluOpcode_X[i23] & opcodeALU_01011[i23]) | (~aluOpcode_X[i23] & ~opcodeALU_01011[i23]);
													end
													endgenerate
													
wire [4:0] opcodeALURdinCheckBits_X;	genvar i24;
													generate
													for (i24 = 0; i24<5; i24=i24+1) begin: loop_Rdin_ctrl_24
														assign opcodeALURdinCheckBits_X[i24] = (aluOpcode_X[i24] & opcodeALU_01100[i24]) | (~aluOpcode_X[i24] & ~opcodeALU_01100[i24]);
													end
													endgenerate
													
wire opcodeALUCycCheck_X;			assign opcodeALUCycCheck_X = &(opcodeALUCycCheckBits_X);
wire opcodeALUDropCheck_X;			assign opcodeALUDropCheck_X = &(opcodeALUDropCheckBits_X);
wire opcodeALUCwcCheck_X;			assign opcodeALUCwcCheck_X = &(opcodeALUCwcCheckBits_X);
wire opcodeALUChbCheck_X;			assign opcodeALUChbCheck_X = &(opcodeALUChbCheckBits_X);
wire opcodeALURdinCheck_X;			assign opcodeALURdinCheck_X = &(opcodeALURdinCheckBits_X);

wire cyc_ctrl_X;						assign cyc_ctrl_X = aluOp_ctrl_X & opcodeALUCycCheck_X;
wire drop_ctrl_X;						assign drop_ctrl_X = aluOp_ctrl_X & opcodeALUDropCheck_X;
wire cwc_ctrl_X;						assign cwc_ctrl_X = aluOp_ctrl_X & opcodeALUCwcCheck_X;
wire chb_ctrl_X;						assign chb_ctrl_X = aluOp_ctrl_X & opcodeALUChbCheck_X;
wire rdin_ctrl_X;						assign rdin_ctrl_X = aluOp_ctrl_X & opcodeALURdinCheck_X;

/* Mult/Div Module: */
wire [31:0] multDiv_result_X;
wire multDiv_status_1bit_X;
wire [31:0] multDiv_status_X;
wire multDiv_inputRDY_X;
wire multDiv_resultRDY_X;

/*ECE 554 Remainder:*/
wire [31:0] multDiv_remainder_X;
wire multdiv_output_has_error_X;
wire multdiv_checker_is_enabled_X;

multdiv multdiv1( .data_operandA(dataA_X), 
						.data_operandB(aluSrc_select_X[15:0]), 
						.ctrl_MULT(mult_ctrl_X), 
						.ctrl_DIV(div_ctrl_X), 
						.clock(clock), 
						.data_result(multDiv_result_X),
						.out_remainder(multDiv_remainder_X),
						.data_exception(multDiv_status_1bit_X), 
						.data_inputRDY(multDiv_inputRDY_X), 
						.data_resultRDY(multDiv_resultRDY_X)
);

/**
* ECE 554 Mult-div ARGUS CHECKER:
*/
multdiv_checker multdiv_argus_checker(	.inA(dataA_X),
													.inB(aluSrc_select_X[15:0]), 
													.inMultDivResult(multDiv_result_X), 
													.ctrl_MULT(mult_ctrl_X), 
													.ctrl_DIV(div_ctrl_X), 
													.inRemainder(multDiv_remainder_X), 
													.outError(multdiv_output_has_error_X), 
													.enable(multdiv_checker_is_enabled_X)
);


genvar i19;
generate
	for (i19 = 1; i19<32; i19=i19+1) begin: loop_status_extend_ctrl_19
	assign multDiv_status_X[i19] = 1'b0;
end
endgenerate

assign multDiv_status_X[0] = multDiv_status_1bit_X;
						
/* ALU Module: */
wire [31:0] alu_result_X;
wire a_ne_b_X, a_lt_b_X;

abl17_alu myabl17_alu(		.data_operandA(dataA_X), 
									.data_operandB(aluSrc_select_X), 
									.ctrl_ALUopcode(aluOpcodeBranch_select_X), 
									.ctrl_shiftamt(shamt_X), 
									.data_result(alu_result_X), 
									.isNotEqual(a_ne_b_X), 
									.isLessThan(a_lt_b_X),
									.adder_has_error(adder_has_error_X),
									.sra_has_error(sra_has_error_X),
									.sll_has_error(sll_has_error_X)
);


/* Cyc Module: */
wire [31:0] cyc_result_X;

cycle my_cycle(				.in(reg24_X), 
									.out(cyc_result_X)
);

/* Drop Module: */
wire [31:0] rXX_drop_result_X;
wire [31:0] modifiedIR_drop_result_X;

dropModule my_dropModule(	.r0(reg16_X), 
									.r1(reg17_X), 
									.r2(reg18_X), 
									.r3(reg19_X), 
									.r4(reg20_X), 
									.r5(reg21_X), 
									.r6(reg22_X), 
									.r7(reg23_X), 
									.r8(reg24_X), 
									.rxx(rXX_drop_result_X), 
									.modinst(modifiedIR_drop_result_X)
);

/* Cwc Module: */
wire [31:0] cwc_result_X;
wire redwin, greenwin;

wincon my_wincon(				.r11(reg16_X), 
									.r12(reg17_X), 
									.r13(reg18_X), 
									.r14(reg19_X), 
									.r15(reg20_X), 
									.r16(reg21_X), 
									.r17(reg22_X), 
									.r18(reg23_X), 
									.rwin(redwin), 
									.gwin(greenwin));

assign cwc_result_X[31:9] = reg24_X[31:9];
assign cwc_result_X[8] = redwin | greenwin;
assign cwc_result_X[7:0] = reg24_X[7:0];

/* Chb Module: */
wire [31:0] chb_result_X;

assign chb_result_X[31:8] = reg24_X[31:8];
assign chb_result_X[7] = ~reg24_X[7];
assign chb_result_X[6:0] = reg24_X[6:0];

/* Rdin Module: */
wire [31:0] rdin_result_X;

assign rdin_result_X[31:2] = 30'b000000000000000000000000000000;
assign rdin_result_X[1] = button_drop_in;
assign rdin_result_X[0] = button_cycle_in;

/* Choose between ALU or MultDiv Result */
wire [31:0] computational_result_select_X;
wire mult_or_div_ctrl_X;			assign mult_or_div_ctrl_X = mult_ctrl_X | div_ctrl_X;

mux_2to1 computational_result_mux_X(		.in0(alu_result_X), 
														.in1(multDiv_result_X), 
														.select(mult_or_div_ctrl_X), 
														.out(computational_result_select_X)
);

/* Choose between computational_result_select_X or cyc Result */
wire [31:0] cyc_result_select_X;

mux_2to1 cyc_result_mux_X(						.in0(computational_result_select_X), 
														.in1(cyc_result_X), 
														.select(cyc_ctrl_X), 
														.out(cyc_result_select_X)
);

/* Choose between cyc_result_select_X or drop Result */
wire [31:0] drop_result_select_X;

mux_2to1 drop_result_mux_X(					.in0(cyc_result_select_X), 
														.in1(rXX_drop_result_X), 
														.select(drop_ctrl_X), 
														.out(drop_result_select_X)
);

/* Choose between drop_result_select_X or cwc Result */
wire [31:0] cwc_result_select_X;

mux_2to1 cwc_result_mux_X(						.in0(drop_result_select_X), 
														.in1(cwc_result_X), 
														.select(cwc_ctrl_X), 
														.out(cwc_result_select_X)
); 

/* Choose between cwc_result_select_X or chb Result */

wire [31:0] chb_result_select_X;

mux_2to1 chb_result_mux_X(						.in0(cwc_result_select_X), 
														.in1(chb_result_X), 
														.select(chb_ctrl_X), 
														.out(chb_result_select_X)
); 

/* Choose between chb_result_select_X or rdin Result in X/M PipeRegister */
wire [31:0] rdin_result_select_X;

mux_2to1 rdin_result_mux_X(					.in0(chb_result_select_X), 
														.in1(rdin_result_X), 
														.select(rdin_ctrl_X), 
														.out(rdin_result_select_X)
); 

/* Choose between IR or modifiedIR for X/M PipeRegister */
wire [31:0] insn_modified_select_X;

mux_2to1 insn_modified_mux_X(					.in0(insn_X), 
														.in1(modifiedIR_drop_result_X), 
														.select(drop_ctrl_X), 
														.out(insn_modified_select_X)
);

/* Compute new status */
wire [31:0] pre_status_select_X;
wire [31:0] status_select_X;

mux_2to1 pre_status_select_mux_X(		.in0(status_F), 
													.in1(multDiv_status_X), 
													.select(mult_or_div_ctrl_X), 
													.out(pre_status_select_X)
);

mux_2to1 status_select_mux_X(		.in0(pre_status_select_X), 
											.in1(N_val_X), 
											.select(setx_ctrl_X), 
											.out(status_select_X)
);


/* Compute b_lt_a */
wire b_lt_a_X;							assign b_lt_a_X = (~a_lt_b_X) & (a_ne_b_X);

/* Compute the branch_ctrl_X bit */
wire branch_ctrl_X;					assign branch_ctrl_X = (blt_ctrl_X & b_lt_a_X) | (bne_ctrl_X & a_ne_b_X);

/* Compute branch_select_X bit */
wire [31:0] branch_select_X;

mux_2to1 branch_mux_X(		.in0(pcPlusOne_F), 
									.in1(pcPlusOnePlusN_X), 
									.select(branch_ctrl_X), 
									.out(branch_select_X)
);

/* Compute jr_select_X bit */
wire [31:0] jr_select_X;

mux_2to1 jr_mux_X(			.in0(branch_select_X), 
									.in1(dataB_X), 
									.select(jr_ctrl_X), 
									.out(jr_select_X)
);

/* Compute jump_select_X bit */
wire [31:0] jump_select_X;

mux_2to1 jump_mux_X(			.in0(jr_select_X), 
									.in1(N_val_X), 
									.select(jump_ctrl_X), 
									.out(jump_select_X)
);

/* Compute bex_branch_ctrl_X bit */
wire bex_branch_ctrl_X;
assign bex_branch_ctrl_X =  bex_ctrl_X & ((~status_F[31]) & (|(status_F[30:0])));

/* Compute bex_select_X */
wire [31:0] bex_select_X;

mux_2to1 bex_mux_X(			.in0(jump_select_X), 
									.in1(pcPlusOnePlusN_J1_X), 
									.select(bex_branch_ctrl_X), 
									.out(bex_select_X)
);

/* Compute branchRecovery_ctrl */
wire branchRecovery_ctrl;			assign branchRecovery_ctrl = jump_ctrl_X | jr_ctrl_X | branch_ctrl_X | bex_branch_ctrl_X;

/* 
*
*
*
*					pipeRegister between Execute and Memory Stages 
*
*
*
*/

wire [31:0] pcPlusOne_M, insn_M, dataO_M, dataMpre_M;

pipeRegister pipeRegister_XM(		.enable(1'b1),
											.clock(~clock), 
											.clear(reset), 
											.pcPlusOne_in(pcPlusOne_X), 
											.insn_in(insn_modified_select_X), 
											.in1(rdin_result_select_X), 
											.in2(dataB_X), 
											.pcPlusOne_out(pcPlusOne_M), 
											.insn_out(insn_M), 
											.out1(dataO_M),
											.out2(dataMpre_M) 
);

/* 
*
*
*
*					WM Bypassing
*
*
*
*/

wire [4:0] opcode_01000;			assign opcode_01000 = 5'b01000;

wire [4:0] opcodeCheckBits_WM_XM;		genvar i11;
													generate
													for (i11 = 0; i11<5; i11=i11+1) begin: loop_WM_ctrl_11
														assign opcodeCheckBits_WM_XM[i11] = (opcode_M[i11] & opcode_00111[i11]) | (~opcode_M[i11] & ~opcode_00111[i11]);
													end
													endgenerate

wire opcodeCheck_WM_XM;				assign opcodeCheck_WM_XM = &(opcodeCheckBits_WM_XM);

wire [4:0] opcodeCheckBits_WM_MW;		genvar j11;
													generate
													for (j11 = 0; j11<5; j11=j11+1) begin: loop_WM_ctrl_11j
														assign opcodeCheckBits_WM_MW[j11] = (opcode_W[j11] & opcode_01000[j11]) | (~opcode_W[j11] & ~opcode_01000[j11]);
													end
													endgenerate

wire opcodeCheck_WM_MW;				assign opcodeCheck_WM_MW = &(opcodeCheckBits_WM_MW);

wire [4:0] RDEqRDBits_WM;			genvar i12;
											generate
											for (i12 = 0; i12<5; i12=i12+1) begin: loop_WM_ctrl_12
												assign RDEqRDBits_WM[i12] = (insn_M[22+i12] & insn_W[22+i12]) | (~insn_M[22+i12] & ~insn_W[22+i12]);
											end
											endgenerate
											
wire RDEqRD_WM;						assign RDEqRD_WM = &(RDEqRDBits_WM);

wire WM_ctrl;							assign WM_ctrl = opcodeCheck_WM_XM & opcodeCheck_WM_MW & RDEqRD_WM;

/* 
*
*
*
*					Actual WM bypassing 
*
*
*
*/

wire [31:0] dataM_M;

mux_2to1 MW_mux_X(		.in0(dataMpre_M), 
								.in1(memToReg_select_W), 
								.select(WM_ctrl), 
								.out(dataM_M)
);

/* 
*
*
*
*					Memory Stage 
*
*
*
*/

wire [4:0] opcode_M;					assign opcode_M = insn_M[31:27];
wire memWrite_ctrl_M;

control_XM mycontrol_XM(	.in(opcode_M), 
									.memWrite(memWrite_ctrl_M)
);

wire [31:0] readData_M;

assign debug_addr = dataO_M[11:0];
assign debug_data = dataM_M;

dmem mydmem(	.address	(debug_addr),
					.clock		(clock),
					.data		(debug_data),
					.wren		(memWrite_ctrl_M),
					.q			(out2) // change where output q goes...
);

assign readData_M = out2;

/* 
*
*
*
*					pipeRegister between Memory and Writeback Stages 
*
*
*
*/

wire [31:0] pcPlusOne_W, insn_W, dataO_W, dataD_W;


pipeRegister pipeRegister_MW(		.enable(1'b1),
											.clock(~clock), 
											.clear(reset),  
											.pcPlusOne_in(pcPlusOne_M), 
											.insn_in(insn_M), 
											.in1(dataO_M), 
											.in2(readData_M),  
											.pcPlusOne_out(pcPlusOne_W), 
											.insn_out(insn_W), 
											.out1(dataO_W),
											.out2(dataD_W) 
);

/* 
*
*
*
*					Writeback Stage 
*
*
*
*/

wire [4:0] opcode_W;					assign opcode_W = insn_W[31:27];
wire [4:0] rd_W;						assign rd_W = insn_W[26:22];
wire jump_ctrl_W, regWrite_ctrl_W, memToReg_ctrl_W;

control_MW mycontrol_MW(		.in(opcode_W), 
										.jump(jump_ctrl_W), 
										.regWrite(regWrite_ctrl_W), 
										.memToReg(memToReg_ctrl_W)
);

wire [31:0] memToReg_select_W, jump_select_W;

mux_2to1 memToReg_mux_W(	.in0(dataO_W), 
									.in1(dataD_W), 
									.select(memToReg_ctrl_W), 
									.out(memToReg_select_W)
);

mux_2to1 jump_mux_W(			.in0(memToReg_select_W), 
									.in1(pcPlusOne_W), 
									.select(jump_ctrl_W), 
									.out(jump_select_W)
);



endmodule

/**
*
*
*
*
*
*
*
*
* 			MODULES THAT ARE NEEDED FOR FUNCTIONALITY
*
*
*
*
*
*
*
*/

module pipeRegister(enable, clock, clear, pcPlusOne_in, insn_in, in1, in2, pcPlusOne_out, insn_out, out1, out2);
input enable, clock, clear;
input [31:0] pcPlusOne_in, insn_in, in1, in2;
output [31:0] pcPlusOne_out, insn_out, out1, out2;

register pcPlusOne_register(.dataInput(pcPlusOne_in), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(pcPlusOne_out));
register insn_register(.dataInput(insn_in), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(insn_out));
register inout1_register(.dataInput(in1), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out1));
register inout2_register(.dataInput(in2), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out2));

endmodule

////////////////////////////////////////////////////

module pipeRegister_DXX(enable, clock, clear, pcPlusOne_in, insn_in, in1, in2, pcPlusOne_out, insn_out, out1, out2,
								in_Reg16, in_Reg17, in_Reg18, in_Reg19, in_Reg20, in_Reg21, in_Reg22, in_Reg23, in_Reg24,
								out_Reg16, out_Reg17, out_Reg18, out_Reg19, out_Reg20, out_Reg21, out_Reg22, out_Reg23, out_Reg24);
input enable, clock, clear;
input [31:0] pcPlusOne_in, insn_in, in1, in2;
output [31:0] pcPlusOne_out, insn_out, out1, out2;
input [31:0] in_Reg16, in_Reg17, in_Reg18, in_Reg19, in_Reg20, in_Reg21, in_Reg22, in_Reg23, in_Reg24;
output [31:0] out_Reg16, out_Reg17, out_Reg18, out_Reg19, out_Reg20, out_Reg21, out_Reg22, out_Reg23, out_Reg24;

register pcPlusOne_register(.dataInput(pcPlusOne_in), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(pcPlusOne_out));
register insn_register(.dataInput(insn_in), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(insn_out));
register inout1_register(.dataInput(in1), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out1));
register inout2_register(.dataInput(in2), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out2));

register reg16_register(.dataInput(in_Reg16), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg16));
register reg17_register(.dataInput(in_Reg17), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg17));
register reg18_register(.dataInput(in_Reg18), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg18));
register reg19_register(.dataInput(in_Reg19), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg19));
register reg20_register(.dataInput(in_Reg20), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg20));
register reg21_register(.dataInput(in_Reg21), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg21));
register reg22_register(.dataInput(in_Reg22), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg22));
register reg23_register(.dataInput(in_Reg23), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg23));
register reg24_register(.dataInput(in_Reg24), .clk(clock), .clr(clear), .inEnable(enable), .regOutput(out_Reg24));

endmodule

////////////////////////////////////////////////////

module register(dataInput, clk, clr, inEnable, regOutput);
	input [31:0] dataInput;
	input clk, clr, inEnable;
	output [31:0] regOutput;

//	wire isValidInput;
	
//	assign isValidInput = clk & inEnable;
	
	genvar i3;
	generate
		for (i3 = 0; i3<32; i3=i3+1) begin: loop1
			dflipflop a_dff(.d(dataInput[i3]), .enable(inEnable), .aclr(clr), .clk(/*isValidInput*/ clk), .f(regOutput[i3]));
		end
	endgenerate
	
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

////////////////////////////////////////////////////
////////////////////////////////////////////////////

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

////////////////////////////////////////////////////

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

////////////////////////////////////////////////////

module barrel_sll(in, shamt, out);
	input [31:0] in;
	input [4:0] shamt;
	output [31:0] out;
	
	assign out = (in << shamt);
endmodule

////////////////////////////////////////////////////

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

////////////////////////////////////////////////////

module barrel_sra(in, shamt, out);
	input signed [31:0] in;
	input [4:0] shamt;
	output signed [31:0] out;
	
	assign out = (in >>> shamt);
endmodule

////////////////////////////////////////////////////

module mux_2to1(in0, in1, select, out);
	input [31:0] in0;
	input [31:0] in1;
	input select;
	output [31:0] out;
	
	assign out = select ? in1 : in0;
endmodule

////////////////////////////////////////////////////

module mux_2to1_5bit(in0, in1, select, out);
	input [4:0] in0;
	input [4:0] in1;
	input select;
	output [4:0] out;
	
	assign out = select ? in1 : in0;
endmodule

////////////////////////////////////////////////////

module decoder1(inputBin, outputHot);
	input [4:0] inputBin;
	output [31:0] outputHot;
	
	wire [31:0] outputHot;
	assign outputHot = (1 << inputBin);
	
endmodule

////////////////////////////////////////////////////////////////////////////////

module tristate(in, oe, out);
	input [31:0] in;
	input oe;
	output [31:0] out;
	
	assign out = oe ? in : 32'bz;
endmodule

////////////////////////////////////////////////////////////////////////////////

module dflipflop(d, enable, aclr, clk, f);
	input d, enable, aclr, clk;
	output f;
	reg f;
	
	wire d_select;
	assign d_select = (d & enable) | (~enable & f);
	
	always @(posedge clk or posedge aclr) begin
		if(aclr) begin
			f = 1'b0;
		end else begin
		f = d_select;
		end
	end
endmodule

////////////////////////////////////////////////////////////////////////////////

module decoder(inputBin, outputHot, enable);
	input [4:0] inputBin;
	input enable;
	output [31:0] outputHot;
	
	wire [31:0] outputHot;
	assign outputHot = (enable) ? (1 << inputBin) : 32'b0;
	
endmodule

////////////////////////////////////////////////////////////////////////////////

module regFile(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB,
					data_readReg16, data_readReg17, data_readReg18, data_readReg19, data_readReg20, data_readReg21, data_readReg22, data_readReg23, data_readReg24,
					
					data_readReg1, data_readReg2, data_readReg3, data_readReg4, data_readReg5,
					data_readReg6, data_readReg7, data_readReg8, data_readReg9, data_readReg10,
					data_readReg11, data_readReg12, data_readReg13, data_readReg14, data_readReg15,
					data_readReg25, data_readReg26, data_readReg27, data_readReg28, data_readReg29,
					data_readReg30, data_readReg31
);
   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;
   output [31:0] data_readRegA, data_readRegB;
	output [31:0] data_readReg16, data_readReg17, data_readReg18, data_readReg19, data_readReg20, data_readReg21, data_readReg22, data_readReg23, data_readReg24;

	/*554 outputs:*/
	output [31:0] 	data_readReg1, data_readReg2, data_readReg3, data_readReg4, data_readReg5,
						data_readReg6, data_readReg7, data_readReg8, data_readReg9, data_readReg10,
						data_readReg11, data_readReg12, data_readReg13, data_readReg14, data_readReg15,
						data_readReg25, data_readReg26, data_readReg27, data_readReg28, data_readReg29,
						data_readReg30, data_readReg31;
	
	wire [31:0] rdVal_decoderOutput, rs1Val_decoderOutput, rs2Val_decoderOutput;
	
	/*
	wire [31:0] r16Val_decoderOutput, r17Val_decoderOutput, r18Val_decoderOutput, 
					r19Val_decoderOutput, r20Val_decoderOutput, r21Val_decoderOutput, 
					r22Val_decoderOutput, r23Val_decoderOutput, r24Val_decoderOutput;
	assign r16Val_decoderOutput = 32'b00000000000000010000000000000000;
	assign r17Val_decoderOutput = 32'b00000000000000100000000000000000;
	assign r18Val_decoderOutput = 32'b00000000000001000000000000000000;
	assign r19Val_decoderOutput = 32'b00000000000010000000000000000000;
	assign r20Val_decoderOutput = 32'b00000000000100000000000000000000;
	assign r21Val_decoderOutput = 32'b00000000001000000000000000000000;
	assign r22Val_decoderOutput = 32'b00000000010000000000000000000000;
	assign r23Val_decoderOutput = 32'b00000000100000000000000000000000;
	assign r24Val_decoderOutput = 32'b00000001000000000000000000000000; 
	*/
	wire [31:0] flipflopInEnable;
	wire [31:0] regOutput [31:0];
	wire const_true;
	
	assign const_true = 1'b1;
	
	//Initialize decoders:
	decoder rdVal_decoder(ctrl_writeReg, rdVal_decoderOutput, const_true);
	decoder rs1Val_decoder(ctrl_readRegA, rs1Val_decoderOutput, const_true);
	decoder rs2Val_decoder(ctrl_readRegB, rs2Val_decoderOutput, const_true);
	
//	assign flipflopInEnable = rdVal_decoderOutput & ctrl_writeEnable;
	
	genvar j4;
	generate
		for (j4 = 0; j4 < 32; j4=j4+1) begin: loop0j4
			assign flipflopInEnable[j4] = rdVal_decoderOutput[j4] & ctrl_writeEnable;
		end
	endgenerate
	
	
	genvar i6;
	generate
		for (i6 = 0; i6<32; i6=i6+1) begin: loop1i6
			register a_register(.dataInput(data_writeReg), .clk(clock), .clr(ctrl_reset), 
										.inEnable(flipflopInEnable[i6]), .regOutput(regOutput[i6]));
			tristate4Input a_tri(.in(regOutput[i6]), .oe(rs1Val_decoderOutput[i6]), .out(data_readRegA), .clr(ctrl_reset));
			tristate4Input b_tri(.in(regOutput[i6]), .oe(rs2Val_decoderOutput[i6]), .out(data_readRegB), .clr(ctrl_reset));
			/*
			tristate4Input tri_16(.in(regOutput[i6]), .oe(r16Val_decoderOutput[i6]), .out(data_readReg16), .clr(ctrl_reset));
			tristate4Input tri_17(.in(regOutput[i6]), .oe(r17Val_decoderOutput[i6]), .out(data_readReg17), .clr(ctrl_reset));
			tristate4Input tri_18(.in(regOutput[i6]), .oe(r18Val_decoderOutput[i6]), .out(data_readReg18), .clr(ctrl_reset));
			tristate4Input tri_19(.in(regOutput[i6]), .oe(r19Val_decoderOutput[i6]), .out(data_readReg19), .clr(ctrl_reset));
			tristate4Input tri_20(.in(regOutput[i6]), .oe(r20Val_decoderOutput[i6]), .out(data_readReg20), .clr(ctrl_reset));
			tristate4Input tri_21(.in(regOutput[i6]), .oe(r21Val_decoderOutput[i6]), .out(data_readReg21), .clr(ctrl_reset));
			tristate4Input tri_22(.in(regOutput[i6]), .oe(r22Val_decoderOutput[i6]), .out(data_readReg22), .clr(ctrl_reset));
			tristate4Input tri_23(.in(regOutput[i6]), .oe(r23Val_decoderOutput[i6]), .out(data_readReg23), .clr(ctrl_reset));
			tristate4Input tri_24(.in(regOutput[i6]), .oe(r24Val_decoderOutput[i6]), .out(data_readReg24), .clr(ctrl_reset));
			*/
		end
	endgenerate
	
	assign data_readReg16 = regOutput[16];
	assign data_readReg17 = regOutput[17];
	assign data_readReg18 = regOutput[18];
	assign data_readReg19 = regOutput[19];
	assign data_readReg20 = regOutput[20];
	assign data_readReg21 = regOutput[21];
	assign data_readReg22 = regOutput[22];
	assign data_readReg23 = regOutput[23];
	assign data_readReg24 = regOutput[24];
	
	/*ECE 554 Extension:*/
	assign data_readReg1 = regOutput[1];
	assign data_readReg2 = regOutput[2];
	assign data_readReg3 = regOutput[3];
	assign data_readReg4 = regOutput[4];
	assign data_readReg5 = regOutput[5];
	assign data_readReg6 = regOutput[6];
	assign data_readReg7 = regOutput[7];
	assign data_readReg8 = regOutput[8];
	assign data_readReg9 = regOutput[9];
	assign data_readReg10 = regOutput[10];
	assign data_readReg11 = regOutput[11];
	assign data_readReg12 = regOutput[12];
	assign data_readReg13 = regOutput[13];
	assign data_readReg14 = regOutput[14];
	assign data_readReg15 = regOutput[15];
	assign data_readReg25 = regOutput[25];
	assign data_readReg26 = regOutput[26];
	assign data_readReg27 = regOutput[27];
	assign data_readReg28 = regOutput[28];
	assign data_readReg29 = regOutput[29];
	assign data_readReg30 = regOutput[30];
	assign data_readReg31 = regOutput[31];
			
endmodule

module tristate4Input(in, oe, out, clr);
	input [31:0] in;
	input oe, clr;
	output [31:0] out;
	
	assign out = oe ? in : 32'bz;
endmodule


////////////////////////////////////////////////////////////////////////////////

/*** Note: Perhaps this is correct. Ask the TA. 
module control_FD(in, jump, regWrite, regDst); ***/

module control_FD(in, regDst);

input [4:0] in;
output regDst;

// regDst = 00010 | 00100 | 00110 | 00111
assign regDst = (~in[4] & ~in[3] & ~in[2] & in[1] & ~in[0]) | (~in[4] & ~in[3] & in[2] & ~in[1] & ~in[0]) |
					 (~in[4] & ~in[3] & in[2] & in[1] & ~in[0]) | (~in[4] & ~in[3] & in[2] & in[1] & in[0]);

endmodule

////////////////////////////////////////////////////////////////////////////////

module control_DX(in, setx, bex, jump, jr, blt, bne, aluSrc, aluOp, aluOpBranch);

input [4:0] in;
output setx, bex, jump, jr, blt, bne, aluSrc, aluOp, aluOpBranch;

// setx = 10101
assign setx = (in[4] & ~in[3] & in[2] & ~in[1] & in[0]);
// bex = 10110
assign bex = (in[4] & ~in[3] & in[2] & in[1] & ~in[0]);
// Jump = 00001 | 00011
assign jump = (~in[4] & ~in[3] & ~in[2] & ~in[1] & in[0]) | (~in[4] & ~in[3] & ~in[2] & in[1] & in[0]);
// jr = 00100
assign jr = (~in[4] & ~in[3] & in[2] & ~in[1] & ~in[0]);
// blt = 00110
assign blt = (~in[4] & ~in[3] & in[2] & in[1] & ~in[0]);
// bne = 00010
assign bne = (~in[4] & ~in[3] & ~in[2] & in[1] & ~in[0]);
// aluSrc = 00101 | 00111 | 01000
assign aluSrc = (~in[4] & ~in[3] & in[2] & ~in[1] & in[0]) | (~in[4] & ~in[3] & in[2] & in[1] & in[0]) |
					 (~in[4] & in[3] & ~in[2] & ~in[1] & ~in[0]);
// aluOp = 00000 --> default action is addition
assign aluOp = (~in[4] & ~in[3] & ~in[2] & ~in[1] & ~in[0]);
// aluOpBranch = 00010 | 00110
assign aluOpBranch = (~in[4] & ~in[3] & ~in[2] & in[1] & ~in[0]) | (~in[4] & ~in[3] & in[2] & in[1] & ~in[0]);

endmodule

////////////////////////////////////////////////////////////////////////////////

module control_XM(in, memWrite);

input [4:0] in;
output memWrite;

// memWrite = 00111
assign memWrite = (~in[4] & ~in[3] & in[2] & in[1] & in[0]);

endmodule

////////////////////////////////////////////////////////////////////////////////

module control_MW(in, jump, regWrite, memToReg);

input [4:0] in;
output jump, regWrite, memToReg;

// Jump = 00001 | 00011
assign jump = (~in[4] & ~in[3] & ~in[2] & ~in[1] & in[0]) | (~in[4] & ~in[3] & ~in[2] & in[1] & in[0]);
// regWrite = 00000 | 00101 | 00011 | 01000
assign regWrite = (~in[4] & ~in[3] & ~in[2] & ~in[1] & ~in[0]) | (~in[4] & ~in[3] & in[2] & ~in[1] & in[0]) |
						(~in[4] & ~in[3] & ~in[2] & in[1] & in[0]) | (~in[4] & in[3] & ~in[2] & ~in[1] & ~in[0]); 
// memToReg = 01000
assign memToReg = (~in[4] & in[3] & ~in[2] & ~in[1] & ~in[0]);

endmodule































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

module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, out_remainder, data_exception, data_inputRDY, data_resultRDY);
   input signed [31:0] data_operandA;
   input signed [15:0] data_operandB;
   input ctrl_MULT, ctrl_DIV, clock;             
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
	mult mult1(data_operandA, data_operandB, my_tristates[1], mult_exception, clock, my_tristates2[1], my_tristates3[1]);
	// Get result
	//assign mult_result = initial_data;
	div div1(data_operandA, data_operandB, my_tristates[2], clock, my_tristates2[2], my_tristates3[2], out_remainder);
	
	assign data_exception = ((~|data_operandB[15:0] & ctrl_DIV) | (mult_exception & ctrl_MULT));
//	assign data_inputRDY = 1'b1;
//	assign data_resultRDY = 1'b1;
	//assign data_result[31:0] = results[2];
endmodule

// 5 to 32 decoder
module decoder32(in, out);
	input[4:0] in;
	output[31:0] out;
	assign out = (1 << in);
endmodule

// 2 to 4 decoder
module decoder8(in, out);
	input[1:0] in;
	output[3:0] out;
	assign out = (1 << in);
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


module as515_alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
   output [31:0] data_result;
   output isNotEqual, isLessThan;
	wire[31:0]my_tristates[31:0];
	wire[31:0]decoder_result;
	
	decoder32 my_decoder(.in(ctrl_ALUopcode), .out(decoder_result));
	
	thirtytwo_bit_adder ba1(.A(data_operandA), .B(data_operandB), .C_in(1'b0), .S(my_tristates[0]));
	thirtytwo_bit_adder ba2(.A(data_operandA), .B(~data_operandB), .C_in(1'b1), .S(my_tristates[1]));
	and32 a1(.inA(data_operandA), .inB(data_operandB), .out(my_tristates[2]));
	or32 o1(.inA(data_operandA), .inB(data_operandB), .out(my_tristates[3]));
	barrel_shifter_sll s1(.in(data_operandA), .out(my_tristates[4]), .shift(ctrl_shiftamt));
	barrel_shifter_sra s2(.in(data_operandA), .out(my_tristates[5]), .shift(ctrl_shiftamt));
	
	//check_isEqual chk(.inA(my_tristates[1]), .result(isNotEqual));
	assign isNotEqual = ~|my_tristates[1];
	assign isLessThan = ((data_operandA[31] & ~data_operandB[31])|
								(my_tristates[1][31] & ~data_operandA[31] & ~data_operandB[31]) |
								(my_tristates[1][31] & data_operandA[31] & data_operandB[31]));
	genvar i;
	generate
	for (i=0; i<32; i=i+1) begin: loop1
		tristate my_tristate(.in(my_tristates[i]), .oe(decoder_result[i]), .out(data_result));
	end
	endgenerate
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




module mult(data_operandA, data_operandB, result, mult_exception, clock, datainput_ready, dataoutput_ready);
	input signed [31:0] data_operandA;
   input signed [15:0] data_operandB;
	input clock;
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
	assign result = initial_data[8][32:1];
	
	wire [15:0] exception_wire;
	for (l=32; l<48; l=l+1) begin: loop4
		assign exception_wire[l-32] = initial_data[8][l] ^ (data_operandA[31] ^ data_operandB[15]);
	end
	assign mult_exception = |exception_wire;
	//assign mult_exception = &(initial_data[8][47:32]) & (data_operandA[31] ^ data_operandB[15]));
	
	endgenerate
endmodule


module multdiv_control(sel, ctrl_shift, ctrl_alu, alu_enable);
	input[2:0] sel;
	output ctrl_shift, ctrl_alu, alu_enable;
	assign ctrl_shift = (sel[2] & ~sel[1] & ~sel[0]) | (~sel[2] & sel[1] & sel[0]);
	assign ctrl_alu = (sel[2] & ~sel[1] & ~sel[0]) | (sel[2] & sel[1] & ~sel[0]) | (sel[2] & ~sel[1] & sel[0]);
	assign alu_enable = ~((~sel[2] & ~sel[1] & ~sel[0]) | (sel[2] & sel[1] & sel[0]));
endmodule

module multdiv_alu(alu_enable, ctrl_alu, inA, inB, out);
	input alu_enable, ctrl_alu;
	input signed [31:0] inA, inB;
	wire signed [31:0] result_add, result_sub, result_mux;
	output signed [31:0] out;
	thirtytwo_bit_adder ba1(.A(inA), .B(inB), .C_in(1'b0), .S(result_add));
	thirtytwo_bit_adder ba2(.A(inA), .B(~inB), .C_in(1'b1), .S(result_sub));
	mux2to1 muxxy(.inA(result_add), .inB(result_sub), .sel(ctrl_alu), .out(result_mux));
	assign out = alu_enable ? result_mux : inA;
endmodule


//module check_isEqual(inA, result);
//	input[31:0] inA;
//	output result;
//	assign result = 1'b0;
//	genvar i;
//	generate
//	for (i=0; i<32; i=i+1) begin: loop1
//		assign result = result | inA[i] | 1'b0;
//	end
//	endgenerate
//endmodule

module barrel_shifter_sll(in, shift, out);
	input signed [31:0] in;
	input [4:0] shift;
	output signed[31:0] out;
	wire signed[31:0] a[3:0];
	
	mux2to1 my_mux(.inA(in), .inB(in<<5'b10000), .sel(shift[4]), .out(a[0]));
	mux2to1 my_mux1(.inA(a[0]), .inB(a[0]<<5'b01000), .sel(shift[3]), .out(a[1]));
	mux2to1 my_mux2(.inA(a[1]), .inB(a[1]<<5'b00100), .sel(shift[2]), .out(a[2]));
	mux2to1 my_mux3(.inA(a[2]), .inB(a[2]<<5'b00010), .sel(shift[1]), .out(a[3]));
	mux2to1 my_mux4(.inA(a[3]), .inB(a[3]<<5'b00001), .sel(shift[0]), .out(out));
endmodule

module barrel_shifter_sra(in, shift, out);
	input signed [31:0] in;
	input [4:0] shift;
	output signed[31:0] out;
	wire signed[31:0] a[3:0];
	
	mux2to1 my_mux(.inA(in), .inB(in>>>5'b10000), .sel(shift[4]), .out(a[0]));
	mux2to1 my_mux1(.inA(a[0]), .inB(a[0]>>>5'b01000), .sel(shift[3]), .out(a[1]));
	mux2to1 my_mux2(.inA(a[1]), .inB(a[1]>>>5'b00100), .sel(shift[2]), .out(a[2]));
	mux2to1 my_mux3(.inA(a[2]), .inB(a[2]>>>5'b00010), .sel(shift[1]), .out(a[3]));
	mux2to1 my_mux4(.inA(a[3]), .inB(a[3]>>>5'b00001), .sel(shift[0]), .out(out));
endmodule

module mux2to1(inA, inB, sel, out);
	input[31:0] inA, inB;
	input sel;
	output[31:0] out;
	assign out = (sel) ? inB : inA;
endmodule

// 1-bit I/O Tristate buffer
module tristate1(in, out, enable);
	input in;
	input enable;
	output out;
	assign out = enable ? in : 1'bz;
endmodule

module and32(inA, inB, out);
	input [31:0] inA, inB;
	output [31:0] out;
	assign out = (inA & inB);
endmodule

module or32(inA, inB, out);
	input [31:0] inA, inB;
	output [31:0] out;
	assign out = (inA | inB);
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


















module cycle(in, out);
	input [31:0] in;
	output [31:0] out;
	wire a, b, c;
	assign a = in[6];
	assign b = in[5];
	assign c = in[4];
	assign out[4] = ~c;
	assign out[5] = b&~c|~b&c;
	assign out[6] = a&~c|a&~b|~a&b&c;
	assign out[31:7] = in[31:7];
	assign out[3:0] = in[3:0];
	
endmodule

module dropModule(r0, r1, r2, r3, r4, r5, r6, r7, r8, rxx, modinst);
	input [31:0] r0, r1, r2, r3, r4, r5, r6, r7, r8;
	output [31:0] rxx, modinst;
	assign modinst[31:25] = 7'b0000010;
	assign modinst[21:0] = 22'b0;
	assign modinst[24:22] = r8[6:4];
	wire [31:0] muxout;
	
	mux8 eightonem(r0, r1, r2, r3, r4, r5, r6, r7, r8[6:4], muxout);
	drop dropped(muxout, r8[7], rxx);

endmodule

module mux8(r0, r1, r2, r3, r4, r5, r6, r7, sel, out);
	input [31:0] r0, r1, r2, r3, r4, r5, r6, r7;
	input [2:0] sel;
	output [31:0] out;
	reg [31:0] out;
	
	always@(sel)
	begin:mux
		case(sel)
			3'b000: out = r0;
			3'b001: out = r1;
			3'b010: out = r2;
			3'b011: out = r3;
			3'b100: out = r4;
			3'b101: out = r5;
			3'b110: out = r6;
			3'b111: out = r7;
		endcase
	end

endmodule

module drop(cin, color, cout);
	input [31:0] cin;
	output [31:0] cout;
	input color; // r = 1, g = 0;
	wire [7:0] occ0, r0, g0, occ1, r1, g1;
	assign occ0 = cin[23:16];
	assign r0 = cin[15:8];
	assign g0 = cin[7:0];
	assign cout[31:24] = 8'b00000000;
	assign cout[23:16] = occ1;
	assign cout[15:8] = r1;
	assign cout[7:0] = g1;
	
	assign occ1[7] = 1;
	assign occ1[6] = occ0[6]|occ0[7];
	assign occ1[5] = occ0[5]|occ0[6];
	assign occ1[4] = occ0[4]|occ0[5];
	assign occ1[3] = occ0[3]|occ0[4];
	assign occ1[2] = occ0[2]|occ0[3];
	assign occ1[1] = occ0[1]|occ0[2];
	assign occ1[0] = occ0[0]|occ0[1];
	
	// red drop logic
	sel rd7(r0[7], 1'b1, r1[7], ~occ0[7]&color);
	sel rd6(r0[6], 1'b1, r1[6], ~occ0[6]&occ0[7]&color);
	sel rd5(r0[5], 1'b1, r1[5], ~occ0[5]&occ0[6]&color);
	sel rd4(r0[4], 1'b1, r1[4], ~occ0[4]&occ0[5]&color);
	sel rd3(r0[3], 1'b1, r1[3], ~occ0[3]&occ0[4]&color);
	sel rd2(r0[2], 1'b1, r1[2], ~occ0[2]&occ0[3]&color);
	sel rd1(r0[1], 1'b1, r1[1], ~occ0[1]&occ0[2]&color);
	sel rd0(r0[0], 1'b1, r1[0], ~occ0[0]&occ0[1]&color);
	
	// green drop logic
	sel gd7(g0[7], 1'b1, g1[7], ~occ0[7]&~color);
	sel gd6(g0[6], 1'b1, g1[6], ~occ0[6]&occ0[7]&~color);
	sel gd5(g0[5], 1'b1, g1[5], ~occ0[5]&occ0[6]&~color);
	sel gd4(g0[4], 1'b1, g1[4], ~occ0[4]&occ0[5]&~color);
	sel gd3(g0[3], 1'b1, g1[3], ~occ0[3]&occ0[4]&~color);
	sel gd2(g0[2], 1'b1, g1[2], ~occ0[2]&occ0[3]&~color);
	sel gd1(g0[1], 1'b1, g1[1], ~occ0[1]&occ0[2]&~color);
	sel gd0(g0[0], 1'b1, g1[0], ~occ0[0]&occ0[1]&~color);
	
endmodule

module sel(ina, inb, out, s);
	input ina, inb, s;
	output out;
	assign out = s ? inb:ina;
endmodule












module wincon(r11, r12, r13, r14, r15, r16, r17, r18, rwin, gwin);
	input [31:0] r11, r12, r13, r14, r15, r16, r17, r18;
	// r11 is left most column
	// r18 is right most column
	// 15 is lowest red, 8 is highest red
	// 7 is lowest green, 0 is highest green
	output rwin, gwin;
	// [0] is left most column
	// [0][0] is top left
	// [7][7] is bottom right
	wire [7:0] r[7:0], g[7:0];
	wire [3:0] rwins, gwins; // 3... vertical, horizontal, right and down, right and up...1
	assign r[0] = r11[15:8];// first column
	assign r[1] = r12[15:8];
	assign r[2] = r13[15:8];
	assign r[3] = r14[15:8];
	assign r[4] = r15[15:8];/// >>>>> is top side
	assign r[5] = r16[15:8];
	assign r[6] = r17[15:8];
	assign r[7] = r18[15:8];
	assign g[0] = r11[7:0];
	assign g[1] = r12[7:0];
	assign g[2] = r13[7:0];
	assign g[3] = r14[7:0];
	assign g[4] = r15[7:0];
	assign g[5] = r16[7:0];
	assign g[6] = r17[7:0];
	assign g[7] = r18[7:0];
	wire [4:0] rwru[4:0], gwru[4:0]; //tracks possible wins right and up; 5 columns, 5 rows
	wire [4:0] rwrd[4:0], gwrd[4:0]; //tracks possible wins right and down; 5 columns, 5 rows
	wire [7:0] rwh[4:0], gwh[4:0]; //tracks possible wins horizontal; 5 columns, 8 rows
	wire [4:0] rwv[7:0], gwv[7:0]; //tracks possible wins vertical; 8 columns, 5 rows
	assign rwins[0] = (|rwru[4])|(|rwru[3])|(|rwru[2])|(|rwru[1])|(|rwru[0]);
	assign gwins[0] = (|gwru[4])|(|gwru[3])|(|gwru[2])|(|gwru[1])|(|gwru[0]);
	assign rwins[1] = (|rwrd[4])|(|rwrd[3])|(|rwrd[2])|(|rwrd[1])|(|rwrd[0]);
	assign gwins[1] = (|gwrd[4])|(|gwrd[3])|(|gwrd[2])|(|gwrd[1])|(|gwrd[0]);
	assign rwins[2] = (|rwh[4])|(|rwh[3])|(|rwh[2])|(|rwh[1])|(|rwh[0]);
	assign gwins[2] = (|gwh[4])|(|gwh[3])|(|gwh[2])|(|gwh[1])|(|gwh[0]);
	assign rwins[3] = (|rwv[7])|(|rwv[6])|(|rwv[5])|(|rwv[4])|(|rwv[3])|(|rwv[2])|(|rwv[1])|(|rwv[0]);
	assign gwins[3] = (|gwv[7])|(|gwv[6])|(|gwv[5])|(|gwv[4])|(|gwv[3])|(|gwv[2])|(|gwv[1])|(|gwv[0]);
	assign rwin = |rwins;
	assign gwin = |gwins;
	
	genvar i;
	genvar j;
	generate
	// check vertical;
	for (i = 0; i<=4; i = i+1) begin: vrow
		for (j = 0; j<8; j = j+1) begin: vcol
			assign rwv[j][i] = r[j][i]&r[j][i+1]&r[j][i+2]&r[j][i+3];
			assign gwv[j][i] = g[j][i]&g[j][i+1]&g[j][i+2]&g[j][i+3];
		end
	end
	
	// check horizontal
	
	for (i = 0; i<8; i = i+1) begin: hrow
		for (j = 0; j<=4; j = j+1) begin: hcol
			assign rwh[j][i] = r[j][i]&r[j+1][i]&r[j+2][i]&r[j+3][i];
			assign gwh[j][i] = g[j][i]&g[j+1][i]&g[j+2][i]&g[j+3][i];
		end
	end
	
	// check right up
	
	for (i = 0; i<=4; i = i+1) begin: rdrow
		for (j = 0; j<=4; j = j+1) begin: rdcol
			assign rwrd[j][i] = r[j][i]&r[j+1][i+1]&r[j+2][i+2]&r[j+3][i+3];
			assign gwrd[j][i] = g[j][i]&g[j+1][i+1]&g[j+2][i+2]&g[j+3][i+3];
		end
	end
	
	// check right down
	
	for (i = 3; i<8; i = i+1) begin: rurow
		for (j = 0; j<=4; j = j+1) begin: rucol
			assign rwru[j][i-3] = r[j][i]&r[j+1][i-1]&r[j+2][i-2]&r[j+3][i-3];
			assign gwru[j][i-3] = g[j][i]&g[j+1][i-1]&g[j+2][i-2]&g[j+3][i-3];
		end
	end
	
	endgenerate

endmodule



/**
* ###########################
* ##	 554 Final Project   ##
* ##								##
* ###########################
*/

module multdiv_checker(inA, inB, inMultDivResult, ctrl_MULT, ctrl_DIV, inRemainder, outError, enable);
	/**
	* Refer to Figure 4. Multiplier/Divider Sub-Checker in Argus paper
	* TODO: Modulo operation currently uses Verilog's built in operand %. Need to implement using combinational logic.
	*/
	
	input signed [31:0] inA;
	input signed [15:0] inB;
	// Opcodes:
	input ctrl_MULT, ctrl_DIV;
	
	input signed [31:0] inMultDivResult;
	input [31:0] inRemainder;		// TODO: determine if signed or unsigned
	output outError;
	output enable;
	
	// Constants:
	wire [31:0] zero_32bit;						assign zero_32bit = 32'b00000000000000000000000000000000;
	wire [31:0] mersenne_5;						assign mersenne_5 = 32'b00000000000000000000000000011111;
	wire [31:0] negate_Remainder;				assign negate_Remainder = ~inRemainder;
	wire [31:0] negative_Remainder;			abl17_adder_32bit negativeRemainderAdder(.a(negate_Remainder), 
																											  .b(zero_32bit), 
																											  .cin(is_instruction_division), 
																											  .sum(negative_Remainder)
														);
	
	// &([] ~^ []) determines whether two values are exactly equal
	wire is_instruction_multiplication;		assign is_instruction_multiplication = ctrl_MULT;
	wire is_instruction_division;				assign is_instruction_division = ctrl_DIV;
	
	// Determine whether to enable the output of the checker. In other words, if opcodes are neither 00110 nor 00111, disable.
	assign enable = is_instruction_multiplication | is_instruction_division;
	
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
								.in1(negative_Remainder), 
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

