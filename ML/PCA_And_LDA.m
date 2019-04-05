s = cd;
data = [];
labels = [];
for i = 1:6
    for j = 1:40
        filename = 'data\person_';
        filename = horzcat(filename,num2str(i),'_',num2str(j),'.jpg');
        data = cat(3,data,im2double(imread(filename)));
        labels = vertcat(labels,i);
    end
end

%% Pure PCA
%get mean and covariances
mean = 1/size(data,3)*sum(data,3);
mew = reshape(mean,[2500,1]);
dataN = reshape(data, [2500,1,240]);
dataCent = dataN - mew;
dataCent = reshape(dataCent,[2500 240]);
covar = 1/size(data,3)*dataCent*dataCent';

%eigen decomp of covariance
[V,D,Wt] = eig(covar);
Dnorm = sum(D,2);
W = Wt';
[vals,ind] = sort(Dnorm,1);
for i = 2485:1:2500
     mat(:,i-2484) = W(ind(i),:);
 end
mat2 = reshape(mat,[50 50 16]);
figure
%top 16 principal components
for i = 1:1:16
    subplot(4,4,i)
    imagesc(mat2(:,:,17-i))
    colormap gray
end

%% Pure LDA
means = [];
covars = [];
dat = reshape(data,[2500,240]);
for i = 1:6
    reldat = dat(:,1+40*(i-1):40*i);
    means(:,i) = 1/40*sum(reldat,2);
    covars(:,:,i) = 1/40*(reldat-means(:,i))*(reldat-means(:,i))';
end
%sB(:,:,i,j) = (means(:,j)-means(:,i))*(means(:,j)-means(:,i))';
sB = [];
for i = 1:5
    for j = i+1:6
        j
        sB(:,i,j) = (means(:,j)-means(:,i));
        sW(:,:,i,j) = covars(:,:,i) + covars(:,:,j) + eye(2500,2500);
        wopt(:,i,j) = pinv(sW(:,:,i,j))*sB(:,i,j);
    end
end
wstar = squeeze(wopt);
wstar = reshape(wstar,[50 50 5 6]);

figure
k = 1;
for i = 1:5
    for j = i+1:6
       subplot(4,4,k);
       imagesc(wstar(:,:,i,j));
       title(strcat(num2str(i),' vs ',num2str(j)));
       k = k + 1;
       colormap gray
    end
end
%% Classification with PCA
E = mat(:,2:16)'*dat;
testdata = [];
testlabels = [];
z3 = [];
for i = 1:6
    for j = 1:10
        filename = 'testdata\person_';
        filename = horzcat(filename,num2str(i),'_',num2str(j),'.jpg');
        testdata = cat(3,testdata,im2double(imread(filename)));
        testlabels = vertcat(testlabels,i);
    end
end
testshape = reshape(testdata,[2500 length(testlabels)]);
for i = 1:6
    reldat3 = E(:,1+40*(i-1):40*i);
    means3(:,i) = 1/40*sum(reldat3,2);
    covars3(:,:,i) = 1/40*(reldat3-means3(:,i))*(reldat3-means3(:,i))';
    z3(i) = 1/det(covars3(:,:,i));
    covarinv3(:,:,i) = inv(covars3(:,:,i));
end
Etest = mat(:,2:16)'*testshape;
for i = 1:1:length(testlabels)
    for j = 1:6
        prob3(i,j) = z3(j)*exp(-.5*(Etest(:,i)-means3(:,j))'*...
            covarinv3(:,:,j)*(Etest(:,i)-means3(:,j)));
    end
end
[~,labelout] = max(prob3,[],2);
for i = 1:6
    alpha(i) = sum((labelout == i)==(testlabels ~= i));
    FalsePosError(i) = alpha(i)/sum(testlabels == i)/6;
    beta(i) = sum((labelout ~= i)==(testlabels == i));
    FalseNegError(i) = beta(i)/sum(testlabels ~= i)*5/6;
    TotalErrProb3(i) = FalsePosError(i) + FalseNegError(i);
end
AvgTotalErr3 = 1/6*sum(TotalErrProb3);
%% CLassification with LDA
wstar = squeeze(wopt);
votes = zeros(60,6);
for i = 1:6
    for j = i+1:6
        temp = wstar(:,i,j)'*testshape;
        temp = temp';
        votes(:,i) = votes(:,i) + (temp <= 0);
        votes(:,j) = votes(:,j) + (temp > 0);
    end
end
[~,labelout2] = max(votes,[],2);
for i = 1:6
    alpha(i) = sum((labelout2 == i)==(testlabels ~= i));
    FalsePosError(i) = alpha(i)/sum(testlabels == i)/6;
    beta(i) = sum((labelout2 ~= i)==(testlabels == i));
    FalseNegError(i) = beta(i)/sum(testlabels ~= i)*5/6;
    TotalErrProb4(i) = FalsePosError(i) + FalseNegError(i);
end
AvgTotalErr4 = 1/6*sum(TotalErrProb4);
%% LDA + PCA data transform.
%get mean and covariances
mean = 1/size(data,3)*sum(data,3);
mew = reshape(mean,[2500,1]);
dataN = reshape(data, [2500,1,240]);
dataCent = dataN - mew;
dataCent = reshape(dataCent,[2500 240]);
covar = 1/size(data,3)*dataCent*dataCent';

%eigen decomp of covariance
[V,D,Wt] = eig(covar);
Dnorm = sum(D,2);
W = Wt';
[vals,ind] = sort(Dnorm,1);
mat = [];
for i = 2471:1:2500
     mat(:,i-2470) = W(ind(i),:);
end
%%
E = mat'*dat;
means = [];
covars = [];
for i = 1:6
    reldat = E(:,1+40*(i-1):40*i);
    means(:,i) = 1/40*sum(reldat,2);
    covars(:,:,i) = 1/40*(reldat-means(:,i))*(reldat-means(:,i))';
end
sB = [];
sW = [];
wopt = [];
for i = 1:5
    for j = i+1:6
        sB(:,i,j) = (means(:,j)-means(:,i));
        sW(:,:,i,j) = covars(:,:,i) + covars(:,:,j);
        wopt(:,i,j) = pinv(sW(:,:,i,j))*sB(:,i,j);
    end
end
%% Classify with LDA + PCA
votes = zeros(60,6);
lastdat = mat'*testshape;
for i = 1:6
    for j = i+1:6
        temp = wopt(:,i,j)'*lastdat;
        temp = temp';
        votes(:,i) = votes(:,i) + (temp <= 0);
        votes(:,j) = votes(:,j) + (temp > 0);
    end
end
[~,labelout3] = max(votes,[],2);
for i = 1:6
    alpha(i) = sum((labelout3 == i)==(testlabels ~= i));
    FalsePosError(i) = alpha(i)/sum(testlabels == i)/6;
    beta(i) = sum((labelout3 ~= i)==(testlabels == i));
    FalseNegError(i) = beta(i)/sum(testlabels ~= i)*5/6;
    TotalErrProb5(i) = FalsePosError(i) + FalseNegError(i);
end
AvgTotalErr5 = 1/6*sum(TotalErrProb5);