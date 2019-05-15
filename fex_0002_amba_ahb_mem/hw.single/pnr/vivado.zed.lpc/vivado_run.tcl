#---------------------------------------------------------
if {[info exists env(VIVADO_VER)] == 0} {
     set VIVADO_VER vivado.2017.4
} else {
     set VIVADO_VER $::env(VIVADO_VER)
}
if {[info exists env(CONFMC_HOME)] == 0} {
     set CONFMC_HOME $::env(HOME)/work/projects/ez-usb-fx3
} else {
     set CONFMC_HOME $::env(CONFMC_HOME)
}
if {[info exists env(DEVICE)] == 0} { 
     set DEVICE xc7z020-clg484-1
} else {
     set DEVICE $::env(DEVICE)
}
if {[info exists env(FPGA_TYPE)] == 0} {
     set FPGA_TYPE  ZYNQ7000
     set DEVICE     xc7z020-clg484-1
     set BOARD_TYPE ZED
} else {
     set FPGA_TYPE $::env(FPGA_TYPE)
     if {${FPGA_TYPE}=="ZYNQ7000"} {
          set DEVICE     xc7z020-clg484-1
          set BOARD_TYPE ZED
     } else {
          puts "${FPGA_TYPE} not supported"
          exit 1
     }
}
if {[info exists env(MODULE)] == 0} { 
     set MODULE fpga
} else { 
     set MODULE $::env(MODULE)
}
if {[info exists env(WORK)] == 0} { 
     set WORK work
} else { 
     set WORK $::env(WORK)
}
if {[info exists env(RIGOR)] == 0} { 
     set RIGOR 1
} else { 
     set RIGOR $::env(RIGOR)
}

#---------------------------------------------------------
set_part ${DEVICE}
set_property part ${DEVICE} [current_project]
#set_property board_part xilinx.com:vcu108:part0:1.2 [current_project]
#
file mkdir ${WORK}

set out_dir ${WORK}
set part    ${DEVICE}
set module  ${MODULE}
set rigor   ${RIGOR}

#---------------------------------------------------------
# Assemble the design source files
#proc proc_read { {out_dir ${WORK}} {part ${DEVICE}} {module ${MODULE}} { rigor 0 } } {
     set DIR_RTL        "../../design/verilog"
     set DIR_BFM        "${CONFMC_HOME}/hwlib/trx_ahb"
     set DIR_MEM        "../../../iplib/mem_ahb"
     set DIR_MEM_BRAM   "../../../iplib/mem_ahb/bram_simple_dual_port/z7/${VIVADO_VER}"
     set DIR_XDC        "xdc"

     read_ip "
         ${DIR_MEM_BRAM}/bram_simple_dual_port_32x8KB/bram_simple_dual_port_32x8KB.xci
         ${DIR_MEM_BRAM}/bram_simple_dual_port_32x16KB/bram_simple_dual_port_32x16KB.xci
         ${DIR_MEM_BRAM}/bram_simple_dual_port_32x32KB/bram_simple_dual_port_32x32KB.xci
     "
#         ${DIR_MEM_BRAM}/bram_simple_dual_port_32x64KB/bram_simple_dual_port_32x64KB.xci
#         ${DIR_MEM_BRAM}/bram_simple_dual_port_32x128KB/bram_simple_dual_port_32x128KB.xci
#         ${DIR_MEM_BRAM}/bram_simple_dual_port_32x256KB/bram_simple_dual_port_32x256KB.xci
#         ${DIR_MEM_BRAM}/bram_simple_dual_port_32x512KB/bram_simple_dual_port_32x512KB.xci

     read_edif "
         $::env(DIR_BFM_EDIF)/bfm_ahb.edif
     "

     set_property verilog_dir "
                ${DIR_RTL}
                ${DIR_BFM}/rtl/verilog
                ${DIR_MEM}/rtl/verilog
                ${DIR_MEM_BRAM}
     " [current_fileset]

     read_verilog  "
                ./syn_define.v
                ${DIR_RTL}/fpga.v
                ${DIR_BFM}/rtl/verilog/bfm_ahb_stub.v
                ${DIR_MEM}/rtl/verilog/bram_ahb.v
     "

     read_xdc "
         ${DIR_XDC}/fpga_etc.xdc
         ${DIR_XDC}/fpga_zed.xdc
         ${DIR_XDC}/con-fmc_lpc_zed.xdc
     "

#     return 0
#}

#---------------------------------------------------------
# Run synthesis and implementation
#proc proc_synth { out_dir {part ${DEVICE}} {module ${MODULE}} { rigor 0 } } {
     #proc_read ${out_dir} ${part} ${module} ${rigor}
     synth_design -top ${module} -part ${part}\
                  -verilog_define SYN=1\
                  -verilog_define VIVADO=1\
                  -verilog_define ${FPGA_TYPE}=1
     write_edif -force ${module}.edn
     write_checkpoint -force ${out_dir}/post_synth
     if { ${rigor} == 1} {
        report_timing_summary -file ${out_dir}/post_synth_timing_summary.rpt
        report_timing -sort_by group -max_paths 5 -path_type summary -file ${out_dir}/post_synth_timing.rpt
        report_utilization -file ${out_dir}/post_synth_util.rpt
     }
#     return 0
#}

#set_param memory.dontrundrc true
#---------------------------------------------------------
# Run map
#proc proc_map { out_dir part module { rigor 0 } } {
     if { [file exists ${out_dir}/post_synth.dcp] == 0 } {
         puts "${out_dir}/post_synth.dcp not found"
         exit 1
     }
     #read_checkpoint ${out_dir}/post_synth.dcp; link_design
     #open_checkpoint ${out_dir}/post_synth.dcp
     opt_design
     write_checkpoint -force ${out_dir}/post_opt
     if { ${rigor} == 1} {
        power_opt_design
     }
#     return 0
#}

#set_property is_enabled false [get_drc_checks MIG-69]
#---------------------------------------------------------
# Run par (place)
#proc proc_place { out_dir part module { rigor 0 } } {
     if { [file exists ${out_dir}/post_opt.dcp] == 0 } {
         puts "${out_dir}/post_opt.dcp not found"
         exit 1
     }
     #read_checkpoint ${out_dir}/post_opt.dcp; link_design
     #open_checkpoint ${out_dir}/post_opt.dcp;
     place_design
     write_checkpoint -force ${out_dir}/post_place
     if { ${rigor} == 1} {
        report_clock_utilization -file ${out_dir}/post_place_clock_util.rpt
        #if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
        #   puts "Found setup timing violations --> running physicall optimization"
        #   phys_opt_design
        #}
        report_timing_summary -file ${out_dir}/post_place_timing_summary.rpt
        report_timing -sort_by group -max_paths 5 -path_type summary -file ${out_dir}/post_place_timing.rpt
        report_utilization -file ${out_dir}/post_place_util.rpt
     }
#     return 0
#}

#---------------------------------------------------------
# Run par (route)
#proc proc_route { out_dir part module { rigor 0 } } {
     if { [file exists ${out_dir}/post_place.dcp] == 0 } {
         puts "${out_dir}/post_place.place not found"
         exit 1
     }
     #read_checkpoint ${out_dir}/post_place.dcp; link_design
     #open_checkpoint ${out_dir}/post_place.dcp
     route_design
     write_checkpoint -force ${out_dir}/post_route
     if { ${rigor} == 1} {
        report_timing_summary -file ${out_dir}/post_route_timing_summary.rpt
        report_timing -sort_by group -max_paths 5 -path_type summary -file ${out_dir}/post_synth_timing.rpt
        report_utilization -file ${out_dir}/post_route_util.rpt
     }
#     return 0
#}

#---------------------------------------------------------
# Generate reports
#proc proc_report { out_dir part module { rigor 0 } } {
     if { [file exists ${out_dir}/post_route.dcp] == 0 } {
         puts "${out_dir}/post_route.place not found"
         exit 1
     }
     #read_checkpoint ${out_dir}/post_route.dcp; link_design
     #open_checkpoint ${out_dir}/post_route.dcp
     report_drc -file ${out_dir}/post_imp_drc.rpt
     write_verilog -force ${out_dir}/${module}_time.v -mode timesim -sdf_anno true
     write_xdc -no_fixed_only -force ${out_dir}/${module}_all.xdc
#     return 0
#}

#---------------------------------------------------------
# Geneate bitfile
#proc proc_bitgen { out_dir part module { rigor 0 } } {
     if { [file exists ${out_dir}/post_route.dcp] == 0 } {
         puts "${out_dir}/post_route.place not found"
         exit 1
     }
     #read_checkpoint ${out_dir}/post_route.dcp; link_design
     #open_checkpoint ${out_dir}/post_route.dcp
     write_bitstream -force ${module}.bit 
#     return 0
#}

#---------------------------------------------------------
#proc_synth   ${WORK} ${DEVICE} ${MODULE} ${RIGOR}
#proc_map     ${WORK} ${DEVICE} ${MODULE} ${RIGOR}
#proc_place   ${WORK} ${DEVICE} ${MODULE} ${RIGOR}
#proc_route   ${WORK} ${DEVICE} ${MODULE} ${RIGOR}
#proc_report  ${WORK} ${DEVICE} ${MODULE} ${RIGOR}
#proc_bitgen  ${WORK} ${DEVICE} ${MODULE} ${RIGOR}

#---------------------------------------------------------
#exit
