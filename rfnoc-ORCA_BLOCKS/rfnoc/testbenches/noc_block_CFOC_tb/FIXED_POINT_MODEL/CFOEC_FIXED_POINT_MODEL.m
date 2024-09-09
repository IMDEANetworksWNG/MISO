%FREQUENCY OFFSET ESTIMATION AND CORRECTION FIXED POINT MODEL

clear all, close all, clc;
PD_ODATA=load('PD_ODATA.dat');

INPUT_DATA_i = bitshift(bitand(PD_ODATA,bin2dec('11111111111111100000000000000000')),-17); 
INPUT_DATA_q = bitshift(bitand(PD_ODATA,bin2dec('00000000000000001111111111111110')),-1); 

INPUT_DATA_i = double(typecast(uint16(INPUT_DATA_i*2),'int16'))/2;
INPUT_DATA_q = double(typecast(uint16(INPUT_DATA_q*2),'int16'))/2;
PD_FLAG = bitand(PD_ODATA,1);

osps =2;
COR_SIZE = osps*128;
NPER = 7;
NBITSNCO = 14;
QUANT_SIN = 12; 
LATENCY_NCO = 9;
b0_PD_FLAG = PD_FLAG;
b0_datain_i = INPUT_DATA_i;
b0_datain_q = INPUT_DATA_q;
clear PD_FLAG INPUT_DATA_i INPUT_DATA_q

b1_state = 'st1_WAIT';
b1_counter_NPER = 0;
b1_counter_COR_SIZE = 0;
b1_ACC_i = 0;
b1_ACC_q = 0;

acc_out = ufi(0,40,0);
temp2 = 0;

for ii = 1:length(b0_PD_FLAG)
   %b1: state machine for packet_detected_flag
   switch(b1_state)
      case('st1_WAIT')
         if b0_PD_FLAG(ii) == 1
            b1_state = 'st3_ACC';
         end
         b1_ACC_i = 0;
         b1_ACC_q = 0;
         b1_CORDIC_en = 0;
      case('st2_COUNT')
         if b1_counter_COR_SIZE == COR_SIZE-1
           b1_counter_COR_SIZE = 0;
           b1_state = 'st3_ACC';
         else 
           b1_counter_COR_SIZE = b1_counter_COR_SIZE + 1;    
         end
         b1_CORDIC_en = 0;
      case('st3_ACC') 
         if b1_counter_NPER < NPER
            b1_counter_NPER = b1_counter_NPER + 1;
            b1_state = 'st2_COUNT';
         else
            b1_counter_NPER = 0;
            b1_state = 'st4_CORDIC';
         end
            b1_ACC_i = b1_ACC_i + b0_datain_i(ii);
            b1_ACC_q = b1_ACC_q + b0_datain_q(ii);
            b1_CORDIC_en = 0;
      case('st4_CORDIC') 
         b1_state = 'st5_WAIT_PD_LOW';
         b1_CORDICin_i = b1_ACC_i;
         b1_CORDICin_q = b1_ACC_q;
         b1_CORDIC_en = 1;
      case('st5_WAIT_PD_LOW')
         if b0_PD_FLAG(ii) == 0
            b1_state = 'st1_WAIT';
         end
         b1_CORDIC_en = 0;
   end
  
   if b1_CORDIC_en == 1
      %True angle
%       temp1 = angle(complex(floor(b1_ACC_i*2^-2), floor(b1_ACC_q*2^-2)));
      %Estimated angle
      angle_ant = temp2;
      [~, ~, temp2] = cordic_atan(floor(b1_ACC_i*2^-2), floor(b1_ACC_q*2^-2), 0, 14);
%       angle_est = temp2.*2^-22;
      
      [X_foc,complex_sincos,acc_out] = CFOC(complex(b0_datain_i,b0_datain_q),...
         temp2,NBITSNCO,QUANT_SIN,ii,angle_ant,acc_out,LATENCY_NCO);
      
   end
end

figure(1), clf;
plot(real(X_foc),'b');
hold on;
plot(real(complex_sincos),'r');
legend('I samples (CFOEC out)', 'CFO (Cosine)');

function [x, y, z] = cordic_atan(x, y, z, n)
   % Perform CORDIC vectoring kernel algorithm for N kernel iterations.
   xtmp = x; %Q16.0
   ytmp = y; %Q16.0
   % z -> %Q22.0

   %inpLUT values must be computed offline considering fixed-point resolution 
   inpLUT = atan(2.^(-(0:n-1)));
   inpLUT_INT = round(inpLUT.*2^22);

   for idx = 1:n
       if y < 0
           x(:) = x - floor(ytmp); %Q17.0
           y(:) = y + floor(xtmp); %Q17.0
           z(:) = z - inpLUT_INT(idx);
       else
           x(:) = x + floor(ytmp);
           y(:) = y - floor(xtmp);
           z(:) = z + inpLUT_INT(idx);
       end
       xtmp = bitsra(x, idx); % bit-shift-right for multiply by 2^(-idx)
       ytmp = bitsra(y, idx); % bit-shift-right for multiply by 2^(-idx)
   end
end

function [X_foc,complex_sincos,acc_out] = CFOC(X_pd_out,angle_est, n_bits,QUANT_SIN,index_in,angle_ant,acc_out,LATENCY_NCO)
%% DDFS MODEL 

   one_over_2pi = round(1/(2*pi)*2^13);

   %FCW = floor((angle_est.*2^40./(2*pi)./(128*osps)));
   FCW = floor(angle_est.*one_over_2pi.*2^-3);

   % FCW_ant = (angle_ant.*2^40./(2*pi)./(128*osps));
   FCW_ant = floor(angle_ant.*one_over_2pi.*2^-3);

   acc_out2 = 0;
   t2 = linspace(0,0.25,2^(n_bits-2));
   LUT_SIN2 = floor(((1/sqrt(2)).*sin(2*pi*t2)).*2^QUANT_SIN).'; 
   index_MSB = zeros(size(X_pd_out));
   index_LSB = zeros(size(X_pd_out));
   cos_out2 = zeros(size(X_pd_out));
   sin_out2 = zeros(size(X_pd_out));

   for ii = 1:length(X_pd_out)-1
      if ii < index_in+LATENCY_NCO
         acc_out2 = mod(acc_out2+FCW_ant,2^40-1); 
         acc_out = accumpos(acc_out,FCW_ant);
      else
         acc_out2 = mod(acc_out2+FCW,2^40-1);
         acc_out = accumpos(acc_out,FCW);
      end

      index = floor(acc_out2*2^(n_bits-40));

      index_MSB(ii) = floor(index*2^(-n_bits+2));
      index_LSB(ii) = index - (index_MSB(ii)*2^(n_bits-2));

      temp  = LUT_SIN2(index_LSB(ii)+1);
      temp2  = LUT_SIN2((2^(n_bits-2)-1 - index_LSB(ii))+1);

      switch(index_MSB(ii))
         case(0)
            sin_out2(ii) = temp;
            cos_out2(ii) = temp2;
         case(1)
            sin_out2(ii) = temp2;
            cos_out2(ii) = -temp;
         case(2)
            sin_out2(ii) = -temp;
            cos_out2(ii) = -temp2;
         case(3)
            sin_out2(ii) = -temp2;
            cos_out2(ii) = temp;
      end

   end

   complex_sincos = (1/sqrt(2)).*complex(cos_out2,-sin_out2);

   X_focR = floor( ((real(X_pd_out) .* cos_out2) + ...
                    (imag(X_pd_out) .* sin_out2)).*2^-(QUANT_SIN-1));
   X_focI = floor( ((imag(X_pd_out) .* (cos_out2)) - ...
                    (real(X_pd_out) .* (sin_out2))).*2^-(QUANT_SIN-1));
   X_foc = complex(X_focR,X_focI);

end