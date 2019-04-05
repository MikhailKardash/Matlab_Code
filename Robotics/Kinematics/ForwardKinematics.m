%{
This function is supposed to implement forward kinematics for a robot arm
with 3 links constrained to move in 2-D. 



INPUTS:
l0, l1, l2 : Lengths of the robot links 
theta0, theta1, theta2 : Robot joint angles


OUTPUTS:
[x_1,y_1]: location of the first joint
[x_2,y_2]: location of the second joint
[x_e,y_e]: location of the end effector

Note: Remember the zeroth joint x_0, y_0 is always at the origin [0,0]

(See illustration in the question)


%}

function [x_1,y_1,x_2,y_2,x_e,y_e] = ForwardKinematics(l0,l1,l2, theta0, theta1, theta2)
   x_1 = l0*cos(theta0);
   y_1 = l0*sin(theta0);
   x_2 = l1*cos(theta1+theta0) + x_1;
   y_2 = l1*sin(theta1+theta0) + y_1;
   x_e = l2*cos(theta2+theta1+theta0) + x_2;
   y_e = l2*sin(theta2+theta1+theta0) + y_2;
 
end