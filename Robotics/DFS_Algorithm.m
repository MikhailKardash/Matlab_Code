clc; clear; close all;

data = load('data.mat');
cur_loc = 1;
h = figure();
show_maze(data, h);
draw_cursor(cur_loc, [data.num_rows, data.num_cols], 'r', h);

N = data.num_cols*data.num_rows;

% TODO: Implement DFS

stack = java.util.Stack(); %create stack
visited = zeros(N,1); %visited nodes
parent = zeros(N,1); %parent nodes
stack.push(cur_loc);

%implemented as per pseudocode
while( (~stack.isEmpty()) && (cur_loc ~= data.goal(1)*data.goal(2)))
    i = stack.pop(); %pop curpos
    if(visited(i) == 0) 
        visited(i) = 1;
        neighbors = sense_maze(i,data); %get neighbors if unvisited
        for k=1:1:length(neighbors) 
            if (visited(neighbors(k)) == 0) %find unvisited neighbors
                stack.push(neighbors(k)); %push neighbors onto the stack
                parent(neighbors(k)) = i;
            end
        end
    end
    cur_loc = i; %update cur_loc
    draw_cursor(cur_loc,[data.num_rows, data.num_cols],'r',h); %draw after iteration
end

cur_loc = data.goal(1)*data.goal(2); %work way back out of the maze
%loop to draw green (correct) path
while (parent(cur_loc) ~= 0)
    draw_cursor(cur_loc,[data.num_rows, data.num_cols],'g',h);
    cur_loc = parent(cur_loc); 
end