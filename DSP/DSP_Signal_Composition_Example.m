%% 
%Task 1
clear all
notes = [440 495 550 587 660 733 825];
notes2 = [206 220 248 275 293 330 367];
Fs = 8e3;
L = 0.5;

nu=0;do=1; re=2; mi=3; fa=4; so=5; la=6; ti=7;%notes freq
dob=1; reb=2; mib=3; fab=4; sob=5; lab=6; tib=7;

test = [0 1 2 3 4 5 6 7];
gentest = makeseq(test, L, Fs, notes);
audiowrite('Test.wav',gentest,Fs);

%%
%Task 2
figure
spectrogram(gentest);
title('Spectrogram of the 7 notes');

%%
%Task 3
melody=[do;nu; do;nu;so;nu;so;nu;la;nu;la;nu;so;nu;nu;nu;...
    fa; nu; fa; nu;mi;nu;mi;nu;re;nu;re;nu;do;nu;nu;nu]; %notes sequence

chorus=[dob;sob;mib;sob;dob;sob;mib;sob;dob;lab;fab;lab;dob;sob;mib;sob;...
    tib;sob;fab;sob;dob;sob;mib;sob;tib;sob;fab;sob;dob;sob;mib;sob];

genmel = makeseq(melody, L, Fs, notes);
genchor = makeseq(chorus, L, Fs, notes2);

xMe = 0.6*genmel + 0.4*genchor;
audiowrite('MelChor.wav',xMe,Fs);

%%
%Task 4
figure
spectrogram(xMe)
title('Spectrogram of chorus + melody');

%%
%Task 5
b=[1 -3.1820023 3.9741082 -2.293354 0.52460587];
a=[0.62477732 -2.444978 3.64114 -2.444978 0.62477732];
yMe = filter(a,b,xMe);
audiowrite('Twinkle.wav',yMe,Fs)

%%
%Task 6
figure
freqz(a,b,1000)
title("freq response of the IIR highpass filter");
%%
%Task 7
k = audioread('output.wav');
temp = xMe-k';
Err = sum(temp.^2);
Errweighted = (1/length(k))*Err;
%%
%Task 8
k2 = audioread('outputFILT.wav');
temp2 = yMe-k2';
Err2 = sum(temp2.^2);
Errweighted2 = (1/length(k))*Err2;
%%
%Functions
function [note] = makenote(noteval, dur, samplerate, notefreqs)
    pie = 3.14159265358979323846264338327950288;
    k = 1/samplerate;
    t = 0:k:dur;
    if (noteval == 0)
        note = zeros(size(t,1),size(t,2));
    else
        t = 2*pie*notefreqs(noteval).*t;
        note = sin(t);
    end
end

function [seq] = makeseq(list, dur, samplerate, notefreqs)
    k = length(list);
    seq = [];
    for i = 1:1:k
        seq = horzcat(seq, makenote(list(i), dur, samplerate, notefreqs));
    end
end
