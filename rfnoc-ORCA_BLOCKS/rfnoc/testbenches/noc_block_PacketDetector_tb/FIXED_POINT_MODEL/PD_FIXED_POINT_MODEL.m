clear all, clc, close all;

load RX_FRAME_LONG_TB.mat
SAVE_FILES = false;
PLOT_RESULTS = true;

SCALING_IN = 2^4*2; %USED BECAUSE THE VADATECH FPGA ADC DATAPATH IS 12-BITS AND THE USRP IS 16-BITS
x = RX_FRAME_INT.*SCALING_IN;
PD_threshold = 0.5;
noise_threshold = 16;
nsps = 2;  %2-SAMPLES PER SYMBOL

inpLength = (size(x,1)); 

received_delay_line = zeros(128*nsps+1,1);
delay_acc = zeros(128*nsps+1,2);
r_acc = 0; %Initialize the Accumulator
rD_acc = 0; %Initialize the Accumulator

M = zeros(length(x),1); % NORMALIZED AUTOCORRELATION OUTPUT
PD_FLAG = zeros(size(x)); %PACKET DETECTED FLAG OUTPUT
x_zp = zeros(size(x)); %128*NSPS CYCLES DELAYED IQ OUTPUT SAMPLES
r_acc_out = zeros(size(x));

%INIT SIGNALS 
counter = 0;
max_temp = -inf;
STATE = 0; % 0 = ST_WAIT; 1 = ST_PD 

% Process the input signal to model a slicing window as in the real time
% processing system
for ii = 1:inpLength
   received_delay_line(:,1) = [received_delay_line(2:end,1); x(ii)]; %Q16.0
   r_n = x(ii); % Actual sample % %Q16.0
   r_nD = received_delay_line(1); % Delayed sample %Q16.0
   r_nD_c = r_nD'; % Delayed complex conjugate sample %Q16.0
   
   r_n_x_r_nD_c = complex(real(r_n)*real(r_nD) + imag(r_n)*imag(r_nD),...
                          imag(r_n)*real(r_nD) - real(r_n)*imag(r_nD)); %Q16.0*Q16.0 + Q16.0*Q16.0 = Q33.0
                        
   delay_acc(:,1) = [delay_acc(2:end,1); r_n_x_r_nD_c]; %Q33.0
   r_acc = r_acc - delay_acc(1,1) + r_n_x_r_nD_c; %256 samples ACC -> 8 bits -> %Q41.0
   
   r_acc_q = floor(r_acc*2^-9); %Reduce (CUT 9 LSB bits) -> %Q32.0
   
   c_n = real(r_acc_q)*real(r_acc_q)+imag(r_acc_q)*imag(r_acc_q); %Q64.0
   
   r_nD_x_r_nD_c = r_nD * r_nD_c;
   delay_acc(:,2) = [delay_acc(2:end,2); r_nD_x_r_nD_c];
   rD_acc = rD_acc - delay_acc(1,2) + r_nD_x_r_nD_c;
   
   rD_acc_q = floor(rD_acc*2^-9);  %(CUT 9 LSB bits) -> %Q32.0
   
   p_n = real(rD_acc_q)*real(rD_acc_q)+imag(rD_acc_q)*imag(rD_acc_q); %Q64.0
   m_n = floor(c_n - floor(PD_threshold*(p_n))); %Q64.0
   m_n_reduced = floor(m_n*2^-33);
   M(ii,1) = m_n;
   
   %STATE MACHINE MODEL
   if STATE == 0
      PD_FLAG(ii) = 0;
      PD_COUNTER = 0;
      
   elseif STATE == 1
      PD_FLAG(ii) = 1;
      PD_COUNTER = PD_COUNTER+1;
   end
   
   switch(STATE)
      case(0) % WAIT_STATE
         if m_n_reduced > noise_threshold
            if m_n_reduced>0.75*max_temp
               if counter < 64*4-1 
                  counter = counter+1;
               else
                  counter = 0;
                  STATE = 1; %jump to PD_STATE
                  PD_FLAG(ii) = 1;
               end
               if m_n_reduced> max_temp
                  max_temp = m_n_reduced;
               end
            end
         else
            max_temp = -inf;
            counter = 0;
         end
      case(1)
         if PD_COUNTER == 17*128*nsps*3
            STATE = 0;
            %max_temp = -inf;
         end
   end
   
   %DELAYED OUTPUT
   x_zp(ii) = r_nD; 
end

if PLOT_RESULTS
   figure(1), clf;
   plot(real(x)/max(real(x))*0.5*max(M),'b','linewidth',0.25);
%    plot(real(x),'b','linewidth',0.25);
   hold on, grid on;
   plot(M,'m','linewidth',1.5);
   plot(PD_FLAG*1.2*max(M),'r','linewidth',2);
   legend('Real(RX-SIGNAL)','NAC','PD FLAG');
end

if SAVE_FILES
   
   %PD Testbench input file
      RX_FRAME_INT_r = real(x);
      RX_FRAME_INT_i = imag(x);
      RX_FRAME_INT_write = zeros(length(RX_FRAME_INT)*2,1);
      RX_FRAME_INT_write(1:2:end) = RX_FRAME_INT_r;
      RX_FRAME_INT_write(2:2:end) = RX_FRAME_INT_i;

      %Write the generated IQ vector to a text file
      fileID = fopen(['../IDATA_INT.dat'],'w');
      fprintf(fileID,'%d,%d\n',RX_FRAME_INT_write);
      fclose(fileID);
   %PD Testbench output file
      O_DATA = floor(M.*2^-33)*2+PD_FLAG; % EACH SAMPLE IS O_DATA[31:0] = {M[63:33],PD_FLAG}
      fileID = fopen(['../ODATA_INT.dat'],'w');
      fprintf(fileID,'%d\n',O_DATA);
      fclose(fileID);  
      
   %CFOEC Testbench input file
      racc_i2=double(typecast(int32(floor(real(r_acc_out).*2^-17)*2*2^16),'uint32'));
      racc_q2=double(typecast(int16(floor(imag(r_acc_out).*2^-17)*2),'uint16'));
      racc_i=floor(real(r_acc_out).*2^-17);
      racc_q=floor(imag(r_acc_out).*2^-17);
      O_DATA = racc_i2 + racc_q2 + PD_FLAG; % EACH SAMPLE IS O_DATA[31:0] = {racc_i[32:17], 0, racc_q[32:17], PD_FLAG}
      fileID = fopen(['CFOEC_in_INT.dat'],'w');
      fprintf(fileID,'%d\n',O_DATA);
      fclose(fileID);  
      
      save('../../noc_block_CFOC_tb/FIXED_POINT_MODEL/CFOE_TB_v1.mat','racc_i','racc_q','PD_FLAG','x_zp');
end
