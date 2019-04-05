clear all
load TrainingSamplesDCT_8_new
cheetah = imread('cheetah.bmp');
%there's a noisy strip on the right that I get rid of.
cheetah = im2double(cheetah(:,1:268));


cheetah = padarray(cheetah,[4 5],'replicate');
cheetah = padarray(cheetah,[0 2],'post','replicate');
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
%%
%initialization
%get my 8 coeffs for each classifier. Use COLUMNS.
x = TrainsampleDCT_FG;
%number of dimensions
BIN = 64;
for count = 1:1
%     coeffs = reshape(randperm(64),[BIN 64/BIN]);
    coeffs = reshape([1:64],[BIN 64/BIN]);
    %USE COLUMNS
    prior = rand(1,64/BIN);
    prior = prior./sum(prior);
    means = rand(BIN,64/BIN);
    cov = rand(BIN,64/BIN);
    for i = [1:64/BIN]
%         covar(:,:,i) = diag(cov(:,i));
        covar(:,:,i) = eye(BIN);
    end
    [classchet(count),qchet(count,:)] = getClassif(covar,means,prior,x,coeffs,BIN);
end
x = TrainsampleDCT_BG;
for count = 1:1
%     coeffs = reshape(randperm(64),[BIN 64/BIN]);
    coeffs = reshape([1:64],[BIN 64/BIN]);
    %USE COLUMNS
    prior = rand(1,64/BIN);
    prior = prior./sum(prior);
    means = rand(BIN,64/BIN);
    cov = rand(BIN,64/BIN);
    for i = [1:64/BIN]
%         covar(:,:,i) = diag(cov(:,i));
        covar(:,:,i) = eye(BIN);
    end
    [classbg(count),qbg(count,:)] = getClassif(covar,means,prior,x,coeffs,BIN);
end
%%
priorbg = 1053/(250+1053);
priorchet = 250/(1053 + 250);
cheetahcomp = logical(imread('cheetah_mask.bmp'));
for (i = 1:1)
    i
    for j = (1:1)
        j
        Aimg = classify(classchet(i),classbg(j),cheetah,priorbg,priorchet,...
            cheetahdata,BIN);
        %error probabilities
        %false positive
        alpha = sum(sum((Aimg == true)&(cheetahcomp == false)));
        FalsePosError = alpha/sum(sum(cheetahcomp == true))*priorchet;
        %false negative
        beta = sum(sum((Aimg == false)&(cheetahcomp == true)));
        FalseNegError = beta/sum(sum(cheetahcomp == false))*priorbg;
        %Total Error Probability
        TotalErrorProb(i,j) = FalseNegError + FalsePosError;
    end
end
% TotalErrorProb = reshape(TotalErrorProb,[1 25]);
%%
function [Aimg] = classify(classFG,classBG,cheetah,priorbg,priorchet,...
    cheetahdata,n)
for(i = 1:1:64/n)
    detbg(i) = 1/sqrt(det(classBG.covar(:,:,i)))*classBG.prior(i);
    detchet(i) = 1/sqrt(det(classFG.covar(:,:,i)))*classFG.prior(i);
    covarbginv(:,:,i) = inv(classBG.covar(:,:,i));
    covarchetinv(:,:,i) = inv(classFG.covar(:,:,i));
    %probabilities
end
%probabilities
for j = 1:1:64/n
    for i = [1:1:68850]
        probIndexBG(i,j) = detbg(j)*exp((cheetahdata(i,classBG.coeffs(:,j))-...
            classBG.means(:,j)')*covarbginv(:,:,j)*...
            (cheetahdata(i,classBG.coeffs(:,j))-classBG.means(:,j)')'*(-1/2));
        probIndexFG(i,j) = detbg(j)*exp((cheetahdata(i,classFG.coeffs(:,j))-...
            classFG.means(:,j)')*covarbginv(:,:,j)*...
            (cheetahdata(i,classFG.coeffs(:,j))-classFG.means(:,j)')'*(-1/2));
    end
end

%final image
%assume equiprobable
probIndexBG = sum(probIndexBG,2);
probIndexFG = sum(probIndexFG,2);
probBG_X = probIndexBG.*(priorbg);
probFG_X = probIndexFG.*(priorchet);
A = (probBG_X <= probFG_X);
Aimg = reshape(A,[255 270]);
figure
imagesc(Aimg)
title('64 feature classifier');   
colormap gray
end
%%
function [class,Q] = getClassif(covar,means,prior,x,coeffs,n)
piTerm = nthroot(2*pi,n/2);
pRI = 1/size(x,1);
Q1 = Inf;
Q = [];
covarstor = covar;
meanstor = means;
pristor = prior;
for count = 1:1:200
    for i = [1:64/n]
        %can exclude pi term tbh.
        detTerm = 1/sqrt(det(covar(:,:,i)))*prior(i);
        invTerm = pinv(covar(:,:,i));
        prob(:,i) = 0;
        for j = 1:size(x,1)
            prob(j,i) = exp(-.5*((x(j,coeffs(:,i))...
                - means(:,i)')*invTerm*(x(j,coeffs(:,i))...
                - means(:,i)')'));
        end
        prob(:,i) = prob(:,i).*detTerm;
    end
    %%
    %E part
    h = zeros(size(x,1),64/n);
    ind = find(prob == 0);
    prob(ind) = realmin;
    for i = [1:64/n]
        h(:,i) = prob(:,i)./sum(prob,2);
    end
    ind = find(h == 0);
    h(ind) = realmin;
%     Qnext = sum(sum(h.*log(prob)));
%     Q = horzcat(Q,Qnext);
%     if (abs(abs(Qnext) - abs(Q1)) > 10^-10)
%         Q1 = Qnext;
%     else
%         covar = covarstor;
%         means = meanstor;
%         prior = pristor;
%         break;
%     end
    %%
    %M part
    
    for i = 1:64/n
        covarNEW(:,:,i) = zeros(n);
        meanNEW(:,i) = sum(h(:,i).*x(:,coeffs(:,i)),1);
        meanNEW(:,i) = meanNEW(:,i)/sum(h(:,i));
        priorNEW(i) = pRI*sum(h(:,i));
        for j = 1:size(x,1)
            covarNEW(:,:,i) = covarNEW(:,:,i) + h(j,i)*(x(j,coeffs(:,i)) - ...
                meanNEW(:,i)')'*(x(j,coeffs(:,i)) - ...
                meanNEW(:,i)');
        end
        covarNEW(:,:,i) = covarNEW(:,:,i)./sum(h(:,i));
        covarNEW(:,:,i) = covarNEW(:,:,i).*eye(n);
        %add small epsilon
%         covarNEW(:,:,i) = covarNEW(:,:,i) + eye(n).*10^-(5*32/n);
%         covarNEW(:,:,i) = max(covarNEW(:,:,i),10^-6);
    end%     covarstor = covar;
%     meanstor = means;
%     pristor = prior;

    covar = covarNEW;
    means = meanNEW;
    prior = priorNEW;
end
class.covar = covar;
class.means = means;
class.prior = prior;
class.coeffs = coeffs;
end