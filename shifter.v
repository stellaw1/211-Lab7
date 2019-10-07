module shifter(in, shift, sout);
    input [15:0] in;
    input [1:0] shift;
    output [15:0] sout;

    reg [15:0] shiftee;
    assign sout = shiftee;

    always @(shift) begin
        if (shift == 2'b0) begin
            shiftee = in; //default: shiftee = in, namely output the unchanged in. 
        end else if (shift == 2'b01) begin
            shiftee[15] = in[14];
            shiftee[14] = in[13];
            shiftee[13] = in[12];
            shiftee[12] = in[11];
            shiftee[11] = in[10];
            shiftee[10] = in[9];
            shiftee[9] = in[8];
            shiftee[8] = in[7];
            shiftee[7] = in[6];
            shiftee[6] = in[5];
            shiftee[5] = in[4];
            shiftee[4] = in[3];
            shiftee[3] = in[2];
            shiftee[2] = in[1];
            shiftee[1] = in[0];
            shiftee[0] = 1'b0;
        end else if (shift == 2'b10) begin
            shiftee[15] = 1'b0;
            shiftee[14] = in[15];
            shiftee[13] = in[14];
            shiftee[12] = in[13];
            shiftee[11] = in[12];
            shiftee[10] = in[11];
            shiftee[9] = in[10];
            shiftee[8] = in[9];
            shiftee[7] = in[8];
            shiftee[6] = in[7];
            shiftee[5] = in[6];
            shiftee[4] = in[5];
            shiftee[3] = in[4];
            shiftee[2] = in[3];
            shiftee[1] = in[2];
            shiftee[0] = in[1];
        end else begin //if (shift == 2'b11) 
            shiftee[15] = 1'b1;
            shiftee[14] = in[15];
            shiftee[13] = in[14];
            shiftee[12] = in[13];
            shiftee[11] = in[12];
            shiftee[10] = in[11];
            shiftee[9] = in[10];
            shiftee[8] = in[9];
            shiftee[7] = in[8];
            shiftee[6] = in[7];
            shiftee[5] = in[6];
            shiftee[4] = in[5];
            shiftee[3] = in[4];
            shiftee[2] = in[3];
            shiftee[1] = in[2];
            shiftee[0] = in[1];
        end
    end
endmodule