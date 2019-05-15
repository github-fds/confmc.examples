//------------------------------------------------------------------------------
`include "fft_model_fixed.v"

//------------------------------------------------------------------------------
module xfft_16bit256samples(
       input  wire        aclk
     , input  wire        aresetn
     , input  wire [ 7:0] s_axis_config_tdata
     , input  wire        s_axis_config_tvalid
     , output reg         s_axis_config_tready=1'b1
     , input  wire [31:0] s_axis_data_tdata
     , input  wire        s_axis_data_tvalid
     , output wire        s_axis_data_tready
     , input  wire        s_axis_data_tlast
     , output wire [63:0] m_axis_data_tdata
     , output reg  [ 7:0] m_axis_data_tuser=8'h0
     , output wire        m_axis_data_tvalid
     , input  wire        m_axis_data_tready
     , output wire        m_axis_data_tlast
     , output reg         event_frame_started=1'b0
     , output reg         event_tlast_unexpected=1'b0
     , output reg         event_tlast_missing=1'b0
     , output reg         event_status_channel_halt=1'b0
     , output reg         event_data_in_channel_halt=1'b0
     , output reg         event_data_out_channel_halt=1'b0
);
   //---------------------------------------------------------------------------
   always @ (posedge aclk or negedge aresetn) begin
   if (aresetn==1'b0) begin
       s_axis_config_tready = 1'b1;
   end else begin
       if (s_axis_config_tvalid==1'b1) begin
           s_axis_config_tready = 1'b0;
       end
   end // if
   end // always
   //---------------------------------------------------------------------------
   fft_model_fixed #(.P_SAMPLE_NUM       (1 )
                    ,.P_SAMPLE_FIXED_INT (2 ) // for s_axis_tdata_fixed
                    ,.P_SAMPLE_FIXED_FRAC(14) // for s_axis_tdata_fixed
                    ,.P_TWID_FIXED_INT   (2 )
                    ,.P_TWID_FIXED_FRAC  (14)
                    ,.P_FFT_FIXED_INT    (2+16) // for m_axis_tdata_fixed
                    ,.P_FFT_FIXED_FRAC   (14 ) // for m_axis_tdata_fixed
                    ,.P_DIT              (1  )//1=DIT, 0=DIF
                    ,.P_DIR              (1  )//1=forward, 0=inverse
                    )
   u_fft_fixed (
       .axis_reset_n  ( aresetn             )
     , .axis_clk      ( aclk                )
     , .s_axis_tvalid ( s_axis_data_tvalid  )
     , .s_axis_tready ( s_axis_data_tready  )
     , .s_axis_tdata  ( s_axis_data_tdata   )
     , .m_axis_tvalid ( m_axis_data_tvalid  )
     , .m_axis_tready ( m_axis_data_tready  )
     , .m_axis_tlast  ( m_axis_data_tlast   )
     , .m_axis_tdata  ( m_axis_data_tdata   )
   );
endmodule
//------------------------------------------------------------------------------
