module regfile(data_in, writenum, write, readnum, clk, data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;

    //decode writenum from binary to 8-bit one hot
    wire [7:0] writeNumOneHot;
    Dec #(3, 8) writeNum(writenum, writeNumOneHot);

    //declare 8 16-bit buses to store data in each register
    wire [15:0] data_0; 
    wire [15:0] data_1;
    wire [15:0] data_2;
    wire [15:0] data_3;
    wire [15:0] data_4;
    wire [15:0] data_5;
    wire [15:0] data_6;
    wire [15:0] data_7;

    //instantiate 8 16-bit registers, R0-R7
    //DEBUG: might need to make a module for writing files
    vDFFE #(16) R0(clk, writeNumOneHot[0] & write, data_in, data_0); 
    vDFFE #(16) R1(clk, writeNumOneHot[1] & write, data_in, data_1); 
    vDFFE #(16) R2(clk, writeNumOneHot[2] & write, data_in, data_2); 
    vDFFE #(16) R3(clk, writeNumOneHot[3] & write, data_in, data_3); 
    vDFFE #(16) R4(clk, writeNumOneHot[4] & write, data_in, data_4); 
    vDFFE #(16) R5(clk, writeNumOneHot[5] & write, data_in, data_5); 
    vDFFE #(16) R6(clk, writeNumOneHot[6] & write, data_in, data_6); 
    vDFFE #(16) R7(clk, writeNumOneHot[7] & write, data_in, data_7); 

    //instantiate read file
    enableRead readRegister(readnum, data_out, data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7);

endmodule


//Source: Lab5 slides 
//Register with load enable
//
// Parameters: 
// n = width of data
module vDFFE(clk, en, in, out) ;
  parameter n = 1; 
  input clk, en ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = en ? in : out;

  always @(posedge clk)
    out = next_out;  
endmodule


//Source: slide set 6
// n:m decoder
//
// Parameters:
// a - binary input   (n bits wide)
// b - one hot output (m bits wide)
module Dec(a, b) ;
  parameter n=2 ;
  parameter m=4 ;

  input  [n-1:0] a ;
  output [m-1:0] b ;

  wire [m-1:0] b = 1 << a ;
endmodule


//to read data from selected register
module enableRead(readnum, data_out, data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7);
    input [2:0] readnum;
    input [15:0] data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7;
    output [15:0] data_out;
    reg [15:0] data_out; 

    //decode readnum from binary to 8-bit one hot
    wire [7:0] readOneHot;
    Dec #(3, 8) readNum(readnum, readOneHot);

    //everytime readnum changes, reassign data_out to be data stored in corresponding register
    always @(readnum) begin //DEBUG sensitivity list
        case (readOneHot)
            8'b00000001: data_out = data_0;
            8'b00000010: data_out = data_1;
            8'b00000100: data_out = data_2;
            8'b00001000: data_out = data_3;
            8'b00010000: data_out = data_4;
            8'b00100000: data_out = data_5;
            8'b01000000: data_out = data_6;
            8'b10000000: data_out = data_7;
            default: data_out = 16'bxxxxxxxxxxxxxxxx;
        endcase
    end

endmodule