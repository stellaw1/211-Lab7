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
    assign sximm5 = {{11{from_instruction_reg[4]}}, from_instruction_reg[4:0]};
    assign sximm8 = {{8{from_instruction_reg[7]}}, from_instruction_reg[7:0]};
    assign shift = from_instruction_reg[4:3];
    
    Mux3 #(3) selectNum(from_instruction_reg[10:8], from_instruction_reg[7:5], from_instruction_reg[2:0], nsel, readnum); //check order of inputs
    assign writenum = readnum;
endmodule
