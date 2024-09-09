%% GEN GOLAY_SEG VHDL FILES

clear all;
close all;
clc;

load GOLAY_SEQ.mat

GOLAY_A_MOD = zeros(1,128);
GOLAY_B_MOD = zeros(1,128);

GOLAY_A_MOD(1,1:2:128) = real(Ga128_rot(1:2:128));
GOLAY_A_MOD(1,2:2:128) = -imag(Ga128_rot(2:2:128));
GOLAY_B_MOD(1,1:2:128) = real(Gb128_rot(1:2:128));
GOLAY_B_MOD(1,2:2:128) = -imag(Gb128_rot(2:2:128));

dir = '';
entity = 'GOLAY_SEQ_pkg';
 
f = sprintf([dir entity '.vhd']);
 
pack = fopen(f,'w');
   fprintf(pack,['-- GENERATED WITH MATLAB...' '\n']);
   fprintf(pack,['\n']);
   fprintf(pack,['library ieee;' '\n']);
   fprintf(pack,['use ieee.std_logic_1164.all;' '\n']);
   fprintf(pack,['use ieee.numeric_std.all;' '\n']);
   fprintf(pack,'\n');
     
   fprintf(pack,['package ' entity ' is \n']);
   fprintf(pack,'\n');
   fprintf(pack,['\t constant GOLAY_A : std_logic_vector(0 to 128-1) := ( "']);
   for ii=1:128
      if (GOLAY_A_MOD(ii)==1)
         fprintf(pack,'0');
      else
         fprintf(pack,'1');
      end
   end
   fprintf(pack,'"); \n \n');

   fprintf(pack,['\t constant GOLAY_B : std_logic_vector(0 to 128-1) := ( "']);
   for ii=1:128
      if (GOLAY_B_MOD(ii)==1)
         fprintf(pack,'0');
      else
         fprintf(pack,'1');
      end
   end
   fprintf(pack,'"); \n \n');     
     
   %%%%%%%%%%%%%%%%%
   fprintf(pack,['end ' entity '; \n']);

fclose(pack);