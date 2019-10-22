module datapath(mdata, sximm8, vsel, writenum, write, readnum, clk, loada, loadb, loadc, loads, shift, asel, bsel, ALUop, N, Z, V, datapath_out);
    input [15:0] mdata; //16-bit output of a memory block (Lab7)
    input [15:0] sximm8; //sign extended 8-bit immediate driven from instruction decoder. sximm8 is a 16-bit sign extended version of the 8-bit value in the lower 8-bits of the instruction register
    input write, clk, loada, loadb, loadc, loads, asel, bsel;
    input [3:0] vsel;
    input [2:0] writenum, readnum;
    input [1:0] shift, ALUop;
    output N, Z, V;
    output [15:0] datapath_out;

    //declare signals
    wire[15:0] sximm5, data_in, data_out, fromAtoMux6, fromBtoShifter, sout, Ain, Bin, out;
    wire[7:0] PC;
    wire zero, overflow, negative;

    //assign zero to mdata and PC
    assign mdata = 16'b0;
    assign PC = 8'b0;

    //instantiate block 9: first 4 bit MUX
    Mux4 #(16) mux1(mdata, sximm8, {8'b0, PC}, datapath_out, vsel, data_in);

    //instantiate block 1: register file
    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);

    //instantiat blocks 3 and 4: pipeline register A and B
    vDFFE #(16) pipeA(clk, loada, data_out, fromAtoMux6); //DEBUG
    vDFFE #(16) pipeB(clk, loadb, data_out, fromBtoShifter); //DEBUG

    //instantiate block 8: shifter unit
    shifter shifter8(fromBtoShifter, shift, sout);

    //instantiate block 6 and 7: Mux6 and Mux7
    assign Ain = asel ? 16'b0 : fromAtoMux6;
    assign Bin = bsel ? sximm5 : sout;

    // Mux2 #(16) mux6(16'b0, fromAtoMux6, asel, Ain);
    // Mux2 #(16) mux7({11'b0, datapath_in[4:0]}, sout, bsel, Bin);

    //instantiate block 2: ALU unit
    ALU alu2(Ain, Bin, ALUop, out, zero);

     //Z = zero flag, N = negative flag, V = overflow flag
    assign negative = out[15] ? 1'b1 : 1'b0;
    assign overflow = ( Ain[15] & Bin[15] & ~out[15] ) || ( ~Ain[15] & ~Bin[15] & out[15]) ? 1'b1 : 1'b0;

    //instantiate block 5: pipeline register C
    vDFFE #(16) pipeC(clk, loadc, data_out, out);

    //instantiate block 10: 3-bit status register
    vDFFE #(3) status10(clk, loads, {zero, overflow, negative}, {Z, V, N});
endmodule