function [acell] = houghTrans(a)
%find D values
D = ceil(sqrt(size(a,1)^2 + size(a,2)^2));
%create accumulator cells
thetas = [-90:1:90];
acell = [-D:1:D]'*thetas.*0;
%find nonzero values
[y,x] = find(a > 0);
%find rho using linear algebra
k = [x-1,y-1];
transform = [cosd(thetas);sind(thetas)];
rho = round(k*transform);
%populate acell
for i = 1:1:size(x,1)
    for j = 1:1:(size(thetas,2))
        acell(-rho(i,j) + D + 1, j) = acell(-rho(i,j) + D + 1, j) + 1;
    end
end
end