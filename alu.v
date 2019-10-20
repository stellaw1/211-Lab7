module ALU(Ain, Bin, ALUop, out, Z);
  input [15:0] Ain, Bin;
  input [1:0] ALUop;
  output [15:0] out;
  output Z;

  wire [15:0] add_val, sub_val, and_val, not_b;
  
  //calculate possible output values
  assign add_val = Ain + Bin;
  assign sub_val = Ain - Bin;
  assign and_val = Ain & Bin;
  assign not_b = ~Bin;

  
  //MUX that selects which operation to output 
  Mux_k_4_binary #(16) alu_MUX(not_b,and_val,sub_val,add_val, ALUop, out);
  assign Z = ~(|out); //assign Z = 1 if output is all 0's
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

// //k bit selecter MUX (used in data path)
// module Mux2(a1, a0, s, b);
//   parameter k = 1;
//   input [k-1:0] a1, a0; //inputs
//   input s; //select
//   output [k-1:0] b;
//   wire [k-1:0] b =   ({k{~s}} & a0) |
// 		     ({k{s}} & a1) ;
// endmodule

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