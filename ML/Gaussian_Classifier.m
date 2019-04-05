clear all
load TrainingSamplesDCT_8_new
cheetah = imread('cheetah.bmp');
%there's a noisy strip on the right that I get rid of.
cheetah = im2double(cheetah(:,1:268));

%means
meanchet = mean(TrainsampleDCT_FG,1);
meanbg = mean(TrainsampleDCT_BG,1);

%priors, see proof.
priorchet = 250/(1053 + 250);
priorbg = 1053/(1053 + 250);

%64dim covars.
covarchet = (1/250)*(TrainsampleDCT_FG - meanchet)'*(TrainsampleDCT_FG...
    - meanchet);
covarbg = (1/1053)*(TrainsampleDCT_BG - meanbg)'*(TrainsampleDCT_BG...
    - meanbg);

%%
%1dim covars.
for i = [1:64]
    covar1dchet(i) = (1/250)*(TrainsampleDCT_FG(:,i) - meanchet(i))'*...
        (TrainsampleDCT_FG(:,i) - meanchet(i));
    covar1dbg(i) = (1/1053)*(TrainsampleDCT_BG(:,i) - meanbg(i))'*...
        (TrainsampleDCT_BG(:,i) - meanbg(i));
end

for i = [1:64]
    condchet(:,i) = (1/sqrt(2*pi*covar1dchet(i)))*exp(-1*...
        ((TrainsampleDCT_FG(:,i) - meanchet(i)).^2)/(2*covar1dchet(i)));
    condbg(:,i) = (1/sqrt(2*pi*covar1dbg(i)))*exp(-1*...
        ((TrainsampleDCT_BG(:,i) - meanbg(i)).^2)/(2*covar1dbg(i)));
end

%%64 plots
for j = [0:7]
    figure
    for i = [1:8]
        subplot(4,2,i)
        scatter(TrainsampleDCT_FG(:,i+8*j),condchet(:,i+8*j));
        hold on
        scatter(TrainsampleDCT_BG(:,i+8*j),condbg(:,i+8*j));
        title(strcat('n = ',num2str(i+8*j)));
        hold off
    end
end
%%
comp = abs(meanchet-meanbg);
[compsort, ind] = sort(comp,'descend');
best = ind(1:8);
worst = ind(57:64);

%best
figure
    for i = [1:8]
        subplot(4,2,i)
        scatter(TrainsampleDCT_FG(:,best(i)),condchet(:,best(i)));
        hold on
        scatter(TrainsampleDCT_BG(:,best(i)),condbg(:,best(i)));
        title(strcat('n = ',num2str(best(i))));
        hold off
    end
%worst
figure
    for i = [1:8]
        subplot(4,2,i)
        scatter(TrainsampleDCT_FG(:,worst(i)),condchet(:,worst(i)));
        hold on
        scatter(TrainsampleDCT_BG(:,worst(i)),condbg(:,worst(i)));
        title(strcat('n = ',num2str(worst(i))));
        hold off
    end


cheetah = padarray(cheetah,[4 5],'symmetric');
%get blocks and dct2.
q = 1;
B= zeros(8,8,255*270);
for j = 1:1:270
    for i = 1:1:255
        B(:,:,q) = dct2(cheetah(i:i+7,j:j+7));
        q = q + 1;
    end
end
%zig zag mapping
Bshaped = zeros(64,size(B,3));
for i = 1:1:size(B,3)
    Bshaped(:,i) = reshape(B(:,:,i)',[1 64]);
end
fileID = fopen('Zig-Zag Pattern.txt');
indices = fscanf(fileID,'%d   ') + 1;
Bzigzag(indices,:) = Bshaped;
cheetahdata = Bzigzag';

detbg = det(covarbg);
detchet = det(covarchet);
covarbginv = inv(covarbg);
covarchetinv = inv(covarchet);
%probabilities
for i = [1:1:68850]
    probIndexBG(i) = 1/sqrt(detbg*(2*pi)^64)*exp((cheetahdata(i,:)-...
        meanbg)*covarbginv*(cheetahdata(i,:)-meanbg)'*(-1/2));
    probIndexFG(i) = 1/sqrt(detchet*(2*pi)^64)*exp((cheetahdata(i,:)-...
        meanchet)*covarchetinv*(cheetahdata(i,:)-meanchet)'*(-1/2));
end


%final image
%assume equiprobable
probBG_X = probIndexBG.*(priorbg);
probFG_X = probIndexFG.*(priorchet);
A = (probBG_X <= probFG_X);
Aimg = reshape(A,[255 270]);
figure
imagesc(Aimg)
title('64 feature classifier');   
colormap gray

%comparison
cheetahcomp = logical(imread('cheetah_mask.bmp'));

%error probabilities
%false positive
alpha = sum(sum((Aimg == true)&(cheetahcomp == false)));
FalsePosError = alpha/sum(sum(cheetahcomp == true))*priorchet
%false negative
beta = sum(sum((Aimg == false)&(cheetahcomp == true)));
FalseNegError = beta/sum(sum(cheetahcomp == false))*priorbg
%Total Error Probability
TotalErrorProb = FalseNegError + FalsePosError


%%
meanchet8d = mean(TrainsampleDCT_FG(:,best));
meanbg8d = mean(TrainsampleDCT_BG(:,best));

%8dim covars.
covarchet8d = (1/250)*(TrainsampleDCT_FG(:,best) - meanchet8d)'*...
    (TrainsampleDCT_FG(:,best) - meanchet8d);
covarbg8d = (1/1053)*(TrainsampleDCT_BG(:,best) - meanbg8d)'*...
    (TrainsampleDCT_BG(:,best) - meanbg8d);

detbg8d = det(covarbg8d);
detchet8d = det(covarchet8d);
covarbginv8d = inv(covarbg8d);
covarchetinv8d = inv(covarchet8d);

for i = [1:1:68850]
    probIndexBG8d(i) = 1/sqrt(detbg8d*(2*pi)^8)*...
        exp((cheetahdata(i,best)-meanbg8d)*covarbginv8d*...
        (cheetahdata(i,best)-meanbg8d)'*(-1/2));
    probIndexFG8d(i) = 1/sqrt(detchet8d*(2*pi)^8)*...
        exp((cheetahdata(i,best)-meanchet8d)*covarchetinv8d*...
        (cheetahdata(i,best)-meanchet8d)'*(-1/2));
end

%final image
%assume equiprobable
probBG_X = probIndexBG8d.*(priorbg);
probFG_X = probIndexFG8d.*(priorchet);
A = (probBG_X <= probFG_X);
Aimg = reshape(A,[255 270]);
figure
imagesc(Aimg)
title('8 feature classifier');
colormap gray

%comparison
cheetahcomp = logical(imread('cheetah_mask.bmp'));

%error probabilities
%false positive
alpha = sum(sum((Aimg == true)&(cheetahcomp == false)));
FalsePosError = alpha/sum(sum(cheetahcomp == true))*priorchet
%false negative
beta = sum(sum((Aimg == false)&(cheetahcomp == true)));
FalseNegError = beta/sum(sum(cheetahcomp == false))*priorbg
%Total Error Probability
TotalErrorProb = FalseNegError + FalsePosError
