@ECHO OFF
REM CLS

SET TARGET=Project1\x64\Debug\Project1.exe

%TARGET% -c 0 -v 0^
         --num_of_sample=256^
         --sampling_freq=2000000^
         --signal_spec="100000:1.0:0"^
         --signal_spec="200000:1.0:0"^
         --signal_spec="300000:1.0:0"^
         --data_file_float="data_float.txt"^
         --data_file_fixed="data_fixed.txt"^
         --fft_file_float="fft_float.txt"^
         --fft_file_fixed="fft_fixed.txt"
