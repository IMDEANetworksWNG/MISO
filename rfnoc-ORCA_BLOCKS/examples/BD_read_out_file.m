%% Carrier Frequency Offset Correction block plot output file

clear all, clc;

SEL_OUT = 0;
filename = ['BD_OUT_SEL' num2str(SEL_OUT) '.dat'];
count = 150000; %Number of samples to read

%Read GNU Radio output file
DATA1 = read_complex_binary (filename, count);

% Integer scaling
DATA = fix(DATA1.*2^15); 

if SEL_OUT == 0

   % Extract LSB bit (PD Flag)
   CE_FLAG = mod(imag(DATA),2);
   IQ_SAMPLES = floor(DATA*0.5); %Keep the 15 MSB bits of the complex data
   
   figure(1), clf;
   plot(real(IQ_SAMPLES),'b'); 
   hold on; 
   plot(imag(IQ_SAMPLES),'r'); 
   %Scale the PD flag to be on the same magnitude order than the IQ samples
   plot(CE_FLAG.*1.2*max(real(IQ_SAMPLES)),'k','linewidth',1.5);
   if SEL_OUT == 0 
      legend('I samples (BD out)','Q samples (BD out)','Scaled PD FLAG'); 
   else
      legend('CFO (cosine)','CFO (sine)','Scaled PD FLAG'); 
   end
elseif SEL_OUT == 1
   DATA_i_int = double(typecast(int16((real(DATA))),'uint16'));
   DATA_q_int = double(typecast(int16((imag(DATA))),'uint16'));

   CORR_OUT = DATA_q_int+(DATA_i_int.*2^16);
   CORR_OUT = double(typecast(uint32(CORR_OUT),'int32'))/2;
   
   figure(2), clf;
   plot(CORR_OUT,'linewidth',1.2);
   legend('BD CORRELATION OUTPUT');
end