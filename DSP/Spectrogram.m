clear all
[sequence,Fs] = audioread('Sample.wav');
%% 
%Part1
R = 128;
M = 2*R;
audio = sequence;
r128case = getspec(R,M,audio);

%%
%part 2
R = 512;
M = 2*R;
audio = sequence;
r512case = getspec(R,M,audio);
R = 2048;
M = 2*R;
audio = sequence;
r2048case = getspec(R,M,audio);

%%
%part 4
%get xr
R = 128;
M = 2*R;
xrsegs = ifft(r128case,M,1);
r = 1:size(xrsegs,2);
xhat = zeros(R*(length(r)-1)+M,1);
what = xhat;
ind1 = ((r-1).*R + 1);
ind2 = ((r-1).*R + M);
for i=1:max(r)
    xhat(ind1(i):ind2(i)) = xhat(ind1(i):ind2(i)) + xrsegs(:,i);
    what(ind1(i):ind2(i)) = what(ind1(i):ind2(i)) + hamming(M);
end
xhat = xhat;
xout = xhat./what;
audiowrite('outputlab1.wav',xout,Fs);
delay = length(xout)-length(sequence);
MSE = 1/length(xout)*sum((xout(delay+1:length(xout))-sequence).^2);
figure
stem(sequence);
title('original signal');
figure
stem(xout);
title('output signal');
%%

function [spect] = getspec(R,M,audio)
%first have to segment.
k = 1:floor(length(audio)/R); %number of segments
audio(length(audio)+1:max(k)*R + M) = 0; %zero padding.
%inefficient algorithm, but it's ok, get the segments
ind1 = ((k-1).*R + 1);
ind2 = ((k-1).*R + M);
w = hamming(M); %length M hamming window will be multiplied.
for i = 1:max(k)
    segments(:,i) = audio(ind1(i):ind2(i));
    output(:,i) = segments(:,i).*w;
end
ti = strcat(' for M = ',num2str(M),' and R = ',num2str(R));
spect = fft(output,M,1);
spectabs = 20.*log(abs(spect));
figure
imagesc(spectabs(M/2+1:M,:))
title(strcat('Spectrogram script output',ti));
xlabel('segment index');
%actual spectrogram
figure
spectrogram(audio,hamming(M),M-R,M,'yaxis')
title(strcat('Matlab function output',ti));

end