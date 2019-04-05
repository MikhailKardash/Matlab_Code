a = zeros(11);
a(1,1) = 5;
a(6,6) = 5;
a(1,11) = 5;
a(11,1) = 5;
a(11,11) = 5;
[acell] = houghTrans(a);
figure
imshow(a);
figure
imagesc(acell)
K = (size(acell,1)-1)/2
title('Accumulator for i-ii');
colormap gray
colorbar
xlabel('theta');
ylabel('rho');
set(gca,'XTickLabel',[-70 -50 -30 -10 9 29 49 69 89]);
set(gca,'YTickLabel',[K-5 K-10 K-15 K-20 K-25 K-30]);
houghGraph(acell,2,90,0,a)


% %iii
img = imread('lane.png');
E = edge(img(:,:,1),'sobel');
[acell2] = houghTrans(E);
K = (size(acell2,1)-1)/2
figure
imshow(img)
figure
imshow(E)
figure
imagesc(acell2)
title('Accumulator for iii-iv');
colormap gray
colorbar
xlabel('theta');
ylabel('rho');
set(gca,'XTickLabel',[-70 -50 -30 -10 9 29 49 69 89]);
set(gca,'YTickLabel',[K-200 K-400 K-600 K-800 K-1000 K-1200 K-1400 K-1600 K-1800 K-2000 K-2200]);
houghGraph(acell2,0.75*max(max(acell2)),90,0,img);
houghGraph(acell2,0.75*max(max(acell2)),53,50,img);
%looks like the threshold is actually 52 to 66 degrees if you want the
%fully thicc line
%for literally just the 2 lines we need, use 53, 1.
%but hey, let's at least stay relatively consistent :)