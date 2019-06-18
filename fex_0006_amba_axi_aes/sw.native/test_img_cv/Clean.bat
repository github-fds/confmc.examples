@ECHO OFF
REM CLS

SET TOP=Test

IF EXIST %TOP%     DEL /q %TOP%
IF EXIST %TOP%.ncb DEL /q %TOP%.ncb
IF EXIST %TOP%.ilk DEL /q %TOP%.ilk
IF EXIST %TOP%.plg DEL /q %TOP%.plg
IF EXIST %TOP%.opt DEL /q %TOP%.opt
IF EXIST %TOP%.exe DEL /q %TOP%.exe
IF EXIST %TOP%.exe.stackdump DEL /q %TOP%.exe.stackdump
IF EXIST Debug        RMDIR /s/q Debug
IF EXIST *.o          DEL /q *.o
IF EXIST obj          RMDIR /s/q obj
IF EXIST result.png   DEL /q result.png

IF EXIST CMakeCache.txt      DEL /Q    CMakeCache.txt
IF EXIST CMakeFiles          RD  /Q /S CMakeFiles
IF EXIST cmake_install.cmake DEL /Q    cmake_install.cmake
IF EXIST Makefile            DEL /Q    Makefile
IF EXIST result.png          DEL /Q    result.png
IF EXIST result.jpg          DEL /Q    result.jpg
IF EXIST DisplayImage        DEL /Q    DisplayImage

