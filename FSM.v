//defining state encodings
`define RST 8'b0000_0000
`define IF1 8'b0000_0001
`define IF2 8'b0000_0010
`define UPDATE 8'b0000_0011
`define DECODE 8'b0000_0100
`define HALT 8'b0000_0101

`define MOVim1 8'd6
`define MOVim2 8'd7
`define MOVim3 8'd8
`define MOVim4 8'd9

`define MOV1 8'd10
`define MOV2 8'd11
`define MOV3 8'd12
`define MOV4 8'd13

`define ADD1 8'd14
`define ADD2 8'd15
`define ADD3 8'd16
`define ADD4 8'd17

`define CMP1 8'd18
`define CMP2 8'd19
`define CMP3 8'd20
`define CMP4 8'd21

`define AND1 8'd22
`define AND2 8'd23
`define AND3 8'd24
`define AND4 8'd25

`define MVN1 8'd26
`define MVN2 8'd27
`define MVN3 8'd28
`define MVN4 8'd29

`define LDR1 8'd30
`define LDR2 8'd32
`define LDR3 8'd33
`define LDR4 8'd34
`define LDR5 8'd35

`define STR1 8'd36
`define STR2 8'd37
`define STR3 8'd38
`define STR4 8'd39
`define STR5 8'd40
`define STR6 8'd41

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
    reg [7:0] present_state;

    always @(posedge clk) begin
      
	    //set next state
        casex ({reset,present_state}) 
            //if reset 1 and other inputs anything, go to RST
            {1'b1,8'bxxxxxxxx}: present_state = `RST;
	        
            //if reset 0 start next instruction
            {1'b0,`RST} : present_state = `IF1;
            {1'b0,`IF1} : present_state = `IF2;
            {1'b0,`IF2} : present_state = `UPDATE;
            {1'b0,`UPDATE} : present_state = `DECODE;

	        {1'b0,`DECODE} : case ({opcode,op}) 
                                    5'b110_10: present_state = `MOVim1;
                                    5'b110_00: present_state = `MOV1;
                                    5'b101_00: present_state = `ADD1;
                                    5'b101_01: present_state = `CMP1;
                                    5'b101_10: present_state = `AND1;
                                    5'b101_11: present_state = `MVN1;
                                    5'b011_00: present_state = `LDR1;
                                    5'b100_00: present_state = `STR1;
                                    5'b111_00: present_state = `HALT;
                                    default: present_state = `IF1;
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
	    //HALT STATE, loops back to HALT
            {1'b0,`HALT}: present_state = `HALT;
	    //states of LDR instruction
            {1'b0,`LDR1}: present_state = `LDR2;
            {1'b0,`LDR2}: present_state = `LDR3;
            {1'b0,`LDR3}: present_state = `LDR4;
            {1'b0,`LDR4}: present_state = `LDR5;
            {1'b0,`LDR5}: present_state = `IF1;
	    //states of STR instruction
            {1'b0,`STR1}: present_state = `STR2;
            {1'b0,`STR2}: present_state = `STR3;
            {1'b0,`STR3}: present_state = `STR4;
            {1'b0,`STR4}: present_state = `STR5;
            {1'b0,`STR5}: present_state = `STR6;
            {1'b0,`STR6}: present_state = `IF1;

            default: present_state = `RST;
	    endcase 

        //set outputs depending on which state
        case(present_state) 
            `RST: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr} 
            = 21'b_0000_0_0_0_0_0_0_0_000_0_1_0_1_00_0;
            `IF1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr} 
            = 21'b_0000_0_0_0_0_0_0_0_000_0_0_1_0_01_0;
            `IF2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr} 
            = 21'b_0000_0_0_0_0_0_0_0_000_1_0_1_0_01_0;
            `UPDATE: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr} 
            = 21'b_0000_0_0_0_0_0_0_0_000_0_1_0_0_00_0;
	     `DECODE: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr} 
            = 21'b_0000_0_0_0_0_0_0_0_000_0_0_0_0_00_0;
	    `HALT: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr} 
            = 21'b_0000_0_0_0_0_0_0_0_000_0_0_0_0_00_0;
            
            //write sximm8 from decoder to Rd
            `MOVim1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd} 
            = 20'b_0100_1_0_0_0_0_0_0_100_0_0_0_0_00;
            
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


            //LDR instruction states
	    //load value at register Rn to A
            `LDR1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_1_0_0_0_0_0_100_0_0_0_0_00_0;
            //add A with sximm5, load into C
            `LDR2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_0_0_1_0_0_1_000_0_0_0_0_00_0;
            //load datapath out into data address
            `LDR3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_0_0_0_0_0_0_000_0_0_0_0_00_1;
            //read value at data address
            `LDR4: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_0_0_0_0_0_0_000_0_0_0_0_01_0;
            //save this to register Rd
            `LDR5: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_1000_1_0_0_0_0_0_0_010_0_0_0_0_01_0;

            //STR instruction states
	    //load value at register Rn to A
            `STR1: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_1_0_0_0_0_0_100_0_0_0_0_00_0;
            //add A with sximm5, load into C
            `STR2: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_0_0_1_0_0_1_000_0_0_0_0_00_0;
            //load datapath out into data address
            `STR3: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_0_0_0_0_0_0_000_0_0_0_0_00_1;
            //load value at Rd to B
            `STR4: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_0_1_0_0_0_0_010_0_0_0_0_00_0;
            //load this value to C
            `STR5: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_0_0_1_0_1_0_000_0_0_0_0_00_0;
            //write datapath out to memory location of datapath out
            `STR6: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'b_0000_0_0_0_0_0_0_0_000_0_0_0_0_10_0;

            default: {vsel,write,loada,loadb,loadc,loads,asel,bsel,nsel,load_ir,load_pc,addr_sel,reset_pc,mem_cmd,load_addr}
            = 21'bxxxxxxxxxxxxxxxxxxxx;
        endcase
    end
endmodule