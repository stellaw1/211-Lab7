module cpu(clk,reset,in, datapath_out,data_address, V, N, Z, mem_cmd);
	input clk, reset;
	input [15:0] in;
	output [15:0] datapath_out;
    output [1:0] mem_cmd; 
    output [8:0] data_address;
	output V, N, Z;

	//instantiate PC module
    wire load_pc, reset_pc, load_ir, addr_sel;
    wire [8:0] PC, cpu_out, count;
    
    PC myPC(  .reset_pc(reset_pc), 
            .load_pc(load_pc), 
            .out(PC),
	    .clk(clk) );


    //data address Register
    vDFFE #(9) data_addr(clk, load_addr, datapath_out[8:0], data_address);


    //Mux2 to Memory block
    assign mem_addr = addr_sel? PC : data_address;


	//16 bit instruction register, holds instruction from input and decodes to FSM and datapath
    wire [15:0] instr_regout;

    vDFFE #(16) instr_reg(clk, load_ir, in, instr_regout);


    //instruction decoder instantiation with inputs from instruction reg and from FSM
	wire [2:0] opcode_DE, readnum_DE, writenum_DE, nsel_FSM;
    wire [1:0] ALUop_DE;
	wire [1:0] op_DE, shift_DE;
	wire [15:0] sximm5_DE, sximm8_DE;

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


    //FSM instantiation with inputs from instruction decoder and status, reset
	//output to instruction decoder and to datapath
	wire loada_FSM, loadb_FSM, loadc_FSM, loads_FSM, write_FSM, asel_FSM, bsel_FSM;
	wire [3:0] vsel_FSM;
 	
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
            .addr_sel(addr_sel), 
            .load_addr(load_addr), 
            .reset_pc(reset_pc), 
            .mem_cmd(mem_cmd) );


	//datapath instantiation
	datapath DP(	.mdata (in),
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
			.datapath_out(datapath_out) );
	
endmodule
