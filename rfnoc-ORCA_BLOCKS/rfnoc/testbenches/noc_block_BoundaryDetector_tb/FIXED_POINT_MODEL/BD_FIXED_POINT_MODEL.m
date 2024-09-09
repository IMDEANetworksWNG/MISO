clear all, clc;

load BD_IN.mat

%Downsample the signal 
X_DS = floor(x_zp(1:2:end).*2^-1);
PD_FLAG_DS = PD_FLAG(1:2:end);
inpLength = (size(X_DS.',2));

delay_acc_32 = zeros(32+1,1);
received_delay_line_64 = zeros(64+1,1);
received_delay_line_128 = zeros(128+1,1);
r_acc_32 = 0; %Initialize the Accumulator
received_delay_line_96 = zeros(96,1);
   
DETECTED = false;
max_pos = 0;
r_acc_out = zeros(size(X_DS));

% Process the input signal to model a slicing window as in the real time
% processing system

for ii = 1:inpLength
   received_delay_line_64(:,1) = [received_delay_line_64(2:end,1); X_DS(ii)];
   received_delay_line_128(:,1) = [received_delay_line_128(2:end,1); X_DS(ii)];
   r_n = X_DS(ii); % Actual sample
   r_nD = received_delay_line_64(1); % 64-Delayed sample
   r_nD128 = received_delay_line_128(1); % 128-Delayed sample
   r_nD_c = r_nD'; % Delayed complex conjugate sample
   r_nD128_c = r_nD128'; % Delayed complex conjugate sample
   
   r_n_x_r_nD_c = r_n * (r_nD_c+r_nD128_c);
   delay_acc_32(:,1) = [delay_acc_32(2:end,1); real(r_n_x_r_nD_c)];
   r_acc_32 = r_acc_32 - delay_acc_32(1,1) + real(r_n_x_r_nD_c);
  
   % Buffer to track the last maximum prior to the phase inversion
   received_delay_line_96(:,1) = [received_delay_line_96(2:end,1); r_acc_32];

   if PD_FLAG_DS(ii)>0 && DETECTED == false
      if sum(received_delay_line_96(49:96,1)>0) == 0
         [~,max_pos] = max(received_delay_line_96(1:48,1));
         max_pos = ii - 96 + max_pos;
         DETECTED = true;
      end
      r_acc_out(ii) = r_acc_32;%./p_acc;
   else
      r_acc_out(ii) = 0;%./p_acc;
   end
end

END_OF_STF = max_pos + 128 + 32;
CEF_INDEX = END_OF_STF+1:END_OF_STF+128*9;
CEF_ESTIMATE = X_DS(CEF_INDEX).';

CEF_FLAG = zeros(size(X_DS));
CEF_FLAG(CEF_INDEX) = 1;

figure(1), clf;
plot(real(X_DS)./max(real(X_DS))*1.2*max(r_acc_out),'b');
hold on;
plot(r_acc_out,'r');
plot(CEF_FLAG,'m');

