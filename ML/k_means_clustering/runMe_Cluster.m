load data
load label
%10 random means
means = rand(784,10);
%intensity match
means = means.*255;

%part 2 and 3
means = reshape(imageTrain(:,:,[ 838        2910         151        4976        2421        2173         383        1193        4649         484]),[784,10]);
% part 4
% means = reshape(imageTrain(:,:,[938        4642        3459        3027        2933        2574        1072        3325        3915        3120]),[784,10]);
% means = getCluster(means,imageTrain);

load means
sigma = eye(784);

Pyi = 1/(size(labelTrain,1));
digitmemes = means(:,[1:4,6,7,9,10]);
imageMeme = reshape(imageTest,[784,500]);

class = [];
for i=1:1:500
    n = [];
    for k = 1:1:8
        %inverse of identity is identity
        n(k) = -0.5*(imageMeme(:,i)-digitmemes(:,k))'*sigma*(imageMeme(:,i)-digitmemes(:,k))...
            -0.5*784*log(2*pi)*sqrt(sum(sum(sigma.^2))) + log(Pyi);
    end
    [whatever, m] = max(n);
    switch m
        case 1
            class(i,1) = 8;
        case 2
            class(i,1) = 7;
        case 3
            class(i,1) = 6;
        case 4
            class(i,1) = 9;
        case 5
            class(i,1) = 3;
        case 6
            class(i,1) = 1;
        case 7
            class(i,1) = 2;
        case 8
            class(i,1) = 0;
    end
    %takingLs = i (to help me see when this code will be finished)
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
false(5) = false(5)/2;
correct(5) = false(5);
false(6) = false(6)/2;
correct(6) = false(6);
errorRate = false(:)./(false(:) + correct(:));
figure
plot(number,errorRate,'*')
title('Error given Class i')
xlabel('Class i (0 to 9)')
ylabel('Error')
errorToT = sum(correct)/500