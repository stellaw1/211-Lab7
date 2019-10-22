//cpu testbench
module cpu_tb();
	reg clk, reset, s, load;
	reg [15:0] in;
	wire [15:0] sim_out;
	wire sim_N, sim_V, sim_Z, sim_w;
	reg err;

	//instantiate cpu DUT
	cpu DUT(	.clk (clk),
			.reset (reset),
			.s (s),
			.load (load),
			.in (in),
			.out (sim_out),
			.N (sim_N),
			.V (sim_V),
			.Z (sim_Z),
			.w (sim_w) );
	
	//automatic error checker 
	task error_check;
        input [15:0] expected_sim_out;
        begin
            //if the data_out in the instantiated DUT is erraneous, display the actual and expected state, and set err = 1
            if (sim_out !== expected_sim_out) begin
				$display("out error expected: %d, actual: %d", expected_sim_out, DUT.out);
				err = 1'b1;
			end
        end
    endtask

	//clock signal forever loop
	initial begin
    		clk = 0; #5;
    		forever begin
      			clk = 1; #5;
     			clk = 0; #5;
    		end
  	end

	//testcases go here
	initial begin
		//initialize signals
		err = 1'b0;
		s = 1'b0;
		reset = 1'b0;

		//testcase 1: MOV immediate instruction
		in = 16'b110_10_000_01100100; //REG[000] = 100
		load = 1'b1;
		s = 1'b1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd100);

		// //testcase 2: MOV instruction with shift 
		// in = 16'b110_00_000_001_10_000; //REG[001] = REG[000] / 2 = 50;
		// load = 1'b1;
		// s = 1'b1;
		// #30;
		// load = 1'b0;
		// #10;

		// error_check(16'd50);

		// //testcase 3: ADD instruction with REG[0] and REG[1] and store in REG[2]
		// in = 16'b100_00_000_010_00_001; //REG[2] = REG[0]+REG[1]  = 150;
		// load = 1'b1;
		// s = 1'b1;
		// #40;
		// load = 1'b0;
		// #10;

		// error_check(16'd150);

		// //testcase 4: test reset
		// reset = 1'b1;

		// error_check(16'd150);

		//print results, whether errors were found
        if (~err) 
            $display ("All test cases passed with no errors. ");
        else
            $display ("Error found. ");

        $stop;
	end
endmodule