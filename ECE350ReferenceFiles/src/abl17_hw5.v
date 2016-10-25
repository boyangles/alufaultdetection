module abl17_hw5(	inclock, resetn, /*ps2_clock, ps2_data,*/ debug_word, debug_addr, leds, 
					lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon, 	
					seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8);

	input 			inclock, resetn;
	//inout 			ps2_data, ps2_clock;
	
	output 			lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon;
	output 	[7:0] 	leds, lcd_data;
	output 	[6:0] 	seg1, seg2, seg3, seg4, seg5, seg6, seg7, seg8;
	output 	[31:0] 	debug_word;
	output  [11:0]  debug_addr;
	
	wire			clock;
	wire			lcd_write_en;
	wire 	[31:0]	lcd_write_data;
	wire	[7:0]	ps2_key_data;
	wire			ps2_key_pressed;
	wire	[7:0]	ps2_out;	

	
	// clock divider (by 5, i.e., 10 MHz)
//	pll div(inclock,clock);
	
	// UNCOMMENT FOLLOWING LINE AND COMMENT ABOVE LINE TO RUN AT 50 MHz
	//assign clock = inclock;
	
	// your processor
	wire [31:0] out1, out2;
	processor myprocessor(inclock, ~resetn, ps2_key_pressed, ps2_out, lcd_write_en, lcd_write_data, debug_word, debug_addr, out1, out2);
	
	// keyboard controller
	//PS2_Interface myps2(clock, resetn, ps2_clock, ps2_data, ps2_key_data, ps2_key_pressed, ps2_out);
	
	// lcd controller
	lcd mylcd(inclock, ~resetn, lcd_write_en, lcd_write_data[7:0], lcd_data, lcd_rw, lcd_en, lcd_rs, lcd_on, lcd_blon);
	
	// example for sending ps2 data to the first two seven segment displays
	Hexadecimal_To_Seven_Segment hex1(ps2_out[3:0], seg1);
	Hexadecimal_To_Seven_Segment hex2(ps2_out[7:4], seg2);
	
	// the other seven segment displays are currently set to 0
	Hexadecimal_To_Seven_Segment hex3(4'b0, seg3);
	Hexadecimal_To_Seven_Segment hex4(4'b0, seg4);
	Hexadecimal_To_Seven_Segment hex5(4'b0, seg5);
	Hexadecimal_To_Seven_Segment hex6(4'b0, seg6);
	Hexadecimal_To_Seven_Segment hex7(4'b0, seg7);
	Hexadecimal_To_Seven_Segment hex8(4'b0, seg8);
	
	// some LEDs that you could use for debugging if you wanted
	assign leds = 8'b00101011;
	
endmodule
























































module processor(clock, reset, ps2_key_pressed, ps2_out, lcd_write, lcd_data, debug_data, debug_addr, out1, out2 
/* Fetch outputs */
//////,						inPC_F_output 						// Output to the PC latch for the next instruction [31:0]
//,						stall_ctrl_output					// Describes whether to stall on a data hazard
//////,						outPC_F_output 					// Output from the PC into the instruction memory [31:0]
//////,						inAddress_imem_F_output 		// Input to the address for imem [11:0]
//////,						outInsn_imem_F_output			//	Output instruction from the imem [31:0]
//,						pcPlusOne_F_output				// PC+1 for the fetch stage [31:0]
/* FD pipeRegister outputs */
//,						branchRecovery_ctrl_output		// Branch Recovery bit
//,						insn_select_F_output				// Output from NOP mux for branch recovery for Fetch part
//,						pcPlusOne_D_output				// Output of PC+1 from FD pipeRegister
//////,						insn_D_output						// Output of insn from FD pipeRegister
/* Stalling Logic outputs */
//,						RSEqRD_Stall_DX_output			// Is RS (from D stage) = RD (from X stage)?
//,						RTEqRD_Stall_DX_output			// Is RT (from D stage) = RD (from X stage)?
//,						RDEqRD_Stall_DX_output			// Is RD (from D stage) = RD (from X stage)?
//,						opcodeForRS_Stall_D_output		// Is opcode = 00000 | 00101 | 00010 | 00110 | 01000 for Decode Stage?
//,						opcodeForRD_Stall_D_output		// Is opcode = 00010 | 00100 | 00110 for Decode Stage?
//,						opcodeForRT_Stall_D_output		// Is opcode = 00000 for Decode stage?
//,						opcodeForLoad_Stall_X_output  // Is opcode = 01000 for Execute stage?
//////,						stall_ctrl_D_output				// Output for stall ctrl bit
/* Decode stage outputs */
//,						regDst_ctrl_D_output				// RegDst control for D
//,						writeReg_select_output			// Register that is written to regFile... Rd or R31
//,						readReg2_select_output			// Register that correspond to B input/output of regFile
//,						regFileOutputA_D_output			// Register read value A for regFile
//,						regFileOutputB_D_output			// Register read value B for regFile
/* DX pipeRegister outputs */
//,						insn_select_D_output				// Output from NOP mux for branch recovery for Decode part
//////, 						stall_select_D_output			// output from stall mux for Stall logic for Decode stage
//,						pcPlusOne_X_output				// Output from pipeRegister into X stage for PC+1
//////,						insn_X_output						// Output from pipeRegister into X stage for insn X
//,						dataApre_X_output					// Data for read register A into X stage before selection
//,						dataBpre_X_output					// Data for read register B into X stage before selection
/* AMWX Bypassing outputs */
//,						RSEqRD_AMX_XM_output				// Is RS (from X stage) = RD (from M stage)?
//,						opcodeCheck_AMX_M_output		// Is opcode = 00000 | 00101 for Memory stage?
//////,						AMX_ctrl_output					// AMX control bit for MX bypassing mux
//,						RSEqRD_AWX_XW_output				// Is RS (from X stage) = RD (from W stage)?
//,						opcodeCheck_AWX_W_output		// Is opcode = 00000 | 00101 for Writeback stage?
//////,						AWX_ctrl_output					// AWX control bit for MX bypassing mux
/* BMWX Bypassing outputs */
//////,						BMX_ctrl_output					// BMX control bit for MX bypassing mux
//////,						BWX_ctrl_output					// BWX control bit for MX bypassing mux
/* Actual AMWX Bypassing outputs */
//,						dataA_X_output						// Output after bypassing from DX pipeRegister to X stage for A
//,						dataB_X_output						// Output after bypassing from DX pipeRegister to X stage for B
/* Execute stage outputs */
//////,						N_val_J1_X_output
//,						imm_SE_X_output
//,						pcPlusOnePlusN_X_output
//,						aluSrc_select_X_output
//,						aluOpcode_final_X_output
//,						alu_result_X_output
//,						b_lt_a_X_output
//////,						jump_select_X_output
/* XM pipeRegister outputs */
//,						insn_M_output
//,						dataO_M_output
//,						dataMpre_M_output
/* WM Bypassing outputs */
//////,						WM_ctrl_output
/* Actual WM Bypassing outputs */
//,						dataM_M_output
/* Memory stage outputs */
//////,						readFromMemory_output
/* MW pipeRegister outputs */
//,						insn_W_output
//,						dataO_W_output
//,						dataD_W_output
/* Write stage outputs */
//////,						regFile_data_W_output
//////,						regFile_register_W_output
);

	input 			clock, reset, ps2_key_pressed;
	input 	[7:0]	ps2_out;
	
	output 			lcd_write;
	output 	[31:0] 	lcd_data;
	
	// GRADER OUTPUTS - YOU MUST CONNECT TO YOUR DMEM
	output 	[31:0] 	debug_data;
	output	[11:0]	debug_addr;
	
	output [31:0] out1, out2;
	
	
	//
	//
	//			THESE ARE DEBUGGING OUTPUTS!!!!!
	//
	//
	/* Fetch outputs */
//////	output [31:0] inPC_F_output;							assign inPC_F_output = jump_select_X;
//	output stall_ctrl_output;								assign stall_ctrl_output = stall_ctrl;
//////	output [31:0] outPC_F_output;							assign outPC_F_output = outPC_F;
//////	output [11:0] inAddress_imem_F_output;				assign inAddress_imem_F_output = pc_F[11:0];
//////	output [31:0] outInsn_imem_F_output;				assign outInsn_imem_F_output = insn_F;
//	output [31:0] pcPlusOne_F_output;					assign pcPlusOne_F_output = pcPlusOne_F;
	/* FD pipeRegister outputs */
//	output branchRecovery_ctrl_output;					assign branchRecovery_ctrl_output = branchRecovery_ctrl;
//	output [31:0] insn_select_F_output;					assign insn_select_F_output = insn_select_F;
//	output [31:0] pcPlusOne_D_output;					assign pcPlusOne_D_output = pcPlusOne_D;
//////	output [31:0] insn_D_output;							assign insn_D_output = insn_D;
	/* Stalling Logic outputs */
//	output RSEqRD_Stall_DX_output;						assign RSEqRD_Stall_DX_output = RSEqRD_Stall;
//	output RTEqRD_Stall_DX_output;						assign RTEqRD_Stall_DX_output = RTEqRD_Stall;
//	output RDEqRD_Stall_DX_output;						assign RDEqRD_Stall_DX_output = RDEqRD_Stall;
//	output opcodeForRS_Stall_D_output;					assign opcodeForRS_Stall_D_output = opcodeCheck_Stall_FD0;
//	output opcodeForRD_Stall_D_output;					assign opcodeForRD_Stall_D_output = opcodeCheck_Stall_FD2;
//	output opcodeForRT_Stall_D_output;					assign opcodeForRT_Stall_D_output = opcodeCheck_Stall_FD;
//	output opcodeForLoad_Stall_X_output;				assign opcodeForLoad_Stall_X_output = opcodeCheck_Stall_DX;
//////	output stall_ctrl_D_output;							assign stall_ctrl_D_output = stall_ctrl;
	/* Decode stage outputs */
//	output regDst_ctrl_D_output;							assign regDst_ctrl_D_output = regDst_ctrl_D;
//	output [4:0] writeReg_select_output;				assign writeReg_select_output = writeReg_select;
//	output [4:0] readReg2_select_output;				assign readReg2_select_output = readReg2_select;
//	output [31:0] regFileOutputA_D_output;				assign regFileOutputA_D_output = regFileOutputA_D;
//	output [31:0] regFileOutputB_D_output;				assign regFileOutputB_D_output = regFileOutputB_D;
	/* DX pipeRegister outputs */
//	output [31:0] insn_select_D_output;					assign insn_select_D_output = insn_select_D;
//////	output [31:0] stall_select_D_output;				assign stall_select_D_output = stall_select_D;
//	output [31:0] pcPlusOne_X_output;					assign pcPlusOne_X_output = pcPlusOne_X;
//////	output [31:0] insn_X_output;							assign insn_X_output = insn_X;
//	output [31:0] dataApre_X_output;						assign dataApre_X_output = dataApre_X;
//	output [31:0] dataBpre_X_output;						assign dataBpre_X_output = dataBpre_X;
	/* AMWX Bypassing outputs */
//	output RSEqRD_AMX_XM_output;							assign RSEqRD_AMX_XM_output = RSEqRD_AMX;
//	output opcodeCheck_AMX_M_output;						assign opcodeCheck_AMX_M_output = opcodeCheck_AMX;
//////	output AMX_ctrl_output;									assign AMX_ctrl_output = AMX_ctrl;
//	output RSEqRD_AWX_XW_output;							assign RSEqRD_AWX_XW_output = RSEqRD_AWX;
//	output opcodeCheck_AWX_W_output;						assign opcodeCheck_AWX_W_output = opcodeCheck_AWX;
//////	output AWX_ctrl_output;									assign AWX_ctrl_output = AWX_ctrl;
	/* BMWX Bypassing outputs */
//////	output BMX_ctrl_output;									assign BMX_ctrl_output = BMX_ctrl;
//////	output BWX_ctrl_output;									assign BWX_ctrl_output = BWX_ctrl;
	/* Actual AMWX Bypassing outputs */
//	output [31:0] dataA_X_output;							assign dataA_X_output = dataA_X;
//	output [31:0] dataB_X_output;							assign dataB_X_output = dataB_X;
	/* Execute stage outputs */
//////	output [31:0] N_val_J1_X_output;						assign N_val_J1_X_output = N_val_X;
//	output [31:0] imm_SE_X_output;						assign imm_SE_X_output = imm_SE_X;
//	output [31:0] pcPlusOnePlusN_X_output;				assign pcPlusOnePlusN_X_output = pcPlusOnePlusN_X;
//	output [31:0] aluSrc_select_X_output;				assign aluSrc_select_X_output = aluSrc_select_X;
//	output [31:0] aluOpcode_final_X_output;			assign aluOpcode_final_X_output = aluOpcodeBranch_select_X;
//	output [31:0] alu_result_X_output;					assign alu_result_X_output = alu_result_X;
//	output b_lt_a_X_output; 								assign b_lt_a_X_output = b_lt_a_X;
//////	output [31:0] jump_select_X_output;					assign jump_select_X_output = jump_select_X;
	/* XM pipeRegister outputs */
//	output [31:0] insn_M_output; 							assign insn_M_output = insn_M;
//	output [31:0] dataO_M_output;							assign dataO_M_output = dataO_M;
//	output [31:0] dataMpre_M_output;						assign dataMpre_M_output = dataMpre_M;
	/* WM Bypassing outputs */
//////	output WM_ctrl_output;									assign WM_ctrl_output = WM_ctrl;
	/* Actual WM Bypassing outputs */
//	output [31:0] dataM_M_output;							assign dataM_M_output = dataM_M;
	/* Memory stage outputs */
//////	output [31:0] readFromMemory_output; 				assign readFromMemory_output = readData_M;
	/* MW pipeRegister outputs */
//	output [31:0] insn_W_output;							assign insn_W_output = insn_W;
//	output [31:0] dataO_W_output;							assign dataO_W_output = dataO_W;
//	output [31:0] dataD_W_output;							assign dataD_W_output = dataD_W;
	/* Write stage outputs */
//////	output [31:0] regFile_data_W_output;				assign regFile_data_W_output = jump_select_W;
//////	output [4:0] regFile_register_W_output;			assign regFile_register_W_output = writeReg_select;
	
	
	
	
	
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

wire [31:0] pc_stall_select_X; 
mux_2to1 pc_stall_F(	.in0(jump_select_X), 
							.in1(pc_F), 
							.select(stall_ctrl), 
							.out(pc_stall_select_X)
);

register register_PC_F(		.dataInput(/*jump_select_X*/ pc_stall_select_X), 
									.clk(~clock), 
									.clr(reset), 
									.inEnable(~stall_ctrl), 
									.regOutput(outPC_F)
);

wire [31:0] pc_F; 						assign pc_F = outPC_F;
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

wire [31:0] fdRegister_stall_select_X; 
mux_2to1 fdRegister_stall_F(	.in0(insn_select_F), 
										.in1(insn_D), 
										.select(stall_ctrl), 
										.out(fdRegister_stall_select_X)
);


pipeRegister pipeRegister_FD(		.enable(~stall_ctrl),
											.clock(~clock), 
											.clear(reset), 
											.pcPlusOne_in(pcPlusOne_F), 
											.insn_in(/*insn_select_F*/ fdRegister_stall_select_X), 
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

regFile regFile_D(		.clock(clock), 
								.ctrl_writeEnable(regWrite_ctrl_W), 
								.ctrl_reset(reset), 
								.ctrl_writeReg(writeReg_select), 
								.ctrl_readRegA(rs_D), 
								.ctrl_readRegB(readReg2_select), 
								.data_writeReg(jump_select_W), 
								.data_readRegA(regFileOutputA_D), 
								.data_readRegB(regFileOutputB_D)
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

pipeRegister pipeRegister_DX(		.enable(1'b1),
											.clock(~clock), 
											.clear(reset), 
											.pcPlusOne_in(pcPlusOne_D), 
											.insn_in(stall_select_D), 
											.in1(regFileOutputA_D), 
											.in2(regFileOutputB_D), 
											.pcPlusOne_out(pcPlusOne_X), 
											.insn_out(insn_X), 
											.out1(dataApre_X),
											.out2(dataBpre_X) 
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

											
/* Getting the PC+1+N value */
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

wire jump_ctrl_X, jr_ctrl_X, blt_ctrl_X, bne_ctrl_X, aluSrc_ctrl_X, aluOp_ctrl_X, aluOpBranch_ctrl_X;

control_DX mycontrol_DX(		.in(opcode_X), 
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

/* ALU Module: */
wire [31:0] alu_result_X;
wire a_ne_b_X, a_lt_b_X;

abl17_alu myabl17_alu(		.data_operandA(dataA_X), 
									.data_operandB(aluSrc_select_X), 
									.ctrl_ALUopcode(aluOpcodeBranch_select_X), 
									.ctrl_shiftamt(shamt_X), 
									.data_result(alu_result_X), 
									.isNotEqual(a_ne_b_X), 
									.isLessThan(a_lt_b_X)
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

/* Compute branchRecovery_ctrl */
wire branchRecovery_ctrl;			assign branchRecovery_ctrl = jump_ctrl_X | jr_ctrl_X | branch_ctrl_X;

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
											.insn_in(insn_X), 
											.in1(alu_result_X), 
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

module abl17_alu(data_operandA, data_operandB, ctrl_ALUopcode, ctrl_shiftamt, data_result, isNotEqual, isLessThan);
   input [31:0] data_operandA, data_operandB;
   input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
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

module regFile(clock, ctrl_writeEnable, ctrl_reset, ctrl_writeReg, ctrl_readRegA, ctrl_readRegB, data_writeReg, data_readRegA, data_readRegB);
   input clock, ctrl_writeEnable, ctrl_reset;
   input [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
   input [31:0] data_writeReg;
   output [31:0] data_readRegA, data_readRegB;
	
	wire [31:0] rdVal_decoderOutput, rs1Val_decoderOutput, rs2Val_decoderOutput;
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
		end
		
	endgenerate
			
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

module control_DX(in, jump, jr, blt, bne, aluSrc, aluOp, aluOpBranch);

input [4:0] in;
output jump, jr, blt, bne, aluSrc, aluOp, aluOpBranch;

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
