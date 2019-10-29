module cpu(clk,reset,s,load,in,out,V, N, Z,w);
	input clk, reset, s ,load;
	input [15:0] in;
	output [15:0] out;
	output V, N, Z, w;

	wire [15:0] instr_regout;
    wire load_pc, reset_pc, load_ir
    wire [8:0] next_pc, pc_out, cpu_out, count

    //instantiate PC module
    PC PC(  .reset_pc(reset_pc), 
            .load_pc(load_pc), 
            .out(pc_out) );

    //Mux2 to Memory block
    assign mem_addr = addr_sel? pc_out : 9'b0;


	//16 bit instruction register, holds instruction from input and decodes to FSM and datapath
	vDFFE #(16) instr_reg(clk, load_ir, in, instr_regout);
	
	wire [2:0] opcode_DE, readnum_DE, writenum_DE, nsel_FSM;
    wire [1:0] ALUop_DE;
	wire [1:0] op_DE, shift_DE;
	wire [15:0] sximm5_DE, sximm8_DE;

	//intruction Decoder with inputs from instruction reg and from FSM
	instruction_Decoder decoder(	.from_instruction_reg (instr_regout), 
					.nsel (nsel_FSM), 
					.opcode (opcode_DE),
					 .op (op_DE), 
					.ALUop (ALUop_DE),
					.sximm5 (sximm5_DE),
					.sximm8(sximm8_DE),
					.shift(shift_DE),
					.readnum(readnum_DE),
					.writenum(writenum_DE) );

	wire loada_FSM, loadb_FSM, loadc_FSM, loads_FSM, write_FSM, asel_FSM, bsel_FSM;
	wire [3:0] vsel_FSM;
 	
	//Finite state machine controller with inputs from instruction decoder and status, reset
	//output to instruction decoder and to datapath
	// FSM FSM(	.s(s),
	// 		.reset(reset),
	// 		.clk(clk),
	// 		.opcode(opcode_DE),
	// 		.op(op_DE),
	// 		.nsel(nsel_FSM),
	// 		.loada(loada_FSM),
	// 		.loadb(loadb_FSM),
	// 		.loadc(loadc_FSM),
	// 		.loads(loads_FSM),
	// 		.vsel(vsel_FSM),
	// 		.write(write_FSM),
	// 		.asel(asel_FSM),
	// 		.bsel(bsel_FSM),
	// 		.w(w) );
    FSM FSM(.reset(reset), 
            .clk(clk), 
            .opcode(opcode_DE), 
            .op(op_DE), 
            .vsel(vsel_FSM), 
            .write(write_FSM), 
            .loada(loada_FSM), 
            .loadb(loadb_FSM), 
            .loadc(loadc_FSM), 
            .loads(loads_FSM), 
            .asel(asel_FSM), 
            .bsel(bsel_FSM), 
            .nsel(nsel_FSM),
            .load_ir(load_ir), 
            .load_pc(load_pc), 
            .addr_sel(),
            .reset_pc(reset_pc), 
            .mem_cmd() );
 
	//altered datapath from lab5 with inputs from instruction decoder and FSM controller
	datapath DP(	.mdata (16'b0),
            .sximm8 (sximm8_DE), 
            .sximm5 (sximm5_DE),
			.vsel (vsel_FSM),
			.writenum (writenum_DE),
			.write (write_FSM),
			.readnum (readnum_DE),
			.clk (clk),
			.loada (loada_FSM),
			.loadb (loadb_FSM),
			.loadc (loadc_FSM),
			.loads (loads_FSM),
			.shift (shift_DE),
			.asel (asel_FSM),
			.bsel (bsel_FSM),
			.ALUop (ALUop_DE),
			.Z (Z),
			.V (V),
			.N (N),
			.datapath_out(out) );

	
endmodule
