`define MWRITE 2'b10
`define MREAD 2'b01

module lab7_top(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    //cpu module instantiation
    cpu CPU(.clk(),
            .reset(),
            .in(),
            .out(),
            .V(), 
            .N(), 
            .Z(), 
            .addr_sel(), 
            .mem_cmd() );

    //Read write memory block instantiation
    RAM MEM(.clk(),
            .read_address(),
            .write_address(),
            .write(),
            .din(),
            .dout() );

    //tri state driver
    wire [15:0] mdata;
    wire read_data, read_eq, write_eq;

    EqComp #(2) read_compare(`MREAD, mem_cmd, read_eq);
    EqComp #(2) write_compare(`MWRITE, mem_cmd, write_eq);

    EqComp #(1) addr_compare(1'b0, mem_addr[8], msel);

    assign read_data = msel & read_eq;
    assign mdata = read_data ? dout : 1'bz;
    
endmodule

