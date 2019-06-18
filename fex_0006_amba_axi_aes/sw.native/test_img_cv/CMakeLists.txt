cmake_minimum_required( VERSION 3.1 )
#cmake_minimum_required( VERSION 2.8 )

#------------------------------------------------------------------------------
# linux_x86_64
# linux_armv7l
EXECUTE_PROCESS( COMMAND uname -s
                 COMMAND tr -d '\n'
                 COMMAND tr '[:upper:]' '[:lower:]'
                 OUTPUT_VARIABLE os )
EXECUTE_PROCESS( COMMAND uname -m
                 COMMAND tr -d '\n'
                 COMMAND tr '[:upper:]' '[:lower:]'
                 OUTPUT_VARIABLE arch )

#------------------------------------------------------------------------------
if ( "$ENV{CONFMC_HOME}" STREQUAL "" )
    set( CONFMC_HOME "$ENV{HOME}/work/projects/ez-usb-fx3" )
else()
    set( CONFMC_HOME "$ENV{CONFMC_HOME}" )
endif()
message( "CONFMC_HOME = ${CONFMC_HOME}" )

#------------------------------------------------------------------------------
set(CMAKE_C_COMPILER "gcc")
set(CMAKE_CXX_COMPILER "g++")

#------------------------------------------------------------------------------
project( Test CXX C )
find_package( OpenCV REQUIRED )
set( my_srcs src/main.cpp
             src/arg_parser.cpp
             src/test_bench.cpp
             src.aes/rijndael.c
             ../../iplib/aes128_axi/api/c/aes128_api.c
             ${CONFMC_HOME}/hwlib/trx_axi/api/c/bfm_api.c )
include_directories( src src.aes
                     ${CONFMC_HOME}/include
                     ${CONFMC_HOME}/hwlib/trx_axi/api/c
                     ../../iplib/aes128_axi/api/c )
link_directories( ${CONFMC_HOME}/lib/${os}_${arch} /lib/x86_64-linux-gnu )
set( CMAKE_C_STANDARD 99 )
set( CMAKE_CXX_STANDRAD 11 )
add_compile_options( -DBFM_AXI )
#add_compile_options( -std=gnu++11 -DBFM_AXI )
#option( WITH_C   -std=gnu99 -DBFM_AXI )
#option( WITH_CXX -std=gnu++11 -DBFM_AXI )
add_executable( Test ${my_srcs} )
target_link_libraries( Test  ${OpenCV_LIBS}
                             avformat avcodec swscale avutil
                             libconapi.a
                             libusb-1.0.so )
add_custom_target( run ./Test -r -i images/face_320x240.jpg )
