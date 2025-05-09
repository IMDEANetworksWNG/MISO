fid = fopen('test.bin', 'rb');
muestras_iq = fread(fid, 'float32', 'complex');
fclose(fid);


sample_rate = 50e6;
N = lenght(muestras_iq);
f = (-N/2:N/2-1)*(sample_rate/N);
espectro = fftshift(fft(muestras_iq))/N;
plot(f, abs(espectro));
xlabel('Frequency (Hz)');
ylabel('Amplitud');
title('Frequency Spectrum');
