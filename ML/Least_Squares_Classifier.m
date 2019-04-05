load mnist.mat
%account for alpha
trainX = horzcat(ones(60000,1),trainX);
testX = horzcat(ones(10000,1),testX);
testY = double(testY);

% %%
%1 vs all classifier
result1 = zeros(10,length(testX));
result3 = zeros(10,length(trainX));
for label = [0:1:9]
    label
    y1 = find(trainY == label);
    data1 = trainX(y1,:);
    ynot1 = find(trainY ~= label);
    dataneg1 = trainX(ynot1,:);
    fX = ones(length(y1),1);
    fX = vertcat(fX,-1*ones(length(ynot1),1));
    x = vertcat(data1,dataneg1);
    x = double(x);
    %now i have fX = B*x, so b = x\fX;
    B = lsqminnorm(x,fX);    
    xtest = double(testX);
    xtrain = double(trainX);
    yout = B'*xtest';
    yout = yout';  
    youtT = B'*xtrain';
    youtT = youtT';
    result1(label + 1,:) = yout;
    result3(label + 1,:) = youtT;
end
[~,labelout] = max(result1,[],1);
[~,labelout3] = max(result3,[],1);
labelout = labelout - 1;
labelout3 = labelout3 - 1;
correct = sum(labelout == testY);
correct3 = sum(labelout3 == trainY);
error = 1-correct/length(testY);
error3 = 1-correct3/length(trainY);
% confusion matrix
H = max(labelout);
L = min(labelout);
J1 = zeros(H-L+1);
for i = (1:1:H-L+1)
    for j = (1:1:H-L+1)
        %row,column
        J1(j,i) = sum((labelout == L + i - 1)&(testY == L + j - 1));
    end
end
H = max(labelout3);
L = min(labelout3);
J3 = zeros(H-L+1);
for i = (1:1:H-L+1)
    for j = (1:1:H-L+1)
        %row,column
        J3(j,i) = sum((labelout3 == L + i - 1)&(trainY == L + j - 1));
    end
end

%%
%one vs one classifier
for i = [0:9]
    y1 = find(trainY == i);
    data1 = trainX(y1,:);
    for j = [0:9]
        if (j > i)
            j
            ynot1 = find(trainY == j);
            dataneg1 = trainX(ynot1,:);
            fX = ones(length(y1),1);
            fX = vertcat(fX,-1*ones(length(ynot1),1));
            x = vertcat(data1,dataneg1);
            x = double(x);
            %now i have fX = B*x, so b = x\fX;
            B2(:,:,i+1,j+1) = lsqminnorm(x,fX);
        else
            B2(:,:,i+1,j+1) = zeros(785,1);
        end
    end
end
%%
%classify the one vs one data.
xtest = double(testX);
xtrain = double(trainX);
votes = zeros(10,size(xtest,1));
votes2 = zeros(10,size(xtrain,1));
for i = [0:9]
    for j = [0:9]
        if(j > i)
            yout2 = B2(:,:,i+1,j+1)'*xtest';
            yout2 = yout2';
            yout2 = 1*(yout2 >= 0) - 1*(yout2 < 0);
            k = find(yout2 == 1);
            votes(i+1,k) = votes(i+1,k) + 1;
            k = find(yout2 == -1);
            votes(j+1,k) = votes(j+1,k) + 1;
            %train data
            yout4 = B2(:,:,i+1,j+1)'*xtrain';
            yout4 = yout4';
            yout4 = 1*(yout4 >= 0) - 1*(yout4 < 0);
            k = find(yout4 == 1);
            votes2(i+1,k) = votes2(i+1,k) + 1;
            k = find(yout4 == -1);
            votes2(j+1,k) = votes2(j+1,k) + 1;
        end
    end
end
[~,labelout2] = max(votes,[],1);
labelout2 = labelout2 - 1;
correct = sum(labelout2 == testY);
error2 = 1-correct/length(testY);
H = max(labelout2);
L = min(labelout2);
J2 = zeros(H-L+1);
for i = (1:1:H-L+1)
    for j = (1:1:H-L+1)
        %row,column
        J2(j,i) = sum((labelout2 == L + i - 1)&(testY == L + j - 1));
    end
end
[~,labelout4] = max(votes2,[],1);
labelout4 = labelout4 - 1;
correct2 = sum(labelout4 == trainY);
error4 = 1-correct2/length(trainY);
H = max(labelout4);
L = min(labelout4);
J4 = zeros(H-L+1);
for i = (1:1:H-L+1)
    for j = (1:1:H-L+1)
        %row,column
        J4(j,i) = sum((labelout4 == L + i - 1)&(trainY == L + j - 1));
    end
end