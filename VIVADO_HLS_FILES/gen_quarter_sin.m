%% GEN quarter_sin.h file
clear all, clc;

log2_NPOINTS = 14;
log2_QUANT_SIN = 12;

t2 = linspace(0,0.25,2^(log2_NPOINTS-2));
LUT_SIN2 = floor(((1/sqrt(2)).*sin(2*pi*t2)).*2^log2_QUANT_SIN).'; 
length_ROM = length(t2);

%Open and write file quarter_sin.h
dir = '../';
nombre = 'quarter_sin';
f = sprintf([dir nombre '.h']);
pack = fopen(f,'w');
 
fprintf(pack,['/* GENERATED WITH MATLAB...*/' '\n']);
fprintf(pack,'\n');
fprintf(pack,['/* Samples for a quarter sin wave signal */\n']);
fprintf(pack,'\n');

fprintf(pack,['#define log2_NPOINTS ' num2str(log2_NPOINTS) '\n']);
fprintf(pack,['#define NPOINTSm2 ' num2str(2^(log2_NPOINTS-2)-1) ' // 2^(log2_NPOINTS-2)-1 \n']);
fprintf(pack,['#define log2_QUANT_SIN ' num2str(log2_QUANT_SIN) '\n']);
fprintf(pack,'\n');
fprintf(pack,['const ap_uint<'  num2str(log2_QUANT_SIN) '> quarter_sin['  num2str(length_ROM) '] = { ']);
for i=1:length_ROM
   fprintf(pack,num2str(LUT_SIN2(i)));
   if i ~= length_ROM
      fprintf(pack,', \n                                        ');
   else
      fprintf(pack,'\n                                       };');
   end
end

fclose(pack);
 