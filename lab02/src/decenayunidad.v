
module decenayunidad(
    input  [4:0] bin,
    output [3:0] unidadyx,
    output [3:0] decenayx
);
    reg [12:0] BCD_R;

    always @(*) begin
        BCD_R = 13'b0;  
        BCD_R[4:0] = bin; 

        if (BCD_R[8:5] >= 5) 
          BCD_R[8:5] = BCD_R[8:5] + 3;
        if (BCD_R[12:9] >= 5) 
         BCD_R[12:9] = BCD_R[12:9] + 3;
        BCD_R = BCD_R << 1;

        if (BCD_R[8:5] >= 5) 
          BCD_R[8:5] = BCD_R[8:5] + 3;
        if (BCD_R[12:9] >= 5) 
          BCD_R[12:9] = BCD_R[12:9] + 3;
        BCD_R = BCD_R << 1;

        if (BCD_R[8:5] >= 5) 
          BCD_R[8:5] = BCD_R[8:5] + 3;
        if (BCD_R[12:9] >= 5) 
          BCD_R[12:9] = BCD_R[12:9] + 3;
        BCD_R = BCD_R << 1;

        if (BCD_R[8:5] >= 5) 
          BCD_R[8:5] = BCD_R[8:5] + 3;
        if (BCD_R[12:9] >= 5) 
          BCD_R[12:9] = BCD_R[12:9] + 3;
        BCD_R = BCD_R << 1;

        if (BCD_R[8:5] >= 5)
           BCD_R[8:5] = BCD_R[8:5] + 3;
        if (BCD_R[12:9] >= 5) 
          BCD_R[12:9] = BCD_R[12:9] + 3;
        BCD_R = BCD_R << 1;
    end

    assign unidadyx = BCD_R[8:5];
    assign decenayx = BCD_R[12:9];
endmodule
