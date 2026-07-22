// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (lin64) Build 6511674 Tue Jun 16 11:01:26 MDT 2026
// Date        : Wed Jul 22 15:52:42 2026
// Host        : jet.csh.rit.edu running 64-bit Rocky Linux 9.8 (Blue Onyx)"
RELEASE_TYPE="stable
// Command     : write_verilog -force -mode funcsim
//               /users/u31/sol/vhdl_guitar_pedal/hdl/vhdl_guitar_pedal.gen/sources_1/ip/playback_ram/playback_ram_sim_netlist.v
// Design      : playback_ram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "playback_ram,blk_mem_gen_v8_4_13,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_13,Vivado 2026.1" *) 
(* NotValidForBitStream *)
module playback_ram
   (clka,
    ena,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [2:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [23:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_mode = "slave BRAM_PORTB" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [9:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [23:0]doutb;

  wire [9:0]addra;
  wire [9:0]addrb;
  wire clka;
  wire [23:0]dina;
  wire [23:0]doutb;
  wire ena;
  wire enb;
  wire [2:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [23:0]NLW_U0_douta_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [23:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "8" *) 
  (* C_COMMON_CLK = "1" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     5.178975 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "playback_ram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEMORY_OPTIMIZATION = "1" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "1024" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "24" *) 
  (* C_READ_WIDTH_B = "24" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "1" *) 
  (* C_USE_BYTE_WEB = "1" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "3" *) 
  (* C_WEB_WIDTH = "3" *) 
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "1024" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "READ_FIRST" *) 
  (* C_WRITE_WIDTH_A = "24" *) 
  (* C_WRITE_WIDTH_B = "24" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  playback_ram_blk_mem_gen_v8_4_13 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[23:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[23:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0}),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web({1'b0,1'b0,1'b0}));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2026.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
kZgFhM2d/jlaPzxpf6XHBAvY3udA2n90sVrL5ios3dCU6DHMG01BptGv7AEkMGv1nBWc9wOv8Ao5
MO+RYUWfJloAgvE9oz3EJHrmhQHk1oDdQ/EpnejIRbEZCjmfHUEI21gyKS6oLdkyx2gHs3HX+wks
75MnE8jDP5XEe0wRk70=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CotVlRfEkpF8whBUKgocdcjhKyrcMEGPZvHkGVHISj+GCXwa3Gdeme07eFJpz/ZotBRm0H+nvk9U
c+cu76zAYcGZA4BB8k5S5CN9te+cdcMud4cLzxM3NWHdGuMLRnzIf+YH7ADhhyN/3GRT3GlBC9un
8gg46/rnawNHyJnmhY8sUwhYJFSC6Zp+YpCreJEMMsSSR0D4CM0VZx3eT8IWhFsOz6ekLOhifcRk
JdWdOdywGnTqpOq97/LmRPbfEGBiYB5YDEex+rP8S+WkdfZSRXRcMfIMDifCL2F9vyvALaXXU/HK
kczWE+R+OoMRMGX7ipHLpx7Q08Lk2uu9pJiE9Q==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
tZnJNN2Qmv8npxJcsUh1oNo5AcwWv4Go3b6+WqtB8cYERd3tAiuYpzM9E8x0/NSOgU2lO+XGGWqL
PXOFRGE6+vT9Uw+MMZ7IhiFhNUxakIUv/kmA/Kpo9+5Y8aWN581krtWN9KT8/ccdMg7//qZ5aT8D
c323EB+407vCn2c62Ug=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
KKZGVVr56cxydgpa10+BIppw9vsPylE78OMiTW7WTk1ML6QnGGk6Ufm83Q5BYCGjf79wKt+EDVr2
Faz5O4p7NqDjYc+6UH+r3tYhzg8ax3QQ/lL0h4ROXjjznYZN4GT3jpmEVd5M9uz0VZRUklNggvzs
aHgFve9gt7F5cG1cwxr+CFWUfKcsH6XCTrNM3UP1/Ye33LxT6qzhZVuCb4w1zybXO9K1HZRARNeE
XmaMeB1MHLiswqCVSWCi3ahqMoTIL8Nkwb7LISvYxN88qxMca/sR/Y59W48DrGDRBBzZ48hIpVXK
9wpPb6wF5zA03FsVqRSc5JxQzfKhTSxAnXSVMA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ywVnQUL8hRlFZUGP9Kpsx7UfX2m6K2oMp1dIrzsl1e7ahG0jDMr0uZjciYiQvVpl++f7jBR3qTGo
/E63+MEs3aH3oSmrd0H/Etz+j2FU3ASZNwvS98uACXUBPzAeEwFUuJ9/8jqLJsiNybXigf8spDDy
xB/JnUfJl4/mmyClxySXyscK3aOnErzAZ9B9i8PeHPttmRn6onzR+wukt29Z0ETtVcyKKb9JQeO5
4ipDn79/o1IPYLzFyyiP5/oKUP/4zmX/6pbiO6bdzi2kdrhBtRE6ztlUGTI0WBHPOO+nZcIlF5S4
jckQo17l4fcqBJC8p6S7fb4eyfp+IU8PFj6wDQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2026.1-2030.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GUQu/hEzrCx6whrKX9cnRKGYwu/EkGwKC+5ZIAahvY/upngQfvNVWyz4hLS5Q+jQdoupTTPWruY8
5QnccTfRLO/UNkPmbg8atB4asCjrKgLIhzPG1pqhoH9BtKKby74jLu4vyRH0Hk9XOXkAXLos7eBX
Nudw/vzxy74RzWXjstE5NRhMqfXi+jrP7VLV+NT9AN7PZQ8SsVifNwD2P2HwGzqQT/beYW8LvNbr
bRbtDAwcCcJomfkUvNb4pYE7MuJK22aox2ar8nUAviLnxnmy/ASVSGou0mCxgkZKW88UP70HDIhl
aueFj0IyK2H6IPJM9GCgGAwEeA0w0rzI7faPlg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
YHSFaIRKyhIVU+ZO/EyZESP/nTM928AcWJGbKx6Nxkm8PEl7yBr3z8S8G0MbToKUpAO14Ei843y2
QSES26grec+g5bQHTjG1w5mR0gi3IRbGAT8ctIbI6qe8HxLmMViuDiYNb2JRHPBhpGjx1o9s0K53
1FVtSLcIMPdvZ6vGzYYlswxXiOA7D0qdnIFeJXb/6BzeYM/ZSO3kXFNYZVuhaNU0AcFxQzxAe/sK
lx5QdNGpyfexd+UnTCdHIul+eFr91+gTUaOVHDR7qvAiX+c3k+nbn4d1gBOExbPG5xXxO9QzpWZH
pkGcv5/2mmPVGGa6bx1rd+/wxxqJYs2r4GBQhQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
SuOFRD2tIt83R5vOz6fwY9Uj1WJom9jlw00FrgpAa9zzHh8NDaN1pvHliEpw0RI/EXGai+RqFTtv
ODI2Qchq2R+Ohalo8v9B//WzHrQEoZOqY8ExEpKNbhp2IJiwsZKz4enjUze+QgFiZFFBQSuEtvRx
6PvI0tTjXp4d4nJZP6HbKHFzj2SEggoTEvkYm2QqrEIRu3HQ9cXOaM9B77eWbQvHHj8yGYRw4A5u
Grwq5j0VzH8/eaysSLlB32jy65hpz1XiigFMnu01jNTA/Fh2qkMYpJeiiityiftiHDGBeEi78AUU
DCNlSbHo0NgXbyxwgV82OqxM0bTJUXK6Gh6/8xgla6TEAub1vTzQH5Uche+S6QnV24o6ll5HwYyV
RoBr27Aj0mceN3MNqSTnsoEMthFh1MLmp0imxgG/6NjNFKABJTDuaGPLE9XjU59knvKP1VKk9Fp5
rI7Y3IvGFhu0bHKEhV60LLTosXWr9gzS3uKCMCb0T38cAx5GX6FcChb0

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
WC3gV9hDsJlJGDWXD9/OXXBzEn6vsr7+oOdKz7gm4Rk/FFR50y93jhYmcWd1K2InGg42AOhIHo2Z
TvhSjky9Smc6kaftDv0qbAD/y3awUgVWMhvanfJnlEuAZfoFEJGwGr9jYg55AvfvuX1rQTtKoUFi
ACZ7pJVaLnkCKFVPNuhRAQxCs7KLW7cG1ALcdtOdnRrcG3bh4dHzct2JzL2/VK03C8gPKr3uM6DE
9O0lltoTf/AzP3jfV2LZekZChJx+UY4WWMhnVCiQKoa9voReSAKbrxHl/hqJvWQiYa6CFpABdUpX
fjEHVkVIdpnVpslTz0sOxXMvpxX7F8T6O5KvOA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Iqc6J3NDm5J0Ukvjev1H/S4Q4RmJahnBq0A8nClyXeu33t4xanh+aGq3+WcR0KQRtSZvQDrbXWvy
VpRaHzQu/lgwraB5780gv5qhqt1D3uYyerl5fx6fl2ozWlr8yZKs/qaDlktEWGF0MPUsJuYE6ZcM
72yOpO5/ynMUgwJs9FVcK5pRasgkXgOUeN1tA6mmLAiYCor4CtxoB2CGVa0z1Xsrai6cNrXCDd8I
D1f10kYi4ICIsU7uhC3hLMQ66OSpgzGDdHUq52hVB7ESc7B/fk4nrcm0mSK0cPc0un7O8vvvykdb
kA7qDovHJqWd0VWle0m3J0DvA2pKJUU4AmG51A==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Y+N5GKAwdOuN9nS/lU52Y4ZNhFpP5Eg6jiLvP1rQk7jt7v332HLd3dDgIcKOvTZ+cT2qc/fEH3km
qRW6R6MDwiTEv5NDgR96180FbWhHKmyQ/AZmvgAhcSnKARj27eDEkTFcUfN+RgRNycooCPjQ2LvE
RAHSYS+ob7G8GxymUfgoG2pJ1BZF8n98Yv+Aj+fx3pPWyFx63XYQu0VIla5KV1WkhDxakW9v4pJh
kWzHMGwdhrs9q2KAQjFgZaDXVv5oFd/wcJWXkvkbsRdm3Ok9s3OwuaW9LsKnBGReVg6ii5BR+7Za
9w0kFZHcWjmf5ns8L/rFEzHcIGqE15ZlLKYekg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 29072)
`pragma protect data_block
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
ju4=
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
