//cpu testbench
module cpu_tb();
    
	reg clk, reset, s, load;
    
	reg [15:0] in;
   
	wire [15:0] sim_out;
   
	wire sim_N, sim_V, sim_Z, sim_w;
	reg err;

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

		//test MOV instruction
		in = 16'b110_10_000_01100100; //REG[000] = 100
		load = 1'b1;
		reset = 1'b0;
		s = 1'b0;
		#10;
		load = 1'b0;
		#5;

		if (sim_out != 16'd100) begin
			$display("datapath error expected: %d, actual: %d", 16'd100,sim_out);
			err = 1'b1;
		end

		//test MOV instruction with shift /2
		in = 16'b110_00_000_001_10_000; //REG[001] = REG[000] / 2 = 50;
		load = 1'b1;
		reset = 1'b0;
		s = 1'b0;
		#10;
		load = 1'b0;
		#5;

		if (sim_out != 16'd50) begin
			$display("datapath error expected: %d, actual: %d", 16'd50,sim_out);
			err = 1'b1;
		end

		//test ADD instruction with REG[0] and REG[1] and store in REG[2]
		in = 16'b100_00_000_010_00_001; //REG[2] = REG[0]+REG[1]  = 150;
		load = 1'b1;
		reset = 1'b0;
		s = 1'b0;
		#10;
		load = 1'b0;
		#5;

		if (sim_out != 16'd150) begin
			$display("datapath error expected: %d, actual: %d", 16'd150,sim_out);
			err = 1'b1;
		end
	end
endmodule