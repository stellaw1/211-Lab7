module shifter(in, shift, sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;

    reg [15:0] shiftee;
    assign sout = shiftee;

    always @(*) begin
        case(shift)
            2'b0: shiftee = in; 
            2'b01: shiftee << in;
            2'b10: shiftee >> in;
            2'b11: begin
                shiftee[15] = in[15];
                shiftee >> in;
            end
            default: shiftee = 16'bxxxxxxxxxxxxxxxx;
        end
    end
endmodule