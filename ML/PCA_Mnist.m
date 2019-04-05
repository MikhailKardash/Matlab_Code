load data
load label
 
%now just for digit 5
fives = [];
j = 1;
for i = 1:1:5000
    if labelTrain(i) == 5
        fives(:,:,j) = imageTrain(:,:,i);
        j = j + 1;
    end
end
fivesmean = sum(fives,3)/size(fives,3);
mew5 = reshape(fivesmean,[784,1]);
fivesRE = reshape(fives,[784,size(fives,3)]);
j = [];
for i = 1:1:size(fives,3)
    j(:,i) = fivesRE(:,i)-mew5;
end
fivescov = j*j'/size(fives,3);
[V,D,Wt] = eig(fivescov);
Dnorm = sum(D,2);
W = Wt';
[vals,ind] = sort(Dnorm,1);
mat = zeros(784,10);
for i = 775:1:784
     mat(:,i-774) = W(ind(i),:);
 end
mat2 = reshape(mat,[28 28 10]);
figure
hold on
%top 10 principal components
for i = 1:1:10
    subplot(2,5,i)
    imagesc(mat2(:,:,11-i))
    colormap gray
end
hold off
W5 = W;

%entire sample set
samplemean = sum(imageTrain,3)/5000;
mew = reshape(samplemean,[784,1]);
imageTrainRE = reshape(imageTrain,[784,5000]);
j = imageTrainRE - mew;
samplecov = j*j'/5000;
[V,D,Wt] = eig(samplecov);
Dnorm = sum(D,2);
W = Wt';
[vals,ind] = sort(Dnorm,1);
mat = zeros(784,10);
for i = 775:1:784
     mat(:,i-774) = W(ind(i),:);
 end
mat2 = reshape(mat,[28 28 10]);
figure
hold on
%top 10 principal components
for i = 1:1:10
    subplot(2,5,i)
    imagesc(mat2(:,:,11-i))
    colormap gray
end
hold off
figure
plot([1:1:784],Dnorm)
title('Eigenvalues');
set(gca,'Xdir','reverse');

%looks like we are ok with somthing from (784 -700)
%thus I would suggest subspaces with dimension 84 or lower
er = 1;
errorRate = [];
for topN =  [5, 10, 20, 30, 40, 60, 90, 130, 180, 250]
% for topN = 84
    topN
    Vectors = -1*W(785-topN:784,:)/255;
    imageTestRE = reshape(imageTest,[784 500]);
    x = Vectors*(imageTestRE-mew);
    y = Vectors*(imageTrainRE-mew);
    means = [];
    cova = zeros(topN,topN,10);
    for i = 1:1:10
        temp = [];
        k = find(labelTrain == i-1);
        means(:,i) = sum(y(:,k),2)/size(k,1);
        temp = y(:,k) - means(:,i);
        cova(:,:,i) = temp*temp'/size(k,1);
        cova(:,:,i) = inv(cova(:,:,i));
    end
    same = [];
    for i = 1:1:5000
        same(:,i) = y(:,i) - means(:,labelTrain(i)+1);
    end
    covar = same*same'/5000;
    %implement same algorithm as from hw31
    class = [];
    thing = inv(covar);
    for i=1:1:500
        n = [];
        for k = 1:1:10
            if topN > 150
                n(k) = -0.5*(x(:,i)-means(:,k))'*cova(:,:,k)*(x(:,i)-means(:,k))...
                -0.5*topN*log(2*pi) + log(1/10);
            else
            n(k) = -0.5*(x(:,i)-means(:,k))'*cova(:,:,k)*(x(:,i)-means(:,k))...
                -0.5*topN*log(2*pi) + log(1/10)-0.5*log(det(inv(cova(:,:,k))));
            end
        end
        [whatever, m] = max(n);
        class(i,1) = m - 1;
    end

    false = [0 0 0 0 0 0 0 0 0 0];
    correct = [0 0 0 0 0 0 0 0 0 0];
    howManyNum = [0 0 0 0 0 0 0 0 0 0];
    for z1 = 1:1:500
        if(class(z1) == labelTest(z1))
            correct(labelTest(z1)+1) = correct(labelTest(z1)+1) + 1;
        else
            false(labelTest(z1)+1) = false(labelTest(z1)+1) + 1;
        end
    end
    number = [0 1 2 3 4 5 6 7 8 9];
    errorRate(er) = sum(false(:))/sum(correct)
    er = er + 1;
end
figure
plot([5, 10, 20, 30, 40, 60, 90, 130, 180, 250],errorRate)

%result is about the same?
Vec5 = W5(1:744,:);
x = Vec5*(imageTestRE-mew);
[fivey, ind] = max(sum(x.^2,1));
figure
imagesc(imageTest(:,:,ind))
colormap gray
