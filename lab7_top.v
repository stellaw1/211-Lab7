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
    cpu CPU(.clk(~KEY[0]),
            .reset(~KEY[1]),
            .in(read_data),
            .datapath_out(write_data),
            .mem_addr(mem_addr), 
            .V(HEX5[3]), 
            .N(HEX5[6]), 
            .Z(HEX5[0]), 
            .mem_cmd(mem_cmd) );

    //Read write memory block instantiation
    RAM #(16, 9, "auto.txt") MEM(.clk(~KEY[0]),
            .read_address(mem_addr),
            .write_address(mem_addr),
            .write(write_flag),
            .din(write_data),
            .dout(mem_dout) );

    //memory block tri state driver
    wire [15:0] mem_data, switch_data;
    wire read_flag, read_eq, write_eq, msel;

    assign msel = ~mem_addr[8];

    assign read_eq = (mem_cmd == `MREAD);
    assign write_eq = (mem_cmd == `MWRITE);

    assign write_flag = write_eq & msel;

    assign read_flag = msel & read_eq;
    assign mem_data = read_flag ? mem_dout : 16'bz;

    //Stage 3 CL block from Switch inputs instantiation
    wire input_eq, switch_en;
    
    assign input_eq = (mem_addr == 9'h140);
    assign switch_en = input_eq & read_eq;

    assign switch_data = switch_en ? {8'b0, SW[7:0]} : 16'bz;

    //Stage 3 CL block for LED outputs instantiation
    wire output_en, LED_en;

    assign output_en = (mem_addr == 9'h100);
    
    assign LED_en = output_en & write_eq;

    vDFFE #(8) regOut(~KEY[0], LED_en, write_data[7:0], LEDR[7:0]);
    assign LEDR[9:8] = 2'b00;

    //Mux2 for assigning read_data either from memory block or SW inputs
    assign read_data = ~switch_en ? mem_data : switch_data;

endmodule
