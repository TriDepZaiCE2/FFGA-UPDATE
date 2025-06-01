onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /TopLevelCPU_tb/clk
add wave -noupdate /TopLevelCPU_tb/rst
add wave -noupdate /TopLevelCPU_tb/mode_run
add wave -noupdate /TopLevelCPU_tb/step
add wave -noupdate /TopLevelCPU_tb/reg_select
add wave -noupdate /TopLevelCPU_tb/dut/pc_out
add wave -noupdate /TopLevelCPU_tb/dut/instr_out
add wave -noupdate /TopLevelCPU_tb/dut/reg_debug
add wave -noupdate /TopLevelCPU_tb/dut/CU/state
add wave -noupdate /TopLevelCPU_tb/dut/CU/pc_enable
add wave -noupdate /TopLevelCPU_tb/dut/CU/pc_load
add wave -noupdate /TopLevelCPU_tb/dut/CU/ir_load
add wave -noupdate /TopLevelCPU_tb/dut/CU/rf_we
add wave -noupdate /TopLevelCPU_tb/dut/CU/mem_read
add wave -noupdate /TopLevelCPU_tb/dut/CU/mem_write
add wave -noupdate /TopLevelCPU_tb/dut/CU/alu_op
add wave -noupdate /TopLevelCPU_tb/dut/CU/sel_alu_src
add wave -noupdate /TopLevelCPU_tb/dut/RF/rdata1
add wave -noupdate /TopLevelCPU_tb/dut/RF/rdata2
add wave -noupdate /TopLevelCPU_tb/dut/RF/wdata
add wave -noupdate /TopLevelCPU_tb/dut/RF/raddr1
add wave -noupdate /TopLevelCPU_tb/dut/RF/raddr2
add wave -noupdate /TopLevelCPU_tb/dut/RF/waddr
add wave -noupdate /TopLevelCPU_tb/dut/ALU/op1
add wave -noupdate /TopLevelCPU_tb/dut/ALU/op2
add wave -noupdate /TopLevelCPU_tb/dut/ALU/result
add wave -noupdate /TopLevelCPU_tb/dut/ALU/zero
add wave -noupdate /TopLevelCPU_tb/dut/RAM/addr
add wave -noupdate /TopLevelCPU_tb/dut/RAM/din
add wave -noupdate /TopLevelCPU_tb/dut/RAM/dout
add wave -noupdate /TopLevelCPU_tb/dut/RAM/we
add wave -noupdate /TopLevelCPU_tb/dut/PC/pc_out
add wave -noupdate /TopLevelCPU_tb/dut/IR/instr_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2100 ns}
