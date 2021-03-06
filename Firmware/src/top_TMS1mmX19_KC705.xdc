# KC705 configuration
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
# enable if ENABLE_TEN_GIG_ETH = false
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]

# 200MHz onboard diff clock
create_clock -name system_clock -period 5.0 [get_ports {SYS_CLK_P}]
# 156.25MHz
create_clock -name user_clock   -period 6.4 [get_ports {USER_CLK_P}]
create_clock -name si5324_clock -period 6.4 [get_ports {SI5324CLK_P}]
# 125MHz
create_clock -name sgmii_clock  -period 8.0 [get_ports {SGMIICLK_Q0_P}]

# PadFunction: IO_L12P_T1_MRCC_33
set_property -dict {PACKAGE_PIN AD12 IOSTANDARD DIFF_SSTL15 VCCAUX_IO DONTCARE} [get_ports {SYS_CLK_P}]
# PadFunction: IO_L12N_T1_MRCC_33
set_property -dict {PACKAGE_PIN AD11 IOSTANDARD DIFF_SSTL15 VCCAUX_IO DONTCARE} [get_ports {SYS_CLK_N}]

# Set DCI_CASCADE
set_property slave_banks {32 34} [get_iobanks 33]

# 156.25MHz clock, IOSTANDARD is overridden in IBUFDS
set_property -dict {PACKAGE_PIN K28 IOSTANDARD LVDS_25} [get_ports {USER_CLK_P}]
set_property -dict {PACKAGE_PIN K29 IOSTANDARD LVDS_25} [get_ports {USER_CLK_N}]

# 125MHz clock, for GTP/GTH/GTX
set_property PACKAGE_PIN G8 [get_ports {SGMIICLK_Q0_P}]
set_property PACKAGE_PIN G7 [get_ports {SGMIICLK_Q0_N}]

# External clock IC Si5324
set_property -dict {PACKAGE_PIN AE20 IOSTANDARD LVCMOS25} [get_ports SI5324_RSTn]
set_property PACKAGE_PIN L8 [get_ports SI5324CLK_P]
set_property PACKAGE_PIN L7 [get_ports SI5324CLK_N]

# clock domain interaction, must explictly specify all possible pairs.
# Command with only one `-group' parameter means the clock is asynchronous to all other, including generated from its own, clocks.
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks system_clock] -group [get_clocks -include_generated_clocks user_clock]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks system_clock] -group [get_clocks -include_generated_clocks si5324_clock]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks system_clock] -group [get_clocks -include_generated_clocks sgmii_clock]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks user_clock]   -group [get_clocks -include_generated_clocks si5324_clock]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks user_clock]   -group [get_clocks -include_generated_clocks sgmii_clock]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks si5324_clock] -group [get_clocks -include_generated_clocks sgmii_clock]

# seems we ran out of bufg's
# set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets global_clock_reset_inst/I]
# false path of resetter
set_false_path -from [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *GLOBAL_RST_reg*}] -filter {NAME =~ *C}]

#<-- LEDs, buttons and switches --<

# Bank: 33 - GPIO_SW_7 (CPU_RESET)
set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS15 VCCAUX_IO DONTCARE SLEW SLOW} [get_ports {SYS_RST}]
# LED:
# Bank: 33 - GPIO_LED_0_LS
set_property -dict {PACKAGE_PIN AB8 IOSTANDARD LVCMOS15 DRIVE 12 SLEW SLOW} [get_ports {LED8Bit[0]}]
# Bank: 33 - GPIO_LED_1_LS
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS15 DRIVE 12 SLEW SLOW} [get_ports {LED8Bit[1]}]
# Bank: 33 - GPIO_LED_2_LS
set_property -dict {PACKAGE_PIN AC9 IOSTANDARD LVCMOS15 DRIVE 12 SLEW SLOW} [get_ports {LED8Bit[2]}]
# Bank: 33 - GPIO_LED_3_LS
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS15 DRIVE 12 SLEW SLOW} [get_ports {LED8Bit[3]}]
# Bank: - GPIO_LED_4_LS
set_property -dict {PACKAGE_PIN AE26 IOSTANDARD LVCMOS25 DRIVE 12 SLEW SLOW} [get_ports {LED8Bit[4]}]
# Bank: - GPIO_LED_5_LS
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS25 DRIVE 12 SLEW SLOW} [get_ports {LED8Bit[5]}]
# Bank: - GPIO_LED_6_LS
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS25 DRIVE 12 SLEW SLOW} [get_ports {LED8Bit[6]}]
# Bank: - GPIO_LED_7_LS
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS25 DRIVE 12 SLEW SLOW} [get_ports {LED8Bit[7]}]
# GPIO_DIP_SW0
set_property -dict {PACKAGE_PIN Y29 IOSTANDARD LVCMOS25 SLEW SLOW} [get_ports {DIPSw4Bit[0]}]
# GPIO_DIP_SW1
set_property -dict {PACKAGE_PIN W29 IOSTANDARD LVCMOS25 SLEW SLOW} [get_ports {DIPSw4Bit[1]}]
# GPIO_DIP_SW2
set_property -dict {PACKAGE_PIN AA28 IOSTANDARD LVCMOS25 SLEW SLOW} [get_ports {DIPSw4Bit[2]}]
# GPIO_DIP_SW3
set_property -dict {PACKAGE_PIN Y28 IOSTANDARD LVCMOS25 SLEW SLOW} [get_ports {DIPSw4Bit[3]}]
# GPIO_SW_N : SW2
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS15 SLEW SLOW} [get_ports {BTN5Bit[0]}]
# GPIO_SW_E : SW3
set_property -dict {PACKAGE_PIN AG5 IOSTANDARD LVCMOS15 SLEW SLOW} [get_ports {BTN5Bit[1]}]
# GPIO_SW_S : SW4
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS15 SLEW SLOW} [get_ports {BTN5Bit[2]}]
# GPIO_SW_C : SW5
set_property -dict {PACKAGE_PIN G12 IOSTANDARD LVCMOS25 SLEW SLOW} [get_ports {BTN5Bit[3]}]
# GPIO_SW_W : SW6
set_property -dict {PACKAGE_PIN AC6 IOSTANDARD LVCMOS15 SLEW SLOW} [get_ports {BTN5Bit[4]}]

#>-- LEDs, buttons and switches -->

#<-- UART --<

set_property -dict {PACKAGE_PIN K24 IOSTANDARD LVCMOS25} [get_ports {USB_RX}]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS25} [get_ports {USB_TX}]

#>-- UART -->

#<-- control interface --<

set_false_path -from [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *control_interface_inst*sConfigReg_reg[*]}] -filter {NAME =~ *C}]
set_false_path -from [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *control_interface_inst*sPulseReg_reg[*]}] -filter {NAME =~ *C}]
set_false_path -to [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *control_interface_inst*sRegOut_reg[*]}] -filter {NAME =~ *D}]

#>-- control interface -->

#<-- SMA MGT --<

set_property PACKAGE_PIN K2 [get_ports SMA_MGT_TX_P]
set_property PACKAGE_PIN K1 [get_ports SMA_MGT_TX_N]
set_property PACKAGE_PIN K6 [get_ports SMA_MGT_RX_P]
set_property PACKAGE_PIN K5 [get_ports SMA_MGT_RX_N]

# set_property LOC GTXE2_CHANNEL_X0Y8 [get_cells aurora_64b66b_inst/aurora_64b66b_0_support_inst/aurora_64b66b_0_i/inst/aurora_64b66b_0_wrapper_i/aurora_64b66b_0_multi_gt_i/aurora_64b66b_0_gtx_inst/gtxe2_i]
set_property LOC GTXE2_COMMON_X0Y2 [get_cells aurora_64b66b_inst/aurora_64b66b_0_support_inst/gt_common_support/gtxe2_common_i]

#>-- SMA MGT -->

#<-- ten gig eth interface --<

# SFP
set_property -dict {PACKAGE_PIN Y20 IOSTANDARD LVCMOS25} [get_ports SFP_TX_DISABLE_N]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS25} [get_ports SFP_LOS_LS]
set_property PACKAGE_PIN H2 [get_ports SFP_TX_P]
set_property PACKAGE_PIN H1 [get_ports SFP_TX_N]
set_property PACKAGE_PIN G4 [get_ports SFP_RX_P]
set_property PACKAGE_PIN G3 [get_ports SFP_RX_N]

# False paths for async reset removal synchronizers
set_false_path -to [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *ten_gig_eth_pcs_pma_core_support_layer_i/*shared*sync1_r_reg*}] -filter {NAME =~ *PRE}]
set_false_path -to [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *ten_gig_eth_pcs_pma_core_support_layer_i/*shared*sync1_r_reg*}] -filter {NAME =~ *CLR}]

# Constraint for GT location
#set_property LOC GTXE2_CHANNEL_X0Y10 [get_cells ten_gig_eth_pcs_pma_core_support_layer_i/ten_gig_eth_pcs_pma_i/*/gt0_gtwizard_10gbaser_multi_gt_i/gt0_gtwizard_10gbaser_i/gtxe2_i]
set_property LOC GTXE2_COMMON_X0Y2 [get_cells ten_gig_eth_cores.ten_gig_eth_inst/ten_gig_eth_pcs_pma_inst/ten_gig_eth_pcs_pma_core_support_layer_i/ten_gig_eth_pcs_pma_gt_common_block/gtxe2_common_0_i]

# create_generated_clock -name ddrclock -divide_by 1 -invert -source [get_pins *rx_clk_ddr/C] [get_ports xgmii_rx_clk]
# set_output_delay -max 1.500 -clock [get_clocks ddrclock] [get_ports * -filter {NAME =~ *xgmii_rxd*}]
# set_output_delay -min -1.500 -clock [get_clocks ddrclock] [get_ports * -filter {NAME =~ *xgmii_rxd*}]
# set_output_delay -max 1.500 -clock [get_clocks ddrclock] [get_ports * -filter {NAME =~ *xgmii_rxc*}]
# set_output_delay -min -1.500 -clock [get_clocks ddrclock] [get_ports * -filter {NAME =~ *xgmii_rxc*}]

#>-- ten gig eth interface -->

#<-- gigabit eth interface --<

set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS25} [get_ports PHY_RESET_N]
set_property -dict {PACKAGE_PIN J21 IOSTANDARD LVCMOS25} [get_ports MDIO]
set_property -dict {PACKAGE_PIN R23 IOSTANDARD LVCMOS25} [get_ports MDC]
#
set_property -dict {PACKAGE_PIN U28 IOSTANDARD LVCMOS25} [get_ports RGMII_RXD[3]]
set_property -dict {PACKAGE_PIN T25 IOSTANDARD LVCMOS25} [get_ports RGMII_RXD[2]]
set_property -dict {PACKAGE_PIN U25 IOSTANDARD LVCMOS25} [get_ports RGMII_RXD[1]]
set_property -dict {PACKAGE_PIN U30 IOSTANDARD LVCMOS25} [get_ports RGMII_RXD[0]]
set_property -dict {PACKAGE_PIN L28 IOSTANDARD LVCMOS25} [get_ports RGMII_TXD[3]]
set_property -dict {PACKAGE_PIN M29 IOSTANDARD LVCMOS25} [get_ports RGMII_TXD[2]]
set_property -dict {PACKAGE_PIN N25 IOSTANDARD LVCMOS25} [get_ports RGMII_TXD[1]]
set_property -dict {PACKAGE_PIN N27 IOSTANDARD LVCMOS25} [get_ports RGMII_TXD[0]]
set_property -dict {PACKAGE_PIN M27 IOSTANDARD LVCMOS25} [get_ports RGMII_TX_CTL]
set_property -dict {PACKAGE_PIN K30 IOSTANDARD LVCMOS25} [get_ports RGMII_TXC]
set_property -dict {PACKAGE_PIN R28 IOSTANDARD LVCMOS25} [get_ports RGMII_RX_CTL]
set_property -dict {PACKAGE_PIN U27 IOSTANDARD LVCMOS25} [get_ports RGMII_RXC]

# already set in ip / tri_mode_ethernet_mac_0.xdc
# create_clock -period 8 [get_ports RGMII_RXC]
set rx_clk_var [get_clocks -of [get_ports RGMII_RXC]]
set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks -of_objects [get_ports RGMII_RXC]] -group [get_clocks -include_generated_clocks sgmii_clock]

set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp [get_cells -hier -filter {name =~ *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_idelayctrl_common_i}]

# If TEMAC timing fails, use the following to relax the requirements
# The RGMII receive interface requirement allows a 1ns setup and 1ns hold - this is met but only just so constraints are relaxed
#set_input_delay -clock [get_clocks tri_mode_ethernet_mac_0_rgmii_rx_clk] -max -1.5 [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]
#set_input_delay -clock [get_clocks tri_mode_ethernet_mac_0_rgmii_rx_clk] -min -2.8 [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]
#set_input_delay -clock [get_clocks tri_mode_ethernet_mac_0_rgmii_rx_clk] -clock_fall -max -1.5 -add_delay [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]
#set_input_delay -clock [get_clocks tri_mode_ethernet_mac_0_rgmii_rx_clk] -clock_fall -min -2.8 -add_delay [get_ports {rgmii_rxd[*] rgmii_rx_ctl}]

# the following properties can be adjusted if requried to adjust the IO timing
# the value shown (12) is the default used by the IP
# increasing this value will improve the hold timing but will also add jitter.
# set_property IDELAY_VALUE 12 [get_cells -hier -filter {name =~ *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_i/*/rgmii_interface/delay_rgmii_rx* *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_i/*/rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]
set_property IDELAY_VALUE 10 [get_cells -hier -filter {name =~ *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_i/*/rgmii_interface/delay_rgmii_rx*}]
set_property IDELAY_VALUE 10 [get_cells -hier -filter {name =~ *trimac_fifo_block/trimac_sup_block/tri_mode_ethernet_mac_i/*/rgmii_interface/rxdata_bus[*].delay_rgmii_rx*}]

# FIFO Clock Crossing Constraints
# control signal is synched separately so this is a false path
set_max_delay -from [get_cells -hier -filter {name =~ *tx_fifo_i/rd_addr_txfer_reg[*]}] -to [get_cells -hier -filter {name =~ *fifo*wr_rd_addr_reg[*]}] 6 -datapath_only
set_max_delay -from [get_cells -hier -filter {name =~ *rx_fifo_i/rd_addr_reg[*]}] -to [get_cells -hier -filter {name =~ *fifo*wr_rd_addr_reg[*]}] 6 -datapath_only
set_max_delay -from [get_cells -hier -filter {name =~ *rx_fifo_i/wr_store_frame_tog_reg}] -to [get_cells -hier -filter {name =~ *fifo_i/resync_wr_store_frame_tog/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells -hier -filter {name =~ *rx_fifo_i/update_addr_tog_reg}] -to [get_cells -hier -filter {name =~ *rx_fifo_i/sync_rd_addr_tog/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells -hier -filter {name =~ *tx_fifo_i/wr_frame_in_fifo_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_wr_frame_in_fifo/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells -hier -filter {name =~ *tx_fifo_i/wr_frames_in_fifo_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_wr_frames_in_fifo/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells -hier -filter {name =~ *tx_fifo_i/frame_in_fifo_valid_tog_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_fif_valid_tog/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells -hier -filter {name =~ *tx_fifo_i/rd_txfer_tog_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_rd_txfer_tog/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells -hier -filter {name =~ *tx_fifo_i/rd_tran_frame_tog_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_rd_tran_frame_tog/data_sync_reg0}] 6 -datapath_only

# False paths for async reset removal synchronizers
set_false_path -to [get_pins -of_objects [get_cells -hierarchical -filter {NAME =~ *tri_mode_ethernet*reset_sync*}] -filter {NAME =~ *PRE}]

#>-- gigabit eth interface -->

# I2C
set_property -dict {PACKAGE_PIN K21 IOSTANDARD LVCMOS25} [get_ports I2C_SCL]
set_property -dict {PACKAGE_PIN L21 IOSTANDARD LVCMOS25} [get_ports I2C_SDA]

# SMA
set_property -dict {PACKAGE_PIN L25 IOSTANDARD LVCMOS25} [get_ports USER_SMA_CLOCK_P]
set_property -dict {PACKAGE_PIN K25 IOSTANDARD LVCMOS25} [get_ports USER_SMA_CLOCK_N]
set_property -dict {PACKAGE_PIN Y23 IOSTANDARD LVCMOS25} [get_ports USER_SMA_GPIO_P]
set_property -dict {PACKAGE_PIN Y24 IOSTANDARD LVCMOS25} [get_ports USER_SMA_GPIO_N]

# Local Variables:
# mode: tcl
# End:
