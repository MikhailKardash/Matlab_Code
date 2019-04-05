clear all
f1 = 'train-images.idx3-ubyte';
f2 = 'train-labels.idx1-ubyte';
f3 = 't10k-images.idx3-ubyte';
f4 = 't10k-labels.idx1-ubyte';

[trainimgs trainlabels] = readMNIST(f1,f2,20000,0);
[testimgs testlabels] = readMNIST(f3,f4,10000,0);

addpath(strcat(cd,'\libsvm-3.22\windows'))
%%
x = trainimgs;
y = ones(10,length(trainlabels));
for i = 1:10
    y(i,:) = (trainlabels == i-1) - (trainlabels ~= i-1); 
end
%%
xtest = testimgs;
ytest = ones(10,length(testlabels));
for i = 1:10
    ytest(i,:) = (testlabels == i-1) - (testlabels ~= i-1); 
end
%%
for i = 1:10
    for j = [2,4,8]
        iter = [num2str(i),' ',num2str(j)]
        svmopts=['-t 0 -c ',num2str(j)];
        model(i,log2(j))=svmtrain(y(i,:)',x,svmopts);
    end
end
%%
Acc = ones(10,3,3);
Pout = ones(10,3,10000);
for i = 1:10
    for j = 1:3
        iter = [num2str(i),' ',num2str(j)]
        [~, Acc(i,j,:), Pout(i,j,:)] = svmpredict(ytest(i,:)',xtest,model(i,j));        
    end
end
%%
for i = 1:10
    figure
    for j = 1:3
        [~,temp1] = sort(model(i,j).sv_coef,'descend');
        [~,temp2] = sort(model(i,j).sv_coef,'ascend');
        subplot(3,6,1+6*(j-1));
        imagesc(reshape(model(i,j).SVs(temp1(1),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,2+6*(j-1));
        imagesc(reshape(model(i,j).SVs(temp1(2),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,3+6*(j-1));
        imagesc(reshape(model(i,j).SVs(temp1(3),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,4+6*(j-1));
        imagesc(reshape(model(i,j).SVs(temp2(1),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
        subplot(3,6,5+6*(j-1));
        imagesc(reshape(model(i,j).SVs(temp2(2),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
        subplot(3,6,6+6*(j-1));
        imagesc(reshape(model(i,j).SVs(temp2(3),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
    end
end
%%
inds = zeros(3,10000);
for i = 1:3
    [~,inds(i,:)] = max(Pout(:,i,:));
end
inds = inds -1;
%%
sums = zeros(1,3);
for i = 1:3
    sums(i) = sum(inds(i,:) == testlabels')/10000;
end
%%
nums = zeros(10,3);
for i = 1:3
    for j = 1:10
        nums(j,i) = length(model(j,i).sv_coef);
    end
end
%%
for i = 1:10
    for j = [2,4,8]
        iter = [num2str(i),' ',num2str(j)]
        svmopts=['-t 2 -c ',num2str(j)];
        modelR(i,log2(j))=svmtrain(y(i,:)',x,svmopts);
    end
end
%%
AccR = ones(10,3,3);
PoutR = ones(10,3,10000);
for i = 1:10
    for j = 1:3
        iter = [num2str(i),' ',num2str(j)]
        [~, Acc(i,j,:), PoutR(i,j,:)] = svmpredict(ytest(i,:)',xtest,modelR(i,j));        
    end
end
%%
indsR = zeros(3,10000);
for i = 1:3
    [~,indsR(i,:)] = max(PoutR(:,i,:));
end
indsR = indsR -1;
%%
sumsR = zeros(1,3);
for i = 1:3
    sumsR(i) = sum(indsR(i,:) == testlabels')/10000;
end
%%
numsR = zeros(10,3);
for i = 1:3
    for j = 1:10
        numsR(j,i) = length(modelR(j,i).sv_coef);
    end
end
%%
for i = 1:10
    figure
    for j = 1:3
        [~,temp1] = sort(modelR(i,j).sv_coef,'descend');
        [~,temp2] = sort(modelR(i,j).sv_coef,'ascend');
        subplot(3,6,1+6*(j-1));
        imagesc(reshape(modelR(i,j).SVs(temp1(1),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,2+6*(j-1));
        imagesc(reshape(modelR(i,j).SVs(temp1(2),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,3+6*(j-1));
        imagesc(reshape(modelR(i,j).SVs(temp1(3),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,4+6*(j-1));
        imagesc(reshape(modelR(i,j).SVs(temp2(1),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
        subplot(3,6,5+6*(j-1));
        imagesc(reshape(modelR(i,j).SVs(temp2(2),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
        subplot(3,6,6+6*(j-1));
        imagesc(reshape(modelR(i,j).SVs(temp2(3),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
    end
end
%%
vectorC = [.5:.25:2];
vectorG = [.5/784:.5/784:2.5/784];
for i = 1:length(vectorC)
    for j = 1:length(vectorG)
        i
        j
        svmopts=['-t 2 -c ',num2str(vectorC(i)),' -g ', num2str(vectorG(j))];
        modelo(i,j) = svmtrain(y(9,:)',x,svmopts);
    end
end
%%
accs = zeros(length(vectorC),length(vectorG),3);
for i = 1:length(vectorC)
    for j = 1:length(vectorG)
        i
        j
        [~,accs(i,j,:),~] = svmpredict(ytest(9,:)',xtest,modelo(i,j));
    end
end
%%
%optimal C = 2;
%now sweep gamma.
gamma = [5/784:1/784:20/784];
for i = 1:length(gamma)
    i
    svmopts=['-t 2 -c 2 -g ', num2str(gamma(i))];
    modelOG(i) = svmtrain(y(9,:)',x,svmopts);
end
accsOG = zeros(length(gamma),3);
for i = 1:length(gamma)
    i
    [~,accsOG(i,:),~] = svmpredict(ytest(9,:)',xtest,modelOG(i));
end
%%
%final C = 2 gamma = 0.0204
for i = 1:10
    i
    svmopts=['-t 2 -c 2 -g .0204'];
    modelfin(i) = svmtrain(y(i,:)',x,svmopts);
end
%%
accfin = zeros(10,3);
Finout = ones(10,10000);
for i = 1:10
    i
    [~,accfin(i,:),Finout(i,:)] = svmpredict(ytest(i,:)',xtest,modelfin(i));
end
%%
indsF = zeros(1,10000);
[~,indsF] = max(Finout);
indsF = indsF -1;
%%
sumsF = sum(indsF == testlabels')/10000;
%%
for i = 1:3
    figure
    for j = 1:10
        subplot(2,5,j)
        temp = reshape(Pout(j,i,:),[1 10000]);
        plot(cumsum(hist(temp)))
        title([num2str(j-1),': c-',num2str(2^i)]);
    end
end
%%
for i = 1:3
    figure
    for j = 1:10
        subplot(2,5,j)
        temp = reshape(PoutR(j,i,:),[1 10000]);
        plot(cumsum(hist(temp)))
        title([num2str(j-1),': c-',num2str(2^i)]);
    end
end
%%
for i = 1:10
    figure
    for j = 1:1
        [~,temp1] = sort(modelfin(i).sv_coef,'descend');
        [~,temp2] = sort(modelfin(i).sv_coef,'ascend');
        subplot(3,6,1+6*(j-1));
        imagesc(reshape(modelfin(i).SVs(temp1(1),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,2+6*(j-1));
        imagesc(reshape(modelfin(i).SVs(temp1(2),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,3+6*(j-1));
        imagesc(reshape(modelfin(i).SVs(temp1(3),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' pos']);
        subplot(3,6,4+6*(j-1));
        imagesc(reshape(modelfin(i).SVs(temp2(1),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
        subplot(3,6,5+6*(j-1));
        imagesc(reshape(modelfin(i).SVs(temp2(2),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
        subplot(3,6,6+6*(j-1));
        imagesc(reshape(modelfin(i).SVs(temp2(3),:),[28 28])');
        title([num2str(i-1),': c-',num2str(2^j),' neg']);
    end
end
%%
figure
for j = 1:10
    subplot(2,5,j)
    plot(cumsum(hist(Finout(i,:))))
    title([num2str(j-1),': c-',num2str(2^i)]);
end