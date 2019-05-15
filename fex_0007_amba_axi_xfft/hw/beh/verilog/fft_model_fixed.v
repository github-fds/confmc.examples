//------------------------------------------------------------------------------
// Copyright (c) 2019 by Future Design Systems
// All right reserved.
//
// http://www.future-ds.com
//------------------------------------------------------------------------------
// fft_model_fixed.v
//------------------------------------------------------------------------------
// VERSION = 2019.04.10.
//------------------------------------------------------------------------------
// Macros
//------------------------------------------------------------------------------
// Note:
// * input: real-value stream
// * output: complex-value stream
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module fft_model_fixed
     #(parameter P_SAMPLE_NUM         =8 // num of samples in a stream (P_SAMPLE_FIXED_WID-bit wise)
               , P_FFT_NUM_SAMPLE     =256 // num of samples for an FFT
               , P_SAMPLE_FIXED_INT   =2  // bit-width of integer part of sample
               , P_SAMPLE_FIXED_FRAC  =14 // bit-width of fractional part of sample
               , P_FFT_FIXED_INT      =(P_SAMPLE_FIXED_INT+clogb2(P_FFT_NUM_SAMPLE))// bit-width of integer part of fft result
               , P_FFT_FIXED_FRAC     =P_SAMPLE_FIXED_FRAC // bit-width of fractional part of fft result
               , P_TWID_FIXED_INT     =2  // bit-width of integer part of twiddle including sign-bit
               , P_TWID_FIXED_FRAC    =14  // bit-width of fractional part of twiddle
               , P_SAMPLE_FIXED_WID   =(P_SAMPLE_FIXED_INT+P_SAMPLE_FIXED_FRAC)
               , P_FFT_FIXED_WID      =(P_FFT_FIXED_INT+P_FFT_FIXED_FRAC)
               , P_TWID_FIXED_WID     =(P_TWID_FIXED_INT+P_TWID_FIXED_FRAC)
               , P_DIN_WID=2*P_SAMPLE_NUM*P_SAMPLE_FIXED_WID
               , P_DOUT_WID=2*P_SAMPLE_NUM*P_FFT_FIXED_WID
               , P_DIT=1 // 1=DIT, 0=DIF
               , P_DIR=1 // 1=forward, 0=inverse
               )
(
       input  wire                   axis_reset_n
     , input  wire                   axis_clk // stream clock
     , input  wire                   s_axis_tvalid
     , output reg                    s_axis_tready=1'b0
     , input  wire [P_DIN_WID-1:0]   s_axis_tdata
     , output reg                    m_axis_tvalid
     , input  wire                   m_axis_tready
     , output reg                    m_axis_tlast
     , output reg  [P_DOUT_WID-1:0]  m_axis_tdata // pair of {imag,real}
);
    //--------------------------------------------------------------------------
    reg [P_SAMPLE_FIXED_WID-1:0] data_fixed_real[0:P_FFT_NUM_SAMPLE-1];
    reg [P_SAMPLE_FIXED_WID-1:0] data_fixed_imag[0:P_FFT_NUM_SAMPLE-1];
    reg [P_FFT_FIXED_WID-1:0]    fft_fixed_real [0:P_FFT_NUM_SAMPLE-1];
    reg [P_FFT_FIXED_WID-1:0]    fft_fixed_imag [0:P_FFT_NUM_SAMPLE-1];
    //--------------------------------------------------------------------------
    integer idx, idy;
    integer num;
    integer sam;
integer flag;
    //--------------------------------------------------------------------------
    localparam ST_READY='b0
             , ST_PIPE ='b1;
    reg [1:0] state=ST_READY;
    //--------------------------------------------------------------------------
    always @ (posedge axis_clk or negedge axis_reset_n) begin
    if (axis_reset_n==1'b0) begin
        s_axis_tready =1'b0;
        for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
             data_fixed_real[idx] = {P_SAMPLE_FIXED_WID{1'b0}};
             data_fixed_imag[idx] = {P_SAMPLE_FIXED_WID{1'b0}};
             fft_fixed_real [idx] = {P_FFT_FIXED_WID{1'b0}};
             fft_fixed_imag [idx] = {P_FFT_FIXED_WID{1'b0}};
        end
        num   = 0;
        sam   = 0;
flag=0;
        state = ST_READY;
    end else begin
    case (state)
    ST_READY: begin
       s_axis_tready = 1'b1;
       if (s_axis_tvalid==1'b1) begin
           for (idx=0; idx<P_SAMPLE_NUM; idx=idx+1) begin
                // fill 0 for all imaginary part of input data
                {data_fixed_imag[num+idx],data_fixed_real[num+idx]}
                     = s_axis_tdata[idx*P_SAMPLE_FIXED_WID*2+:P_SAMPLE_FIXED_WID*2];
           end
           if ((num+P_SAMPLE_NUM)==P_FFT_NUM_SAMPLE) begin
               if (P_DIT==1) do_fft_dit_radix2(P_FFT_NUM_SAMPLE, P_DIR);
               else          do_fft_dif_radix2(P_FFT_NUM_SAMPLE, P_DIR);
               num   = 0;
               sam   = 0;
               state = ST_PIPE;
           end else begin
               num = num + P_SAMPLE_NUM;
           end
       end
       end // ST_READY
    ST_PIPE: begin
       if ((m_axis_tready==1'b1)&&(m_axis_tvalid==1'b1)) begin
            if ((sam+P_SAMPLE_NUM)==P_FFT_NUM_SAMPLE) begin
                //if (P_DIT==1) do_fft_dit_radix2(P_FFT_NUM_SAMPLE, P_DIR);
                //else          do_fft_dif_radix2(P_FFT_NUM_SAMPLE, P_DIR);
                sam = 0;
flag=1;
            end else begin
                sam = sam + P_SAMPLE_NUM;
            end
       end
       end // ST_PIPE
    default: begin
             state = ST_READY;
             end
    endcase
    end // if
    end // always
    //--------------------------------------------------------------------------
    always @ ( * ) begin
       if (state==ST_PIPE) begin
           for (idy=0; idy<P_SAMPLE_NUM; idy=idy+1) begin
                {data_fixed_imag[sam+idy],data_fixed_real[sam+idy]}
                     = s_axis_tdata[idy*P_SAMPLE_FIXED_WID*2+:P_SAMPLE_FIXED_WID*2];
                m_axis_tvalid = 1'b1;
                m_axis_tdata[idy*P_FFT_FIXED_WID*2+:2*P_FFT_FIXED_WID]
                     = {fft_fixed_imag[sam+idy],fft_fixed_real[sam+idy]};
           end
       end else begin
           m_axis_tvalid = 1'b0;
       end
       if ((sam+P_SAMPLE_NUM)==P_FFT_NUM_SAMPLE) begin
                m_axis_tlast = 1'b1;
       end else begin
                m_axis_tlast = 1'b0;
       end
    end
    //--------------------------------------------------------------------------
    localparam real P_TWID_FIXED_MAX_VALUE=2.0**(P_TWID_FIXED_INT-1)-1.0/(2**(P_TWID_FIXED_FRAC))
                  , P_TWID_FIXED_MIN_VALUE=-2.0**(P_TWID_FIXED_INT-1);
    //--------------------------------------------------------------------------
    real wtable_float_real[0:P_FFT_NUM_SAMPLE/2-1];
    real wtable_float_imag[0:P_FFT_NUM_SAMPLE/2-1];
    //--------------------------------------------------------------------------
    real float_real [0:P_FFT_NUM_SAMPLE-1];
    real float_imag [0:P_FFT_NUM_SAMPLE-1];
    //--------------------------------------------------------------------------
    // decimation in time FFT.
    // 1. build Wtable
    // 2. bit-reverse swap
    // 3. fft in natural order (note that inputs have been swaped already)
    task do_fft_dit_radix2;
        input [31:0] num; // number of samples
        input        direction; // 1=forward, 0=inverse
        integer windex;
        real    wr, wi;
        integer i, j, k, h;
        integer m, n; // butterfly pair
        real    tmpr, tmpi;
        real    dmR, dmI;
        integer idx;
    begin
        make_wtable(num, 1);
        bit_reverse_swap_dit(num); // bit-reverse-swap on data_fixed_imag/data_fixed_imag
        for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
             float_real[idx] = data_fixed2real(data_fixed_real[idx]);
             float_imag[idx] = data_fixed2real(data_fixed_imag[idx]);
        end
        for (i=2; i<=num; i=i*2) begin /* log2(N) times loop */
           h = i/2;
           for (j=0; j<h; j=j+1) begin
              /* the j-th i-th root of unity */
              windex = j*num/i;
              wr = wtable_float_real[windex];
              wi = wtable_float_imag[windex];
              for (k=j; k<num; k = k+i) begin
                 m = k;
                 n = m+h;
                 /* (a+ib)*(c+id) = (ac-bd)+i(ad+bc) */
                 tmpr  = wr*float_real[n] - wi*float_imag[n];
                 tmpi  = wr*float_imag[n] + wi*float_real[n];
                 dmR   = float_real[m];
                 dmI   = float_imag[m];
                 float_real[m] = (dmR + tmpr);
                 float_imag[m] = (dmI + tmpi);
                 float_real[n] = (dmR - tmpr);
                 float_imag[n] = (dmI - tmpi);
              end
           end
        end
        if (direction==1) begin
            for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
                 fft_fixed_real[idx] = fft_real2fixed(float_real[idx]/$itor(num));
                 fft_fixed_imag[idx] = fft_real2fixed(float_imag[idx]/$itor(num));
            end
        end else begin
            for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
                 fft_fixed_real[idx] = fft_real2fixed(float_real[idx]);
                 fft_fixed_imag[idx] = fft_real2fixed(float_imag[idx]);
            end
        end
        for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
            if (float_real[idx]/$itor(num)>P_TWID_FIXED_MAX_VALUE) $display("%m value overflow (%f:%f)", float_real[idx]/$itor(num), P_TWID_FIXED_MAX_VALUE);
            if (float_real[idx]/$itor(num)<P_TWID_FIXED_MIN_VALUE) $display("%m value underflow (%f:%f)", float_real[idx]/$itor(num), P_TWID_FIXED_MIN_VALUE);
            if (float_imag[idx]/$itor(num)>P_TWID_FIXED_MAX_VALUE) $display("%m value overflow (%f:%f)", float_imag[idx]/$itor(num), P_TWID_FIXED_MAX_VALUE);
            if (float_imag[idx]/$itor(num)<P_TWID_FIXED_MIN_VALUE) $display("%m value underflow (%f:%f)", float_imag[idx]/$itor(num), P_TWID_FIXED_MIN_VALUE);
        end
    end
    endtask
    //--------------------------------------------------------------------------
    // decimation in frequency FFT.
    // 1. build Wtable
    // 2. fft in natural order
    // 3. bit-reverse swap (note that output swaped)
    task do_fft_dif_radix2;
        input [31:0] num; // number of samples
        input        direction; // 1=forward, 0=inverse
        integer windex;
        real    wr, wi;
        integer i, j, k, h;
        integer m, n; // butterfly pair
        real    tmR, tmI, tnR, tnI;
        integer idx;
    begin
        make_wtable(num, 1);
        for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
             float_real[idx] = data_fixed2real(data_fixed_real[idx]);
             float_imag[idx] = data_fixed2real(data_fixed_imag[idx]);
        end
        for (i=num; i>0; i=i/2) begin /* log2(N) times loop */
           h = i/2;
           for (j=0; j<h; j=j+1) begin
              /* the j-th i-th root of unity */
              windex = j*num/i;
              wr = wtable_float_real[windex];
              wi = wtable_float_imag[windex];
              for (k=j; k<num; k=k+i) begin
                 m = k;
                 n = k+h;
                 /* (a+ib)*(c+id) = (ac-bd)+i(ad+bc) */
                 tmR = (float_real[m] + float_real[n]);
                 tmI = (float_imag[m] + float_imag[n]);
                 tnR = (float_real[m] - float_real[n]);
                 tnI = (float_imag[m] - float_imag[n]);
                 float_real[m]  = tmR;
                 float_imag[m]  = tmI;
                 float_real[n]  = wr*tnR - wi*tnI;
                 float_imag[n]  = wr*tnI + wi*tnR;
              end
           end
        end
        if (direction==1) begin
            for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
                 fft_fixed_real[idx] = fft_real2fixed(float_real[idx]/$itor(num));
                 fft_fixed_imag[idx] = fft_real2fixed(float_imag[idx]/$itor(num));
            end
        end else begin
            for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
                 fft_fixed_real[idx] = fft_real2fixed(float_real[idx]);
                 fft_fixed_imag[idx] = fft_real2fixed(float_imag[idx]);
            end
        end
        for (idx=0; idx<P_FFT_NUM_SAMPLE; idx=idx+1) begin
            if (float_real[idx]/$itor(num)>P_TWID_FIXED_MAX_VALUE) $display("%m value overflow (%f:%f)", float_real[idx]/$itor(num), P_TWID_FIXED_MAX_VALUE);
            if (float_real[idx]/$itor(num)<P_TWID_FIXED_MIN_VALUE) $display("%m value underflow (%f:%f)", float_real[idx]/$itor(num), P_TWID_FIXED_MIN_VALUE);
            if (float_imag[idx]/$itor(num)>P_TWID_FIXED_MAX_VALUE) $display("%m value overflow (%f:%f)", float_imag[idx]/$itor(num), P_TWID_FIXED_MAX_VALUE);
            if (float_imag[idx]/$itor(num)<P_TWID_FIXED_MIN_VALUE) $display("%m value underflow (%f:%f)", float_imag[idx]/$itor(num), P_TWID_FIXED_MIN_VALUE);
        end
        bit_reverse_swap_dif(num); // bit-reverse-swap on data_fixed_imag/data_fixed_imag
    end
    endtask
    //--------------------------------------------------------------------------
    function real data_fixed2real;
        input signed [P_SAMPLE_FIXED_WID-1:0] fixed;
        integer signed ifrac;
        real    rfrac;
    begin
        ifrac = 1<<P_SAMPLE_FIXED_FRAC;
        rfrac = $itor(ifrac);
        data_fixed2real = $itor(fixed)/rfrac;
    end
    endfunction
    //--------------------------------------------------------------------------
    function signed [P_FFT_FIXED_WID-1:0] fft_real2fixed;
        input  real value;
        integer signed ifrac;
        real    rfrac;
    begin
        ifrac = 1<<P_FFT_FIXED_FRAC;
        rfrac = $itor(ifrac);
        fft_real2fixed = $rtoi(value*rfrac);
    end
    endfunction
    //--------------------------------------------------------------------------
    // bit-reverse swap on input data for decimation in time
    task bit_reverse_swap_dit;
        input [31:0] num; // number of samples
        integer nb;
        reg [15:0] idx, idy, idz;
        reg [P_SAMPLE_FIXED_WID-1:0] rtmp, itmp;
    begin
        nb = clogb2(num);
        for (idx=0; idx<num; idx=idx+1) begin
             idy = 16'h0;
             for (idz=0; idz<nb; idz=idz+1) idy[idz] = idx[nb-1-idz];
             if (idx<idy) begin
                 rtmp = data_fixed_real[idx];
                 itmp = data_fixed_imag[idx];
                 data_fixed_real[idx] = data_fixed_real[idy];
                 data_fixed_imag[idx] = data_fixed_imag[idy];
                 data_fixed_real[idy] = rtmp;
                 data_fixed_imag[idy] = itmp;
             end
        end
    end
    endtask
    //--------------------------------------------------------------------------
    // bit-reverse swap on output data for decimation in frequency
    task bit_reverse_swap_dif;
        input [31:0] num; // number of samples
        integer nb;
        reg [15:0] idx, idy, idz;
        reg [P_FFT_FIXED_WID-1:0] rtmp, itmp;
    begin
        nb = clogb2(num);
        for (idx=0; idx<num; idx=idx+1) begin
             idy = 16'h0;
             for (idz=0; idz<nb; idz=idz+1) idy[idz] = idx[nb-1-idz];
             if (idx<idy) begin
                 rtmp = fft_fixed_real[idx];
                 itmp = fft_fixed_imag[idx];
                 fft_fixed_real[idx] = fft_fixed_real[idy];
                 fft_fixed_imag[idx] = fft_fixed_imag[idy];
                 fft_fixed_real[idy] = rtmp;
                 fft_fixed_imag[idy] = itmp;
             end
        end
    end
    endtask
    //--------------------------------------------------------------------------
    localparam real PI=3.141592
                  , TWO_PI=2.0*PI;
    //--------------------------------------------------------------------------
    // It fills 'num/2' twiddle factos for 'num' samples.
    task make_wtable;
        input [31:0] num; // number of samples
        input        direction; // 1=forward, 0=inverse
        reg [8*128-1:0] file_name;
        integer fp;
        integer idx;
        real theta, epsilon;
    begin
        if (direction) theta = TWO_PI/$itor(num); // forward
        else           theta =-TWO_PI/$itor(num);
        wtable_float_real[0] = 1.0;
        wtable_float_imag[0] = 0.0;
        for (idx=1; idx<(num/2); idx=idx+1) begin
             epsilon = theta*$itor(idx);
             wtable_float_real[idx] =  $cos(epsilon);
             wtable_float_imag[idx] = -$sin(epsilon);
        end
        idx = num/4;
        wtable_float_real[idx] = 0.0;
        if (direction) wtable_float_imag[idx] =-1.0; // forward
        else           wtable_float_imag[idx] = 1.0;
        //---------------------------------------------------------------------
        file_name="twiddle_table.txt";
        fp = $fopen(file_name, "wb");
        if (fp==0) begin
            $display("%m %s cannot open", file_name);
        end else begin
            $fwrite(fp, "# sample_num=%0d %s\n", P_FFT_NUM_SAMPLE, (direction) ? "forward" : "inverse");
            for (idx=0; idx<P_FFT_NUM_SAMPLE/2; idx=idx+1) begin
                 $fwrite(fp, "%f %f\n", wtable_float_real[idx], wtable_float_imag[idx]);
            end
            $fclose(fp);
        end
    end
    endtask
    //--------------------------------------------------------------------------
    function integer clogb2;
    input [31:0] value;
    begin
       value = value - 1;
       for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
          value = value >> 1;
       end
    endfunction
    //--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
// Revision History
//
// 2019.04.10: 'ST_PIPE' updated.
// 2019.03.23: Start by Ando Ki (adki@future-ds.com)
//------------------------------------------------------------------------------
