module datapath(datapath_in, vsel, writenum, write, readnum, clk, loada, loadb, loadc, loads, shift, asel, bsel, ALUop, Z_out, datapath_out);
    input [15:0] datapath_in;
    input vsel, write, clk, loada, loadb, loadc, loads, asel, bsel;
    input [2:0] writenum, readnum;
    input [1:0] shift, ALUop;
    output Z_out;
    output [15:0] datapath_out;

    //declare signals
    wire[15:0] data_in, fromAtoMux6, fromBtoShifter, sout, Ain, Bin, out;

    //instantiate block 9: first MUX
    Mux2 #(16) mux1(datapath_in, datapath_out, vsel, data_in);

    //instantiate block 1: register file
    regfile regfile1(data_in, writenum, write, readnum, clk, data_out);

    //instantiat blocks 3 and 4: pipeline register A and B
    vDFFE pipeA(clk, loada, data_out, fromAtoMux6); //DEBUG
    vDFFE pipeB(clk, loadb, data_out, fromBtoShifter); //DEBUG

    //instantiate block 8: shifter unit
    shifter shifter8(fromBtoShifter, shift, sout);

    //instantiate block 6 and 7: Mux6 and Mux7
    Mux2 #(16) mux6(16'b0, fromAtoMux6, asel, Ain);
    Mux2 #(16) mux7({11'b0, datapath_in[4:0]}, sout, bsel, Bin);

    //instantiate block 2: ALU unit
    ALU alu2(Ain, Bin, ALUop, out, Z);

    //instantiate block 5: pipeline register C
    vDFFE #(16) pipeC(clk, loadc, data_out, out);

    //instantiate block 10: status
    vDFFE #(1) status10(clk, loads, Z_out, Z);
endmodule