%% CIR FIXED_POINT_MODEL

clear all;
close all;
clc;

load INPUT_DATA_TB.mat
load GOLAY_SEQ.mat

INDEXES = find(CEF_FLAG == 1);
CEF_ESTIMATE = floor(X(INDEXES(1):INDEXES(1)+128*9-1).*2^16);
GOLAY_A_MOD = zeros(1,128);
GOLAY_B_MOD = zeros(1,128);

GOLAY_A_MOD(1,1:2:128) = real(Ga128_rot(1:2:128));
GOLAY_A_MOD(1,2:2:128) = -imag(Ga128_rot(2:2:128));
GOLAY_B_MOD(1,1:2:128) = real(Gb128_rot(1:2:128));
GOLAY_B_MOD(1,2:2:128) = -imag(Gb128_rot(2:2:128));

%% Golden Results
preamble_128 = reshape((CEF_ESTIMATE),128,9);

RESULT = zeros(1,128);
RESULT_DEBUG = zeros(8,128);
for ii = 1:8

   BUFFER_B =preamble_128(:,ii).';
   BUFFER_B_EXT = [zeros(1,64) BUFFER_B];

   for jj = 1:128
      if mod(ii,2) == 1
         GOLAY = GOLAY_B_MOD;
      else
         GOLAY = GOLAY_A_MOD;
      end
      
      OPER_A = zeros(128,1);
      BUFFER_B_SHORT = BUFFER_B_EXT(1:end-64).';
      for kk = 1:64
         if GOLAY(2*kk-1) == 1
            OPER_A(2*kk-1) = complex(real(BUFFER_B_SHORT(2*kk-1)),imag(BUFFER_B_SHORT(2*kk-1)));
         else
            OPER_A(2*kk-1) = complex(-real(BUFFER_B_SHORT(2*kk-1)),-imag(BUFFER_B_SHORT(2*kk-1)));
         end
         
         if GOLAY(2*kk) == 1
            OPER_A(2*kk) = complex(-imag(BUFFER_B_SHORT(2*kk)),real(BUFFER_B_SHORT(2*kk)));
         else
            OPER_A(2*kk) = complex(imag(BUFFER_B_SHORT(2*kk)),-real(BUFFER_B_SHORT(2*kk)));
         end
      end
         
      if ii == 3 || ii == 6
         RESULT(jj) = RESULT(jj) + sum(OPER_A);         
      else
         RESULT(jj) = RESULT(jj) - sum(OPER_A);
      end
      RESULT_DEBUG(ii,jj) = sum(OPER_A);        
      BUFFER_B_EXT = [BUFFER_B_EXT(2:end) BUFFER_B_EXT(1)];
   end
end

PLOT_SCALING = 2^-8*2^-15;
figure(1), clf;
plot(abs(RESULT.*PLOT_SCALING),'r');
