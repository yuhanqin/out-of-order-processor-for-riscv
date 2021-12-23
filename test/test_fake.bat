iverilog -g2012 -o ./wave_fake ./tb_fake.v ../lab2_proc/ProcAltVRTL.v ^
../lab2_proc/PRF.v ^
../lab2_proc/aRAT.v ^
../lab2_proc/RAT.v ^
../lab2_proc/freelist_RAT.v ^
../lab2_proc/iq_alu.v ^
../lab2_proc/iq_jmp.v ^
../lab2_proc/ROB.v ^
../lab2_proc/stage_if.v ^
../lab2_proc/latch_if_id.v ^
../lab2_proc/TinyRV2InstVRTL.v ^
../lab2_proc/TinyRV2InstVRTL.v ^
../lab2_proc/latch_id_renaming.v ^
../lab2_proc/stage_renaming.v ^
../lab2_proc/latch_renaming_dispatch.v ^
../lab2_proc/stage_dispatch.v ^
../lab2_proc/stage_rfread_alu.v ^
../lab2_proc/stage_rfread_jmp.v ^
../lab2_proc/stage_ex_alu.v ^
../lab2_proc/stage_ex_jmp.v ^
../lab2_proc/stage_wb.v 
vvp -n ./wave_fake
gtkwave ./wave_fake.vcd