
module cpu(clk,reset,s,load,in,out,N,V,Z,w);
	input clk, reset, s ,load;
	input [15:0] in;
	output [15:0] out;
	output N, V, Z, w;

	wire [15:0] instr_regout;

	//16 bit instruction register, holds instruction from input and decodes to FSM and datapath
	vDFFE #(16) instr_reg(clk, load, in, instr_regout);
	
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
	FSM FSM(	.s(s),
			.reset(reset),
			.clk(clk),
			.opcode(opcode_DE),
			.op(op_DE),
			.nsel(nsel_FSM),
			.loada(loada_FSM),
			.loadb(loadb_FSM),
			.loadc(loadc_FSM),
			.loads(loads_FSM),
			.vsel(vsel_FSM),
			.write(write_FSM),
			.asel(asel_FSM),
			.bsel(bsel_FSM),
			.w(w) );
 
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

//instruction decoder module definition
module instruction_Decoder(from_instruction_reg, nsel, opcode, op, ALUop, sximm5, sximm8, shift, readnum, writenum);
    input [15:0] from_instruction_reg; //rename from_instruction_reg input. 
    input [2:0] nsel; //decide width of nsel from controller FSM
    output [2:0] opcode, readnum, writenum;
    output [1:0] op, ALUop, shift;
    output [15:0] sximm5, sximm8;

    //to controller FSM
    assign opcode = from_instruction_reg[15:13];
    assign op = from_instruction_reg[12:11];

    //to datapath
    assign ALUop = from_instruction_reg[12:11];
    assign sximm5 = {{11{from_instruction_reg[4]}}, from_instruction_reg[3:0]};
    assign sximm8 = {{8{from_instruction_reg[7]}}, from_instruction_reg[6:0]};
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

`define WAIT 5'b11111
`define DECODE 5'b11110
`define STAT 5'b00000
`define MOVim1 5'b00001
`define MOVim2 5'b00010
`define MOVim3 5'b00011
`define MOVim4 5'b00100
`define MOV1 5'b00101
`define MOV2 5'b00110
`define MOV3 5'b00111
`define MOV4 5'b01000
`define ADD1 5'b01001
`define ADD2 5'b01010
`define ADD3 5'b01011
`define ADD4 5'b01100
`define CMP1 5'b01101
`define CMP2 5'b01110
`define CMP3 5'b01111
`define CMP4 5'b10000
`define AND1 5'b10001
`define AND2 5'b10010
`define AND3 5'b10011
`define AND4 5'b10100
`define MVN1 5'b10101
`define MVN2 5'b10110
`define MVN3 5'b10111
`define MVN4 5'b11000

module FSM(s, reset, clk, opcode, op, vsel, write, loada, loadb, loadc, loads, asel, bsel, nsel, w);
    input s, reset, clk;
    input [2:0] opcode;
    input [1:0] op;
    output write, loada, loadb, loadc, loads, asel, bsel;
    output [2:0] nsel;
    output [3:0] vsel;
    output w; 

    reg [3:0] vsel;
    reg write, loada, loadb, loadc, loads, asel, bsel, w;
    reg [2:0] nsel;
    reg [4:0] present_state;

    always @(posedge clk) begin
      
	    //set next state
        casex ({reset,s,present_state}) 
            //if reset 1 and other inputs anything, go to WAIT
            {1'b1,1'bx,5'bxxxxx}: present_state = `WAIT;
	    //if status 1 and reset 0 go to status
	    {1'b0,1'b1,`WAIT}: present_state = `STAT;
	    
            //if reset 0 and s set to 1, start next instruction
            {1'b0,1'b0,`WAIT} : if ({opcode,op} != 5'b0)
					present_state = `DECODE;
	    {1'b0,1'bx,`DECODE} : case ({opcode,op}) 
                        5'b110_10: present_state = `MOVim1;
                        5'b110_00: present_state = `MOV1;
                        5'b101_00: present_state = `ADD1;
                        5'b101_01: present_state = `CMP1;
                        5'b101_10: present_state = `AND1;
                        5'b101_11: present_state = `MVN1;
                        default: present_state = `WAIT;
                        endcase
            //states of MOVim instr
            {1'b0,1'bx,`MOVim1}: present_state = `WAIT;
            //states of MOV instr
            {1'b0,1'bx,`MOV1}: present_state = `MOV2;
            {1'b0,1'bx,`MOV2}: present_state = `MOV3;
            {1'b0,1'bx,`MOV3}: present_state = `WAIT;
            //states of ADD instr
            {1'b0,1'bx,`ADD1}: present_state = `ADD2;
            {1'b0,1'bx,`ADD2}: present_state = `ADD3;
            {1'b0,1'bx,`ADD3}: present_state = `ADD4;
            {1'b0,1'bx,`ADD4}: present_state = `WAIT;
            //states of CMP instr
            {1'b0,1'bx,`CMP1}: present_state = `CMP2;
            {1'b0,1'bx,`CMP2}: present_state = `CMP3;
            {1'b0,1'bx,`CMP3}: present_state = `WAIT;
            //states of AND instr
            {1'b0,1'bx,`AND1}: present_state = `AND2;
            {1'b0,1'bx,`AND2}: present_state = `AND3;
            {1'b0,1'bx,`AND3}: present_state = `AND4;
            {1'b0,1'bx,`AND4}: present_state = `WAIT;
            //states of MVN instr
            {1'b0,1'bx,`MVN1}: present_state = `MVN2;
            {1'b0,1'bx,`MVN2}: present_state = `MVN3;
            {1'b0,1'bx,`MVN3}: present_state = `WAIT;

	    {1'b0,1'bx,`STAT}: present_state = `WAIT;
            default: present_state = `WAIT;
	    endcase 

        //set outputs depending on which state
        case(present_state) 
            `WAIT: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_0_0_0_0_0_000_1;
	    `STAT: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_0_0_1_0_0_000_0;
	    `DECODE: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_0_0_0_0_0_000_0;
            
            //write sximm8 from decoder to Rd
            `MOVim1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0100_1_0_0_0_0_0_0_100_0;
            
            //load from register Rm into B
            `MOV1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_1_0_0_0_0_001_0;
            //perform shift on value and load into C
            `MOV2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_0_1_0_1_0_000_0;
            //write value to Rd
            `MOV3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0001_1_0_0_0_0_0_0_010_0;

            //load Rn into A
            `ADD1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_1_0_0_0_0_0_100_0;
            //load Rm into B
            `ADD2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_1_0_0_0_0_001_0;
            //ADD values at A and sh_B and load into C
            `ADD3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_0_1_0_0_0_000_0;
            //write value at C into Rd
            `ADD4: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0001_1_0_0_0_0_0_0_010_0;

            //load Rn into A
            `CMP1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_1_0_0_0_0_0_100_0;
            //load Rm into B
            `CMP2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_1_0_0_0_0_001_0;
            //SUB sh_B from A and load into status
            `CMP3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_0_0_1_0_0_000_0;

            //load Rn into A
            `AND1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_1_0_0_0_0_0_100_0;
            //load Rm into B
            `AND2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_1_0_0_0_0_001_0;
            //AND A and sh_B and load into C
            `AND3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_0_1_0_0_0_000_0;
            //write value of C into Rd
            `AND4: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0001_1_0_0_0_0_0_0_010_0;

            //load Rm into B
            `MVN1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_1_0_0_0_0_001_0;
            //load NOT sh_B into C
            `MVN2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0000_0_0_0_1_0_0_0_000_0;
            //write value of C into Rd
            `MVN3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 15'b_0001_1_0_0_0_0_0_0_010_0;

            default: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,w} = 12'bxxxxxxxxxxxx;
        endcase
    end
endmodule