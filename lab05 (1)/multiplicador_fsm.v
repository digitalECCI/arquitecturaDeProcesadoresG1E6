// Multiplicador secuencial suma-desplazamiento: 4 bits x 4 bits -> 8 bits
module multiplicador_fsm (
    input  wire       clk,
    input  wire       rst,       // reset asincrono
    input  wire       init,      // pulso de inicio
    input  wire [3:0] MD,        // multiplicando (4 bits)
    input  wire [3:0] MR,        // multiplicador (4 bits)
    output wire       done,
    output wire [7:0] product    // producto (8 bits)
);
    localparam START = 3'b000;
    localparam CHECK = 3'b001;
    localparam ADD   = 3'b010;
    localparam SHIFT = 3'b011;
    localparam END   = 3'b100;

    reg [2:0] state, next_state;
    reg [7:0] PP;   // producto parcial
    reg [7:0] A;    // multiplicando extendido a 8 bits
    reg [3:0] B;    // multiplicador

    wire LSB_B = B[0];
    wire Z     = ((B >> 1) == 4'b0000);   // B sera 0 tras el desplazamiento

    wire reset_dp = (state == START) || ((state == END) && init);
    wire add_dp   = (state == ADD);
    wire sh_dp    = (state == SHIFT);

    always @(posedge clk or posedge rst) begin
        if (rst) state <= START;
        else     state <= next_state;
    end

    always @(*) begin
        case (state)
            START:   next_state = init  ? CHECK : START;
            CHECK:   next_state = LSB_B ? ADD   : SHIFT;
            ADD:     next_state = SHIFT;
            SHIFT:   next_state = Z     ? END   : CHECK;
            END:     next_state = init  ? CHECK : END;
            default: next_state = START;
        endcase
    end

    assign done = (state == END);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PP <= 8'd0;
            A  <= 8'd0;
            B  <= 4'd0;
        end else if (reset_dp) begin
            PP <= 8'd0;
            A  <= {4'b0000, MD};
            B  <= MR;
        end else begin
            if (add_dp) PP <= PP + A;
            if (sh_dp) begin
                A <= A << 1;
                B <= B >> 1;
            end
        end
    end

    assign product = PP;
endmodule
