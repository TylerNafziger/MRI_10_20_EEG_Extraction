function [markers, perimline_sorted] = find1020onPlane(V, aRes, plane_orthogonal, plane_offset, start_point, end_point, percentiles, circumferential)

% Build Plane and extract perimeter
[sx,sy,sz,principal_direction] = planedefine(plane_orthogonal,plane_offset,V);
slice = interp3(double(V),sx,sy,sz);

perim = imfill(im2bw(slice),"holes");
perim = bwperim(perim);

[m,n] = find(perim==1);
perimline = [m,n];

switch principal_direction
    case 1
        secondary_directions = [3,2];
    case 2
        secondary_directions = [3,1];
    case 3
        secondary_directions = [2,1];
end

% Find start and stop points
startDiff = vecnorm(perimline-start_point(secondary_directions),2,2);
[~,start_coord_on_perimeter] = min(startDiff);

if ~isempty(end_point)
    endDiff = vecnorm(perimline-end_point(secondary_directions),2,2);
    [~,end_coord_on_perimeter] = min(endDiff);
end

% Build sorted perimeter
if circumferential == 0
    perimline_sorted = perimwalk(perimline,perimline(start_coord_on_perimeter,:), perimline(end_coord_on_perimeter,:));
else
    perimline_sorted = perimwalk(perimline,perimline(start_coord_on_perimeter,:));
    [~, COind] = perimdistance(perimline_sorted,{sx,sy,sz},aRes,principal_direction);
    perimline_sorted = perimline_sorted(1:COind,:);
end

% Remove duplicate points
Table = table(perimline_sorted(:,1),perimline_sorted(:,2));
TableUnique = unique(Table,'stable');
perimline_sorted = [table2array(TableUnique(:,1)), table2array(TableUnique(:,2))];

% Ensure correct walk direction
sortdirection = perimline_sorted(1:10,1); % Take sample of sorted line to find walk direction
if mean(diff(sortdirection))<0
    perimline_sorted = [perimline_sorted(1,:); flip(perimline_sorted(2:end,:),1)]; % Flip order if going wrong way
end

% Savitsky-Golay Filter
sagx = perimline_sorted(:,1);
sagy = perimline_sorted(:,2);

windowWidth = 35;
polynomialOrder = 2;
smoothX = sgolayfilt(sagx, polynomialOrder, windowWidth);
smoothY = sgolayfilt(sagy, polynomialOrder, windowWidth);

perimline_sorted_filt = [smoothX,smoothY];

% Find Distances
perimdist = perimdistance(perimline_sorted_filt,{sx,sy,sz},aRes,principal_direction);

% If circumferential, find Oz (end_point)
if circumferential ~= 0
    endDiff = vecnorm(perimline_sorted-end_point(secondary_directions),2,2);
    [~,end_coord_on_perimeter] = min(endDiff);
end

% Compute Percentile Markers
markers = [];
if circumferential == 0
    for idx = 1:length(percentiles)
        [~,marker_coord] = min(abs(perimdist - perimdist(end)*percentiles(idx)));
        markers = [markers; slice2coord3(perimline_sorted_filt(marker_coord,:),secondary_directions,{sx,sy,sz})];
    end
else
    for idx = 1:length(percentiles)
        [~,marker_coord] = min(abs(perimdist - perimdist(end_coord_on_perimeter)*percentiles(idx)));
        markers = [markers; slice2coord3(perimline_sorted_filt(marker_coord,:),secondary_directions,{sx,sy,sz})];

        [~,marker_coord] = min(abs(perimdist - (perimdist(end_coord_on_perimeter) + (perimdist(end) - perimdist(end_coord_on_perimeter))*percentiles(idx))));
        markers = [markers; slice2coord3(perimline_sorted_filt(marker_coord,:),secondary_directions,{sx,sy,sz})];
    end

end