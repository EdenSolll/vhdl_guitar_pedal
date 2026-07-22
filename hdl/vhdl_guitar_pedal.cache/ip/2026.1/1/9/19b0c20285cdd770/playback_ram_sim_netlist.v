// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (lin64) Build 6511674 Tue Jun 16 11:01:26 MDT 2026
// Date        : Tue Jul 21 14:29:17 2026
// Host        : jet.csh.rit.edu running 64-bit Rocky Linux 9.8 (Blue Onyx)"
RELEASE_TYPE="stable
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ playback_ram_sim_netlist.v
// Design      : playback_ram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "playback_ram,blk_mem_gen_v8_4_13,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_13,Vivado 2026.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_13 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 29104)
`pragma protect data_block
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
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
