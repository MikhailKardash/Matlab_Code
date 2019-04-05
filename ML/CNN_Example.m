%cd is current directory, which houses all the files.
[trainData,trainLabels,valData,valLabels,testData,testLabels] = ...
    extractCifar10(strcat(cd,'\batch_stuff'));
layers = [imageInputLayer([32 32 3]),...
    convolution2dLayer([3 3],16),...
    batchNormalizationLayer,...
    reluLayer,...
    maxPooling2dLayer(2),...
    convolution2dLayer([3 3],32),...
    batchNormalizationLayer,...
    reluLayer,...
    maxPooling2dLayer(2),...
    convolution2dLayer([3 3],16),...
    batchNormalizationLayer,...
    reluLayer,...
    fullyConnectedLayer(10),...
    softmaxLayer,...
    classificationLayer()];
layers = layers';
valdataBoi = {valData,valLabels};
options = trainingOptions('sgdm',...
    'InitialLearnRate',0.001,'MaxEpochs',20,'MiniBatchSize',...
    128,'ValidationData',valdataBoi,'ValidationFrequency',...
    round(size(trainData,4)/128),'plots','training-progress');
neuralNetProcessor = trainNetwork(trainData,trainLabels,layers,options);

[Ypred,scores] = classify(neuralNetProcessor,testData);
correct = find(Ypred == testLabels);
incorrect = find(Ypred ~= testLabels);

j = categorical({'airplane', 'automobile', 'bird', 'cat', 'deer',...
    'dog','frog','horse','ship','truck'});
% first 3 correct ones
figure
subplot(1,2,1)
imshow(testData(:,:,:,correct(1)))
subplot(1,2,2)
bar(j,scores(correct(1),:));

figure
subplot(1,2,1)
imshow(testData(:,:,:,correct(2)))
subplot(1,2,2)
bar(j,scores(correct(2),:));

figure
subplot(1,2,1)
imshow(testData(:,:,:,correct(3)))
subplot(1,2,2)
bar(j,scores(correct(3),:));

%first 3 incorrect ones
figure
subplot(1,2,1)
imshow(testData(:,:,:,incorrect(1)))
subplot(1,2,2)
bar(j,scores(incorrect(1),:));

figure
subplot(1,2,1)
imshow(testData(:,:,:,incorrect(2)))
subplot(1,2,2)
bar(j,scores(incorrect(2),:));

figure
subplot(1,2,1)
imshow(testData(:,:,:,incorrect(3)))
subplot(1,2,2)
bar(j,scores(incorrect(3),:));

figure
plotconfusion(testLabels,Ypred)

cars2 = imread('cars2.png');
cars2 = padarray(cars2,[75 100],0);
[ymax,xmax] = size(cars2);
xwin = 150;
ywin = 200;
yind = uint8([1:6.25:200]);
xind = uint8([1:4.6875:150]);
heatmap = zeros(size(cars2,1)-ywin,size(cars2,2)-xwin);
toclassify = [];
for x = 1:1:size(cars2,2)-xwin
    for y = 1:1:size(cars2,1)-ywin
        area = cars2(y:y+ywin,x:x+xwin,:);
        areanew = area(yind,xind,:);
        [~,scoresR] = classify(neuralNetProcessor,areanew);
        heatmap(y,x) = scoresR(2);
    end
    x
end

figure
imagesc(heatmap)
colormap gray