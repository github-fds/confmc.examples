#---------------------------------------------------------
if {[info exists env(VIVADO_VER)] == 0} {
     set VIVADO_VER vivado.2018.3
} else {
     set VIVADO_VER $::env(VIVADO_VER)
}
if {[info exists env(CONFMC_HOME)] == 0} {
     set CONFMC_HOME $::env(HOME)/work/projects/ez-usb-fx3
} else {
     set CONFMC_HOME $::env(CONFMC_HOME)
}
if {[info exists env(DEVICE)] == 0} { 
     set DEVICE xczu28dr-ffvg1517-2-e
} else {
     set DEVICE $::env(DEVICE)
}
if {[info exists env(FPGA_TYPE)] == 0} {
     set FPGA_TYPE  zusp
     set DEVICE     xczu28dr-ffvg1517-2-e
     set BOARD_TYPE ZCU111
} else {
     set FPGA_TYPE $::env(FPGA_TYPE)
     set DEVICE     xczu28dr-ffvg1517-2-e
     set BOARD_TYPE ZCU111
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
if {[info exists env(ILA)] == 0} {
     set ILA 0
} else {
     set ILA $::env(ILA)
}
if {[info exists env(FIP_HOME)] == 0} {
     set FIP_HOME ../../../../FIP
} else {
     set FIP_HOME $::env(FIP_HOME)
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
     set DIR_BFM        "${CONFMC_HOME}/hwlib/trx_axi"
     set DIR_AXI        "${FIP_HOME}/amba_axi/rtl/verilog"
     set DIR_APB        "${FIP_HOME}/axi_to_apb/rtl/verilog"
     set DIR_CONFIG     "${FIP_HOME}/xfft_config/rtl/verilog"
     set DIR_MEM        "${FIP_HOME}/mem_axi_dual/rtl/verilog"
     set DIR_MEM_BRAM   "${FIP_HOME}/mem_axi_dual/bram_true_dual_port/${FPGA_TYPE}/${VIVADO_VER}"
     set DIR_M2S        "${FIP_HOME}/axi_mem2stream/rtl/verilog"
     set DIR_S2M        "${FIP_HOME}/axi_stream2mem/rtl/verilog"
     set DIR_XFFT       "${FIP_HOME}/xfft/${FPGA_TYPE}/${VIVADO_VER}/xfft_16bit256samples"
     set DIR_XDC        "./xdc"

     read_edif "
         $::env(DIR_BFM_EDIF)/bfm_axi.edif
         ${FIP_HOME}/axi_mem2stream/syn/vivado.${FPGA_TYPE}/axi_mem2stream.edif
         ${FIP_HOME}/axi_stream2mem/syn/vivado.${FPGA_TYPE}/axi_stream2mem.edif
         ${FIP_HOME}/xfft_config/syn/vivado.${FPGA_TYPE}/xfft_config.edif
     "

     read_ip "
        ${DIR_MEM_BRAM}/bram_true_dual_port_32x16KB/bram_true_dual_port_32x16KB.xci
        ${DIR_MEM_BRAM}/bram_true_dual_port_32x32KB/bram_true_dual_port_32x32KB.xci
        ${DIR_MEM_BRAM}/bram_true_dual_port_32x64KB/bram_true_dual_port_32x64KB.xci
        ${DIR_XFFT}/xfft_16bit256samples.xci
     "

     set_property verilog_dir "
                ${DIR_RTL}
                ${DIR_BFM}/rtl/verilog
                ${DIR_AXI}
                ${DIR_APB}
                ${DIR_CONFIG}
                ${DIR_MEM}
                ${DIR_MEM_BRAM}
                ${DIR_M2S}
                ${DIR_S2M}
                ${DIR_XFFT}
     " [current_fileset]

     set XDC_LIST "
         ${DIR_XDC}/fpga_zcu111.xdc
         ${DIR_XDC}/con-fmc_zcu111.xdc
     "
     if {(${ILA} == 1)&&([file exists "./ila/xdc.ila/ila.xdc"] == 1)} {
         append XDC_LIST "./ila/xdc.ila/ila.xdc "
     }

     if {[file exists "additional.xdc"] == 1} {
         append XDC_LIST "additional.xdc"
     }

     read_verilog  "
                ./syn_define.v
                ${DIR_RTL}/fpga.v
                ${DIR_BFM}/rtl/verilog/bfm_axi_stub.v
                ${DIR_AXI}/amba_axi_m2s3.v
                ${DIR_APB}/axi_to_apb_s3.v
                ${DIR_CONFIG}/xfft_config_stub.v
                ${DIR_MEM}/bram_axi_dual.v
                ${DIR_M2S}/axi_mem2stream_stub.v
                ${DIR_S2M}/axi_stream2mem_stub.v
                ${DIR_XFFT}/xfft_16bit256samples_stub.v
     "

     read_xdc ${XDC_LIST}

     set   fpout  [ open "all.xdc" "w" ]
     foreach F ${XDC_LIST} {
         set   fpin   [ open "$F" r ]
         set   fdata  [ read $fpin ]
         puts  -nonewline $fpout $fdata
         close $fpin
     }
     close $fpout

#     return 0
#}

#=====================================================================
proc number_of_processor {} {
    global tcl_platform env
    switch ${tcl_platform(platform)} {
        "windows" {
            return $env(NUMBER_OF_PROCESSORS)
        }

        "unix" {
            if {![catch {open "/proc/cpuinfo"} f]} {
                set cores [regexp -all -line {^processor\s} [read $f]]
                close $f
                if {$cores > 0} {
                    return $cores
                }
            }
        }

        "Darwin" {
            if {![catch {exec {*}$sysctl -n "hw.ncpu"} cores]} {
                return $cores
            }
        }

        default {
            puts "Unknown System"
            return 1
        }
    }
}
set_param general.maxThreads [number_of_processor]
#=====================================================================
#---------------------------------------------------------
# Run synthesis and implementation
#proc proc_synth { out_dir {part ${DEVICE}} {module ${MODULE}} { rigor 0 } } {
     #proc_read ${out_dir} ${part} ${module} ${rigor}
     #set_property IOB true [ all_inputs  ]
     #set_property IOB true [ all_outputs ]
     synth_design -top ${module} -part ${part}\
                  -verilog_define SYN=1\
                  -verilog_define VIVADO=1\
                  -verilog_define ${FPGA_TYPE}=1\
                  -verilog_define XILINX_Z7=1\
                  -verilog_define AMBA_AXI4=1
     write_edif -force -security_mode all ${module}.edn
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
     if {(${ILA} == 1)&&([file exists "./ila/xdc.ila/ila.xdc"] == 1)} {
         write_debug_probes -force ${module}.ltx
     }
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
