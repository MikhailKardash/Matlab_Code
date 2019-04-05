cars1= imread('cars1.png');
cars1 = double(cars1);
cars1gray = mean(cars1,3);
carsTemp = imread('carsTemplate.png');
carsTemp = double(carsTemp);
carsTempgray = mean(carsTemp,3);

%cross correlation
out1 = xcorr2(cars1gray,carsTempgray);
figure
imagesc(out1)
colormap gray
colorbar
%normalized cross correlation
out2 = normxcorr2(carsTempgray,cars1gray);
figure
imagesc(out2)
colormap gray
colorbar
[~,ind] = max(out2(:));
[i,j] = ind2sub([size(out2,1),size(out2,2)],ind);
figure
hold on
imshow(imread('cars1.png'));
colormap gray
rectangle('Position',[j-size(carsTempgray,2),i-size(carsTempgray,1),...
    size(carsTempgray,2),size(carsTempgray,1)],'edgecolor','r',...
    'linewidth',3);

cars2= imread('cars2.png');
cars2 = double(cars2);
cars2gray = mean(cars2,3);
%normalized xcorr
out3 = normxcorr2(carsTempgray,cars2gray);
figure
imagesc(out3)
colormap gray
colorbar