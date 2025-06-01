module FloatingPointALU (
    input wire [15:0] op1,
    input wire [15:0] op2,
    input wire [3:0] alu_op,    // 4'b1001:FADD, 4'b1010:FSUB, 4'b1011:FMUL
    output reg [15:0] result,
    output wire zero
);

    // Format
    // sign: bit 15
    // exponent: bits 14-10 (5 bits), bias = 15
    // mantissa: bits 9-0, normalized with implicit 1 (1.mantissa)

    // Local parameters for ALU opcodes
    localparam FADD = 4'b1001, FSUB = 4'b1010, FMUL = 4'b1011;

    // Extract fields
    wire sign1 = op1[15];
    wire sign2 = op2[15];
    wire [4:0] exp1 = op1[14:10];
    wire [4:0] exp2 = op2[14:10];
    wire [10:0] mant1 = {1'b1, op1[9:0]}; // implicit leading 1
    wire [10:0] mant2 = {1'b1, op2[9:0]};

    reg sign_res;
    reg [4:0] exp_res;
    reg [11:0] mant_res; // 12 bits for intermediate calc (one extra bit)
    reg [11:0] mant_sum, mant_diff;
    reg [21:0] mant_mul; // 22 bits for mantissa multiply (11x11)
    reg [10:0] mant_final;
    reg [4:0] exp_final;

    // Zero detection: result is zero if all bits zero except sign
    assign zero = (result[14:0] == 0);

    // Helper: normalize mantissa and adjust exponent
    task normalize;
        input [11:0] mant_in;
        input [4:0] exp_in;
        output [10:0] mant_out;
        output [4:0] exp_out;
        reg [11:0] mant_norm;
        reg [4:0] exp_norm;
    begin
        mant_norm = mant_in;
        exp_norm = exp_in;

        // Normalize left if MSB < bit 11
        while (mant_norm[11] == 0 && exp_norm > 0) begin
            mant_norm = mant_norm << 1;
            exp_norm = exp_norm - 1;
        end

        // Round mantissa to 11 bits (drop bit 0)
        mant_out = mant_norm[11:1];
        exp_out = exp_norm;
    end
    endtask

    always @(*) begin
        case (alu_op)
            FADD, FSUB: begin
                // Align exponent
                reg [4:0] exp_diff;
                reg [10:0] mant1_shift, mant2_shift;
                reg [11:0] mant_calc; // 12 bits for sum/diff
                reg sign_op2;

                if (exp1 > exp2) begin
                    exp_diff = exp1 - exp2;
                    mant1_shift = mant1;
                    mant2_shift = mant2 >> exp_diff;
                    exp_res = exp1;
                end else begin
                    exp_diff = exp2 - exp1;
                    mant1_shift = mant1 >> exp_diff;
                    mant2_shift = mant2;
                    exp_res = exp2;
                end

                // Determine operation sign for op2
                sign_op2 = (alu_op == FSUB) ? ~sign2 : sign2;

                if (sign1 == sign_op2) begin
                    // Same sign -> add mantissa
                    mant_calc = mant1_shift + mant2_shift;
                    sign_res = sign1;
                    // Normalize result
                    if (mant_calc[11] == 1) begin
                        // Overflow -> shift right and increase exponent
                        mant_res = mant_calc >> 1;
                        exp_res = exp_res + 1;
                    end else begin
                        mant_res = mant_calc;
                    end
                end else begin
                    // Different signs -> subtract mantissa
                    if (mant1_shift >= mant2_shift) begin
                        mant_calc = mant1_shift - mant2_shift;
                        sign_res = sign1;
                        exp_res = exp_res;
                    end else begin
                        mant_calc = mant2_shift - mant1_shift;
                        sign_res = sign_op2;
                        exp_res = exp_res;
                    end
                    mant_res = mant_calc;
                end

                // Normalize mantissa and exponent
                normalize(mant_res, exp_res, mant_final, exp_final);

                // Pack result
                result = {sign_res, exp_final, mant_final[9:0]};
            end

            FMUL: begin
                // Multiply mantissa (11 bits * 11 bits = 22 bits)
                mant_mul = mant1 * mant2;
                // Add exponent, remove bias twice, then add bias once
                exp_res = exp1 + exp2 - 5'd15;
                sign_res = sign1 ^ sign2;

                // Normalize mantissa: mant_mul is 22 bits, take bits [21:11] as normalized mantissa
                if (mant_mul[21] == 1) begin
                    // Mantissa overflow, shift right 1 and increment exp
                    mant_res = mant_mul[21:10];
                    exp_res = exp_res + 1;
                end else begin
                    mant_res = mant_mul[20:9];
                end

                // Normalize (rare case)
                normalize(mant_res, exp_res, mant_final, exp_final);

                result = {sign_res, exp_final, mant_final[9:0]};
            end

            default: begin
                // Không hỗ trợ, trả về 0
                result = 16'd0;
            end
        endcase
    end

endmodule