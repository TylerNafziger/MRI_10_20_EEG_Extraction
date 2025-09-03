function [x,y,z,princedir] = planedefine(orthogonal, offset, V)
% creates a plane defined by an orthogonal vector, and offset point to
% center plane on. V for defining meshgrid for slice computation

a = orthogonal(1);
b = orthogonal(2);
c = orthogonal(3);
d = dot(orthogonal, offset);

[~, idx] = max(abs(orthogonal));

princedir = idx;

if princedir == 1
    [y,z] = meshgrid(0:size(V,1)-1, 0:size(V,3)-1);
    x = (d - b*y - z*c)/a;
elseif princedir == 2
    [x,z] = meshgrid(0:size(V,2)-1, 0:size(V,3)-1);
    y = (d - a*x - c*z)/b; 
elseif princedir == 3
    [x,y] = meshgrid(0:size(V,2)-1, 0:size(V,1)-1);
    z = (d - b*y - a*x)/c;
end
end