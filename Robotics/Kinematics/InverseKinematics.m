%{
This function is supposed to implement inverse kinematics for a robot arm
with 3 links constrained to move in 2-D. The comments will walk you through
the algorithm for the Jacobian Method for inverse kinematics

INPUTS:
l0, l1, l2: lengths of the robot links
x_e_target, y_e_target: Desired final position of the end effector 

OUTPUTS:
theta0_target, theta1_target, theta2_target: Joint angles of the robot that
take the end effector to [x_e_target,y_e_target]


%}





function [theta0_target, theta1_target, theta2_target] = InverseKinematics(l0,l1,l2,x_e_target,y_e_target)

    


    % Initialize the thetas to some value
    theta0 = pi/6;
    theta1 = 0;
    theta2 = 0;
    
    
    % Obtain end effector position x_e, y_e for current thetas: 
    % HINT: use your ForwardKinematics function
    [x_1,y_1,x_2,y_2,x_e,y_e] = ForwardKinematics(l0,l1,l2, theta0, theta1, theta2);
    xout= x_e;
    yout= y_e;
    
    
    while  (sqrt((x_e - x_e_target)^2 + (y_e - y_e_target)^2) > 1*10^-3) %(Replace the '1'  with a condition that checks if your estimated [x_e,y_e] is close to [x_e_target,y_e_target])
        
        
        % Calculate the Jacobian matrix for current values of theta:
        % HINT: write a function for doing this
        J(1,3) = -1*l2*sin(theta2 + theta1 + theta0);
        J(1,2) = -1*l1*sin(theta1 + theta0) + J(1,3);
        J(1,1) = -1*l0*sin(theta0) + J(1,2);   
        J(2,3) = l2*cos(theta2 + theta1 + theta0);
        J(2,2) = l1*cos(theta1 + theta0) + J(2,3);
        J(2,1) = l0*cos(theta0) + J(2,2);

        %dx/d_theta = L_n*sin(theta_n) dy/d_theta = -L_n*cos(theta_n)

        
        % Calculate the pseudo-inverse of the jacobian using 'pinv()': 
        Jinv = pinv(J);
        
        
        
        
        % Update the values of the thetas by a small step:
        
        a = Jinv*[(x_e_target - x_e)/10;(y_e_target - y_e)/10];

        theta0 = theta0 + a(1);
        theta1 = theta1 + a(2);
        theta2 = theta2 + a(3);

       

        % Obtain end effector position x_e, y_e for the updated thetas:
        [x_1,y_1,x_2,y_2,x_e,y_e] = ForwardKinematics(l0,l1,l2, theta0, theta1, theta2);
        
        
        
        
        % Draw the robot using drawRobot( ) : This will help you visualize how the robot arm moves through the iteration: 
        drawRobot(x_1,y_1,x_2,y_2,x_e,y_e);
        xout = vertcat(xout,x_e);
        yout = vertcat(yout,y_e);
        
        
        
    
        pause(0.00001)  % This will slow the loop just a little bit to help you visualize the robot arm movement 
    end
    hold on
    plot(xout,yout);
    pbaspect([1 1 1]);
    xlim([-20 20]);
    ylim([-20 20]);
    set(gca,'Xtick',-20:2:20)
    set(gca,'Ytick',-20:2:20)
    grid on
    hold off
    
    % Set the theta_target values:
    theta0_target = theta0;
    theta1_target = theta1;
    theta2_target = theta2;







end