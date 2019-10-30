module regfile(data_in, writenum, write, readnum, clk, data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;

    //decode writenum from binary to 8-bit one hot
    wire [7:0] writeNumOneHot;
    Dec #(3, 8) writeNum(writenum, writeNumOneHot);

    //declare 8 16-bit buses to store data in each register
    wire [15:0] R0; 
    wire [15:0] R1;
    wire [15:0] R2;
    wire [15:0] R3;
    wire [15:0] R4;
    wire [15:0] R5;
    wire [15:0] R6;
    wire [15:0] R7;

    //instantiate 8 16-bit registers, R0-R7
    //DEBUG: might need to make a module for writing files
    vDFFE #(16) Reg0(clk, writeNumOneHot[0] & write, data_in, R0); 
    vDFFE #(16) Reg1(clk, writeNumOneHot[1] & write, data_in, R1); 
    vDFFE #(16) Reg2(clk, writeNumOneHot[2] & write, data_in, R2); 
    vDFFE #(16) Reg3(clk, writeNumOneHot[3] & write, data_in, R3); 
    vDFFE #(16) Reg4(clk, writeNumOneHot[4] & write, data_in, R4); 
    vDFFE #(16) Reg5(clk, writeNumOneHot[5] & write, data_in, R5); 
    vDFFE #(16) Reg6(clk, writeNumOneHot[6] & write, data_in, R6); 
    vDFFE #(16) Reg7(clk, writeNumOneHot[7] & write, data_in, R7); 

    //instantiate read file
    enableRead readRegister(readnum, R0, R1, R2, R3, R4, R5, R6, R7, data_out);

endmodule


//to read data from selected register
module enableRead(readnum, R0, R1, R2, R3, R4, R5, R6, R7, data_out);
    input [2:0] readnum;
    input [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    output [15:0] data_out;
    reg [15:0] data_out; 

    //decode readnum from binary to 8-bit one hot
    wire [7:0] readOneHot;
    Dec #(3, 8) readNum(readnum, readOneHot);

    //everytime readnum changes, reassign data_out to be data stored in corresponding register
    always @(*) begin //DEBUG sensitivity list
        case (readOneHot)
            8'b00000001: data_out = R0;
            8'b00000010: data_out = R1;
            8'b00000100: data_out = R2;
            8'b00001000: data_out = R3;
            8'b00010000: data_out = R4;
            8'b00100000: data_out = R5;
            8'b01000000: data_out = R6;
            8'b10000000: data_out = R7;
            default: data_out = 16'bxxxxxxxxxxxxxxxx;
        endcase
    end

endmodule