load corrupted_speech.mat

figure
freqz(myRecording2)
title('frequency response of recording');

Fmes = fft(myRecording2);

Fs = 8000;
F1 = 0.5*pi; %from freqz
F2 = 0.75*pi; %from freqz

%generate 4 sinc functions.
t = 0/8000:1/8000:20000/8000;
LP1 = 0.49*sinc(0.49*pi*t);
LP2 = 0.74*sinc(0.74*pi*t);
HP1 = dirac(t) - 0.51*sinc(0.51*pi*t);
HP2 = dirac(t) - 0.76*sinc(0.76*pi*t);

FLP1 = fft(LP1');
FLP2 = fft(LP2');
HLP1 = fft(HP1');
HLP2 = fft(HP2');

BP1 = FLP1.*HLP1;
BP2 = FLP2.*HLP2;

BR1 = 1 - BP1;
BR2 = 1 - BP2;

Fout = Fmes.*BR1.*BR2;
F = ifft(Fout);