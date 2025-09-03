function [dist, cutoffind] = perimdistance(perimline_sorted,planecoords,aRes,orientation)
x = planecoords{1};
y = planecoords{2};
z = planecoords{3};

aRes = permute(aRes,[2,1,3]);

switch orientation
    case 1
        perim3 = slice2coord3(perimline_sorted,[3,2],{x,y,z});
    case 2
        perim3 = slice2coord3(perimline_sorted,[3,1],{x,y,z});
    case 3
         perim3 = slice2coord3(perimline_sorted,[2,1],{x,y,z});
end



tempdist = [];

for j = 1:length(perim3)-1
    if j>1
        tempdist(j) = norm(perim3(j+1,:).*aRes-perim3(j,:).*aRes)+tempdist(j-1);
    else
        tempdist(j) = norm(perim3(j+1,:).*aRes-perim3(j,:).*aRes);
    end
end
dist = [0, tempdist];
% Add derivative term with cutoff
% add index output for reducing perimline_sorted
cutoffind = find(diff(dist)>15);
if ~isempty(cutoffind)
    cutoffind = cutoffind(1);
    dist = dist(1:cutoffind);
end

end
