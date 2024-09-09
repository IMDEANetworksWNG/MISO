%% Carrier Frequency Offset Correction block plot output file

clear all, clc;

SEL_OUT = 0;
filename = ['CIR_OUT_SEL' num2str(SEL_OUT) '.dat'];
count = 15000; %Number of samples to read

%Read GNU Radio output file
DATA1 = read_complex_binary (filename, count);

% Integer scaling
DATA = fix(DATA1.*2^15); 

if SEL_OUT == 0
   absDATA = (abs(DATA))*2^-13; %2^10 (128*8) * 2^15(Integer to floating point conv)
   NBLK = floor(length(absDATA)/128);
   absDATA_reshape = reshape(absDATA(1:128*NBLK),128,NBLK);
   figure(1), clf;
   plot(-63:64,absDATA_reshape(:,2),'b'); 
   hold on;
   plot(-63:64,absDATA_reshape(:,3),'r'); 
   plot(-63:64,absDATA_reshape(:,4),'k'); 
   plot(-63:64,absDATA_reshape(:,5),'c'); 
   plot(-63:64,absDATA_reshape(:,6),'m'); 
   legend('CIR 1','CIR 2','CIR 3','CIR 4','CIR 5'); 
   xlabel('index');
elseif SEL_OUT == 1
   DATA_i_int = double(typecast(int16((real(DATA))),'uint16'));
   DATA_q_int = double(typecast(int16((imag(DATA))),'uint16'));

   CIR = DATA_q_int+(DATA_i_int.*2^16);
   CIR = double(typecast(uint32(CIR),'int32'))*2^-31*2^-10*2^17;
   
   NBLK = floor(length(CIR)/128);
   absDATA_reshape = reshape(CIR(1:128*NBLK),128,NBLK);
   figure(1), clf;
   plot(-63:64,absDATA_reshape(:,2),'b'); 
   hold on;
   plot(-63:64,absDATA_reshape(:,3),'r'); 
   plot(-63:64,absDATA_reshape(:,4),'k'); 
   plot(-63:64,absDATA_reshape(:,5),'c'); 
   plot(-63:64,absDATA_reshape(:,6),'m'); 
   legend('CIR 1','CIR 2','CIR 3','CIR 4','CIR 5'); 
   xlabel('index');
end