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
	
	//automatic error checker checks expected versus actual value, and assigns it an error id number
	task error_check;
        input [15:0] expected, actual, err_num;
        begin
            //if the data_out in the instantiated DUT is erraneous, display the actual and expected state, and set err = 1
            if (actual !== expected) begin
				$display("out error expected: %d, actual: %d error: %d", expected, actual, err_num);
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
		#25;

		//testcase 1: MOV immediate instruction
		in = 16'b110_10_000_01100100; //REG[000] = 100
		load = 1'b1;
		#10;
		s = 1'b1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd100,DUT.DP.REGFILE.Reg0.out,1);

		//testcase 2: MOV instruction with shift 
		in = 16'b110_00_000_001_10_000; //REG[001] = REG[000] / 2 = 50;
		load = 1'b1;
		#10;
		s = 1'b1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd50,DUT.DP.REGFILE.Reg1.out,2);

		//testcase 3: ADD instruction with REG[0] and REG[1] and store in REG[2]
		in = 16'b101_00_000_010_00_001; //REG[2] = REG[0]+REG[1]  = 150;
		load = 1'b1;
		#10;
		s = 1'b1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd150,sim_out,3);

		// //testcase 4: test reset
		// reset = 1'b1;

		// error_check(16'd150);

		//print results, whether errors were found
        if (~err) 
            $display ("ya i knew it would work. EZ");
        else
            $display ("Error found. ");

        $stop;
	end
endmodule
