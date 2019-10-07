module datapath(datapath_in, vsel, writenum, write, readnum, clk, loada, loadb, loadc, loads, shift, asel, bsel, ALUop, Z_out, datapath_out);
    input [15:0] datapath_in;
    input vsel, write, clk, loada, loadb, loadc, loads, asel, bsel;
    input [2:0] writenum, readnu;
    input [1:0] shift, ALUop;
    output Z_out;
    output [15:0] datapath_out;



endmodule