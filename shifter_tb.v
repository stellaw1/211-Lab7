module shifter_tb();
    reg [15:0] sim_in;
    reg [1:0] sim_shift;
    reg err;
    wire [15:0] sim_sout;

    //instantiate DUT: shifter module
    shifter DUT(sim_in, sim_shift, sim_sout);

    task error_checker;
        input [15:0] expected_sim_sout;
        begin
            //if the data_out in the instantiated DUT is erraneous, display the actual and expected state, and set err = 1
            if (DUT.sout !== expected_sim_sout) begin
                $display("ERROR: data_out is %b, expecting %b", DUT.sout, expected_sim_sout);
                err = 1'b1;
            end
        end
    endtask

    initial begin 
        //initialize signals
        err = 1'b0;
        sim_in = 16'b1111000011001111;
        #5;

        //testcase 1: shift = 00
        sim_shift = 2'b0;
        #5;

        error_checker(16'b1111000011001111);
        $display("sim_sout is %b, expecting %b", sim_sout, 16'b1111000011001111);

        //testcase 2: shift = 01
        sim_shift = 2'b01;
        #5;

        error_checker(16'b1110000110011110);
        $display("sim_sout is %b, expecting %b", sim_sout, 16'b1110000110011110);

        //testcase 3: shift = 10
        sim_shift = 2'b10;
        #5;

        error_checker(16'b0111100001100111);
        $display("sim_sout is %b, expecting %b", sim_sout, 16'b0111100001100111);
        
        //testcase 4: shift = 11
        sim_shift = 2'b11;
        #5;

        error_checker(16'b1111100001100111);
        $display("sim_sout is %b, expecting %b", sim_sout, 16'b1111100001100111);

         //print results, whether errors were found
        if (~err) 
            $display ("All test cases passed with no errors. ");
        else
            $display ("Error found. ");
    end
endmodule