module Lab04_Multiplicador_Top (
    input  wire [3:0] MD,    
    input  wire [3:0] MR,    
    input  wire       INIT,  
    input  wire       clk,   
    input  wire       rst_n, 
    output wire       DONE,  
    output wire [6:0] HEX0,  
    output wire [6:0] HEX1,  
    output wire [6:0] HEX2  
);

    
    localparam ST_START = 3'd0;
    localparam ST_CHECK = 3'd1;
    localparam ST_ADD   = 3'd2;
    localparam ST_SHIFT = 3'd3;
    localparam ST_END   = 3'd4;

    reg [2:0] state, next_state;
    reg ctrl_reset, ctrl_add, ctrl_sh, ctrl_done;

    assign DONE = ctrl_done;

    reg [7:0] A_reg;  
    reg [3:0] B_reg;  
    reg [7:0] PP_reg; 

    wire LSB_B = B_reg[0];         
    wire Z     = (B_reg == 4'd0);  

   
    wire [7:0] Sum_Out;
    wire carry_mid, c5, c6, c7, c8;

    sumador_restador_4_bits add_low (
        .A(PP_reg[3:0]), .B(A_reg[3:0]), .Sel(1'b0), .So(Sum_Out[3:0]), .Co(carry_mid)
    );

    sumador_un_bit sum4 (.A(PP_reg[4]), .B(A_reg[4]), .Ci(carry_mid), .So(Sum_Out[4]), .Co(c5));
    sumador_un_bit sum5 (.A(PP_reg[5]), .B(A_reg[5]), .Ci(c5),        .So(Sum_Out[5]), .Co(c6));
    sumador_un_bit sum6 (.A(PP_reg[6]), .B(A_reg[6]), .Ci(c6),        .So(Sum_Out[6]), .Co(c7));
    sumador_un_bit sum7 (.A(PP_reg[7]), .B(A_reg[7]), .Ci(c7),        .So(Sum_Out[7]), .Co(c8));

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= ST_START;
        else        state <= next_state;
    end

    always @(*) begin
        next_state = state;
        ctrl_reset = 1'b0; ctrl_add = 1'b0; ctrl_sh = 1'b0; ctrl_done = 1'b0;

        case (state)
            ST_START: begin
                if (INIT == 1'b1) begin
                    ctrl_reset = 1'b1;
                    next_state = ST_CHECK;
                end else begin
                    ctrl_reset = 1'b0; 
                    next_state = ST_START;
                end
            end
            ST_CHECK: begin
                if (LSB_B == 1'b1) next_state = ST_ADD;
                else               next_state = ST_SHIFT;
            end
            ST_ADD: begin
                ctrl_add = 1'b1;
                next_state = ST_SHIFT;
            end
            ST_SHIFT: begin
                ctrl_sh = 1'b1;
                if (Z == 1'b1) next_state = ST_END;
                else           next_state = ST_CHECK;
            end
            ST_END: begin
                ctrl_done = 1'b1;
                if (INIT == 1'b0) next_state = ST_START; 
                else              next_state = ST_END;
            end
            default: next_state = ST_START;
        endcase
    end

 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            A_reg  <= 8'd0; B_reg  <= 4'd0; PP_reg <= 8'd0;
        end else begin
            if (ctrl_reset) begin
                A_reg  <= {4'd0, MD}; 
                B_reg  <= MR;         
                PP_reg <= 8'd0;       
            end else begin
                if (ctrl_add) PP_reg <= Sum_Out; 
                if (ctrl_sh) begin
                    A_reg <= A_reg << 1; 
                    B_reg <= B_reg >> 1; 
                end
            end
        end
    end


    reg [3:0] bcd_c, bcd_d, bcd_u;
    reg [3:0] show_c, show_d, show_u;

    // Conversión binario -> BCD por corrimientos y sumas de 3 (double dabble),
    // sin `for` y sin `function`: 8 etapas desenrolladas dentro de un `always`,
    // usando `if` para la corrección (nada de `wire` ni operador ternario).
    reg [11:0] p; // variable temporal de trabajo (registro de corrimiento BCD)

    always @(*) begin
        p = 12'd0;

        // etapa 1: corrige y mete PP_reg[7]
        if (p[3:0]  >= 4'd5) p[3:0]  = p[3:0]  + 4'd3;
        if (p[7:4]  >= 4'd5) p[7:4]  = p[7:4]  + 4'd3;
        if (p[11:8] >= 4'd5) p[11:8] = p[11:8] + 4'd3;
        p = {p[10:0], PP_reg[7]};

        // etapa 2: corrige y mete PP_reg[6]
        if (p[3:0]  >= 4'd5) p[3:0]  = p[3:0]  + 4'd3;
        if (p[7:4]  >= 4'd5) p[7:4]  = p[7:4]  + 4'd3;
        if (p[11:8] >= 4'd5) p[11:8] = p[11:8] + 4'd3;
        p = {p[10:0], PP_reg[6]};

        // etapa 3: corrige y mete PP_reg[5]
        if (p[3:0]  >= 4'd5) p[3:0]  = p[3:0]  + 4'd3;
        if (p[7:4]  >= 4'd5) p[7:4]  = p[7:4]  + 4'd3;
        if (p[11:8] >= 4'd5) p[11:8] = p[11:8] + 4'd3;
        p = {p[10:0], PP_reg[5]};

        // etapa 4: corrige y mete PP_reg[4]
        if (p[3:0]  >= 4'd5) p[3:0]  = p[3:0]  + 4'd3;
        if (p[7:4]  >= 4'd5) p[7:4]  = p[7:4]  + 4'd3;
        if (p[11:8] >= 4'd5) p[11:8] = p[11:8] + 4'd3;
        p = {p[10:0], PP_reg[4]};

        // etapa 5: corrige y mete PP_reg[3]
        if (p[3:0]  >= 4'd5) p[3:0]  = p[3:0]  + 4'd3;
        if (p[7:4]  >= 4'd5) p[7:4]  = p[7:4]  + 4'd3;
        if (p[11:8] >= 4'd5) p[11:8] = p[11:8] + 4'd3;
        p = {p[10:0], PP_reg[3]};

        // etapa 6: corrige y mete PP_reg[2]
        if (p[3:0]  >= 4'd5) p[3:0]  = p[3:0]  + 4'd3;
        if (p[7:4]  >= 4'd5) p[7:4]  = p[7:4]  + 4'd3;
        if (p[11:8] >= 4'd5) p[11:8] = p[11:8] + 4'd3;
        p = {p[10:0], PP_reg[2]};

        // etapa 7: corrige y mete PP_reg[1]
        if (p[3:0]  >= 4'd5) p[3:0]  = p[3:0]  + 4'd3;
        if (p[7:4]  >= 4'd5) p[7:4]  = p[7:4]  + 4'd3;
        if (p[11:8] >= 4'd5) p[11:8] = p[11:8] + 4'd3;
        p = {p[10:0], PP_reg[1]};

        // etapa 8: corrige y mete PP_reg[0]
        if (p[3:0]  >= 4'd5) p[3:0]  = p[3:0]  + 4'd3;
        if (p[7:4]  >= 4'd5) p[7:4]  = p[7:4]  + 4'd3;
        if (p[11:8] >= 4'd5) p[11:8] = p[11:8] + 4'd3;
        p = {p[10:0], PP_reg[0]};

        // resultado final
        bcd_c = p[11:8];
        bcd_d = p[7:4];
        bcd_u = p[3:0];

        // apagar ceros a la izquierda (mostrar 'f' en el decodificador para blanco)
        if (bcd_c == 4'd0)                     show_c = 4'hf;
        else                                    show_c = bcd_c;

        if (bcd_c == 4'd0 && bcd_d == 4'd0)     show_d = 4'hf;
        else                                    show_d = bcd_d;

        show_u = bcd_u;
    end

    
    // Decodificador de 7 segmentos con `case`, sin `function`.
    // Los HEX se manejan como reg internos y se asignan al puerto con `assign`.
    reg [6:0] HEX0_r, HEX1_r, HEX2_r;

    always @(*) begin
        case (show_u)
            4'd0: HEX0_r = ~7'b0111111;
            4'd1: HEX0_r = ~7'b0000110;
            4'd2: HEX0_r = ~7'b1011011;
            4'd3: HEX0_r = ~7'b1001111;
            4'd4: HEX0_r = ~7'b1100110;
            4'd5: HEX0_r = ~7'b1101101;
            4'd6: HEX0_r = ~7'b1111101;
            4'd7: HEX0_r = ~7'b0000111;
            4'd8: HEX0_r = ~7'b1111111;
            4'd9: HEX0_r = ~7'b1101111;
            default: HEX0_r = ~7'b0000000;
        endcase
    end

    always @(*) begin
        case (show_d)
            4'd0: HEX1_r = ~7'b0111111;
            4'd1: HEX1_r = ~7'b0000110;
            4'd2: HEX1_r = ~7'b1011011;
            4'd3: HEX1_r = ~7'b1001111;
            4'd4: HEX1_r = ~7'b1100110;
            4'd5: HEX1_r = ~7'b1101101;
            4'd6: HEX1_r = ~7'b1111101;
            4'd7: HEX1_r = ~7'b0000111;
            4'd8: HEX1_r = ~7'b1111111;
            4'd9: HEX1_r = ~7'b1101111;
            default: HEX1_r = ~7'b0000000;
        endcase
    end

    always @(*) begin
        case (show_c)
            4'd0: HEX2_r = ~7'b0111111;
            4'd1: HEX2_r = ~7'b0000110;
            4'd2: HEX2_r = ~7'b1011011;
            4'd3: HEX2_r = ~7'b1001111;
            4'd4: HEX2_r = ~7'b1100110;
            4'd5: HEX2_r = ~7'b1101101;
            4'd6: HEX2_r = ~7'b1111101;
            4'd7: HEX2_r = ~7'b0000111;
            4'd8: HEX2_r = ~7'b1111111;
            4'd9: HEX2_r = ~7'b1101111;
            default: HEX2_r = ~7'b0000000;
        endcase
    end

    assign HEX0 = HEX0_r;
    assign HEX1 = HEX1_r;
    assign HEX2 = HEX2_r;

endmodule