clear all
f1 = 'train-images.idx3-ubyte';
f2 = 'train-labels.idx1-ubyte';
f3 = 't10k-images.idx3-ubyte';
f4 = 't10k-labels.idx1-ubyte';

[trainimgs trainlabels] = readMNIST(f1,f2,20000,0);
[testimgs testlabels] = readMNIST(f3,f4,10000,0);

%%
%initializations.
y = zeros(10,20000);
yp = zeros(10,10000);
for j = 1:10
    y(j,:) = ((j-1) == trainlabels) -1*((j-1) ~= trainlabels);
    yp(j,:) = ((j-1) == testlabels) -1*((j-1) ~= testlabels);
end
g = zeros(10,20000);
gp = zeros(10,10000);
M = 0:1/50:1;
sav = [];
ind = 0;
matstor = [];
errortest = [];
errortrain = [];
maxind = [];
margstor = [];
arr = ones(784,10);
arr = arr.*128;
precalc = zeros(20000,784,51);
for i = 1:784
    precalc(:,i,:) = ((trainimgs(:,i) >= M) -1*(trainimgs(:,i) < M));
end
for k = 1:250
    %%
    k
    R = exp(-1.*y.*g);
    Rp = exp(-1.*yp.*gp);
    deriv = zeros(10,784,51);
    inds = zeros(10,51);
    vals = zeros(10,51);
    temp1 = zeros(1,784);
    temp2 = zeros(1,784);
    temptot = zeros(1,102);
    threshF = zeros(10,1);
    flag = zeros(10,51);
    flagf = zeros(10,1);
    for j = 1:10
        L = y(j,:).*R(j,:);
        for i = 1:51
            temp1 = L*precalc(:,:,i);
            temp2 = -temp1;
            temptot = [temp1,temp2];
            [vals(j,i),ind(j,i)] = max(temptot);
        end
    end
    flag = ind > 784;
    ind = ind - 784.*flag;
    for j = 1:10
        [~,threshF(j)] = max(vals(j,:));
        flagf(j) = flag(j,threshF(j));
        arr(ind(j,threshF(j)),j) = 255*(1-flagf(j));
    end
    %%
    K = ones(20000,10);
    Kp = ones(10000,10);
    for j = 1:10
        K(:,j) = K(:,j) - 2*(trainimgs(:,ind(j,threshF(j))) < M(threshF(j)));
        if (flagf(j))
            K(:,j) = -K(:,j);
        end
        Kp(:,j) = Kp(:,j) -2*(testimgs(:,ind(j,threshF(j))) < M(threshF(j)));
        if (flagf(j))
            Kp(:,j) = -Kp(:,j);
        end
    end
    %%
    out = y';
    yeet = [];
    weights = zeros(10,1);
    for j = 1:10
        yeet = sum((K(:,j)~=y(j,:)').*R(j,:)')/sum(R(j,:));
        weights(j) = 0.5*log((1-yeet)/yeet);
    end
    %%
    C = K';
    Cp = Kp';
    L = [];
    temper1 = zeros(1,10);
    temper2 = zeros(1,10);
    tempmax = zeros(1,10);
    for i = 1:10
        g(i,:) = g(i,:) + weights(i)*C(i,:);
        [~,tempmax(i)] = max(g(i,:));
        temper1(i) = sum(sign(g(i,:))~=y(i,:))/20000;
        gp(i,:) = gp(i,:) + weights(i)*Cp(i,:);
        temper2(i) = sum(sign(gp(i,:))~=yp(i,:))/10000;
    end
    [~,test] = max(gp);
    test = test - 1;
    error2 = sum(test ~= testlabels')/10000
    errortest = vertcat(errortest,temper2);
    errortrain = vertcat(errortrain,temper1);
    maxind = vertcat(maxind,tempmax);
    if(k == 5 || k == 10 || k == 50 || k == 100 || k == 250)
        margstor = cat(3,margstor,exp(-1.*y.*g)./20000);
    end
end