clear all
load TrainingSamplesDCT_subsets_8.mat
load Prior_1.mat
load Prior_2.mat
load TrainingSamplesDCT_subsets_8.mat
load Alpha.mat

cheetah = imread('cheetah.bmp');
%there's a noisy strip on the right that I get rid of.
cheetah = im2double(cheetah(:,1:268));

%mew0
mu0_BG_strat1 = horzcat(3,zeros(1,63));
mu0_FG_strat1 = horzcat(1,zeros(1,63));
covarPrior = diag(W0);
%%
%IMPORTANT. THIS IS HOW WE DO.
D1_BG = D1_BG;
D1_FG = D1_FG;
% mu0_BG_strat1 = mu0_BG;
% mu0_FG_strat1 = mu0_FG;
%%

%load covariances and means covariances of class conditional.
meanD1_BG = mean(D1_BG);
meanD1_FG = mean(D1_FG);
covarD1_BG = (D1_BG - meanD1_BG)'*(D1_BG - meanD1_BG)/length(D1_BG);
covarD1_FG = (D1_FG - meanD1_FG)'*(D1_FG - meanD1_FG)/length(D1_FG);

%actually start part a
s0 = covarPrior;
s = covarD1_BG;
m = meanD1_BG;
m0 = mu0_BG_strat1;
n = 1/size(D1_BG,1);

mewN_BG = s0*pinv(s0 + n*s)*m' + n*s*pinv(s0 + n*s)*m0';
mewN_BG = mewN_BG';
covarN_BG = s0*inv(s0 + n*s)*n*s;

s0 = covarPrior;
s = covarD1_FG;
m = meanD1_FG;
m0 = mu0_FG_strat1;
n = 1/size(D1_FG,1);

mewN_FG = s0*pinv(s0 + n*s)*m' + n*s*pinv(s0 + n*s)*m0';
mewN_FG = mewN_FG';
covarN_FG = s0*inv(s0 + n*s)*n*s;

%pad image to size 256x272. I will use replicate padding, since that will
%add components with 0 frequency.
%we can ignore any one of the extra rows
cheetah = padarray(cheetah,[4 5],'replicate','both');

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

% n1_1 = sqrt(det(covarN_BG + covarPrior));
% n1_2 = sqrt(det(covarD1_BG))*n1_1;
% n2_1 = sqrt(det(covarN_FG+ covarPrior));
% n2_2 = sqrt(det(covarD1_FG))*n2_1;
% c1 = pinv(covarD1_BG);
% c2 = pinv(covarD1_FG);
% c3 = pinv(covarN_BG+ covarPrior);
% c4 = pinv(covarN_FG+ covarPrior);
% % % % % the 2pi terms don't matter.
probBG_X = zeros(1,68850);
probFG_X = zeros(1,68850);
priorBG = 1/(pi^32)/sqrt(det(covarPrior))*exp(-.5*...
    (meanD1_BG - mu0_BG_strat1)*pinv(covarPrior)*...
    (meanD1_BG - mu0_BG_strat1)');
priorFG = 1/(pi^32)/sqrt(det(covarPrior))*exp(-.5*...
    (meanD1_FG - mu0_FG_strat1)*pinv(covarPrior)*...
    (meanD1_FG - mu0_FG_strat1)');
% for i = [1:1:68850]
%     probBG_X(i) = 1/(n1_2)*exp(-.5*(cheetahdata(i,:)-meanD1_BG)*...
%         c1*(cheetahdata(i,:)-meanD1_BG)')*exp(-.5*...
%         (meanD1_BG - mewN_BG)*c3*(meanD1_BG - mewN_BG)')*priorBG;
%     probFG_X(i) = 1/(n2_2)*exp(-.5*(cheetahdata(i,:)-meanD1_FG)*...
%         c2*(cheetahdata(i,:)-meanD1_FG)')*exp(-.5*...
%         (meanD1_FG - mewN_FG)*c4*(meanD1_FG - mewN_FG)')*priorFG;
% end
n3_1 = 1/sqrt(det(covarN_BG + covarD1_BG));
n4_1 = 1/sqrt(det(covarN_FG + covarD1_FG));
c5 = pinv(covarN_BG + covarD1_BG);
c6 = pinv(covarN_FG + covarD1_FG);
%the 2pi terms don't matter.
for i = [1:1:68850]
      probBG_X(i) = n3_1*exp(-.5*(cheetahdata(i,:)-mewN_BG)*...
         c5*(cheetahdata(i,:)-mewN_BG)')*priorBG;
      probFG_X(i) = n4_1*exp(-.5*(cheetahdata(i,:)-mewN_FG)*...
         c6*(cheetahdata(i,:)-mewN_FG)')*priorFG;
end


A = (probBG_X <= probFG_X);
Aimg = reshape(A,[255 270]);
figure
imagesc(Aimg)
title('D1 classifier noalpha');
colormap gray

%comparison
cheetahcomp = logical(imread('cheetah_mask.bmp'));

%error probabilities
%false positive
alpha1 = sum(sum((Aimg == true)&(cheetahcomp == false)));
FalsePosError = alpha1/sum(sum(cheetahcomp == true))*priorBG;
%false negative
beta = sum(sum((Aimg == false)&(cheetahcomp == true)));
FalseNegError = beta/sum(sum(cheetahcomp == false))*priorFG;
%Total Error Probability
TotalErrorProb = FalseNegError + FalsePosError

%%
for n = [1:length(alpha)]
    s0 = covarPrior;
    s = covarD1_BG;
    m = meanD1_BG;
    m0 = mu0_BG_strat1;
    
    mewN_BG = alpha(n)*m' +(1-alpha(n))*m0';
    mewN_BG = mewN_BG';
    covarN_BG = (1-alpha(n))*s;
    
    s0 = covarPrior;
    s = covarD1_FG;
    m = meanD1_FG;
    m0 = mu0_FG_strat1;
    
    mewN_FG = alpha(n)*m' +(1-alpha(n))*m0';
    mewN_FG = mewN_FG';
    covarN_FG = (1-alpha(n))*s;
    n1_1 = det(covarN_BG);
    n1_2 = sqrt(det(covarD1_BG));
    n2_1 = det(covarN_FG);
    n2_2 = sqrt(det(covarD1_FG));
    c1 = pinv(covarD1_BG);
    c2 = pinv(covarD1_FG);
    c3 = pinv(covarN_BG);
    c4 = pinv(covarN_FG);
    %the 2pi terms don't matter.
    for i = [1:1:68850]
        probBG_X(i) = 1/(n1_2)*exp(-.5*(cheetahdata(i,:)-meanD1_BG)*...
            c1*(cheetahdata(i,:)-meanD1_BG)')*exp(-.5*...
            (meanD1_BG - mewN_BG)*c3*(meanD1_BG - mewN_BG)');
        probFG_X(i) = 1/(n2_2)*exp(-.5*(cheetahdata(i,:)-meanD1_FG)*...
            c2*(cheetahdata(i,:)-meanD1_FG)')*exp(-.5*...
            (meanD1_FG - mewN_FG)*c4*(meanD1_FG - mewN_FG)');
    end
% n3_1 = 1/sqrt(det(covarN_BG + covarD1_BG));
% n4_1 = 1/sqrt(det(covarN_FG + covarD1_FG));
% c5 = pinv(covarN_BG + covarD1_BG);
% c6 = pinv(covarN_FG + covarD1_FG);
% 
% %the 2pi terms don't matter.
% for i = [1:1:68850]
%       probBG_X(i) = n3_1*exp(-.5*(cheetahdata(i,:)-mewN_BG)*...
%          c5*(cheetahdata(i,:)-mewN_BG)');
%       probFG_X(i) = n4_1*exp(-.5*(cheetahdata(i,:)-mewN_FG)*...
%          c6*(cheetahdata(i,:)-mewN_FG)');
% end
    
    priorBG = 1/(pi^32)/sqrt(det(covarPrior))*exp(-.5*...
        (meanD1_BG - mu0_BG_strat1)*pinv(covarPrior)*...
        (meanD1_BG - mu0_BG_strat1)');
    priorFG = 1/(pi^32)/sqrt(det(covarPrior))*exp(-.5*...
        (meanD1_FG - mu0_FG_strat1)*pinv(covarPrior)*...
        (meanD1_FG - mu0_FG_strat1)');
    A = (probBG_X*priorBG <= probFG_X*priorFG);
    Aimg = reshape(A,[255 270]);
    figure
    imagesc(Aimg)
    title(strcat('D1 classifier, alpha = ',num2str(alpha(n))));
    colormap gray
    
    %error probabilities
    %false positive
    alpha1 = sum(sum((Aimg == true)&(cheetahcomp == false)));
    FalsePosError(n) = alpha1/sum(sum(cheetahcomp == true))*priorBG;
    %false negative
    beta = sum(sum((Aimg == false)&(cheetahcomp == true)));
    FalseNegError(n) = beta/sum(sum(cheetahcomp == false));
    %Total Error Probability
    TotalErrorProb(n) = FalseNegError(n) + FalsePosError(n)*priorFG;
end

figure
semilogx(alpha,TotalErrorProb);
title('Error probability of D1 vs alpha');

%%
%part B
priorchet = length(D1_FG)/(length(D1_BG) + length(D1_FG));
priorbg = length(D1_BG)/(length(D1_BG) + length(D1_FG));

meanchet = mean(D1_FG,1);
meanbg = mean(D1_BG,1);
comp = abs(meanchet-meanbg);
[compsort, ind] = sort(comp,'descend');
best = ind(1:8);
worst = ind(57:64);

covarchet = (1/length(D1_FG))*(D1_FG - meanchet)'*...
    (D1_FG - meanchet);
covarbg = (1/length(D1_BG))*(D1_BG - meanbg)'*...
    (D1_BG - meanbg);
detbg = det(covarbg);
k11 = 1/sqrt(detbg*(2*pi)^64);
detchet = det(covarchet);
k22 = 1/sqrt(detchet*(2*pi)^64);
covarbginv = inv(covarbg);
covarchetinv = inv(covarchet);
%probabilities
for i = [1:1:68850]
    probIndexBG(i) = k11*exp((cheetahdata(i,:)-...
        meanbg)*covarbginv*(cheetahdata(i,:)-meanbg)'*(-1/2));
    probIndexFG(i) = k22*exp((cheetahdata(i,:)-...
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
FalsePosError = alpha/sum(sum(cheetahcomp == true))*priorchet;
%false negative
beta = sum(sum((Aimg == false)&(cheetahcomp == true)));
FalseNegError = beta/sum(sum(cheetahcomp == false))*priorbg;
%Total Error Probability
TotalErrorProb = FalseNegError + FalsePosError

%%
meanD1_BG = mean(D1_BG);
meanD1_FG = mean(D1_FG);
covarD1_BG = (D1_BG - meanD1_BG)'*(D1_BG - meanD1_BG)/length(D1_BG);
covarD1_FG = (D1_FG - meanD1_FG)'*(D1_FG - meanD1_FG)/length(D1_FG);

%actually start part a
s0 = covarPrior;
s = covarD1_BG;
m = meanD1_BG;
m0 = mu0_BG_strat1;
n = 1/size(D1_BG,1);

mewN_BG = s0*pinv(s0 + n*s)*m' + n*s*pinv(s0 + n*s)*m0';
mewN_BG = mewN_BG';
covarN_BG = s0*inv(s0 + n*s)*n*s;

s0 = covarPrior;
s = covarD1_FG;
m = meanD1_FG;
m0 = mu0_FG_strat1;
n = 1/size(D1_FG,1);

mewN_FG = s0*pinv(s0 + n*s)*m' + n*s*pinv(s0 + n*s)*m0';
mewN_FG = mewN_FG';
covarN_FG = s0*inv(s0 + n*s)*n*s;

covarchet = (1/length(D1_FG))*(D1_FG - mewN_FG)'*...
    (D1_FG - mewN_FG);
covarbg = (1/length(D1_BG))*(D1_BG - mewN_BG)'*...
    (D1_BG - mewN_BG);
meanbg = mewN_BG;
meanchet = mewN_FG;
detbg = det(covarbg);
detchet = det(covarchet);
covarbginv = inv(covarbg);
covarchetinv = inv(covarchet);

for i = [1:1:68850]
    probIndexBG(i) = 1/sqrt(detbg*(2*pi)^64)*exp((cheetahdata(i,:)-...
        meanbg)*covarbginv*(cheetahdata(i,:)-meanbg)'*(-1/2));
    probIndexFG(i) = 1/sqrt(detchet*(2*pi)^64)*exp((cheetahdata(i,:)-...
        meanchet)*covarchetinv*(cheetahdata(i,:)-meanchet)'*(-1/2));
end

%final image
%assume equiprobable
probBG_X = probIndexBG.*(priorBG);
probFG_X = probIndexFG.*(priorFG);
A = (probBG_X <= probFG_X);
Aimg = reshape(A,[255 270]);
figure
imagesc(Aimg)
title('MAP estimate classifier');   
colormap gray

%error probabilities
%false positive
alpha = sum(sum((Aimg == true)&(cheetahcomp == false)));
FalsePosError = alpha/sum(sum(cheetahcomp == true))*priorchet;
%false negative
beta = sum(sum((Aimg == false)&(cheetahcomp == true)));
FalseNegError = beta/sum(sum(cheetahcomp == false))*priorbg;
%Total Error Probability
TotalErrorProb = FalseNegError + FalsePosError