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
    if (sim_datapath_out !== 16'h42) begin
      err = 1; 
      $display("FAILED: MOV R3, #42 wrong -- Regs[R3]=%h is wrong, expected %h", sim_datapath_out, 16'h42); 
      $stop; 
    end





    // //testcase1: test the register by putting a value in reg 0 and just make sure it makes it to output
    // sim_sximm8 = 16'h42;
    // sim_write = 1'b1;
    // sim_writenum = 3'b0;
    // sim_readnum = 3'b0;
    // sim_loada = 1'b1;
    // sim_loadc = 1'b1;
    // sim_loads = 1'b1;
    // #10;

    // if (sim_datapath_out !== 16'h42) begin
    //   $display("datapath_out error 1. output: %d, expected: %d", sim_datapath_out, 16'h42);
    //    err = 1'b1;
    // end
    // if (sim_Z !== 1'b1) begin
    //   $display("Z out error 1. output %d, expected: %d", sim_Z, 1'b1);
    //    err = 1'b1;
    // end

    // sim_write = 1'b0;


    // //testcase 2: change the value at register 1 but don't change output
    // sim_writenum = 3'b001;
    // sim_sximm8 = 16'd17978;
    // sim_write = 1'b1;
    // sim_loadb = 1'b0;
    // sim_readnum = 3'b001;
    // sim_asel = 1'b0;
    // sim_loadc = 1'b0;
    // #10;

    // if (sim_datapath_out !== 16'd40503) begin
    //   $display("datapath_out error 2. output: %d, expected: %d", sim_datapath_out, 16'd40503);
    //    err = 1'b1;
    // end
    // if (sim_Z !== 1'b0) begin
    //   $display("Z out error 2. output %d, expected: %d", sim_Z,1'b0);
    //    err = 1'b1;
    // end
  
    // //testcase 3: output the addition of the two variables and  this to register2
    // sim_loadc = 1'b1;
    // sim_loada = 1'b0;
    // sim_vsel = 1'b0;
    // sim_writenum = 3'b010;
    // #10;

    // if (sim_datapath_out !== 16'd58481) begin
    //   $display("datapath_out error 3. output: %d, expected: %d", sim_datapath_out, 16'd58481);
    //    err = 1'b1;
    // end
    // if (sim_Z !== 1'b0) begin
    //   $display("Z out error 3. output %d, expected: %d", sim_Z,1'b0);
    //    err = 1'b1;
    // end

    // sim_write = 1'b0; #10;

    // //testcase 4: a new value to register 0 and try shifting it right one bit to divide it in half then send to output
    //  writenum = 3'b0;
    //  sximm8 = 16'd9264; #5;
    //  write = 1'b0;
    //  loadb = 1'b1;
    //  shift = 2'b10;
    //  asel = 1'b1;
    //  loadc = 1'b1;
    // #5;

    // if (sim_datapath_out !== 16'd4632) begin
    //   $display("datapath_out error 4. output: %d, expected: %d",sim_datapath_out, 16'd4632);
    //    err = 1'b1;
    // end
    // if (Z_out !== 1'b0) begin
    //   $display("Z out error 4. output %d, expected: %d", Z_out,1'b0);
    //    err = 1'b1;
    // end

    // write = 1'b0; #5;


    // //testcase 5: write this halved value to register 0, and shift it back to its original value to test output
    //  writenum = 3'b0;
    //  vsel = 1'b0;
    // #5;
    //  write = 1'b1;
    //  shift = 2'b01;
    // #5;

    // if (sim_datapath_out !== 16'd9264) begin
    //   $display("datapath_out error 5. output: %d, expected: %d", sim_datapath_out, 16'd9264);
    //    err = 1'b1;
    // end
    // if (Z_out !== 1'b0) begin
    //   $display("Z out error 5. output %d, expected: %d", Z_out,1'b0);
    //    err = 1'b1;
    // end

    // write = 1'b0; #5;


    // //testcase 6: add value to register1 and add value at register 0 to it
    //  sximm8 = 16'd10468;
    //  loadb = 1'b0;
    //  writenum = 3'b001;
    // #5;
    //  vsel = 1'b1;
    //  readnum = 3'b001;
    //  shift = 2'b00;
    //  loada = 1'b1;
    //  asel = 1'b0;
    // #5;

    // if (sim_datapath_out !== 16'd15100) begin
    //   $display("datapath_out error 6. output: %d, expected: %d", sim_datapath_out, 16'd15100);
    //    err = 1'b1;
    // end
    // if (Z_out !== 1'b0) begin
    //   $display("Z out error 6. output %d, expected: %d", Z_out,1'b0);
    //    err = 1'b1;
    // end

    // write = 1'b0; #5;


    // //testcase 7: save this value at register 0 but don't change the output, load value at loadb
    //  writenum = 3'b0;
    //  loadc = 1'b0;
    //  loadb = 1'b1;
    // #5;
    //  write = 1'b1;
    //  vsel = 1'b0;
    // #5;

    // if (sim_datapath_out !== 16'd15100) begin
    //   $display("datapath_out error 7. output: %d, expected: %d", sim_datapath_out, 16'd15100);
    //    err = 1'b1;
    // end
    // if (Z_out !== 1'b0) begin
    //   $display("Z out error 7. output %d, expected: %d", Z_out,1'b0);
    //    err = 1'b1;
    // end

    // write = 1'b0; #5;


    // //testcase 8: subtract value at register 0 from value at register 2
    //  loadb = 1'b0;
    //  ALUop = 2'b01;
    // #5;
    //  loadc = 1'b1;
    //  readnum = 3'b010;
    // #5;

    // if (sim_datapath_out !== 16'd43381) begin
    //   $display("datapath_out error 8. output: %d, expected: %d", sim_datapath_out, 16'd43381);
    //    err = 1'b1;
    // end
    // if (Z_out !== 1'b0) begin
    //   $display("Z out error 8. output %d, expected: %d", Z_out,1'b0);
    //    err = 1'b1;
    // end
    
    // //testcase 9: test bsel
    //  loadc = 1'b0;
    //  asel = 1'b1;
    //  bsel = 1'b1;
    //  ALUop = 2'b00;
    // #5;
    //  loadc = 1'b1;
    // #5;

    // if (sim_datapath_out !== 16'b000_000_000_000_010_0) begin
    //   $display("datapath_out error 9. output: %d, expected: %d", sim_datapath_out, 16'b000_000_000_000_010_0);
    //    err = 1'b1;
    // end
    // if (Z_out !== 1'b0) begin
    //   $display("Z out error 9. output %d, expected: %d", Z_out,1'b0);
    //    err = 1'b1;
    // end

    // //testcase 10: test Z out
    //  sximm8 = 16'd4;
    //  writenum = 3'b0;
    //  readnum = 3'b0;
    //  asel = 1'b0;
    //  ALUop = 2'b01;
    //  vsel = 1'b1;
    // #5;
    //  write = 1'b1;
    // #5;

    // if (sim_datapath_out !== 16'b0) begin
    //   $display("datapath_out error 10. output: %d, expected: %d", sim_datapath_out, 16'b0);
    //    err = 1'b1;
    // end
    // if (Z_out !== 1'b1) begin
    //   $display("Z out error 10. output %d, expected: %d", Z_out,1'b1);
    //    err = 1'b1;
    // end
    // #5;


    //print results, whether errors were found
    if (~err) 
        $display ("All test cases passed with no errors. ");
    else
        $display ("Error found. ");
    $stop;
  end
endmodule
