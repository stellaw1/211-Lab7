module PC(reset_pc, load_pc, out);
    input reset_pc, load_pc;
    output [8:0] out;
    
    wire [8:0] count, next_pc;

    //PC +1 Counter
    vDFF #(9) counter(clk, out, count); //DEBUG: reset = pc_out??

    //Mux2 to PC
    assign next_pc = reset_pc ? 9'b0 : count;

    //PC
    vDFFE #(9) PC(clk, load_pc, next_pc, out);

endmodule



// Source: Slide Set 5 
// D Flip Flop register that adds one every clk cycle
//
// Parameters: 
// n = width of input and output
module vDFF(clk, in, out) ;
  parameter n = 1;  // width
  input clk ;
  input [n-1:0] in ;
  output [n-1:0] out ;
  reg [n-1:0] out ;

  always @(posedge clk)
    out = in + 1;
endmodule 