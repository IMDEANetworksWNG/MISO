%% File used to generate IQ samples for the USRP RFNoC system. It is based on the 
%% 802.11ad Transmitter Spectral Emission Mask Testing script from MATLAB library
%% Baseband Waveform Generation

% The waveform generator can be configured to generate one or more packets
% with idle time between each packet. 

clear all, clc;

PLOT_ON = true; % true/false %
SAVE_DATA = true; % true/false %

cfgDMG = wlanDMGConfig;    % DMG packet configuration
cfgDMG.MCS = 1;           % SC PHY with pi/2-QPSK modulation
cfgDMG.PSDULength = 10000/4; % Length in Bytes

% Generate a multi-packet waveform
idleTime = 10.0e-6; % One microsecond idle time between packets (considering fs = 1.76GSPS)
%numPackets = 10;  % Generate ten packets
numPackets = 1;

%Output filename
filename = ['IQ_SAMPLES_MCS_' num2str(cfgDMG.MCS) '_1pk'];

% Set random stream for repeatability of results
s = rng(98765);

% Create random bits for all payload data; PSDULength is in bytes
psdu = randi([0 1],cfgDMG.PSDULength*8*numPackets,1);

% Override the ScramblerInitialization property of the DMG configuration
% object by specifying the scrambler initialization
genWaveform = wlanWaveformGenerator(psdu,cfgDMG,...
    'IdleTime',idleTime, ...
    'NumPackets',numPackets);
            
% Get the sampling rate of the waveform
fs = wlanSampleRate(cfgDMG);

%% Oversampling and Filtering

% Define the pulse shaping filter characteristics
Nsym = 8;   % Filter span in symbol durations
beta = 0.25; % Roll-off factor
osps = 2;   % Output samples per symbol

% Create raised cosine transmit filter system object 
rcosFlt = comm.RaisedCosineTransmitFilter(...
    'Shape','Square root', ... %  'Normal'
    'RolloffFactor',beta, ...
    'FilterSpanInSymbols',Nsym, ...
    'OutputSamplesPerSymbol',osps);

% Filter transmit signal for pulse shaping
txWaveform = rcosFlt([genWaveform; zeros(Nsym/2,1)]);

txWaveform_Q = complex( quantize_j(real(txWaveform),16,15,'floor','saturate'),...
                        quantize_j(imag(txWaveform),16,15,'floor','saturate') );

if PLOT_ON
   plot(real(txWaveform_Q))
end

%Zero padding at the beginning of the generated signal
txWaveform_Q = [zeros(10000,1); txWaveform_Q];

%Write the GNU-RADIO input file
if SAVE_DATA
   x_bs_file = zeros(1,length(txWaveform_Q)*2);

   x_bs_file(1:2:end) = real(txWaveform_Q);
   x_bs_file(2:2:end) = imag(txWaveform_Q);

   fileID = fopen([filename '.txt'],'w');
   fwrite(fileID, x_bs_file.', 'single');

   fclose(fileID);
end

% Restore default stream
rng(s);

