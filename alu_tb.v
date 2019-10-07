module ALU_tb();
  reg [15:0] sim_ain, sim_bin;
  wire [15:0] sim_out;
  reg [1:0] sim_ALUop;
  wire sim_Z;
  reg err;

  ALU DUT(sim_ain, sim_bin, sim_ALUop, sim_out, sim_Z);

  initial begin
    sim_ain = 16'b0000010101100010; //1378
    sim_bin = 16'b0101100000100010;//22562
    err = 1'b0;

//test ADD
    sim_ALUop = 2'b00;
    #5;
    if (sim_out != 16'b0101110110000100) begin
      $display("output: %b expected: %b, Test1",sim_out, 16'b0101110110000100);
      err = 1'b1;
    end


//test SUB
    sim_ALUop = 2'b01;
    #5;
    if (sim_out != 16'b1010110101000000) begin
      $display("output: %b expected: %b ,Test2",sim_out, 16'b1010110101000000);
      err = 1'b1;
    end

 //test AND
    sim_ALUop = 2'b10;
    #5;
    if (sim_out != 16'b0000000000100010) begin
      $display("output: %b expected: %b ,Test3",sim_out, 16'b0000000000100010);
      err = 1'b1;
    end


//test NOT B
    sim_ALUop = 2'b11;
    #5;
    if (sim_out != 16'b1010011111011101) begin
      $display("output: %b expected: %b, Test4",sim_out, 16'b1010011111011101);
      err = 1'b1;
    end


    if (err == 1'b0)
      $display("yeeted.");
  end 
endmodule