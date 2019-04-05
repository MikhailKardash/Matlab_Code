clc; clear all; close all;

% There are three functions you need to use from the Potential class.
% The constructor is Potential(x_size, y_size);
% addGoal(loc, intensity, width);
% addRepulsor(loc, intensity, width)
% addAttractor(loc, intensity, width)
% The the comments in Potential for more information on these calls.

loc = [95, 95]; %this is bot location
goal = [5, 5];
potentialField = Potential(100, 100);
% TODO: Add the goal and repulsors to the potential field.
% They must be added before the next comment.
potentialField.addGoal(goal); %add goal
potentialField.addRepulsor([50,55]); %add repulsor



% ************Above Here**************
x = potentialField.x;
y = potentialField.y;
z = potentialField.getField();
dx = potentialField.getdx();
dy = potentialField.getdy();

% Example plotting DO NOT INCLUDE IN YOUR REPORT.
% figure();
% meshc(x, y, z(x, y)); hold on;

% TODO: Plot the field in 3 separate figures as follows
% 1) The mesh
figure
mesh(x,y,z(x,y)); %surface plot
hold on
plot3(loc(1),loc(2),z(loc(1),loc(2)),'r*')
hold off
% 2) The contours
figure
contour(x,y,z(x,y)) %contour plot
% 3) The arrows
hold on %to plot on same graph
plot(loc(1),loc(2),'r*')
quiver(x,y,-1*dx(x,y),-1*dy(x,y)) %quiver function.
hold off
% On each, indicate where the bot begins with a red asteriks

% TODO: Implement the gradient descent algorithm. The dx and dy objects will be
% useful :)
i = 1;
%gradient of a
mag = sqrt(sum([-1*dx(loc(1),loc(2)),-1*dy(loc(1),loc(2))].^2));
%epsilon is 1*10^-4, trial and error. it's close enough
while(mag > 1*10^-4)
    %get adjacent coordinates
    ans = loc(i,:) + (1/mag).*[-1*dx(loc(i,1),loc(i,2)),-1*dy(loc(i,1),loc(i,2))];
    %save the path.
    loc = vertcat(loc,ans);
    i = i+1;
    %recalculate new mag.
    mag = sqrt(sum([-1*dx(loc(i,1),loc(i,2)),-1*dy(loc(i,1),loc(i,2))].^2));
end

%excatly as the figures above.
figure
mesh(x,y,z(x,y)); %surface plot
hold on
plot3(loc(:,1),loc(:,2),z(loc(:,1),loc(:,2)),'r*')
hold off

figure
contour(x,y,z(x,y)) %contour plot
% 3) The arrows
hold on %to plot on same graph
plot(loc(:,1),loc(:,2),'r*')
quiver(x,y,-1*dx(x,y),-1*dy(x,y)) %quiver function.
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%iii part 2.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc = [72, 97]; %this is bot location
goal = [5, 5];
potentialField = Potential(100, 100);
% TODO: Add the goal and repulsors to the potential field.
% They must be added before the next comment.
potentialField.addGoal(goal); %add goal
potentialField.addRepulsor([50,30]); %add repulsor
potentialField.addRepulsor([70,80]); %add repulsor
potentialField.addAttractor([30,35],.3); %high magnitude attractors mess it up
potentialField.addRepulsor([10,40]); 

% ************Above Here**************
x = potentialField.x;
y = potentialField.y;
z = potentialField.getField();
dx = potentialField.getdx();
dy = potentialField.getdy();

% TODO: Implement the gradient descent algorithm. The dx and dy objects will be
% useful :)
i = 1;
mag = sqrt(sum([-1*dx(loc(1),loc(2)),-1*dy(loc(1),loc(2))].^2));
while(mag > 1*10^-4)
    %get adjacent coordinates
    ans = loc(i,:) + (1/mag).*[-1*dx(loc(i,1),loc(i,2)),-1*dy(loc(i,1),loc(i,2))];
    loc = vertcat(loc,ans);
    i = i+1;
    mag = sqrt(sum([-1*dx(loc(i,1),loc(i,2)),-1*dy(loc(i,1),loc(i,2))].^2));
end

figure
mesh(x,y,z(x,y)); %surface plot
hold on
plot3(loc(:,1),loc(:,2),z(loc(:,1),loc(:,2)),'r*')
hold off

figure
contour(x,y,z(x,y)) %contour plot
% 3) The arrows
hold on %to plot on same graph
plot(loc(:,1),loc(:,2),'r*')
quiver(x,y,-1*dx(x,y),-1*dy(x,y)) %quiver function.
hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Extra Credit 1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc = [5,140]; %this is bot location
goal = [15, 5];
potentialField = Potential(50, 150);
% TODO: Add the goal and repulsors to the potential field.
% They must be added before the next comment.
potentialField.addGoal(goal); %add goal
potentialField.addRepulsor([45,10],1,40); %add repulsor
potentialField.addRepulsor([30,5],.3,5); %add repulsor
potentialField.addRepulsor([25,5],.2,5);
potentialField.addRepulsor([5,5],.3,10);
potentialField.addRepulsor([25,50],1,50);
potentialField.addRepulsor([25,75],1,50);


% ************Above Here**************
x = potentialField.x;
y = potentialField.y;
z = potentialField.getField();
dx = potentialField.getdx();
dy = potentialField.getdy();


% TODO: Implement the gradient descent algorithm. The dx and dy objects will be
% useful :)
i = 1;
mag = sqrt(sum([-1*dx(loc(1),loc(2)),-1*dy(loc(1),loc(2))].^2));
while(mag > 1*10^-3)
    %get adjacent coordinates
    ans = loc(i,:) + (1/mag).*[-1*dx(loc(i,1),loc(i,2)),-1*dy(loc(i,1),loc(i,2))];
    loc = vertcat(loc,ans);
    i = i+1;
    mag = sqrt(sum([-1*dx(loc(i,1),loc(i,2)),-1*dy(loc(i,1),loc(i,2))].^2));
end

figure
mesh(x,y,z(x,y)); %surface plot
hold on
plot3(loc(:,1),loc(:,2),z(loc(:,1),loc(:,2)),'r*')
hold off

figure
contour(x,y,z(x,y)) %contour plot
% 3) The arrows
hold on %to plot on same graph
plot(loc(:,1),loc(:,2),'r*')
quiver(x,y,-1*dx(x,y),-1*dy(x,y)) %quiver function.
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Extra Credit 2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc = [95, 95]; %this is bot location
goal = [5, 5];
potentialField = Potential(100, 100);
% TODO: Add the goal and repulsors to the potential field.
% They must be added before the next comment.
potentialField.addGoal(goal); %add goal
potentialField.addRepulsor([50,50]); %add repulsor
x = potentialField.x;
y = potentialField.y;
z = potentialField.getField();
dx = potentialField.getdx();
dy = potentialField.getdy();

% TODO: Implement the gradient descent algorithm. The dx and dy objects will be
% useful :)
i = 1;
%gradient of a
mag = sqrt(sum([-1*dx(loc(1),loc(2)),-1*dy(loc(1),loc(2))].^2));
%epsilon is 1*10^-4, trial and error. it's close enough
while(mag > 1*10^-4)
    %get adjacent coordinates
    ans = loc(i,:) + (1/mag).*[-1*dx(loc(i,1),loc(i,2)),-1*dy(loc(i,1),loc(i,2))];
    if(sqrt(sum(ans(1) - loc(i,1))^2) - sqrt(sum(ans(2) - loc(i,2))^2) < 10^-4)
        lulx = rand;
        luly = 1-lulx;
        ans = loc(i,:) + (1/mag).*[-1*dx(loc(i,1) + lulx,loc(i,2) + ...
            luly),-1*dy(loc(i,1) + lulx,loc(i,2) + luly)];
    end
    %save the path.
    loc = vertcat(loc,ans);
    i = i+1;
    %recalculate new mag.
    mag = sqrt(sum([-1*dx(loc(i,1),loc(i,2)),-1*dy(loc(i,1),loc(i,2))].^2));
end

%excatly as the figures above.
figure
mesh(x,y,z(x,y)); %surface plot
hold on
plot3(loc(:,1),loc(:,2),z(loc(:,1),loc(:,2)),'r*')
hold off

figure
contour(x,y,z(x,y)) %contour plot
% 3) The arrows
hold on %to plot on same graph
plot(loc(:,1),loc(:,2),'r*')
quiver(x,y,-1*dx(x,y),-1*dy(x,y)) %quiver function.
hold off