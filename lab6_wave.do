onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb
add wave -noupdate /cpu_tb/clk
add wave -noupdate /cpu_tb/err
add wave -noupdate /cpu_tb/in
add wave -noupdate /cpu_tb/load
add wave -noupdate /cpu_tb/reset
add wave -noupdate /cpu_tb/s
add wave -noupdate /cpu_tb/sim_N
add wave -noupdate /cpu_tb/sim_V
add wave -noupdate /cpu_tb/sim_Z
add wave -noupdate /cpu_tb/sim_out
add wave -noupdate /cpu_tb/sim_w
add wave -noupdate -divider FSM
add wave -noupdate /cpu_tb/DUT/FSM/s
add wave -noupdate /cpu_tb/DUT/FSM/reset
add wave -noupdate /cpu_tb/DUT/FSM/clk
add wave -noupdate /cpu_tb/DUT/FSM/opcode
add wave -noupdate /cpu_tb/DUT/FSM/op
add wave -noupdate /cpu_tb/DUT/FSM/write
add wave -noupdate /cpu_tb/DUT/FSM/loada
add wave -noupdate /cpu_tb/DUT/FSM/loadb
add wave -noupdate /cpu_tb/DUT/FSM/loadc
add wave -noupdate /cpu_tb/DUT/FSM/loads
add wave -noupdate /cpu_tb/DUT/FSM/asel
add wave -noupdate /cpu_tb/DUT/FSM/bsel
add wave -noupdate /cpu_tb/DUT/FSM/nsel
add wave -noupdate /cpu_tb/DUT/FSM/vsel
add wave -noupdate /cpu_tb/DUT/FSM/w
add wave -noupdate /cpu_tb/DUT/FSM/present_state
add wave -noupdate -divider DP
add wave -noupdate /cpu_tb/DUT/DP/mdata
add wave -noupdate /cpu_tb/DUT/DP/sximm8
add wave -noupdate /cpu_tb/DUT/DP/sximm5
add wave -noupdate /cpu_tb/DUT/DP/write
add wave -noupdate /cpu_tb/DUT/DP/clk
add wave -noupdate /cpu_tb/DUT/DP/loada
add wave -noupdate /cpu_tb/DUT/DP/loadb
add wave -noupdate /cpu_tb/DUT/DP/loadc
add wave -noupdate /cpu_tb/DUT/DP/loads
add wave -noupdate /cpu_tb/DUT/DP/asel
add wave -noupdate /cpu_tb/DUT/DP/bsel
add wave -noupdate /cpu_tb/DUT/DP/vsel
add wave -noupdate /cpu_tb/DUT/DP/writenum
add wave -noupdate /cpu_tb/DUT/DP/readnum
add wave -noupdate /cpu_tb/DUT/DP/shift
add wave -noupdate /cpu_tb/DUT/DP/ALUop
add wave -noupdate /cpu_tb/DUT/DP/N
add wave -noupdate /cpu_tb/DUT/DP/Z
add wave -noupdate /cpu_tb/DUT/DP/V
add wave -noupdate /cpu_tb/DUT/DP/datapath_out
add wave -noupdate /cpu_tb/DUT/DP/data_in
add wave -noupdate /cpu_tb/DUT/DP/data_out
add wave -noupdate /cpu_tb/DUT/DP/fromAtoMux6
add wave -noupdate /cpu_tb/DUT/DP/fromBtoShifter
add wave -noupdate /cpu_tb/DUT/DP/sout
add wave -noupdate /cpu_tb/DUT/DP/Ain
add wave -noupdate /cpu_tb/DUT/DP/Bin
add wave -noupdate /cpu_tb/DUT/DP/out
add wave -noupdate /cpu_tb/DUT/DP/PC
add wave -noupdate /cpu_tb/DUT/DP/zero
add wave -noupdate /cpu_tb/DUT/DP/overflow
add wave -noupdate /cpu_tb/DUT/DP/negative
add wave -noupdate -divider REG
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/data_in
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/writenum
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/readnum
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/write
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/clk
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/data_out
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/writeNumOneHot
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R0
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R1
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R2
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R3
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R4
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R5
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R6
add wave -noupdate /cpu_tb/DUT/DP/REGFILE/R7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {371 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 187
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
WaveRestoreZoom {364 ps} {502 ps}
