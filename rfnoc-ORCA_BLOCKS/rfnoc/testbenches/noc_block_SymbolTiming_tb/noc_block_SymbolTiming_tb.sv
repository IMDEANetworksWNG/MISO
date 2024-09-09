/* 
 * Copyright 2019 IMDEA Networks Institute - Spain
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

`timescale 1ns/1ps
`define NS_PER_TICK 1
`define NUM_TEST_CASES 4

`include "sim_exec_report.vh"
`include "sim_clks_rsts.vh"
`include "sim_rfnoc_lib.svh"

module noc_block_SymbolTiming_tb();
  `TEST_BENCH_INIT("noc_block_SymbolTiming",`NUM_TEST_CASES,`NS_PER_TICK);
  localparam BUS_CLK_PERIOD = $ceil(1e9/166.67e6);
  localparam CE_CLK_PERIOD  = $ceil(1e9/200e6);
  localparam NUM_CE         = 1;  // Number of Computation Engines / User RFNoC blocks to simulate
  localparam NUM_STREAMS    = 1;  // Number of test bench streams
  `RFNOC_SIM_INIT(NUM_CE, NUM_STREAMS, BUS_CLK_PERIOD, CE_CLK_PERIOD);
  `RFNOC_ADD_BLOCK(noc_block_SymbolTiming, 0);

  localparam SPP = 16; // Samples per packet
  localparam MAX_N = 16;

  /********************************************************
  ** Verification
  ********************************************************/
  initial begin : tb_main
    string s;
    logic [31:0] random_word;
    logic [63:0] readback;

    /********************************************************
    ** Test 1 -- Reset
    ********************************************************/
    `TEST_CASE_START("Wait for Reset");
    while (bus_rst) @(posedge bus_clk);
    while (ce_rst) @(posedge ce_clk);
    `TEST_CASE_DONE(~bus_rst & ~ce_rst);

    /********************************************************
    ** Test 2 -- Check for correct NoC IDs
    ********************************************************/
    `TEST_CASE_START("Check NoC ID");
    // Read NOC IDs
    tb_streamer.read_reg(sid_noc_block_SymbolTiming, RB_NOC_ID, readback);
    $display("Read SymbolTiming NOC ID: %16x", readback);
    `ASSERT_ERROR(readback == noc_block_SymbolTiming.NOC_ID, "Incorrect NOC ID");
    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 3 -- Connect RFNoC blocks
    ********************************************************/
    `TEST_CASE_START("Connect RFNoC blocks");
    `RFNOC_CONNECT(noc_block_tb,noc_block_SymbolTiming,SC16,SPP);
    `RFNOC_CONNECT(noc_block_SymbolTiming,noc_block_tb,SC16,SPP);
    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 4 -- Write / readback user registers
    ********************************************************/
/*    `TEST_CASE_START("Write / readback user registers");
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_SymbolTiming, noc_block_SymbolTiming.SR_TEST_REG_0, random_word);
    tb_streamer.read_user_reg(sid_noc_block_SymbolTiming, 0, readback);
    $sformat(s, "User register 0 incorrect readback! Expected: %0d, Actual %0d", readback[31:0], random_word);
    `ASSERT_ERROR(readback[31:0] == random_word, s);
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_SymbolTiming, noc_block_SymbolTiming.SR_TEST_REG_1, random_word);
    tb_streamer.read_user_reg(sid_noc_block_SymbolTiming, 1, readback);
    $sformat(s, "User register 1 incorrect readback! Expected: %0d, Actual %0d", readback[31:0], random_word);
    `ASSERT_ERROR(readback[31:0] == random_word, s);
    `TEST_CASE_DONE(1);
*/

    /********************************************************
    ** Test 5 -- Test sample mode
    ********************************************************/
    `TEST_CASE_START("Test sample mode (keep one in n samples)");
    for (int n = 2; n <=2; n++) begin
      $display("Test N = %0d", n);
      tb_streamer.write_user_reg(sid_noc_block_SymbolTiming,noc_block_SymbolTiming.SR_N,n);
      tb_streamer.write_user_reg(sid_noc_block_SymbolTiming,noc_block_SymbolTiming.SR_VECTOR_MODE,0);
      fork
        begin
          // Send N packets, only one packet should come out
          for (int l = 0; l < n; l++) begin
            for (int i = 0; i < SPP; i++) begin
              tb_streamer.push_word(32'(l*SPP+i),(i == SPP-1));
            end
          end
        end
        begin
          logic [31:0] expected_value, received_value;
          logic last;
          for (int i = 0; i < SPP; i++) begin
            expected_value = 32'(n*(i+1)-1);
            tb_streamer.pull_word(received_value,last);
            $sformat(s, "N = %0d: Incorrect value received! Expected: %0d, Received: %0d", n, expected_value, received_value);
            `ASSERT_ERROR(received_value == expected_value, s);
            //if (i == SPP-1) begin
            //  `ASSERT_ERROR(last == 1'b1, "Incorrect packet length! End of packet not asserted!");
            //end else begin
            //  `ASSERT_ERROR(last == 1'b0, "Incorrect packet length! End of packet asserted early!");
            //end
          end
        end
      join
    end
    `TEST_CASE_DONE(1);
    `TEST_BENCH_DONE;

  end
endmodule
