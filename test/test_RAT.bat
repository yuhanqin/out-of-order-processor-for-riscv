iverilog -o ./wave_RAT ./tb_RAT.v ../lab2_proc/RAT.v
vvp -n ./wave_RAT
gtkwave ./wave_RAT.vcd