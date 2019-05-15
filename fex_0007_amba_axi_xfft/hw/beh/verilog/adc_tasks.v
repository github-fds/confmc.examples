`ifndef ADC_TASKS_V
`define ADC_TASKS_V
//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems.
// All right reserved.
//------------------------------------------------------------------------------
// adc_tasks.v
//------------------------------------------------------------------------------
// VERSION: 2019.04.05.
//------------------------------------------------------------------------------
// Prepare ADC values and write to the memory
// Each sample consists {16-bit imag, 16-bit real}, where imag is zero.
task adc;
     input [31:0] addr;
     input [31:0] num_of_samples;
     input [256*8-1:0] file_name;

     integer      bits_int, bits_fractional;
     reg   [63:0] Sampling_Frequency;
     reg   [63:0] Frequency;
     real Amplitude, Angular;
     real Radian, Time;
     real Signal, value_real;
     integer value_fixed;
     integer fp;
     integer idz;
begin
     fp = $fopen(file_name, "wb");
     if (fp==0) begin
         $display("%m %s cound not open", file_name);
         disable adc;
     end

     bits_int           = 2; // including sign-bit (i.e., 2's complement)
     bits_fractional    = 16-bits_int;
   //Sampling_Frequency = 4_000_000;
     Sampling_Frequency = top.sampling_freq;

     $fwrite(fp, "# sample_freq=%0d sample_num=%0d bit_width=%0d data_type=%s data_format=%s\n",
                            Sampling_Frequency, num_of_samples, bits_int+bits_fractional, "hex", "complex");

   //Frequency =   100_000;
     Frequency = top.sin_freq;
     Angular   = 2.0*3.141592*Frequency;
     Amplitude = 1.0; // if it is not 1.0, it may need to be normalized
     Time   = 0.0;
     Signal = 0.0;

     for (idz=0; idz<num_of_samples; idz=idz+1) begin
          Radian = Time * Angular; 
          Signal = Amplitude * $sin(Radian);
          value_real  = Signal*(1<<bits_fractional);
          value_fixed = $rtoi(value_real);

          axi_write(addr+idz*4, 4, {16'h0,value_fixed[15:0]}); // make imaginary zero
`ifdef XXYY99
          if ((idz%4)!=0) $fwrite(fp, " ");
          $fwrite(fp, "0x%0X+0x%0Xj", value_fixed[15:0], 16'h0);
          if ((idz%4)==3) $fwrite(fp, "\n");
`else
          $fwrite(fp, "0x%X+0x%Xj\n", value_fixed[15:0], 16'h0);
`endif

          Time = Time + 1.0/$itor(Sampling_Frequency);
     end
     $fclose(fp);
end
endtask
//------------------------------------------------------------------------------
// Read FFT results from the memory
// Each sample consists {32-bit imag, 32-bit real}
task get_fft_data;
     input [31:0] addr;
     input [31:0] num_of_samples;
     input [256*8-1:0] file_name;

     integer      bits_int, bits_fractional;
     reg   [63:0] Sampling_Frequency;
     integer fp;

     reg [31:0] dataR, dataI;
     integer idz;
begin
     fp = $fopen(file_name, "wb");
     if (fp==0) begin
         $display("%m %s cound not open", file_name);
         disable get_fft_data;
     end

   //Sampling_Frequency = 4_000_000;
     Sampling_Frequency = top.sampling_freq;

     $fwrite(fp, "# sample_freq=%0d sample_num=%0d bit_width=%0d data_type=%s data_format=%s\n",
                            Sampling_Frequency, num_of_samples, 32, "hex", "complex");

     for (idz=0; idz<num_of_samples; idz=idz+1) begin
          axi_read(addr+idz*8, 4, dataR);
          axi_read(addr+idz*8+4, 4, dataI);
`ifdef XXYY99
          if ((idz%4)!=0) $fwrite(fp, " ");
          $fwrite(fp, "0x%0X+0x%0Xj", dataR, dataI);
          if ((idz%4)==3) $fwrite(fp, "\n");
`else
          $fwrite(fp, "0x%X+0x%Xj\n", dataR, dataI);
`endif
     end

     $fclose(fp);
end
endtask
//------------------------------------------------------------------------------
// Revision History
//
// 2019.04.05: Started by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
`endif
