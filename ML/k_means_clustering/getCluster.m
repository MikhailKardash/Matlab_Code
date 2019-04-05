function [ means ] = getCluster( i,imageTrain )

means = i;

imageTrainFlat = reshape(imageTrain,[784,5000]);

% means(:,1:10) = imageTrainFlat(:,round(rand(1,10)*5000));

for i = 1:1:5000
    for j = 1:1:10
        dist(j,i) = (imageTrainFlat(:,i) - means(:,j))'*(imageTrainFlat(:,i) - means(:,j));
    end
end

[mins,indices] = min(dist);
for i = 1:1:10
    ns = find(indices == i);
    if(size(ns,2) > 0)
        means(:,i) = mean(imageTrainFlat(:,ns),2);
    else
        means(:,i) = zeros(784,1);
    end
end

% means = means + normdist;

for i = 1:1:5000
    for j = 1:1:10
        distnew(j,i) = (imageTrainFlat(:,i) - means(:,j))'*(imageTrainFlat(:,i) - means(:,j));
    end
end

[minsnew,indicesnew] = min(distnew);

iterator = 0;
while sum(indicesnew ~= indices) > 10
    indices = indicesnew;    
    dist = distnew;
    [mins,indicesnew] = min(dist);
    normdist = zeros(784,10);
    ns = [];
    k = [];
    for i = 1:1:10
        ns = find(indices == i);
        if(size(ns,2) > 0)
            means(:,i) = mean(imageTrainFlat(:,ns),2);
        else
            means(:,i) = zeros(784,1);
        end
    end

%     means = means + normdist;

    for i = 1:1:5000
        for j = 1:1:10
            distnew(j,i) = (imageTrainFlat(:,i) - means(:,j))'*(imageTrainFlat(:,i) - means(:,j));
        end
    end
    iterator = iterator + 1
    [minsnew,indicesnew] = min(distnew);
end

output = reshape(means,[28,28,10]);

figure
hold on
for i = 1:1:10
    subplot(2,5,i)
    imagesc(output(:,:,i))
end
colormap gray
hold off

end

