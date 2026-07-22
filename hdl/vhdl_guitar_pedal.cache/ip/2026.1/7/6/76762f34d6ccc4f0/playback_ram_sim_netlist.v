// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (lin64) Build 6511674 Tue Jun 16 11:01:26 MDT 2026
// Date        : Wed Jul 22 15:52:41 2026
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
