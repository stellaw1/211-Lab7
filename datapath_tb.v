module datapath_tb();
  //inputs
  reg [15:0] sim_data_in;
  reg write,clk,asel,bsel,vsel,loada,loadb,loadc,loads;
  reg [2:0] readnum;
  reg [2:0] writenum;
  reg [1:0] shift,ALUop;
  reg err;

  //outputs
  wire [15:0] sim_data_out;
  wire Z_out;

  datapath DUT(.datapath_in(sim_data_in),
		.vsel(vsel),
		.writenum(writenum),
		.write(write),
		.readnum(readnum),
		.clk(clk),
		.loada(loada),
		.loadb(loadb),
		.loadc(loadc),
		.loads(loads),
		.shift(shift),
		.asel(asel),
		.bsel(bsel),
		.ALUop(ALUop),
		.Z_out(Z_out),
		.datapath_out(sim_datapath_out));

//clock signal
  initial begin
    clk = 1; #5;
    forever begin
      clk = 0; #5;
      clk = 1; #5;
    end
  end

//testing the datapath
  initial begin
//test the register
//put a value in reg 0 and just make sure it makes it to output
    assign err = 0;
    assign sim_data_in = 16'd40503;
    assign writenum = 3'b0;
    assign readnum = 3'b0;
    assign write = 1'b1;
    assign asel = 1'b1;
    assign bsel = 1'b0;
    assign vsel = 1'b1;
    assign loada = 1'b1;
    assign loadb = 1'b1;
    assign loadc = 1'b1;
    assign loads = 1'b1;
    assign shift = 2'b0;
    assign ALUop = 2'b0;
    #10;

    if (sim_datapath_out != 16'd40503) begin
      $display("datapath_out error 1. output: %d, expected: %d",datapath_out, 16'd40503);
      assign err = 1'b1;
    end
    if (Z_out != 1'b1) begin
      $display("Z out error 1. output %d, expected: %d", Z_out,1'b1);
      assign err = 1'b1;
    end

assign write = 1'b0; #5;
//change the value at register 1 but don't change output
    assign writenum = 3'b001;
    assign sim_data_in = 16'd17978; #5;
    assign write = 1'b1;
    assign loadb = 1'b0;
    assign readnum = 3'b001;
    assign asel = 1'b0;
    assign loadc = 1'b0;
    #5;

    if (sim_datapath_out != 16'd40503) begin
      $display("datapath_out error 2. output: %d, expected: %d",datapath_out, 16'd40503);
      assign err = 1'b1;
    end
    if (Z_out != 1'b0) begin
      $display("Z out error 2. output %d, expected: %d", Z_out,1'b0);
      assign err = 1'b1;
    end
  
//output the addition of the two variables and assign this to register2
    assign loadc = 1'b1;
    assign loada = 1'b0;
    assign vsel = 1'b0;
    assign writenum = 3'b010;
    #5;

    if (sim_datapath_out != 16'd58481) begin
      $display("datapath_out error 3. output: %d, expected: %d",datapath_out, 16'd58481);
      assign err = 1'b1;
    end
    if (Z_out != 1'b0) begin
      $display("Z out error 3. output %d, expected: %d", Z_out,1'b0);
      assign err = 1'b1;
    end

assign write = 1'b0; #5;

//assign a new value to register 0 and try shifting it right one bit to divide it in half then send to output
    assign writenum = 3'b0;
    assign sim_data_in = 16'd9264; #5;
    assign write = 1'b0;
    assign loadb = 1'b1;
    assign shift = 2'b10;
    assign asel = 1'b1;
    assign loadc = 1'b1;
    #5;
    if (sim_datapath_out != 16'd4632) begin
      $display("datapath_out error 4. output: %d, expected: %d",datapath_out, 16'd4632);
      assign err = 1'b1;
    end
    if (Z_out != 1'b0) begin
      $display("Z out error 4. output %d, expected: %d", Z_out,1'b0);
      assign err = 1'b1;
    end

assign write = 1'b0; #5;
//write this halved value to register 0, and shift it back to its original value to test output
    assign writenum = 3'b0;
    assign vsel = 1'b0;
    #5;
    assign write = 1'b1;
    assign shift = 2'b01;
    #5;
    if (sim_datapath_out != 16'd9264) begin
      $display("datapath_out error 5. output: %d, expected: %d",datapath_out, 16'd9264);
      assign err = 1'b1;
    end
    if (Z_out != 1'b0) begin
      $display("Z out error 5. output %d, expected: %d", Z_out,1'b0);
      assign err = 1'b1;
    end

assign write = 1'b0; #5;
//add value to register1 and add value at register 0 to it
    assign sim_data_in = 16'd10468;
    assign loadb = 1'b0;
    assign writenum = 3'b001;
    #5;
    assign vsel = 1'b1;
    assign readnum = 3'b001;
    assign shift = 2'b00;
    assign loada = 1'b1;
    assign asel = 1'b0;
    #5;
    if (sim_datapath_out != 16'd15100) begin
      $display("datapath_out error 6. output: %d, expected: %d",datapath_out, 16'd15100);
      assign err = 1'b1;
    end
    if (Z_out != 1'b0) begin
      $display("Z out error 6. output %d, expected: %d", Z_out,1'b0);
      assign err = 1'b1;
    end

assign write = 1'b0; #5;
//save this value at register 0 but don't change the output, load value at loadb
    assign writenum = 3'b0;
    assign loadc = 1'b0;
    assign loadb = 1'b1;
    #5;
    assign write = 1'b1;
    assign vsel = 1'b0;
    #5;

    if (sim_datapath_out != 16'd15100) begin
      $display("datapath_out error 7. output: %d, expected: %d",datapath_out, 16'd15100);
      assign err = 1'b1;
    end
    if (Z_out != 1'b0) begin
      $display("Z out error 7. output %d, expected: %d", Z_out,1'b0);
      assign err = 1'b1;
    end

assign write = 1'b0; #5;
//subtract value at register 0 from value at register 2
    assign loadb = 1'b0;
    assign ALUop = 2'b01;
    #5;
    assign loadc = 1'b1;
    assign readnum = 3'b010;
    #5;
    if (sim_datapath_out != 16'd43381) begin
      $display("datapath_out error 8. output: %d, expected: %d",datapath_out, 16'd43381);
      assign err = 1'b1;
    end
    if (Z_out != 1'b0) begin
      $display("Z out error 8. output %d, expected: %d", Z_out,1'b0);
      assign err = 1'b1;
    end
    
//test bsel
    assign loadc = 1'b0;
    assign asel = 1'b1;
    assign bsel = 1'b1;
    assign ALUop = 2'b00;
    #5;
    assign loadc = 1'b1;
    #5;
    if (sim_datapath_out != 16'b000_000_000_000_010_0) begin
      $display("datapath_out error 9. output: %d, expected: %d",datapath_out, 16'b000_000_000_000_010_0);
      assign err = 1'b1;
    end
    if (Z_out != 1'b0) begin
      $display("Z out error 9. output %d, expected: %d", Z_out,1'b0);
      assign err = 1'b1;
    end

//test Z out
    assign sim_data_in = 16'd4;
    assign writenum = 3'b0;
    assign readnum = 3'b0;
    assign asel = 1'b0;
    assign ALUop = 2'b01;
    assign vsel = 1'b1;
    #5;
    assign write = 1'b1;
    #5;
    if (sim_datapath_out != 16'b0) begin
      $display("datapath_out error 10. output: %d, expected: %d",datapath_out, 16'b0);
      assign err = 1'b1;
    end
    if (Z_out != 1'b1) begin
      $display("Z out error 10. output %d, expected: %d", Z_out,1'b1);
      assign err = 1'b1;
    end
    #5;
    if (err == 0)
       $display("yet again yeeted");
  end
endmodule