//Lab 5 Code taken from Arnold Ying and Rain Zhang
module ALU(Ain, Bin, ALUop, out, status);
    input [15:0] Ain, Bin;
    input [1:0] ALUop;
    output [15:0] out;
    output [2:0] status; //status[0]=Z, status[1]=N, status[2]=V

    reg [15:0] out;
    reg [2:0] status;

    always @(*) begin
        //checks the selection and assign out correspondingly with Ain and Bin
        case (ALUop)
            2'b00: out = Ain + Bin;
            2'b01: out = Ain - Bin;
            2'b10: out = Ain & Bin;
            2'b11: out = ~Bin;
            //prevent inferred latches
            default: out = 16'bxxxx_xxxx_xxxx_xxxx;
        endcase

        //assigns the first bit of status value with non-blocking assignment - zero status
        if (out == 0)
            status[0] <= 1;
        else
            status[0] <= 0;

        //assigns the second bit of status value with non-blocking assignment - neg status
        if (out[15] == 1)
            status[1] <= 1;
        else
            status[1] <= 0;

        //assigns the third bit of status value with non-blocking assignment - ovf status
        if ((Ain[15] ^ Bin[15]) & (Ain[15] ^ out[15]) )
            status[2] <= 1;
        else
            status[2] <= 0;

    end
endmodule
