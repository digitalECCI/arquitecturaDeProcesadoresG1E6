module comparador_1b (
    input wire A,
    input wire B,
    output wire Ma,
    output wire Mb,
    output wire i
);
assign Ma = A&~B;
assign Mb = ~A&B;
assign i = ~(A^B);

endmodule 