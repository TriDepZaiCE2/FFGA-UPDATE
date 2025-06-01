module ControlUnit (
    input wire clk,
    input wire rst,
    input wire [3:0] opcode,
    input wire zero_flag,         // Cá» Zero tá»« ALU Ä‘á»ƒ nháº£y
    output reg [2:0] state,
    output reg pc_enable,
    output reg pc_load,
    output reg ir_load,
    output reg rf_we,
    output reg mem_read,
    output reg mem_write,
    output reg [3:0] alu_op,
    output reg sel_alu_src,
    output reg pc_branch    // TÃ­n hiá»‡u cho phÃ©p PC nháº£y cÃ³ Ä‘iá»u kiá»‡n
);

    // Tráº¡ng thÃ¡i FSM
    localparam FETCH   = 3'b000,
               DECODE  = 3'b001,
               EXECUTE = 3'b010,
               MEM     = 3'b011,
               WB      = 3'b100,
               BRANCH  = 3'b101;  // tráº¡ng thÃ¡i nháº£y

    // Opcode má»Ÿ rá»™ng
    localparam OP_ADD  = 4'b0000,
               OP_SUB  = 4'b0001,
               OP_AND  = 4'b0010,
               OP_OR   = 4'b0011,
               OP_XOR  = 4'b0100,
               OP_MUL  = 4'b0101,
               OP_SLL  = 4'b0110,
               OP_SRL  = 4'b0111,
               OP_SRA  = 4'b1000,
               OP_FADD = 4'b1001,
               OP_FSUB = 4'b1010,
               OP_FMUL = 4'b1011,
               OP_LOAD = 4'b1100,
               OP_STORE= 4'b1101,
               OP_BEQ  = 4'b1110,
               OP_BNE  = 4'b1111,
               OP_JMP  = 4'b1010,
               OP_MVI  = 4'b0111,
               OP_MOV  = 4'b0110;

    reg [2:0] current_state, next_state;

    // Cáº­p nháº­t tráº¡ng thÃ¡i
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // Logic chuyá»ƒn tráº¡ng thÃ¡i
    always @(*) begin
        case (current_state)
            FETCH:   next_state = DECODE;
            DECODE:  begin
                case (opcode)
                    OP_LOAD, OP_STORE: next_state = EXECUTE;
                    OP_BEQ, OP_BNE, OP_JMP: next_state = BRANCH;
                    default: next_state = EXECUTE;
                endcase
            end
            EXECUTE: begin
                case (opcode)
                    OP_LOAD, OP_STORE: next_state = MEM;
                    default: next_state = WB;
                endcase
            end
            MEM:     next_state = WB;
            WB:      next_state = FETCH;
            BRANCH:  next_state = FETCH;
            default: next_state = FETCH;
        endcase
    end

    // TÃ­n hiá»‡u Ä‘iá»u khiá»ƒn máº·c Ä‘á»‹nh
    always @(*) begin
        pc_enable = 0;
        pc_load = 0;
        ir_load = 0;
        rf_we = 0;
        mem_read = 0;
        mem_write = 0;
        alu_op = 4'b0000;
        sel_alu_src = 0;
        pc_branch = 0;
        state = current_state;

        case (current_state)
            FETCH: begin
                mem_read = 1;
                ir_load = 1;
                pc_enable = 1;
            end
            DECODE: begin
                // chuáº©n bá»‹ opcode
            end
            EXECUTE: begin
                case (opcode)
                    OP_ADD: alu_op = 4'b0000;
                    OP_SUB: alu_op = 4'b0001;
                    OP_AND: alu_op = 4'b0010;
                    OP_OR: alu_op = 4'b0011;
                    OP_XOR: alu_op = 4'b0100;
                    OP_MUL: alu_op = 4'b0101;
                    OP_SLL: alu_op = 4'b0110;
                    OP_SRL: alu_op = 4'b0111;
                    OP_SRA: alu_op = 4'b1000;
                    OP_FADD: alu_op = 4'b1001;
                    OP_FSUB: alu_op = 4'b1010;
                    OP_FMUL: alu_op = 4'b1011;
                    OP_LOAD, OP_STORE: alu_op = 4'b0000; // tÃ­nh Ä‘á»‹a chá»‰
                    OP_MVI: alu_op = 4'b0000; // dÃ¹ng ALU Ä‘á»ƒ chuyá»ƒn immediate
                    OP_MOV: alu_op = 4'b0000; // chuyá»ƒn dá»¯ liá»‡u
                    default: alu_op = 4'b0000;
                endcase

                sel_alu_src = (opcode == OP_LOAD || opcode == OP_STORE || opcode == OP_MVI || opcode == OP_SLL || opcode == OP_SRL || opcode == OP_SRA);

                if (opcode == OP_LOAD) mem_read = 1;
                if (opcode == OP_STORE) mem_write = 1;
            end
            MEM: begin
                // Äá»c hoáº·c ghi bá»™ nhá»›
                if (opcode == OP_LOAD)
                    mem_read = 1;
                else if (opcode == OP_STORE)
                    mem_write = 1;
            end
            WB: begin
                if (opcode == OP_ADD || opcode == OP_SUB || opcode == OP_AND ||
                    opcode == OP_OR || opcode == OP_XOR || opcode == OP_MUL ||
                    opcode == OP_SLL || opcode == OP_SRL || opcode == OP_SRA ||
                    opcode == OP_FADD || opcode == OP_FSUB || opcode == OP_FMUL ||
                    opcode == OP_MVI || opcode == OP_MOV || opcode == OP_LOAD)
                    rf_we = 1;
            end
            BRANCH: begin
                // Lá»‡nh nháº£y cÃ³ Ä‘iá»u kiá»‡n vÃ  khÃ´ng Ä‘iá»u kiá»‡n
                case (opcode)
                    OP_BEQ: if (zero_flag) pc_load = 1; // nháº£y náº¿u zero
                    OP_BNE: if (!zero_flag) pc_load = 1; // nháº£y náº¿u khÃ¡c zero
                    OP_JMP: pc_load = 1; // nháº£y vÃ´ Ä‘iá»u kiá»‡n
                endcase
            end
        endcase
    end
endmodule