//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// file_writer.v
//------------------------------------------------------------------------------
// VERSION = 2019.04.10.
//------------------------------------------------------------------------------
// Macros
//------------------------------------------------------------------------------
// Note:
//------------------------------------------------------------------------------
module file_writer_fixed
     #(parameter P_SAMPLE_NUM    =1 // num of samples in a stream (P_FIXED_WID-bit wise)
               , P_FIXED_INT     =2
               , P_FIXED_FRAC    =14
               , P_FIXED_WID     =(P_FIXED_INT+P_FIXED_FRAC)
               , P_FFT_NUM_SAMPLE=256 // num of samples for an FFT
               , P_FILE_NAME_REAL ="data_float.txt"
               , P_FILE_NAME_FIXED="data_fixed.txt"
               , P_COMPLEX        = 0
               , P_WID            = (P_COMPLEX) ? 2*P_SAMPLE_NUM*P_FIXED_WID
                                                : P_SAMPLE_NUM*P_FIXED_WID
               )
(
       input  wire             axis_reset_n
     , input  wire             axis_clk // stream clock
     , input  wire             axis_tvalid
     , input  wire             axis_tready
     , input  wire             axis_tlast
     , input  wire [P_WID-1:0] axis_tdata // a pair of {imag,real} when P_COMLEX=1
                                          // otherwize {real}
     , input  wire [63:0] sampling_freq
);
    //--------------------------------------------------------------------------
    reg  [P_FIXED_WID-1:0] data_fixed_real[0:P_FFT_NUM_SAMPLE-1];
    reg  [P_FIXED_WID-1:0] data_fixed_imag[0:P_FFT_NUM_SAMPLE-1];
    //--------------------------------------------------------------------------
    reg done=1'b0;
    integer idx, idy, idz;
    //--------------------------------------------------------------------------
    always @ (posedge axis_clk or negedge axis_reset_n) begin
    if (axis_reset_n==1'b0) begin
        for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
              data_fixed_real[idx] = {P_FIXED_WID{1'b0}};
              data_fixed_imag[idx] = {P_FIXED_WID{1'b0}};
        end
        idz = 0;
        done=1'b0;
    end else begin
        if ((done==1'b0)&&(axis_tvalid==1'b1)&&(axis_tready==1'b1)) begin
           for (idy=0; idy<P_SAMPLE_NUM; idy=idy+1) begin
                if (P_COMPLEX) begin
                    {data_fixed_imag[idz+idy], data_fixed_real[idz+idy]}
                       = axis_tdata[idy*(P_FIXED_WID*2)+:(P_FIXED_WID*2)];
                end else begin
                    {data_fixed_imag[idz+idy], data_fixed_real[idz+idy]}
                       = {{P_FIXED_WID{1'b0}},axis_tdata[idy*P_FIXED_WID+:P_FIXED_WID]};
                end
           end
           idz = idz + P_SAMPLE_NUM;
           if (idz==P_FFT_NUM_SAMPLE) begin
               write_file( P_FILE_NAME_REAL
                         , P_FILE_NAME_FIXED
                         , P_FFT_NUM_SAMPLE
                         , P_COMPLEX);
               idz = 0;
               done=1'b1;
           end
        end
    end // if
    end // always
    //--------------------------------------------------------------------------
    task write_file;
         input [256*8-1:0] file_name_float;
         input [256*8-1:0] file_name_fixed;
         input [31:0] num;
         input        complex; // 1=complex, 0=real-only
         integer fout;
         integer ida;
         integer signed ifrac;
         reg signed [P_FIXED_WID-1:0] idata, rdata; // imaginary and real
         real rtmp, itmp;
    begin
         fout = $fopen(file_name_float, "wb");
         if (fout==0) begin
             $display("%m %s cannot open", file_name_float);
         end else begin
             $fwrite(fout, "# sample_freq=%0d sample_num=%0d bit_width=%0d data_type=%s data_format=%s\n",
                            sampling_freq, num, P_FIXED_WID, "real", (complex) ? "complex" : "real");
             for (ida=0; ida<num; ida=ida+1) begin
                  if (complex) begin
                      idata = data_fixed_imag [ida];
                      rdata = data_fixed_real [ida];
                      ifrac = (1<<P_FIXED_FRAC);
                      itmp  = $itor(idata)/$itor(ifrac);
                      rtmp  = $itor(rdata)/$itor(ifrac);
                      `ifdef MULTI_COLUMN
                      if ((ida%4)!=0) $fwrite(fout, " ");
                      if (itmp<0) $fwrite(fout, "%f%fj", rtmp, itmp);
                      else        $fwrite(fout, "%f+%fj", rtmp, itmp);
                      if ((ida%4)==3) $fwrite(fout, "\n");
                      `else
                      if (itmp<0) $fwrite(fout, "%f%fj\n", rtmp, itmp);
                      else        $fwrite(fout, "%f+%fj\n", rtmp, itmp);
                      `endif
                  end else begin
                      rdata = data_fixed_real[ida];
                      ifrac = 1<<P_FIXED_FRAC;
                      rtmp  = $itor(rdata)/$itor(ifrac);
                      `ifdef MULTI_COLUMN
                      if ((ida%4)!=0) $fwrite(fout, " ");
                      $fwrite(fout, "%f", rtmp);
                      if ((ida%4)==3) $fwrite(fout, "\n");
                      `else
                      $fwrite(fout, "%f\n", rtmp);
                      `endif
                  end
             end
             $fclose(fout);
         end
         fout = $fopen(file_name_fixed, "wb");
         if (fout==0) begin
             $display("%m %s cannot open", file_name_fixed);
         end else begin
             $fwrite(fout, "# sample_freq=%0d sample_num=%0d bit_width=%0d data_type=%s data_format=%s\n",
                            sampling_freq, num, P_FIXED_WID, "hex", (complex) ? "complex" : "real");
             for (ida=0; ida<num; ida=ida+1) begin
                  if (complex) begin
                      idata = data_fixed_imag[ida];
                      rdata = data_fixed_real[ida];
                      `ifdef MULTI_COLUMN
                      if ((ida%4)!=0) $fwrite(fout, " ");
                      $fwrite(fout, "0x%X+0x%Xj", rdata, idata);
                      if ((ida%4)==3) $fwrite(fout, "\n");
                      `else
                      $fwrite(fout, "0x%X+0x%Xj\n", rdata, idata);
                      `endif
                  end else begin
                      rdata = data_fixed_real[ida];
                      `ifdef MULTI_COLUMN
                      if ((ida%4)!=0) $fwrite(fout, " ");
                      $fwrite(fout, "0x%X", rdata);
                      if ((ida%4)==3) $fwrite(fout, "\n");
                      `else
                      $fwrite(fout, "0x%X\n", rdata);
                      `endif
                  end
             end
             $fclose(fout);
         end
    end
    endtask
    //--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2019.04.10: 'axis_tready' changed
// 2019.03.23: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
