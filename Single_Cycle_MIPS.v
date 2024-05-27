module Single_Cycle_MIPS
(
	input wire clk,
	input wire rst
);
	
	wire [31:0] pc_in_top, pc_out_top, INSTRUCTION, wr_data_top, rd_data1_top, rd_data2_top, sign_ext_OUT_top, ALU_Src2_top;
	wire [31:0] ALU_result_top, rd_data_mem_top, pc_plus_4_top, shift_left_branch, branch_address_top, pc_src1_top, pc_src2_top;
	wire [4:0] rs_field_top, rt_field_top, rd_field_top, wr_addr_top;
	wire [15:0] branch_16bit_addr_top;
	wire [25:0] jump_26bit_addr_top;
	wire [5:0] opcode_bits_top, function_bits_top;
	wire RegDst_top, Jump_top, Branch_top, MemRead_top, MemToReg_top, MemWrite_top, ALUSrc_top, RegWrite_top, Zero_flag_top, Branch_taken;
	wire [1:0] ALUOp_top;
	wire [3:0] ALU_control_top;

/* ************************************************************************************************** */
/* ********************************** modules instantiation ***************************************** */
	// pc instantiation
	Program_Counter PC_INS (
		.clk(clk), .rst(rst),
		.pc_in(pc_in_top), .pc_out(pc_out_top)
	);

	// instruction memory instantiation
	Instruction_MEM IMEM (
		.Instruction_addr(pc_out_top), .Instruction_Data(INSTRUCTION)
	);
	
	Instruction_decoding dec (
		.Instruction_Data(INSTRUCTION), .rs_field(rs_field_top), .rt_field(rt_field_top),
		.rd_field(rd_field_top), .branch_16bit_field(branch_16bit_addr_top),
		.jump_26bit_field(jump_26bit_addr_top), .opcode_field(opcode_bits_top), .function_field(function_bits_top)
	);

	// control unit instantiation
	Control_Unit CU (
		.opcode(opcode_bits_top), .RegDst(RegDst_top), .Jump(Jump_top), .Branch(Branch_top),
		.MemRead(MemRead_top), .MemToReg(MemToReg_top), .ALUOp(ALUOp_top), 
		.MemWrite(MemWrite_top), .ALUSrc(ALUSrc_top), .RegWrite(RegWrite_top)
	);

	// wr_addr mux instantiation
	TwoToOne_mux mux1 (
		.IN1(rt_field_top), .IN2(rd_field_top),
		.sel(RegDst_top), .mux_out(wr_addr_top)
	);
	
	// register file instantiation
	Register_File R_F (
		.clk(clk), .rst(rst), .RegWrite(RegWrite_top), .rd_addr1(rs_field_top), .rd_addr2(rt_field_top),
		.wr_addr(wr_addr_top), .wr_data(wr_data_top), .rd_data1(rd_data1_top), .rd_data2(rd_data2_top)
		); 

	// sign extension instantiation
	sign_ext sign_ext (
		.sign_ext_IN(branch_16bit_addr_top), .sign_ext_OUT(sign_ext_OUT_top)
	);

	// ALU Control unit instantiation
	ALU_Control_Unit ALU_CU (
		.ALUOp(ALUOp_top), .Function_field(function_bits_top), .ALU_control(ALU_control_top)
	);

	// ALU src2 mux instantiation
	TwoToOne_mux ALUSrc_mux (
		.IN1(rd_data2_top), .IN2(sign_ext_OUT_top),
		.sel(ALUSrc_top), .mux_out(ALU_Src2_top)
	);

	// ALU Instantiation
	ALU ALU_INS (
		.Src1(rd_data1_top), .Src2(ALU_Src2_top), .ALU_control(ALU_control_top),
		.ALU_result(ALU_result_top), .Zero_flag(Zero_flag_top)
	);

	// Data memory instantiation
	Data_MEM DMEM (
		.clk(clk), .MemWrite(MemWrite_top), .MemRead(MemRead_top), .addr(ALU_result_top),
		.wr_data(rd_data2_top), .rd_data(rd_data_mem_top)
	);

	// wr_data in regfile mux instantiation
	TwoToOne_mux mux2 (
		.IN1(ALU_result_top), .IN2(rd_data_mem_top),
		.sel(MemToReg_top), .mux_out(wr_data_top)
	);

	// next instruction calculations
	// pc+4 adder
	Adder pc_adder (
		.operand1(pc_out_top), .operand2(32'd4), .result(pc_plus_4_top)
	);

	// shift left for branch instruction
	shift_circuit sh1 (
		.shift_left_in(sign_ext_OUT_top), .shift_left_out(shift_left_branch)
	);

	// branch adder
	Adder branch_adder (
		.operand1(pc_plus_4_top), .operand2(shift_left_branch), .result(branch_address_top)
	);

	// branch selector AND gate
	AND_GATE AND1 (
		.in1(Branch_top), .in2(Zero_flag_top), .out(Branch_taken)
	);

	// pcsrc mux
	TwoToOne_mux pc_src_mux (
		.IN1(pc_plus_4_top), .IN2(branch_address_top),
		.sel(Branch_taken), .mux_out(pc_src1_top)
	);

	// pc_in mux
	TwoToOne_mux pc_in_mux (
		.IN1(pc_src1_top), .IN2({pc_plus_4_top[31:28], jump_26bit_addr_top, 2'b00}),
		.sel(Jump_top), .mux_out(pc_in_top)
	);


endmodule