#include <stdio.h>
#include <stdlib.h>
#include <hls_math.h>
#include <ap_int.h>

#include "quarter_sin.h"
#include <hls_stream.h>

struct rfnoc_axis{
  ap_int<32> data;
  ap_uint<1> last;
};

void CFOCddfs(hls::stream<rfnoc_axis> i_data, hls::stream<rfnoc_axis> o_data, ap_int<33> FCW)
{

	#pragma HLS PIPELINE II=1
	#pragma HLS RESOURCE variable=o_data latency=1

	#pragma HLS INTERFACE ap_ctrl_none port=return
	#pragma HLS INTERFACE ap_ctrl_none port=FCW
	#pragma HLS INTERFACE axis port=o_data
	#pragma HLS INTERFACE axis port=i_data

	static rfnoc_axis tmp_data;
	static ap_int<15> itmp, qtmp;
	static ap_uint<1> PD_FLAG;

	static ap_uint<40> acc_out = 0;
	#pragma HLS RESET variable=acc_out
	static ap_uint<2> index_MSB = 0;
	static ap_uint<log2_NPOINTS-2> index_LSB = 0;
	
	static ap_int<32> FCWn;
	static ap_uint<10> data_last_reg;
	static ap_uint<log2_QUANT_SIN> temp1;
	static ap_uint<log2_QUANT_SIN> temp2;
	static ap_int<log2_QUANT_SIN+1> sin_out;
	static ap_int<log2_QUANT_SIN+1> cos_out;
	static ap_int<15+log2_QUANT_SIN+1> odata_i_1, odata_i_2;
	static ap_int<15+log2_QUANT_SIN+1> odata_q_1, odata_q_2;
	static ap_int<15+log2_QUANT_SIN+2> odata_i, odata_q;
	static rfnoc_axis otmp;

	if(!i_data.empty()){
		
		i_data.read(tmp_data); /********* 1 CLOCK CYCLE *********/
	  itmp = tmp_data.data.range(31,17); // RE 
	  qtmp = tmp_data.data.range(15,1); // IM
	  PD_FLAG = tmp_data.data.range(0,0); // PD_FLAG
//		acc_out = acc_out +FCWn;
		acc_out = acc_out +FCW; /********* 2 CLOCK CYCLE *********/
		index_MSB = acc_out.range(39,38);
	 	index_LSB = acc_out.range(37,37-log2_NPOINTS+3);

	 	temp1 = quarter_sin[index_LSB]; /********* 3 CLOCK CYCLE *********/
	 	temp2 = quarter_sin[NPOINTSm2 - index_LSB];
	 	
	 	switch(index_MSB) {  /********* 4 CLOCK CYCLE *********/
		  case 0:
				sin_out  = temp1;
				cos_out  = temp2;
				break;
			case 1:
				sin_out  = temp2;
				cos_out  = -temp1;
				break;
	    case 2:
				sin_out  = -temp1;
				cos_out  = -temp2;
				break;
			case 3:
				sin_out  = -temp2;
				cos_out  = temp1;
				break;
		}

		odata_i_1 = cos_out * itmp;  /********* 5 CLOCK CYCLE ********/
		odata_i_2 = sin_out * qtmp;
		odata_q_1 = cos_out * qtmp;
		odata_q_2 = sin_out * itmp;

		odata_i = odata_i_1 + odata_i_2;  /********* 6 CLOCK CYCLE *********/
		odata_q = odata_q_1 - odata_q_2;
		
		//otmp.data.range(31,17) = odata_i.range(15+log2_QUANT_SIN+1,15+log2_QUANT_SIN+1-15+1);
		otmp.data.range(31,17) = odata_i.range(log2_QUANT_SIN+15-1,log2_QUANT_SIN);
		otmp.data.range(16,16) = 0; 
		//otmp.data.range(15,1) = odata_q.range(15+log2_QUANT_SIN+1,15+log2_QUANT_SIN+1-15+1);
		otmp.data.range(15,1) = odata_q.range(log2_QUANT_SIN+15-1,log2_QUANT_SIN);
		otmp.data.range(0,0) = PD_FLAG;
		otmp.last = tmp_data.last;
		o_data.write(otmp);  /********* 7 CLOCK CYCLE *********/
	}

}
