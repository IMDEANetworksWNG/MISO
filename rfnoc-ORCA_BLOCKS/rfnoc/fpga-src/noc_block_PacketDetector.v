// Copyright (c) 2019 - IMDEA Networks Institute, Spain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


module noc_block_PacketDetector #(
  parameter NOC_ID = 64'hFFFF_C100_0000_0000,
  parameter STR_SINK_FIFOSIZE = 11)
(
  input bus_clk, input bus_rst,
  input ce_clk, input ce_rst,
  input  [63:0] i_tdata, input  i_tlast, input  i_tvalid, output i_tready,
  output [63:0] o_tdata, output o_tlast, output o_tvalid, input  o_tready,
  output [63:0] debug
);

  ////////////////////////////////////////////////////////////
  //
  // RFNoC Shell
  //
  ////////////////////////////////////////////////////////////

  wire [63:0] cmdout_tdata, ackin_tdata;
  wire        cmdout_tlast, cmdout_tvalid, cmdout_tready, ackin_tlast, ackin_tvalid, ackin_tready;

  wire [63:0] str_sink_tdata, str_src_tdata;
  wire        str_sink_tlast, str_sink_tvalid, str_sink_tready, str_src_tlast, str_src_tvalid, str_src_tready;

  wire [31:0] set_data;
  wire [7:0]  set_addr;
  wire        set_stb;
  reg  [63:0] rb_data;
  wire [7:0]  rb_addr;



  wire        clear_tx_seqnum;
  wire [15:0] next_dst_sid;

  noc_shell #(
    .NOC_ID(NOC_ID),
    .STR_SINK_FIFOSIZE(STR_SINK_FIFOSIZE))
  noc_shell (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .i_tdata(i_tdata), .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
    .o_tdata(o_tdata), .o_tlast(o_tlast), .o_tvalid(o_tvalid), .o_tready(o_tready),
    // Computer Engine Clock Domain
    .clk(ce_clk), .reset(ce_rst),
    // Control Sink
    .set_data(set_data), .set_addr(set_addr), .set_stb(set_stb), .set_time(),
    .rb_stb(1'b1), .rb_data(rb_data), .rb_addr(rb_addr),
    // Control Source
    .cmdout_tdata(cmdout_tdata), .cmdout_tlast(cmdout_tlast), .cmdout_tvalid(cmdout_tvalid), .cmdout_tready(cmdout_tready),
    .ackin_tdata(ackin_tdata), .ackin_tlast(ackin_tlast), .ackin_tvalid(ackin_tvalid), .ackin_tready(ackin_tready),
    // Stream Sink
    .str_sink_tdata(str_sink_tdata), .str_sink_tlast(str_sink_tlast), .str_sink_tvalid(str_sink_tvalid), .str_sink_tready(str_sink_tready),
    // Stream Source
    .str_src_tdata(str_src_tdata), .str_src_tlast(str_src_tlast), .str_src_tvalid(str_src_tvalid), .str_src_tready(str_src_tready),
    // Misc
    .vita_time(64'd0), .clear_tx_seqnum(clear_tx_seqnum),
    .src_sid(), .next_dst_sid(next_dst_sid), .resp_in_dst_sid(), .resp_out_dst_sid(),
    .debug(debug));

  ////////////////////////////////////////////////////////////
  //
  // AXI Wrapper
  // Convert RFNoC Shell interface into AXI stream interface
  //
  ////////////////////////////////////////////////////////////
  localparam NUM_AXI_CONFIG_BUS = 1;
  
  wire [31:0] m_axis_data_tdata;
  wire        m_axis_data_tlast;
  wire        m_axis_data_tvalid;
  wire        m_axis_data_tready;
  
  wire [31:0] s_axis_data_tdata;
  wire        s_axis_data_tlast;
  wire        s_axis_data_tvalid;
  wire        s_axis_data_tready;
  
  wire [31:0] m_axis_config_tdata;
  wire        m_axis_config_tvalid;
  wire        m_axis_config_tready;
  
  localparam AXI_WRAPPER_BASE    = 128;
  localparam SR_AXI_CONFIG_BASE  = AXI_WRAPPER_BASE + 1;

  axi_wrapper #(
    .SIMPLE_MODE(1),
    .SR_AXI_CONFIG_BASE(SR_AXI_CONFIG_BASE),
    .NUM_AXI_CONFIG_BUS(NUM_AXI_CONFIG_BUS))
  inst_axi_wrapper (
    .clk(ce_clk), .reset(ce_rst),
    .bus_clk(bus_clk), .bus_rst(bus_rst),      //  <-  this line   
    .clear_tx_seqnum(clear_tx_seqnum),
    .next_dst(next_dst_sid),
    .set_stb(set_stb), .set_addr(set_addr), .set_data(set_data),
    .i_tdata(str_sink_tdata), .i_tlast(str_sink_tlast), .i_tvalid(str_sink_tvalid), .i_tready(str_sink_tready),
    .o_tdata(str_src_tdata), .o_tlast(str_src_tlast), .o_tvalid(str_src_tvalid), .o_tready(str_src_tready),
    .m_axis_data_tdata(m_axis_data_tdata),
    .m_axis_data_tlast(m_axis_data_tlast),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tready(m_axis_data_tready),
    .m_axis_data_tuser(),
    .s_axis_data_tdata(s_axis_data_tdata),
    .s_axis_data_tlast(s_axis_data_tlast),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tready(s_axis_data_tready),
    .s_axis_data_tuser(),
    .m_axis_config_tdata(m_axis_config_tdata),
    .m_axis_config_tlast(),
    .m_axis_config_tvalid(m_axis_config_tvalid),
    .m_axis_config_tready(m_axis_config_tready),
    .m_axis_pkt_len_tdata(),
    .m_axis_pkt_len_tvalid(),
    .m_axis_pkt_len_tready());
  
  ////////////////////////////////////////////////////////////
  //
  // User code
  //
  ////////////////////////////////////////////////////////////
  
  // Control Source Unused
  assign cmdout_tdata  = 64'd0;
  assign cmdout_tlast  = 1'b0;
  assign cmdout_tvalid = 1'b0;
  assign ackin_tready  = 1'b1;

  localparam [7:0] SR_PD_THRESHOLD    = 133;
  localparam [7:0] SR_NOISE_THRESHOLD = 134;
  localparam [7:0] SR_N_COUNT         = 135;
  localparam [7:0] SR_PD_HIGH_TIME    = 136;
  localparam [7:0] SR_SEL_OUT         = 137;
  localparam [7:0] SR_NPER            = 138;

  wire [15:0] PD_threshold;
  wire [15:0] noise_threshold;
  wire [15:0] N_COUNT;
  wire [15:0] PD_HIGH_TIME;
  wire [1:0] SEL_OUT;
  wire [7:0] NPER;

  setting_reg #(
    .my_addr(SR_PD_THRESHOLD), .awidth(8), .width(16))
  sr_pd_threshold (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(PD_threshold), .changed());// 
  setting_reg #(
    .my_addr(SR_NOISE_THRESHOLD), .awidth(8), .width(16))
  sr_noise_threshold(
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(noise_threshold), .changed());// 

  setting_reg #(
    .my_addr(SR_N_COUNT), .awidth(8), .width(16))
  sr_N_COUNT(
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(N_COUNT), .changed());// 

  setting_reg #(
    .my_addr(SR_PD_HIGH_TIME), .awidth(8), .width(16))
  sr_PD_HIGH_TIME(
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(PD_HIGH_TIME), .changed());// 

  setting_reg #(
    .my_addr(SR_SEL_OUT), .awidth(8), .width(2))
  sr_SEL_OUT(
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(SEL_OUT), .changed());// 

  setting_reg #(
    .my_addr(SR_NPER), .awidth(8), .width(8))
  sr_NPER(
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(NPER), .changed());// 

  wire [31:0] pipe_in_tdata;
  wire pipe_in_tvalid, pipe_in_tlast;
  wire pipe_in_tready;

  wire [31:0] pipe_out_tdata;
  wire pipe_out_tvalid, pipe_out_tlast;
  wire pipe_out_tready;

  // Adding FIFO to ensure Pipeline
  axi_fifo_flop #(.WIDTH(32+1))
  pipeline0_axi_fifo_flop (
    .clk(ce_clk),
    .reset(ce_rst),
    .clear(clear_tx_seqnum),
    .i_tdata({m_axis_data_tlast,m_axis_data_tdata}),
    .i_tvalid(m_axis_data_tvalid),
    .i_tready(m_axis_data_tready),
    .o_tdata({pipe_in_tlast,pipe_in_tdata}),
    .o_tvalid(pipe_in_tvalid),
    .o_tready(pipe_in_tready));  

  PacketDetector inst_PacketDetector(
    .ap_clk(ce_clk), 
    .ap_rst_n(~ce_rst), 
    .i_data_TDATA(pipe_in_tdata), // SC16
    .i_data_TVALID(pipe_in_tvalid),
    .i_data_TREADY(pipe_in_tready),
    .i_data_TLAST(pipe_in_tlast),
    .o_data_TDATA(pipe_out_tdata), // 32 bit integer 
    .o_data_TVALID(pipe_out_tvalid),
    .o_data_TREADY(pipe_out_tready),
    .o_data_TLAST(pipe_out_tlast),
    .PD_threshold(PD_threshold),
    .noise_threshold(noise_threshold),
    .N_COUNT(N_COUNT),
    .PD_HIGH_TIME(PD_HIGH_TIME),
    .SEL_OUT(SEL_OUT),
    .NPER(NPER)
  );

  axi_fifo_flop #(.WIDTH(32+1))
  pipeline1_axi_fifo_flop (
    .clk(ce_clk),
    .reset(ce_rst),
    .clear(clear_tx_seqnum),
    .i_tdata({pipe_out_tlast,pipe_out_tdata}),
    .i_tvalid(pipe_out_tvalid),
    .i_tready(pipe_out_tready),
    .o_tdata({s_axis_data_tlast,s_axis_data_tdata}),
    .o_tvalid(s_axis_data_tvalid),
    .o_tready(s_axis_data_tready));

  // Readback registers
  always @*
    case(rb_addr)
      8'd2    : rb_data <= {48'd0, PD_threshold};
      8'd3    : rb_data <= {48'd0, noise_threshold};
      8'd4    : rb_data <= {48'd0, N_COUNT};
      8'd5    : rb_data <= {48'd0, PD_HIGH_TIME};
      8'd6    : rb_data <= {62'd0, SEL_OUT};
      8'd7    : rb_data <= {56'd0, NPER};
      default : rb_data <= 64'h0BADC0DE0BADC0DE;
  endcase

endmodule
