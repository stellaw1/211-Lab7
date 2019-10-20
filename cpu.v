module cpu(clk,reset,s,load,in,out,N,V,Z,w);
	input clk, reset, s ,load;
	input [15:0] in;
	output [15:0] out;
	output N, V, Z, w;

	wire [15:0] instr_regout;

	vDFFE #(16) instr_reg(clk, load, in, instr_regout);
	
	wire opcode_FSM, op_FSM, 

	instruction_Decoder decoder(	.from_instruction_reg (instr_regout), 
					.nsel (nsel_FSM), 
					.opcode (opcode_FSM),
					 .op (op_FSM), 
					.AlUop (ALUop_DE),
					.sximm5 (sximm5_DE),
					.sximm8(sximm8_DE),
					shift(shift_DE),
					.readnum(readnum_DE),
					.writenum(writenum_DE) );

	wire loada_FSM, loadb_FSM, loadc_FSM, write_FSM, loads_FSM, asel_FSM, bsel_FSM;
	wire [3:0] vsel_FSM;

	FSM FSM(	.s(s),
			.reset(reset),
			.clk(clk),
			.opcode(opcode_FSM),
			.op(op_FSM),
			.nsel(nsel_FSM),
			.loada(loada_FSM),
			.loadb(loadb_FSM),
			.loadc(loadc_FSM),
			.loads(loads_FSM);
			.vsel(vsel_FSM),
			.write(write_FSM),
			.asel(asel_FSM),
			.bsel(bsel_FSM),
			.w(w) );

	datapath DP(	.mdata (16'b0),
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
			.Z_out (Z),
			.V (V),
			.N (N),
			.datapath_out(out) );

	
endmodule

//instruction decoder module definition
module instruction_Decoder(from_instruction_reg, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    input [15:0] from_instruction_reg; //rename from_instruction_reg input. 
    input [2:0] nsel; //decide width of nsel from controller FSM
    output [2:0] opcode, readnum, writenum;
    output [1:0] op, ALUop, shift;
    output [15:0] sximm5, sximm8;
    output  shift, readnum, writenum;

    //to controller FSM
    assign opcode = from_instruction_reg[15:13];
    assign op = from_instruction_reg[12:11];

    //to datapath
    assign ALUop = from_instruction_reg[12:11];
    assign sximm5 = {11{from_instruction_reg[4]}, from_instruction_reg[3:0]};
    assign sximm8 = {8{from_instruction_reg[7]}, from_instruction_reg[6:0]};
    assign shift = from_instruction_reg[4:3];
    
    Mux3 #(3) selectNum(from_instruction_reg[10:8], from_instruction_reg[7:5], from_instruction_reg[2:0], nsel, readnum); //check order of inputs
    assign writenum = readnum;
endmodule

//3 input k bit MUX, one hot select
module Mux3(a2, a1, a0, s, b);
  parameter k = 1;
  input [k-1:0] a2, a1, a0; //inputs
  input [2:0] s; //select
  output [k-1:0] b;
  wire [k-1:0] b = ({k{s[0]}} & a0) |
		     ({k{s[1]}} & a1) |
		     ({k{s[2]}} & a2);
endmodule

module FSM(s, reset, clk, opcode, op, vsel, write, loada, loadb, loadc, loads, asel, bsel, nsel, w);
    input s, reset, clk;
    input [2:0] opcode;
    input [1:0] op;
    output vsel, write, loada, loadb, loadc, loads, asel, bsel;
    output [2:0] nsel;
    output w; 

    reg vsel, write, loada, loadb, loadc, loads, asel, bsel;
    reg [2:0] nsel;
    reg [2:0] present_state, next_state;
    reg [15:0] out;

    always @(posedge clk) begin
        vsel = 1'b0;
        write = 1'b0;
        loada = 1'b0;
        loadb = 1'b0;
        loadc = 1'b0;
        loads = 1'b0;
        asel = 1'b0;
        bsel = 1'b0;
        if (reset) begin 
            next_state = `sWait;
        end else begin
            case (present_state)
                `sWait: if (s) next_state = `sGetA;
                        else next_state = `sWait;
                `sGetA: next_state = `sGetB;
                `sGetB: next_state = `sAdd;
                `sAdd: next_state = `sWriteReg;
                `sWriteReg: next_state = `sWait;
                default: next_state = 3'bxxx;
            endcase
            present_state = next_state;
            out = 16'b0;
            case (present_state)
                `sGetA: 
            endcase
        end
    end



endmodule