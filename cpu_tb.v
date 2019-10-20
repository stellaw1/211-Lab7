//cpu testbench
module cpu_tb(clk, reset, s, load, in, out, N, V, Z, w);
    
	reg clk, reset, s, load;
    
	reg [15:0] in;
   
	wire [15:0] sim_out;
   
	wire sim_N, sim_V, sim_Z, sim_w;

	cpu DUT(	.clk (clk),
			.reset (reset),
			.s (s),
			.load (load),
			.in (in),
			.out (sim_out),
			.N (sim_N),
			.V (sim_V),
			.Z (sim_Z),
			.w (sim_w);
	
	//clock signal
	initial begin
    		clk = 1; #5;
    		forever begin
      			clk = 0; #5;
     			clk = 1; #5;
    		end
  	end


	initial begin
		//test ADD instruction
		
	end
endmodule