
//
/* 
 * Copyright 2019 IMDEA Networks Institute
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

//
module noc_block_SymbolTiming #(
  parameter NOC_ID = 64'hE753B35003297234,
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
  wire [31:0] set_data;
  wire [7:0]  set_addr;
  wire        set_stb;
  reg  [63:0] rb_data;
  wire [7:0]  rb_addr;

  wire [63:0] cmdout_tdata, ackin_tdata;
  wire        cmdout_tlast, cmdout_tvalid, cmdout_tready, ackin_tlast, ackin_tvalid, ackin_tready;

  wire [63:0] str_sink_tdata, str_src_tdata;
  wire        str_sink_tlast, str_sink_tvalid, str_sink_tready, str_src_tlast, str_src_tvalid, str_src_tready;

  wire [15:0] src_sid;
  wire [15:0] next_dst_sid, resp_out_dst_sid;
  wire [15:0] resp_in_dst_sid;

  wire        clear_tx_seqnum;

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
    .set_data(set_data), .set_addr(set_addr), .set_stb(set_stb), .set_time(), .set_has_time(),
    .rb_stb(1'b1), .rb_data(rb_data), .rb_addr(rb_addr),
    // Control Source
    .cmdout_tdata(cmdout_tdata), .cmdout_tlast(cmdout_tlast), .cmdout_tvalid(cmdout_tvalid), .cmdout_tready(cmdout_tready),
    .ackin_tdata(ackin_tdata), .ackin_tlast(ackin_tlast), .ackin_tvalid(ackin_tvalid), .ackin_tready(ackin_tready),
    // Stream Sink
    .str_sink_tdata(str_sink_tdata), .str_sink_tlast(str_sink_tlast), .str_sink_tvalid(str_sink_tvalid), .str_sink_tready(str_sink_tready),
    // Stream Source
    .str_src_tdata(str_src_tdata), .str_src_tlast(str_src_tlast), .str_src_tvalid(str_src_tvalid), .str_src_tready(str_src_tready),
    // Stream IDs set by host
    .src_sid(src_sid),                   // SID of this block
    .next_dst_sid(next_dst_sid),         // Next destination SID
    .resp_in_dst_sid(resp_in_dst_sid),   // Response destination SID for input stream responses / errors
    .resp_out_dst_sid(resp_out_dst_sid), // Response destination SID for output stream responses / errors
    // Misc
    .vita_time('d0), .clear_tx_seqnum(clear_tx_seqnum),
    .debug(debug));

  ////////////////////////////////////////////////////////////
  //
  // AXI Wrapper
  // Convert RFNoC Shell interface into AXI stream interface
  //
  ////////////////////////////////////////////////////////////
  wire [31:0] m_axis_data_tdata;
  wire        m_axis_data_tlast;
  wire        m_axis_data_tvalid;
  wire        m_axis_data_tready;

  wire [31:0] s_axis_data_tdata;
  wire        s_axis_data_tlast;
  wire        s_axis_data_tvalid;
  wire        s_axis_data_tready;

  axi_wrapper #(
    .SIMPLE_MODE(1))
  axi_wrapper (
    .clk(ce_clk), .reset(ce_rst),
    .bus_clk(bus_clk), .bus_rst(bus_rst),
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
    .m_axis_config_tdata(),
    .m_axis_config_tlast(),
    .m_axis_config_tvalid(),
    .m_axis_config_tready(),
    .m_axis_pkt_len_tdata(),
    .m_axis_pkt_len_tvalid(),
    .m_axis_pkt_len_tready());

  ////////////////////////////////////////////////////////////
  //
  // User code
  //
  ////////////////////////////////////////////////////////////
  // NoC Shell registers 0 - 127,
  // User register address space starts at 128
  localparam SR_USER_REG_BASE = 128;

  // Control Source Unused
  assign cmdout_tdata  = 64'd0;
  assign cmdout_tlast  = 1'b0;
  assign cmdout_tvalid = 1'b0;
  assign ackin_tready  = 1'b1;

  // Settings registers
  //
  // - The settings register bus is a simple strobed interface.
  // - Transactions include both a write and a readback.
  // - The write occurs when set_stb is asserted.
  //   The settings register with the address matching set_addr will
  //   be loaded with the data on set_data.
  // - Readback occurs when rb_stb is asserted. The read back strobe
  //   must assert at least one clock cycle after set_stb asserts /
  //   rb_stb is ignored if asserted on the same clock cycle of set_stb.
  //   Example valid and invalid timing:
  //              __    __    __    __
  //   clk     __|  |__|  |__|  |__|  |__
  //               _____
  //   set_stb ___|     |________________
  //                     _____
  //   rb_stb  _________|     |__________     (Valid)
  //                           _____
  //   rb_stb  _______________|     |____     (Valid)
  //           __________________________
  //   rb_stb                                 (Valid if readback data is a constant)
  //               _____
  //   rb_stb  ___|     |________________     (Invalid / ignored, same cycle as set_stb)
  //
  localparam [7:0] SR_N           = 129;
  localparam [7:0] SR_VECTOR_MODE = 130;

  wire [15:0] n;
  setting_reg #(
    .my_addr(SR_N), .awidth(8), .width(16), .at_reset(1))
  sr_n (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(n), .changed());

  wire vector_mode;
  setting_reg #(
    .my_addr(SR_VECTOR_MODE), .awidth(8), .width(1), .at_reset(1) /* Drop vectors by default */)
  sr_vector_mode (
    .clk(ce_clk), .rst(ce_rst),
    .strobe(set_stb), .addr(set_addr), .in(set_data), .out(vector_mode), .changed());

  // Readback registers
  // rb_stb set to 1'b1 on NoC Shell
  always @(posedge ce_clk) begin
    case(rb_addr)
      8'd0 : rb_data <= {48'd0, n};
      8'd1 : rb_data <= {63'd0, vector_mode};
      default : rb_data <= 64'h0BADC0DE0BADC0DE;
    endcase
  end

  // Modify packet header data, same as input except SRC / DST SID fields.
  cvita_hdr_modify cvita_hdr_modify (
    .header_in(m_axis_data_tuser),
    .header_out(s_axis_data_tuser),
    .use_pkt_type(1'b0),       .pkt_type(),
    .use_has_time(1'b0),       .has_time(),
    .use_eob(1'b0),            .eob(),
    .use_seqnum(1'b0),         .seqnum(),
    .use_length(1'b0),         .length(),
    .use_payload_length(1'b0), .payload_length(),
    .use_src_sid(1'b1),        .src_sid(src_sid),
    .use_dst_sid(1'b1),        .dst_sid(next_dst_sid),
    .use_vita_time(1'b0),      .vita_time());

  // Note: When dropping samples (i.e. vector_mode = 0), unless this block receives a multiple
  //       of N packets (where N is the decimation rate), there will be a partial formed output
  //       packet. This partial formed packet must be cleared before restarting the block. We
  //       can use clear_tx_seqnum for that purpose as it is strobed at block initialization.

/*
  SymbolTiming2 #(
    .WIDTH(32),
    .MAX_N(2**16-1))
  SymbolTiming (
    .clk(ce_clk),
    .reset(ce_rst | clear_tx_seqnum),
    .vector_mode(vector_mode), .n(n),
    .i_tdata(m_axis_data_tdata), .i_tlast(m_axis_data_tlast), .i_tvalid(m_axis_data_tvalid), .i_tready(m_axis_data_tready),
    .o_tdata(s_axis_data_tdata), .o_tlast(s_axis_data_tlast), .o_tvalid(s_axis_data_tvalid), .o_tready(s_axis_data_tready));
*/

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
    .o_tready(pipe_in_tready)
  );  

  SymbolTiming SymbolTiming_vhdl (
    .clk(ce_clk),
    .rst(ce_rst | clear_tx_seqnum),
    .i_data_TDATA(pipe_in_tdata), 
    .i_data_TLAST(pipe_in_tlast), 
    .i_data_TVALID(pipe_in_tvalid), 
    .i_data_TREADY(pipe_in_tready),
    .o_data_TDATA(pipe_out_tdata), 
    .o_data_TLAST(pipe_out_tlast), 
    .o_data_TVALID(pipe_out_tvalid), 
    .o_data_TREADY(pipe_out_tready));

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
    .o_tready(s_axis_data_tready)
  );


endmodule
