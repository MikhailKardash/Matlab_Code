rp = 3;
rs = 40;
f = [.5 .6];
a = [1 0];
dev = [min(1-db2mag(-rp),db2mag(rp)-1)  db2mag(-40)];
[n,fo,ao,w] = firpmord(f,a,dev);
b = firpm(n+1,fo,ao,w);
figure
freqz(b)
title('Frequency response of FIR pm filter');
figure
zplane(b)
title('Poles and zeroes of FIR pm filter');

[n2,Wn,beta,ftype] = kaiserord(f,a,dev);
hh = fir1(n2,Wn,ftype,kaiser(n2+1,beta),'noscale');
figure
freqz(hh)
title('Frequency response of FIR window filter');
figure
zplane(hh)
title('Poles and zeroes of FIR window filter');

guess = 75; %took may tries.
h2 = fir1(guess,Wn,ftype,gausswin(guess+1),'noscale');
figure
freqz(h2)
title('Frequency response of FIR gaussian window filter');
figure
zplane(h2)
title('Poles and zeroes of FIR gaussian window filter');

[n3, wp] = ellipord(.5,.6,rp,rs);
[b,a] = ellip(n3,rp,rs,.5);
figure
freqz(b,a,1024);
title('Frequency response of elliptic filter');
figure
zplane(b,a);
title('Poles and zeroes of elliptic filter');
