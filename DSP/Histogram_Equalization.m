%image name/path
image = imread('beach.png');
%win size
win_size = 33;
%output, wait until i=616
output= aHE( image,win_size );
%show output
figure
imshow(output,'DisplayRange',[0 255])
title('33 AHE');

win_size = 65;
%output, wait until i=632
output= aHE( image,win_size );
%show output
figure
imshow(output,'DisplayRange',[0 255])
title('65 AHE');

win_size = 129;
%output, wait until i=666
output= aHE( image,win_size );
%show output
figure
imshow(output,'DisplayRange',[0 255])
title('129 AHE');

figure
out2 = histeq(image);
imshow(out2,'DisplayRange',[0 255])
title('normal HE');
