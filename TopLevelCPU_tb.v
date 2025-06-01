`timescale 1ns / 1ps

module TopLevelCPU_tb;

    reg clk = 0;
    reg rst;
    reg mode_run;         // 1 = chạy liên tục, 0 = step mode
    reg step;             // xung bước khi step mode
    reg [2:0] reg_select; // chọn thanh ghi để debug (R0-R7)

    wire [15:0] pc_out;
    wire [15:0] instr_out;
    wire [15:0] reg_debug;
    wire zero_flag;       // Cờ zero từ ALU hoặc CPU

    // Clock 10ns (100 MHz)
    always #5 clk = ~clk;

    // Kết nối DUT (TopLevelCPU)
    TopLevelCPU dut (
        .clk(clk),
        .rst(rst),
        .mode_run(mode_run),
        .step(step),
        .reg_select(reg_select),
        .pc_out(pc_out),
        .instr_out(instr_out),
        .reg_debug(reg_debug)
        // .zero_flag(zero_flag) // Bỏ comment nếu CPU có tín hiệu này
    );

    integer i;  // khai báo biến vòng lặp ngoài

    initial begin
        $display("=== Bắt đầu mô phỏng CPU ===");

        rst = 1;
        mode_run = 0;
        step = 0;
        reg_select = 3'b000; // Xem thanh ghi R0
        #50;  // giữ reset 5 chu kỳ clock (50ns)
        rst = 0;

        // Nạp chương trình hex
        $readmemh("program.hex", dut.RAM.mem);

        // Chạy step mode: từng bước 20 bước
        // Chạy step mode: từng bước 24 bước, xem từng thanh ghi R0-R7 (3 lần vòng lặp)
mode_run = 0;
for (i = 0; i < 24; i = i + 1) begin
    reg_select = i % 8; // Lần lượt xem R0 đến R7
    step = 1;
    #10;
    step = 0;
    #40;

    $display("Step %0d | Time: %0t | PC: %h | IR: %h | Reg[%0d] = %h | Zero = %b",
        i, $time, pc_out, instr_out, reg_select, reg_debug, zero_flag);
end


        // Chạy liên tục
        mode_run = 1;
        $display("\n=== Chạy liên tục 2000ns ===");
        #2000;

        $display("Kết thúc chạy liên tục:");
        $display("PC = %h, IR = %h, Reg[%0d] = %h", pc_out, instr_out, reg_select, reg_debug);

        $finish;
    end

    // Theo dõi realtime
    initial begin
        $monitor("Time: %0t | PC: %h | IR: %h | Reg[%0d]: %h | Zero: %b",
            $time, pc_out, instr_out, reg_select, reg_debug, zero_flag);
    end

    // Xuất waveform dạng VCD
    initial begin
        $dumpfile("TopLevelCPU_tb.vcd");
        $dumpvars(0, TopLevelCPU_tb);
    end

endmodule