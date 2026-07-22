vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xpm
vlib modelsim_lib/msim/blk_mem_gen_v8_4_13
vlib modelsim_lib/msim/xil_defaultlib

vmap xpm modelsim_lib/msim/xpm
vmap blk_mem_gen_v8_4_13 modelsim_lib/msim/blk_mem_gen_v8_4_13
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -mfcu  -sv "+incdir+../../../../../../xilinx_host/Xilinx/2026.1/data/rsb/busdef" \
"/users/u31/sol/xilinx_host/Xilinx/2026.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/users/u31/sol/xilinx_host/Xilinx/2026.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/users/u31/sol/xilinx_host/Xilinx/2026.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_13 -64 -incr -mfcu  "+incdir+../../../../../../xilinx_host/Xilinx/2026.1/data/rsb/busdef" \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../../../xilinx_host/Xilinx/2026.1/data/rsb/busdef" \
"../../../../vhdl_guitar_pedal.gen/sources_1/ip/playback_ram/sim/playback_ram.v" \

vlog -work xil_defaultlib \
"glbl.v"

