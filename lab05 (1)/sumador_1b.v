module sumador_1b (
    input  a,
    input  b,
    input  cin,
    output s,
    output cout
);
    assign cout = b&cin | a&cin | a&b;
    assign s = a ^ (b ^ cin);
    
endmodule