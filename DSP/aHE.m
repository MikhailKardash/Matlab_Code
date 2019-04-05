function [ output ] = aHE( image,win_size )
%establish bounds
k = floor(win_size/2);

%pad the matrix
im2 = padarray(image,[k, k],'symmetric');

output = [];

%algorithm as given, my i,j is the pixel being equalized.
for i = 1+k:1:size(im2,1)-k
    for j = 1+k:1:size(im2,2)-k
        iterator = [-k:1:k];
        rank = 0;
        %x,y is the contextual region, ranges from -k to k
        %rank is the sum of the pixel comparisons.
        rank = sum(sum(im2(i+iterator,j+iterator)<im2(i,j)));
        output(i-k,j-k) = rank*255/(win_size*win_size);
    end
    i
end

end

