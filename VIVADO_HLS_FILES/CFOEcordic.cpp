#include <stdio.h>
#include <stdlib.h>
#include <hls_math.h>
#include <ap_int.h>

#include "atan.h"
#include <hls_stream.h>

typedef ap_int<32> int_32;
typedef ap_int<23> int_23;

void CFOEcordic(hls::stream<int_32> i_data, hls::stream<int_23> o_data, ap_uint<16> n_iter)
{

#pragma HLS PIPELINE II=1
#pragma HLS RESOURCE variable=o_data latency=1

#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_ctrl_none port=n_iter
#pragma HLS INTERFACE axis port=o_data
#pragma HLS INTERFACE axis port=i_data

static ap_int<32> tmp_data;
static ap_int<16> itmp, qtmp;
static ap_int<23> z_plus_bit, z = 0;
static ap_uint<16> n;
static ap_int<17> i_plus_bit, q_plus_bit;
#pragma HLS RESET variable=i_plus_bit
#pragma HLS RESET variable=q_plus_bit
#pragma HLS RESET variable=z_plus_bit

static ap_uint<24> data_valid_reg;

n = n_iter.read();

if(!i_data.empty()){

	i_data.read(tmp_data);
  itmp = tmp_data.range(31,16); // RE 
  qtmp = tmp_data.range(15,0); // IM

  i_plus_bit = itmp; // RE 
	q_plus_bit = qtmp; // IM 
	z_plus_bit = 0;

	for(int idx=0;idx<n;idx++){
	#pragma HLS PIPELINE
  //#pragma HLS UNROLL
		if(q_plus_bit<0){
				i_plus_bit = i_plus_bit - qtmp;
				q_plus_bit = q_plus_bit + itmp;
				z_plus_bit = z_plus_bit - atan_value[idx];
			}
		else{
			i_plus_bit = i_plus_bit + qtmp;
			q_plus_bit = q_plus_bit - itmp;
			z_plus_bit = z_plus_bit + atan_value[idx];
		}

		// Reduce step
		itmp = (i_plus_bit >> (idx+1));
		qtmp = (q_plus_bit >> (idx+1));
	}

		o_data.write(z_plus_bit);
}

}
