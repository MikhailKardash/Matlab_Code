load lineup.mat
j = [1 zeros(1,999) 0.5];
he = conv(j,1); %impulse response, equal to conv(j,delta).
d = [1 zeros(1,4000)];
%remember we set z[n] = x[n], which means that our transfer function = j;
ree = j;
her = filter(1,j,d);

%use our inverse function to delete echo.
z = filter(1, ree, y);

%convolute He and Her
hoa = conv(he,her);




