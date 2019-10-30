module lab7_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial begin
    KEY[0] = 0; #5;
    forever begin
        KEY[0] = 1; #5;
        KEY[0] = 0; #5;
    end
  end

  initial begin
    
    //initialize signals
    err = 0;
    KEY[1] = 1'b0; // reset asserted

    // check if instructions loaded in memory match our data.txt values
    if (DUT.MEM.mem[0] !== 16'b1101000000000111) begin err = 1; $display("FAILED: mem[0] wrong"); $stop; end
    if (DUT.MEM.mem[1] !== 16'b1101000100000010) begin err = 1; $display("FAILED: mem[1] wrong"); $stop; end
    if (DUT.MEM.mem[2] !== 16'b1010000101001000) begin err = 1; $display("FAILED: mem[2] wrong"); $stop; end
    
    #10; // wait until next falling edge of clock
    KEY[1] = 1'b1; // reset de-asserted, PC still undefined if as in Figure 4

    #100; // waiting for RST state to cause reset of PC

    // NOTE: your program counter register output should be called PC and be inside a module with instance name CPU
    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    // @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R0, X

    // if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

    // @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 2 *after* executing MOV R0, X

    // if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    // if (DUT.CPU.DP.REGFILE.R0 !== 16'h5) begin err = 1; $display("FAILED: R0 should be 5."); $stop; end  // because MOV R0, X should have occurred

    // @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 3 *after* executing LDR R1, [R0]

    // if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    // if (DUT.CPU.DP.REGFILE.R1 !== 16'hABCD) begin err = 1; $display("FAILED: R1 should be 0xABCD. Looks like your LDR isn't working."); $stop; end

    // @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 4 *after* executing MOV R2, Y

    // if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    // if (DUT.CPU.DP.REGFILE.R2 !== 16'h6) begin err = 1; $display("FAILED: R2 should be 6."); $stop; end

    // @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // wait here until PC changes; autograder expects PC set to 5 *after* executing STR R1, [R2]
   
    // if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    // if (DUT.MEM.mem[6] !== 16'hABCD) begin err = 1; $display("FAILED: mem[6] wrong; looks like your STR isn't working"); $stop; end

    // // NOTE: if HALT is working, PC won't change again...

    if (~err) $display("INTERFACE OK");
    $stop;
  end
endmodule
