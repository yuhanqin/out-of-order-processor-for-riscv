iverilog -o ./wave_freelist ./tb_freelist.v ../lab2_proc/freelist_RAT.v
vvp -n ./wave_freelist
gtkwave ./wave_freelist.vcd