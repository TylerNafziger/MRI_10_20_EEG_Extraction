function sorted_perimline = perimwalk(perimline,startpoint,endpoint)

% Initialize visited list
visited = false(size(perimline, 1), 1); 

% Initialize the list of sorted perimeter points
sorted_perimline = [];
current_point = startpoint;

% Mark the start point as visited
visited(startpoint) = true;

% Initialize stack for DFS (or queue for BFS)
stack = current_point; % For DFS

% Perform Depth First Search (DFS) to traverse the perimeter by connectivity
while ~isempty(stack)
    % Pop the last point from the stack
    current_point = stack(end, :);
    stack(end, :) = [];  % Remove the last point
    
    % Add the current point to the sorted list
    sorted_perimline = [sorted_perimline; current_point];
    
    % Find the 8-connected neighbors of the current point
    % Find the 8-connected neighbors of the current point, prioritize right (positive x direction)
    neighbors = [current_point(1), current_point(2) + 1; % right (positive x direction)
                 current_point(1) - 1, current_point(2); % up
                 current_point(1) - 1, current_point(2) + 1; % diagonal up-right 
                 current_point(1) + 1, current_point(2) + 1; % diagonal down-right
                 current_point(1) + 1, current_point(2); % down
                 current_point(1), current_point(2) - 1; % left (negative x direction)
                 current_point(1) - 1, current_point(2) - 1; % diagonal up-left
                 current_point(1) + 1, current_point(2) - 1]; % diagonal down-left
                 
             
    % Check which of the neighbors are part of the perimeter and not visited
    for i = 1:size(neighbors, 1)
        neighbor = neighbors(i, :);
        
        % Check if this neighbor is in perimline and not visited
        if any(all(perimline == neighbor, 2)) && ~any(all(sorted_perimline == neighbor, 2))
            stack = [stack; neighbor]; % Add the unvisited neighbor to the stack
        elseif nargin>2 && any(all(neighbor==endpoint))
            sorted_perimline = [sorted_perimline; neighbor];
            return
        end 

    end
end
end