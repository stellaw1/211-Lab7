module datapath_tb();
  //inputs
  reg [15:0] sim_mdata;
  reg [15:0] sim_sximm8; 
  reg [15:0] sim_sximm5;
  reg sim_write, clk, sim_loada, sim_loadb, sim_loadc, sim_loads, sim_asel, sim_bsel;
  reg [3:0] sim_vsel;
  reg [2:0] sim_writenum, sim_readnum;
  reg [1:0] sim_shift, sim_ALUop;
  reg err;

  //outputs
  wire sim_N, sim_Z, sim_V;
  wire [15:0] sim_datapath_out;

  datapath DUT( .mdata (sim_mdata), 
                .sximm8(sim_sximm8), 
                .sximm5(sim_sximm5), 
                .vsel(sim_vsel), 
                .writenum(sim_writenum), 
                .write(sim_write), 
                .readnum(sim_readnum), 
                .clk(clk), 
                .loada(sim_loada), 
                .loadb(sim_loadb), 
                .loadc(sim_loadc), 
                .loads(sim_loads), 
                .shift(sim_shift), 
                .asel(sim_asel), 
                .bsel(sim_bsel), 
                .ALUop(sim_ALUop), 
                .N(sim_N), 
                .Z(sim_Z), 
                .V(sim_V), 
                .datapath_out(sim_datapath_out) );

  //autonomous error checker task
  task error_check;
        input [15:0] expected, actual, err_num;
        begin
            //if the data_out in the instantiated DUT is erraneous, display the actual and expected state, and set err = 1
            if (actual !== expected) begin
				$display("ERROR: expected: %d, actual: %d testcase: %d", expected, actual, err_num);
				err = 1'b1;
			end
			else begin
				$display("Testcase %d passed", err_num);
			end
        end
    endtask

  //clock signal
  initial begin
    clk = 0; #5;
    forever begin
      clk = 1; #5;
      clk = 0; #5;
    end
  end

  //testing the datapath
  initial begin
    //initialize signals
    err = 1'b0;
    sim_mdata = 16'b0;
    sim_sximm8 = 16'b0; 
    sim_sximm5 = 16'b0;
    sim_write = 1'b0;
    sim_loada = 1'b0;
    sim_loadb = 1'b0; 
    sim_loadc = 1'b0;
    sim_loads = 1'b0; 
    sim_asel = 1'b0; 
    sim_bsel = 1'b1;
    sim_vsel = 4'b0100;
    sim_writenum = 3'b0; 
    sim_readnum = 3'b0;
    sim_shift = 2'b0; 
    sim_ALUop = 2'b0;
    #10;
    

    //testcase 0: MOV R3, #42
    //write to R3
    sim_sximm8 = 16'h42; // h for hexadecimal
    sim_writenum = 3'd3;
    sim_write = 1'b1;
    sim_loada = 1;
    #10;

    sim_write = 0;
    #10;

    sim_readnum = 3'd3;
    sim_loadc = 1;
    sim_loads = 1;
    #20;

    // the following checks if MOV was executed correctly
    error_check(16'h42, sim_datapath_out, 0);


    //testcase1: test Z out by writing 0 to Reg0
    sim_sximm8 = 0;
    sim_write = 1'b1;
    sim_writenum = 3'b0;
    sim_readnum = 3'b0;
    sim_loada = 1'b1;
    sim_loadc = 1'b1;
    sim_loads = 1'b1;
    #40;

    error_check(0, sim_datapath_out, 1);
    error_check(1, sim_Z, 2);

    sim_write = 1'b0;
    sim_loads = 0;
    #10;


    //testcase 2: change the value at reg1 but don't change output
    sim_writenum = 3'b001;
    sim_sximm8 = 16'd17978;
    sim_write = 1'b1;
    sim_loadb = 1'b0;
    sim_readnum = 3'b001;
    sim_asel = 1'b0;
    sim_loadc = 1'b0;
    #40;

    sim_write = 0;
    #10;

    error_check(0, sim_datapath_out, 3);
    error_check(1, sim_Z, 4);
    error_check(16'd17978, DUT.REGFILE.R1, 5);
  

    //testcase 3: ADD R2, R1, R3{01}. R2 = R1 + R3 = 16'd17978 + 16'd66 * 2 = 17978 + 132 = 18110
    sim_readnum = 3'b001; //load R1 to A
    sim_loada = 1;
    #10;
    sim_loada = 0;
    #10;

    sim_readnum = 3'b011; // load R3 to B
    sim_shift = 2'b01;
    sim_loadb = 1;
    #10;
    sim_loadb = 0;
    #10;

    sim_loadc = 1'b1; //load sum to C
    sim_loads = 1;
    sim_asel = 0;
    sim_bsel = 0;
    #10;

    error_check(16'd18110, sim_datapath_out, 6);

    sim_vsel = 4'b0001;
    sim_write = 1;
    sim_writenum = 3'b010;
    #10;

    sim_write = 1'b0; 
    sim_vsel = 4'b0100;
    sim_shift = 0;
    #10;

    error_check(16'd18110, DUT.REGFILE.R2, 7);
    error_check(0, sim_Z, 8);

    error_check(16'd66, DUT.pipeB.out, 9);


    //test case 4: test V overflow flag and N negative flag 
    //  using SUB R5, R7, R3 with R1 = -32767 - 66 = - 32833 = 65601 = 16'b1111111111111111 - 16'b1000010 = 16'b11111111_10111101
    
    //write 16'b1111111111111111 to R7
    sim_writenum = 3'b111;
    sim_sximm8 = 16'b11111111_11111111;
    sim_write = 1'b1;
    sim_loada = 1;
    sim_readnum = 3'b111;
    #40;

    sim_write = 0;
    #10;

    error_check(16'b1111111111111111, DUT.REGFILE.R7, 10);
    error_check(16'b1111111111111111, DUT.pipeA.out, 11);

    //load SUB x, R7, R3 to C and datapath_out 
    sim_ALUop = 2'b01;
    sim_loadc = 1'b1;
    sim_loads = 1'b1;
    #20;

    error_check(16'b11111111_10111101, sim_datapath_out, 12);
    error_check(0, sim_Z, 13);
    error_check(1, sim_V, 14);
    error_check(1, sim_N, 15);

    sim_loads = 0;
    sim_ALUop = 2'b00;
    #10;


    //testcase 8: SUB x, R0, R1
    //  x = 0 - 17978 = - 17978 = 16'b1011100111000110
    sim_readnum = 3'b0;
    sim_loada = 1;
    #10;
    sim_loada = 0;
    #10;

    sim_readnum = 3'b001;
    sim_loadb = 1;
    #10;
    sim_loadb = 0;
    #10;
    
    sim_ALUop = 2'b01;
    #10;
    sim_loadc = 1'b1;
    sim_loads = 1;
    #10;

    error_check(16'b1011100111000110, sim_datapath_out, 16); 
    error_check(0, sim_Z, 17);
    error_check(1, sim_N, 18);
    error_check(0, sim_V, 19);
    


    //print results, whether errors were found
    if (~err) 
        $display ("All test cases passed with no errors. ");
    else
        $display ("Error found. ");
    $stop;
  end
endmodule
