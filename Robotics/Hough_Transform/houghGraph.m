function [] = houghGraph(acell,thresh,thetathreshupper,thetathreshlower,img)
D = ceil(sqrt(size(img,1)^2 + size(img,2)^2));
figure
imshow(img)
hold on
for i = 1:1:size(acell,1)
    for j = 1:1:size(acell,2)
        if(acell(i,j) >= thresh)
            rho = D + 1 - i;
            theta = j - 91;
            cond = abs(theta);
            if ((cond >= thetathreshlower) && (cond <= thetathreshupper))
                if (theta == 0)
                    x1 = rho + 1;
                    y1 = 1;
                    y2 = size(img,1);
                    plot([x1,x1],[y1 y2],'LineWidth',3);
                else
                    %this is the price we pay for making rho look like it
                    %does in the book. why. v v v v
                    b = (rho)/(sind(theta))+cotd(theta)+1;
                    m = -cotd(theta);
                    x = [0,size(img,2)];
                    plot(x,m*x + b,'LineWidth',3);
                end
            end
        end
    end
end
hold off

end

