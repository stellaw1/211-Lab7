`define MWRITE 2'b10
`define MREAD 2'b01

module lab7_top(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire[15:0] datapath_out, read_data;
    wire [8:0] mem_addr;
    wire [1:0] mem_cmd;
    wire write_flag;

    //cpu module instantiation
    cpu CPU(.clk(KEY[0]),
            .reset(KEY[1]),
            .in(read_data),
            .datapath_out(datapath_out),
            .data_address(mem_addr), 
            .V(HEX5[3]), 
            .N(HEX5[6]), 
            .Z(HEX5[0]), 
            .mem_cmd(mem_cmd) );

    //Read write memory block instantiation
    RAM #(16, 9) MEM(.clk(KEY[0]),
            .read_address(mem_addr),
            .write_address(mem_addr),
            .write(write_flag),
            .din(datapath_out),
            .dout(read_data) );

    //tri state driver
    wire [15:0] mdata;
    wire dout_en, read_eq, write_eq, msel;

    assign write_flag = write_eq & msel;

    EqComp #(2) read_compare(`MREAD, mem_cmd, read_eq);
    EqComp #(2) write_compare(`MWRITE, mem_cmd, write_eq);

    EqComp #(1) addr_compare(1'b0, mem_addr[8], msel);

    assign dout_en = msel & read_eq;
    assign mdata = dout_en ? read_data : 1'bz;
    
endmodule

