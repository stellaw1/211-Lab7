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
			else begin
				$display("Testcase %d passed", err_num);
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
		s = 1'b1;
		#20;
		load = 1'b0;
		s = 1'b0;
		#20;

		error_check(16'd100, DUT.DP.REGFILE.Reg0.out, 1);

		//testcase 2: MOV instruction with shift 
		in = 16'b110_00_000_001_10_000; //REG[001] = REG[000] / 2 = 50;
		load = 1'b1;
		s = 1'b1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd50, DUT.DP.REGFILE.Reg1.out, 2);

		//testcase 3: ADD instruction with REG[0] and REG[1] and store in REG[2]
		in = 16'b101_00_000_010_00_001; //REG[2] = REG[0] + REG[1]  = 150;
		load = 1'b1;
		s = 1'b1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd150, sim_out, 3);


		//testcase 4: AND REG[4] REG[2] REG[0] 
		in = 16'b101_10_010_100_00_000; //REG[4] = REG[2] & REG[0] = 16'd150 & 16'd100 = 
		load = 1'b1;
		s = 1;
		#50;
		load = 1'b0;
		s = 1'b0;
		#40;

		// error_check(0, DUT.DP.REGFILE.Reg0.out, 0);
		// error_check(0, DUT.DP.REGFILE.Reg2.out, 2);
		error_check(16'd4, sim_out, 4);


		//testcase 5: MVN REG[6] REG[0] calc. ~100
		in = 16'b101_11_000_110_00_000; 
		load = 1'b1;
		s = 1;
		#50;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd65435, sim_out, 5);
		error_check(16'd65435, DUT.DP.REGFILE.Reg6.out, 5);


		//testcase 6: test reset
		reset = 1'b1;
		#20;
		reset = 0;
		#10;

		error_check(5'b11111, DUT.FSM.present_state, 6);


		//testcase 7: test ADD Rd, Rn, Rm{,<sh_op>} with overflow flag
		in = 16'b101_00_000_010_01_001; //REG[2] = REG[0] + REG[1] * 2  = 200;
		load = 1'b1;
		s = 1'b1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd200, sim_out, 7);
		


		//testcase 8: test ADD Rd, Rn, Rm{,<sh_op>} 
		//				also use MOV immediate to load values into Reg
		
		//MOV immediate REG[5] = 110
		in = 16'b110_10_101_01101110; 
		load = 1'b1;
		s = 1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd110, DUT.DP.REGFILE.Reg5.out, 8);

		//ADD REG[7] = REG[5] + REG[0] * 2 = 110 + 200 = 310
		in = 16'b101_00_101_111_01_000; 
		load = 1'b1;
		s = 1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(16'd310, sim_out, 8);
		


		//testcase 9: test ALU instruction CMP Rn, Rm{,<sh_op>} test zero flag
		in = 16'b101_01_000_000_00_000; //Compare REG[0] and REG[0]
		load = 1'b1;
		s = 1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(1'b1, sim_Z, 9);


		//testcase 10: test ALU instruction CMP Rn, Rm{,<sh_op>} test Negative flag
		in = 16'b101_01_001_000_00_111; //Compare REG[1] - REG[7]
		load = 1'b1;
		s = 1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(1'b1, sim_N, 10);
		
		
		//testcase 11: test ALU instruction CMP Rn, Rm{,<sh_op>} test oVerflow flag
		//MOV immediate REG[3] = 8'b1111_1111 (large number)
		in = 16'b110_10_011_11111111; 
		load = 1'b1;
		s = 1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		//MOV REG[3], REG[3] with shift = 01 (*2)
		in = 16'b110_00_000_011_01_011; //REG[3] = (large number) * 2;
		load = 1'b1;
		s = 1'b1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		//CMP check overflow in REG[3]
		in = 16'b101_01_011_000_00_011; //Compare REG[3] and REG[3]
		load = 1'b1;
		s = 1;
		#40;
		load = 1'b0;
		s = 1'b0;
		#40;

		error_check(1'b1, sim_V, 13);



        if (~err) 
            $display ("ya i knew it would work. EZ");
        else
            $display ("Error found. ");

        $stop;
	end
endmodule