//3 input k bit MUX, one hot select
module Mux3(a2, a1, a0, s, b);
  parameter k = 1;
  input [k-1:0] a2, a1, a0; //inputs
  input [2:0] s; //select
  output [k-1:0] b;
  wire [k-1:0] b = ({k{s[0]}} & a0) |
		     ({k{s[1]}} & a1) |
		     ({k{s[2]}} & a2);
endmodule


//k bit ,4 input, binary select MUX
module Mux_k_4_binary(a3, a2, a1, a0, sb, b);
  parameter k = 1 ;
  input [k-1:0] a3, a2, a1, a0; //inputs
  input [1:0] sb; //select
  output [k-1:0] b;
  wire [3:0] s;

  Dec #(2,4) de(sb, s); //decoder takes binary input and gives one hot output
  Mux4 #(k) m(a3, a2, a1, a0, s, b); 
endmodule
  

//4 input k bit MUX, one hot select
module Mux4(a3, a2, a1, a0, s, b);
  parameter k = 1;
  input [k-1:0] a3, a2, a1, a0; //inputs
  input [3:0] s; //select
  output [k-1:0] b;
  wire [k-1:0] b =   ({k{s[0]}} & a0) |
		     ({k{s[1]}} & a1) |
		     ({k{s[2]}} & a2) |
		     ({k{s[3]}} & a3) ;
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

// equality comparator
module EqComp(a, b, eq) ;
  parameter k=8;
  input  [k-1:0] a,b;
  output eq;
  wire   eq;

  assign eq = (a==b) ;
endmodule
