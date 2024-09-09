%% Packet detector plot output file

clear all, clc;

SEL_OUT = 1;
filename = ['PD_OUT_SEL' num2str(SEL_OUT) '.dat'];
count = 150000; %Number of samples to read

%Read GNU Radio output file
DATA1 = read_complex_binary (filename, count);

% Integer scaling
DATA = fix(DATA1.*2^15); 

if SEL_OUT == 0 || SEL_OUT == 3 

   % Extract LSB bit (PD Flag)
   PD_FLAG = mod(imag(DATA),2);
   IQ_SAMPLES = floor(DATA*0.5); %Keep the 15 MSB bits of the complex data
   
   figure(1), clf;
   plot(real(IQ_SAMPLES),'b'); 
   hold on; 
   plot(imag(IQ_SAMPLES),'r'); 
   %Scale the PD flag to be on the same magnitude order than the IQ samples
   plot(PD_FLAG.*1.2*max(real(IQ_SAMPLES)),'k','linewidth',1.5);
   legend('I samples','Q samples','Scaled PD FLAG'); 
elseif SEL_OUT == 1
   DATA_i_int = double(typecast(int16((real(DATA))),'uint16'));
   DATA_q_int = double(typecast(int16((imag(DATA))),'uint16'));

   NAC = DATA_q_int+(DATA_i_int.*2^16);
%    PD_FLAG = mod(NAC,2);
   NAC = double(typecast(uint32(NAC),'int32'))/2;
   
   figure(2), clf;
   plot(NAC,'linewidth',1.2); 
   legend('NAC');
%    hold on; 
%    plot(PD_FLAG.*1.2*max(NAC),'k','linewidth',1.5);
%    legend('NAC','Scaled PD FLAG');                   
elseif SEL_OUT == 2
   % Extract LSB bit (PD Flag)
   PD_FLAG = mod(imag(DATA),2);
   ANGLE = floor(DATA*0.5); %Keep the 15 MSB bits of the ANGLE
   
   figure(1), clf;
   plot(real(ANGLE),'b'); 
   hold on; 
   plot(imag(ANGLE),'r'); 
   %Scale the PD flag to be on the same magnitude order than the IQ samples
   plot(PD_FLAG.*1.2*max(real(ANGLE)),'k','linewidth',1.5);
   legend('Real(r\_acc)','Imag(r\_acc)','Scaled PD FLAG'); 
end