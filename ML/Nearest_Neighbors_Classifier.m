load data
load label

Q = [];
closest_index = [];
for q = 1:1:500
    q
%returns the euclidean distance
    dist = [];
    for i = 1:1:size(imageTrain,3)
        %Euclidean distance is just the norm.
        dist = vertcat(dist,norm(imageTest(:,:,q)-imageTrain(:,:,i)));
    end
    Lf = horzcat(dist,labelTrain);
    Lq = [];

%sort distances by the minimum first. only iterate k times.
    for n=1:1:1
        [s,i] = min(Lf,[],1);
        closest_index = vertcat(closest_index,i);
        Lq = vertcat(Lq,Lf(i(1),:));
        Lf(i(1),:) = [];
    end

%k = 1. Q is the matrix of our results.
Q = vertcat(Q,mode(Lq(1:1,2)));

end    

false = [0 0 0 0 0 0 0 0 0 0];
correct = [0 0 0 0 0 0 0 0 0 0];
howManyNum = [0 0 0 0 0 0 0 0 0 0];
for z1 = 1:1:500
    if(Q(z1) == labelTest(z1))
        correct(labelTest(z1)+1) = correct(labelTest(z1)+1) + 1;
    else
        false(labelTest(z1)+1) = false(labelTest(z1)+1) + 1;
    end
end
number = [0 1 2 3 4 5 6 7 8 9];
errorRate = false(:)./(false(:) + correct(:));
figure
plot(number,errorRate,'*')
title('Error given Class i')
xlabel('Class i (0 to 9)')
ylabel('Error')
errorToT = sum(false)/500
L = find(labelTest ~= Q, 5);

%closest neighbors
figure
imshow(imageTrain(:,:,closest_index(L(1))));
%the incorrect things they classified
figure
imshow(imageTest(:,:,L(1)));
figure
imshow(imageTrain(:,:,closest_index(L(2))));
figure
imshow(imageTest(:,:,L(2)));
figure
imshow(imageTrain(:,:,closest_index(L(3))));
figure
imshow(imageTest(:,:,L(3)));
figure
imshow(imageTrain(:,:,closest_index(L(4))));
figure
imshow(imageTest(:,:,L(4)));
figure
imshow(imageTrain(:,:,closest_index(L(5))));
figure
imshow(imageTest(:,:,L(5)));






