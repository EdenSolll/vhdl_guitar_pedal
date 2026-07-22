transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/blk_mem_gen_v8_4_13
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap blk_mem_gen_v8_4_13 riviera/blk_mem_gen_v8_4_13
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  "+incdir+../../../../../../xilinx_host/Xilinx/2026.1/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_13 -l xil_defaultlib \
"/users/u31/sol/xilinx_host/Xilinx/2026.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/users/u31/sol/xilinx_host/Xilinx/2026.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  \
"/users/u31/sol/xilinx_host/Xilinx/2026.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_13  -v2k5 "+incdir+../../../../../../xilinx_host/Xilinx/2026.1/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_13 -l xil_defaultlib \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../../xilinx_host/Xilinx/2026.1/data/rsb/busdef" -l xpm -l blk_mem_gen_v8_4_13 -l xil_defaultlib \
"../../../../vhdl_guitar_pedal.gen/sources_1/ip/playback_ram/sim/playback_ram.v" \

vlog -work xil_defaultlib \
"glbl.v"

