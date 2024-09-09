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
`define NUM_TEST_CASES 6 

`include "sim_exec_report.vh"
`include "sim_clks_rsts.vh"
`include "sim_rfnoc_lib.svh"

typedef logic[31:0] sample_t[$];

module noc_block_PacketDetector_tb();

function sample_t get_samples_from_file(int num_samples);
  sample_t sample;
  int fd; // file descriptor
  int real_part, imag_part,status;
  
  fd = $fopen("IDATA_INT.dat","r");

  begin
    for(int i = 0; i<num_samples; i++)
    begin
      status = $fscanf(fd,"%d,%d",real_part,imag_part); 
      sample[i] = {real_part[15:0],imag_part[15:0]};
    end
  end
  // Close this file handle
  $fclose(fd);		
  return sample;
endfunction;

function sample_t get_expected_out_from_file(int num_samples);
  sample_t sample;
  int fd; // file descriptor
  int real_part,status;
  
  fd = $fopen("ODATA_INT.dat","r");

  begin
    for(int i = 0; i<num_samples; i++)
    begin
      status = $fscanf(fd,"%d",real_part); 
      sample[i] = real_part[31:0];
    end
  end

  // Close this file handle
  $fclose(fd);
  return sample;
endfunction;


function cvita_payload_t get_payload(sample_t sample, int num_samples);
  cvita_payload_t payload;
  begin
    for(int i = 0; i<num_samples/2; i++)
    begin
      payload.push_back({sample[2*i], sample[2*i + 1]});
      if((2*i + 1) == num_samples-2) // when num_samples is odd
      begin
        payload.push_back({sample[2*i + 2],32'd0});
      end
    end
  end
  return payload;
endfunction 

  `TEST_BENCH_INIT("noc_block_PacketDetector",`NUM_TEST_CASES,`NS_PER_TICK);
  localparam BUS_CLK_PERIOD = $ceil(1e9/166.67e6);
  localparam CE_CLK_PERIOD  = $ceil(1e9/200e6);
  localparam NUM_CE         = 1;  // Number of Computation Engines / User RFNoC blocks to simulate
  localparam NUM_STREAMS    = 1;  // Number of test bench streams
  `RFNOC_SIM_INIT(NUM_CE, NUM_STREAMS, BUS_CLK_PERIOD, CE_CLK_PERIOD);
  `RFNOC_ADD_BLOCK(noc_block_PacketDetector, 0);

  localparam SPP = 16; // Samples per packet
  localparam num_samples = 40000;
  sample_t sample, expected_sample;
  cvita_payload_t payload;// 64 bit word i.e., one payload word = 2 samples*/
  cvita_metadata_t md1;  
  
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
    tb_streamer.read_reg(sid_noc_block_PacketDetector, RB_NOC_ID, readback);
    $display("Read PacketDetector NOC ID: %16x", readback);
    `ASSERT_ERROR(readback == noc_block_PacketDetector.NOC_ID, "Incorrect NOC ID");
    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 3 -- Connect RFNoC blocks
    ********************************************************/
    `TEST_CASE_START("Connect RFNoC blocks");
    `RFNOC_CONNECT(noc_block_tb,noc_block_PacketDetector,SC16,SPP);
    `RFNOC_CONNECT(noc_block_PacketDetector,noc_block_tb,SC16,SPP);
    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 4 -- Write / readback user registers
    ********************************************************/
    `TEST_CASE_START("Write / readback user registers");
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_PD_THRESHOLD, random_word[15:0]);
    tb_streamer.read_user_reg(sid_noc_block_PacketDetector, 2, readback);
    $sformat(s, "User register SR_PD_THRESHOLD incorrect readback! Expected: %0d, Actual %0d", readback[15:0], random_word[15:0]);
    `ASSERT_ERROR(readback[15:0] == random_word[15:0], s);
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_NOISE_THRESHOLD, random_word[15:0]);
    tb_streamer.read_user_reg(sid_noc_block_PacketDetector, 3, readback);
    $sformat(s, "User register SR_NOISE_THRESHOLD incorrect readback! Expected: %0d, Actual %0d", readback[15:0], random_word[15:0]);
    `ASSERT_ERROR(readback[15:0] == random_word[15:0], s);
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_N_COUNT, random_word[15:0]);
    tb_streamer.read_user_reg(sid_noc_block_PacketDetector, 4, readback);
    $sformat(s, "User register SR_N_COUNT incorrect readback! Expected: %0d, Actual %0d", readback[15:0], random_word[15:0]);
    `ASSERT_ERROR(readback[15:0] == random_word[15:0], s);
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_PD_HIGH_TIME, random_word[15:0]);
    tb_streamer.read_user_reg(sid_noc_block_PacketDetector, 5, readback);
    $sformat(s, "User register SR_PD_HIGH_TIME incorrect readback! Expected: %0d, Actual %0d", readback[15:0], random_word[15:0]);
    `ASSERT_ERROR(readback[15:0] == random_word[15:0], s);
    random_word = $random();
    tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_SEL_OUT, random_word[0:0]);
    tb_streamer.read_user_reg(sid_noc_block_PacketDetector, 6, readback);
    $sformat(s, "User register SR_SEL_OUT incorrect readback! Expected: %0d, Actual %0d", readback[0:0], random_word[0:0]);
    `ASSERT_ERROR(readback[0:0] == random_word[0:0], s);
    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 5 -- Test sequence SEL_OUT = 1
    ********************************************************/
    `TEST_CASE_START("Test sequence SEL = 1");
    fork
    begin

      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_SEL_OUT, 1);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_PD_THRESHOLD, 128);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_NOISE_THRESHOLD, 16);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_N_COUNT, 256-2);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_PD_HIGH_TIME, 17*128*2*3);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_NPER, 7);
      sample = get_samples_from_file(num_samples);
      expected_sample = get_expected_out_from_file(num_samples);

      payload = get_payload(sample, num_samples); // 64 bit word i.e., one payload word = 2 samples
      tb_streamer.send(payload,md1);

    end
    begin

      cvita_payload_t recv_payload;
      cvita_metadata_t md;
      int sample_count = 0;
    
      while(sample_count < num_samples-2) begin
        tb_streamer.recv(recv_payload,md);
        for (int k = 0; k < recv_payload.size(); k++) begin
          //$display("sample %0d => RECEIVED FRAME = %0d -- EXPECTED = %0d",sample_count, recv_payload[k][63:32],expected_sample[sample_count]);
          $sformat(s, "Incorrect value received sample = %0d! Expected: %0d, Received: %0d", sample_count, expected_sample[sample_count][31:1], recv_payload[k][63:33]);
          `ASSERT_ERROR(recv_payload[k][63:33] == expected_sample[sample_count][31:1], s);
          $sformat(s, "Incorrect PD-FLAG sample = %0d! Expected: %0d, Received: %0d", sample_count, expected_sample[sample_count][0:0], recv_payload[k][32:32]);
          `ASSERT_ERROR(recv_payload[k][32:32] == expected_sample[sample_count][0:0], s);
          sample_count++;
          //$display("sample %0d  => RECEIVED FRAME = %0d -- EXPECTED = %0d",sample_count, recv_payload[k][31:0],expected_sample[sample_count]);
          $sformat(s, "Incorrect value received sample = %0d! Expected: %0d, Received: %0d", sample_count,  expected_sample[sample_count][31:1], recv_payload[k][31:1]);
          `ASSERT_ERROR(recv_payload[k][31:1] == expected_sample[sample_count][31:1], s);
          $sformat(s, "Incorrect PD-FLAG sample = %0d! Expected: %0d, Received: %0d", sample_count, expected_sample[sample_count][0:0], recv_payload[k][0:0]);
          `ASSERT_ERROR(recv_payload[k][0:0] == expected_sample[sample_count][0:0], s);
          sample_count++;
        end
      end

    end
    join
    `TEST_CASE_DONE(1);

    /********************************************************
    ** Test 6 -- Write Output Data File SEL_OUT = 3
    ********************************************************/
    `TEST_CASE_START("Test sequence SEL = 3 -- Write Output Data to a File");
    fork
    begin

      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_SEL_OUT, 3);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_PD_THRESHOLD, 128);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_NOISE_THRESHOLD, 16);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_N_COUNT, 256-2);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_PD_HIGH_TIME, 17*128*2*3);
      tb_streamer.write_user_reg(sid_noc_block_PacketDetector, noc_block_PacketDetector.SR_NPER, 7);
      sample = get_samples_from_file(num_samples);
      
      payload = get_payload(sample, num_samples); // 64 bit word i.e., one payload word = 2 samples
      tb_streamer.send(payload,md1);

    end
    begin

      cvita_payload_t recv_payload;
      cvita_metadata_t md;
      int sample_count = 0;
			int    fd;       // Variable for file descriptor handle
    
	    // 1. Lets first open a new file and write some contents into it
  	  fd = $fopen ("../../../../../../noc_block_CFOC_tb/FIXED_POINT_MODEL/PD_ODATA.dat", "w");

      while(sample_count < num_samples-2) begin
        tb_streamer.recv(recv_payload,md);
        for (int k = 0; k < recv_payload.size(); k++) begin
	      	$fdisplay (fd, "%0d", recv_payload[k][63:32]);
          sample_count++;
          $fdisplay (fd, "%0d", recv_payload[k][31:0]);
          sample_count++;
        end
      end

	    // Close this file handle
	    $fclose(fd);

    end
    join
    `TEST_CASE_DONE(1);
    `TEST_BENCH_DONE;

  end
endmodule
