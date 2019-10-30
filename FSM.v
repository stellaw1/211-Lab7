//defining state encodings
`define RST 5'b11111
`define IF1 5'b11110
`define IF2 5'b11101
`define UPDATE 5'b11100
`define DECODE 5'b11011

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

//FSM module definition
module FSM(reset, clk, opcode, op, vsel, write, loada, loadb, loadc, loads, asel, bsel, nsel, load_ir, load_pc, addr_sel, load_addr, reset_pc, mem_cmd);

    input reset, clk;
    input [2:0] opcode;
    input [1:0] op;
    output write, loada, loadb, loadc, loads, asel, bsel;
    output load_ir, load_pc, addr_sel, reset_pc, load_addr;
    output [1:0] mem_cmd;
    output [2:0] nsel;
    output [3:0] vsel; 

    reg [3:0] vsel;
    reg write, loada, loadb, loadc, loads, asel, bsel, load_ir, load_addr, load_pc, reset_pc, addr_sel;
    reg [1:0] mem_cmd;
    reg [2:0] nsel;
    reg [4:0] present_state;

    always @(posedge clk) begin
      
	    //set next state
        casex ({reset,present_state}) 
            //if reset 1 and other inputs anything, go to RST
            {1'b1,5'bxxxxx}: present_state = `RST;
	        
            //if reset 0 start next instruction
            {1'b0,`RST} : present_state = `IF1;
            {1'b0,`IF1} : present_state = `IF2;
            {1'b0,`IF2} : present_state = `UPDATE;
            {1'b0,`UPDATE} : present_state = `DECODE;

	        {1'b0,1'bx,`DECODE} : case ({opcode,op}) 
                                    5'b110_10: present_state = `MOVim1;
                                    5'b110_00: present_state = `MOV1;
                                    5'b101_00: present_state = `ADD1;
                                    5'b101_01: present_state = `CMP1;
                                    5'b101_10: present_state = `AND1;
                                    5'b101_11: present_state = `MVN1;
                                    default: present_state = `RST;
                                endcase
            //states of MOVim instr
            {1'b0,`MOVim1}: present_state = `IF1;
            //states of MOV instr
            {1'b0,`MOV1}: present_state = `MOV2;
            {1'b0,`MOV2}: present_state = `MOV3;
            {1'b0,`MOV3}: present_state = `IF1;
            //states of ADD instr
            {1'b0,`ADD1}: present_state = `ADD2;
            {1'b0,`ADD2}: present_state = `ADD3;
            {1'b0,`ADD3}: present_state = `ADD4;
            {1'b0,`ADD4}: present_state = `IF1;
            //states of CMP instr
            {1'b0,`CMP1}: present_state = `CMP2;
            {1'b0,`CMP2}: present_state = `CMP3;
            {1'b0,`CMP3}: present_state = `IF1;
            //states of AND instr
            {1'b0,`AND1}: present_state = `AND2;
            {1'b0,`AND2}: present_state = `AND3;
            {1'b0,`AND3}: present_state = `AND4;
            {1'b0,`AND4}: present_state = `IF1;
            //states of MVN instr
            {1'b0,`MVN1}: present_state = `MVN2;
            {1'b0,`MVN2}: present_state = `MVN3;
            {1'b0,`MVN3}: present_state = `IF1;

            default: present_state = `RST;
	    endcase 

        //set outputs depending on which state
        case(present_state) 
            `RST: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_0_0_0_0_0_0_000_0_1_0_1_00;
            `IF1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_0_0_0_0_0_0_000_0_0_1_0_xx;
            `IF2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_0_0_0_0_0_0_000_1_0_1_0_xx;
            `UPDATE: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_0_0_0_0_0_0_000_0_1_0_0_00;
	        `DECODE: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_0_0_0_0_0_0_000_0_0_0_0_00;
            
            //write sximm8 from decoder to Rd
            `MOVim1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 15'b_0100_1_0_0_0_0_0_0_100_0_0_0_0_00;
            
            //load from register Rm into B
            `MOV1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_0_1_0_0_0_0_001_0_0_0_0_00;
            //perform shift on value and load into C
            `MOV2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_0_0_1_0_1_0_000_0_0_0_0_00;
            //write value to Rd
            `MOV3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0001_1_0_0_0_0_0_0_010_0_0_0_0_00;

            //load Rn into A
            `ADD1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0100_0_1_0_0_0_0_0_100_0_0_0_0_00;
            //load Rm into B
            `ADD2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_0_1_0_0_0_0_001_0_0_0_0_00;
            //ADD values at A and sh_B and load into C
            `ADD3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0000_0_0_0_1_0_0_0_000_0_0_0_0_00;
            //write value at C into Rd
            `ADD4: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0001_1_0_0_0_0_0_0_010_0_0_0_0_00;

            //load Rn into A
            `CMP1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0000_0_1_0_0_0_0_0_100_0_0_0_0_00;
            //load Rm into B
            `CMP2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0000_0_0_1_0_0_0_0_001_0_0_0_0_00;
            //SUB sh_B from A and load into status
            `CMP3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0000_0_0_0_0_1_0_0_000_0_0_0_0_00;

            //load Rn into A
            `AND1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0000_0_1_0_0_0_0_0_100_0_0_0_0_00;
            //load Rm into B
            `AND2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0000_0_0_1_0_0_0_0_001_0_0_0_0_00;
            //AND A and sh_B and load into C
            `AND3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0000_0_0_0_1_0_0_0_000_0_0_0_0_00;
            //write value of C into Rd
            `AND4: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0001_1_0_0_0_0_0_0_010_0_0_0_0_00;

            //load Rm into B
            `MVN1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0000_0_0_1_0_0_0_0_001_0_0_0_0_00;
            //load NOT sh_B into C
            `MVN2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0000_0_0_0_1_0_0_0_000_0_0_0_0_00;
            //write value of C into Rd
            `MVN3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'b_0001_1_0_0_0_0_0_0_010_0_0_0_0_00;

            default: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd}
            = 20'bxxxxxxxxxxxxxxxxxxxx;
        endcase
    end
endmodule