function coord3d = slice2coord3(coord2d, dims, planemesh)
% Computes 3d RAS coordinates from slice coordinates and orientation
% coord2d: Point to convert
% dims: dimensions in RAS of coord2d, example: [1,3]
% planemesh = {x,y,z}
coord2d = round(coord2d);

x = planemesh{1};
y = planemesh{2};
z = planemesh{3};

coord3d = [];
for j = 1:size(coord2d,1)
    if ~any(dims == 1)
        ele3 = x(coord2d(j,dims==3),coord2d(j,dims==2));
        temp = [ele3, coord2d(j,2), coord2d(j,1)];
    elseif ~any(dims == 2)
        ele3 = y(coord2d(j,dims==3), coord2d(j,dims==1));
        temp = [coord2d(j,2), ele3, coord2d(j,1)];
    elseif ~any(dims == 3)
        ele3 = z(coord2d(j,dims==2), coord2d(j,dims==1));
        temp = [coord2d(j,2), coord2d(j,1), ele3];
    end
    coord3d = [coord3d; temp];
end
end