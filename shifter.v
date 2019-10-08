module shifter(in, shift, sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;

    reg [15:0] shiftee;
    assign sout = shiftee;

    always @(*) begin
        case(shift)
            2'b0: shiftee = in; 
            2'b01: shiftee = 1 << in;
            2'b10: shiftee = 1 >> in;
            2'b11: 
                shiftee = $signed (in)<<<1;
            default: shiftee = 16'bxxxxxxxxxxxxxxxx;
        endcase
    end
endmodule