clear all
f1 = 'train-images.idx3-ubyte';
f2 = 'train-labels.idx1-ubyte';
f3 = 't10k-images.idx3-ubyte';
f4 = 't10k-labels.idx1-ubyte';

[trainimgs trainlabels] = readMNIST(f1,f2,60000,0);
[testimgs testlabels] = readMNIST(f3,f4,10000,0);

%10 labels.
%softmax(z) = softmax(z-max(z));

%%
k = 0;
w = normrnd(0,1,10,785);
b = 0;
nu = 10^-5

x = gpuArray([trainimgs,ones(60000,1)]);
y = gpuArray(trainlabels);
wg = gpuArray(w);
act = gpuArray(ones(60000,10));
sfm = act;
xtest = gpuArray([testimgs,ones(10000,1)]);
outputfinal = gpuArray(testlabels);
smfT = outputfinal;
actT = outputfinal;

%
%1 hot encoding
labels = zeros(60000,10);
trainlabels = trainlabels + 1;
for i = 1:10
    labels(:,i) = ind2sub(trainlabels, trainlabels == i);
end
labelgpu = gpuArray(labels);
trainlabels = trainlabels - 1;

% Neural network functions.
k = k + 1;
for i = 1:10
    act(:,i) = wg(i,:)*x';
end
for i = 1:10
    sfm(:,i) = exp(act(:,i))./sum(exp(act),2);
end
presum = labelgpu-sfm;

for i = 1:10
    wg(i,:) = wg(i,:) + nu.*presum(:,i)'*x;
end

%Feedforward
for i = 1:10
    act(:,i) = wg(i,:)*x';
end
for i = 1:10
    sfm(:,i) = exp(act(:,i))./sum(exp(act),2);
end
output = gather(sfm);
[~,pred] = max(output');
pred = pred - 1;
error = sum(pred ~= trainlabels')/60000;

errornext = error;
error = 1;
classerror = errornext;

for i = 1:10
    actT(:,i) = wg(i,:)*xtest';
end
for i = 1:10
    smfT(:,i) = exp(actT(:,i))./sum(exp(actT),2);
end
outputfinal = gather(smfT);
[~,predo] = max(outputfinal');
predo = predo - 1;
finalerror = sum(predo ~= testlabels')/10000;

%probably threshold mag(errornext-error) > 0.001 or something.
%play around with this cuz it's definitely not a local minimum.
while (k < 5000)
    k = k + 1
    for i = 1:10
        act(:,i) = wg(i,:)*x';
    end
    for i = 1:10
        sfm(:,i) = exp(act(:,i))./sum(exp(act),2);
    end
    presum = labelgpu-sfm;
    
    for i = 1:10
        wg(i,:) = wg(i,:) + nu.*presum(:,i)'*x;
    end
    
    %Feedforward
    for i = 1:10
        act(:,i) = wg(i,:)*x';
    end
    for i = 1:10
        sfm(:,i) = exp(act(:,i))./sum(exp(act),2);
    end
    output = gather(sfm);
    [~,pred] = max(output');
    pred = pred - 1;
    error = errornext;
    errornext = sum(pred ~= trainlabels')/60000;
    classerror = horzcat(classerror,errornext);
    
    for i = 1:10
    actT(:,i) = wg(i,:)*xtest';
    end
    for i = 1:10
        smfT(:,i) = exp(actT(:,i))./sum(exp(actT),2);
    end
    outputfinal = gather(smfT);
    [~,predo] = max(outputfinal');
    predo = predo - 1;
    finalerror = horzcat(finalerror,sum(predo ~= testlabels')/10000);
end
%%
%classify test data
