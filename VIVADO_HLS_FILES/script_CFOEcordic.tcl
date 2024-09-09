############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 2015 Xilinx Inc. All rights reserved.
############################################################
open_project CFOEcordic
set_top CFOEcordic
add_files CFOEcordic.cpp
open_solution "solution1"
set_part {xc7k410tffg900-2}
create_clock -period 5 -name default
config_rtl -encoding onehot -reset state -reset_level high
config_interface -m_axi_offset off -register_io off
csynth_design
export_design -format ip_catalog
exit