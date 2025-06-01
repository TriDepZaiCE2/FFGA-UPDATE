module TopLevelCPU (
    input wire clk,
    input wire rst,
    input wire mode_run,         // Không còn ý nghĩa khi mô phỏng clock nhanh
    input wire step,             // Không còn ý nghĩa khi mô phỏng clock nhanh
    input wire [2:0] reg_select, // chọn thanh ghi để debug

    output wire [15:0] pc_out,
    output wire [15:0] instr_out,
    output wire [15:0] reg_debug,
    output wire zero_flag        // ✅ Thêm cổng zero_flag
);

    // ==== Clock Connection (dùng trực tiếp clock nhanh) ====
    wire cpu_clk;
    assign cpu_clk = clk;

    // ==== Wires ====
    wire [15:0] instr;
    wire [15:0] mem_out;
    wire [15:0] alu_result;
    wire [15:0] write_data;
    wire [15:0] alu_src_b;

    wire [2:0] rs = instr[8:6];
    wire [2:0] rt = instr[5:3];
    wire [2:0] rd = instr[11:9];
    wire [3:0] opcode = instr[15:12];
    wire [15:0] immediate = {13'd0, instr[2:0]}; // ví dụ immediate 3-bit
    wire [15:0] pc_jump_addr = {4'b0000, instr[11:0]};  // JMP

    wire pc_enable, pc_load, ir_load, rf_we, mem_read, mem_write, sel_alu_src;
    wire [3:0] alu_op;
    wire zero;
    wire [2:0] fsm_state;

    wire [15:0] op1;
    wire [15:0] op2;

    // ==== Program Counter ====
    ProgramCounter PC (
        .clk(cpu_clk),
        .rst(rst),
        .load(pc_load),
        .inc(pc_enable),
        .pc_in(pc_jump_addr),
        .pc_out(pc_out)
    );

    // ==== Memory (RAM) ====
    SimpleRAM RAM (
        .clk(cpu_clk),
        .we(mem_write),
        .addr(pc_out[5:0]),  // 64 dòng
        .din(op2),
        .dout(mem_out)
    );

    // ==== Instruction Register ====
    InstructionRegister IR (
        .clk(cpu_clk),
        .rst(rst),
        .load(ir_load),
        .instr_in(mem_out),
        .instr_out(instr)
    );

    // ==== Register File ====
    RegisterFile RF (
        .clk(cpu_clk),
        .we(rf_we),
        .raddr1(rs),
        .raddr2(rt),
        .waddr(rd),
        .wdata(write_data),
        .reg_select(reg_select),
        .rdata1(op1),
        .rdata2(op2),
        .reg_data_selected(reg_debug)
    );

    // ==== ALU ====
    MUX2to1 #(16) alu_src_mux (
        .sel(sel_alu_src),
        .in0(op2),
        .in1(immediate),
        .out(alu_src_b)
    );

    IntegerALU ALU (
        .op1(op1),
        .op2(alu_src_b),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(zero)
    );

    // ==== Writeback MUX (ALU or MEM) ====
    MUX2to1 #(16) wb_mux (
        .sel(opcode == 4'b1100),  // 1100 = LOAD
        .in0(alu_result),
        .in1(mem_out),
        .out(write_data)
    );

    // ==== Control Unit ====
    ControlUnit CU (
        .clk(cpu_clk),
        .rst(rst),
        .opcode(opcode),
        .state(fsm_state),
        .pc_enable(pc_enable),
        .pc_load(pc_load),
        .ir_load(ir_load),
        .rf_we(rf_we),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_op(alu_op),
        .sel_alu_src(sel_alu_src)
    );

    assign instr_out = instr;
    assign zero_flag = zero; // ✅ Gán zero_flag ra ngoài

endmodule
