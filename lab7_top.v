`define MWRITE 2'b10
`define MREAD 2'b01

module lab7_top(KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire[15:0] write_data, read_data, mem_dout;
    wire [8:0] mem_addr;
    wire [1:0] mem_cmd;
    wire write_flag;

    //cpu module instantiation
    cpu CPU(.clk(KEY[0]),
            .reset(KEY[1]),
            .in(read_data),
            .datapath_out(write_data),
            .data_address(mem_addr), 
            .V(HEX5[3]), 
            .N(HEX5[6]), 
            .Z(HEX5[0]), 
            .mem_cmd(mem_cmd) );

    //Read write memory block instantiation
    RAM #(16, 9, "data.txt") MEM(.clk(KEY[0]),
            .read_address(mem_addr),
            .write_address(mem_addr),
            .write(write_flag),
            .din(write_data),
            .dout(mem_dout) );

    //memory block tri state driver
    wire [15:0] mdata;
    wire dout_en, read_eq, write_eq, msel;

    assign write_flag = write_eq & msel;

    EqComp #(2) read_compare(`MREAD, mem_cmd, read_eq);
    EqComp #(2) write_compare(`MWRITE, mem_cmd, write_eq);

    EqComp #(1) addr_compare(1'b0, mem_addr[8], msel);

    assign dout_en = msel & read_eq;
    assign read_data = dout_en ? mem_dout : 1'bz;

    //Stage 3 CL block from Switch inputs instantiation
    switchInputCL SWinput(SW, mem_addr, mem_cmd, read_data);

    //Stage 3 CL block for LED outputs instantiation
    LEDoutputCL LEDoutput(clk, write_data, mem_addr, mem_cmd, LEDR);

    
endmodule

//Stage 3 CL block from Switch inputs
module switchInputCL(SW, mem_addr, mem_cmd, read_data);
    input [7:0] SW;
    input [8:0] mem_addr;
    input [1:0] mem_cmd;
    output [7:0] read_data;

    wire en, read_eq, addr_eq;

    EqComp #(2) read_cmd_compare(mem_cmd, `MREAD, read_eq);
    EqComp #(9) read_addr_compare(mem_addr, 9'b140, addr_eq);

    assign en = read_eq & addr_eq;

    assign read_data[15:8] = en ? 8'b0 : 1'bz;
    assign read_data[7:0] = en ? SW[7:0] : 1'bz;

endmodule

//Stage 3 CL block for LED outputs
module LEDoutputCL(clk, write_data, mem_addr, mem_cmd, LEDR);
    input clk;
    input [15:0] write_data;
    input [8:0] mem_addr;
    input [1:0] mem_cmd;
    output [7:0] LEDR;

    wire en, write_eq, addr_eq;

    EqComp #(2) write_cmd_compare(mem_cmd, `MWRITE, write_eq);
    EqComp #(9) write_addr_compare(mem_addr, 9'h100, addr_eq);

    assign en = write_eq & addr_eq;

    vDFFE #(8) regOut(clk, en, write_data[7:0], LEDR[7:0]);

endmodule

