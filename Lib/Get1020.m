function [Markers, perimeter, Labels] = Get1020(V,LM,aRes)
% Extracts 10-20 markers from a threshold filtered MRI volume, it's pixel
% spacings, and principal landmarks
% 
% V: filtered MRI volume
% LM: 4x3 array of 3D coordinates where rows are nasion, left ear, right
%   ear, and inion, in that order. Columns should be in order of Anterior,
%   Right, and Superior, as this is the coordinate order from annotating on a
%   MATLAB RAS volume
% aRes: spatial resolution of the MRI volume. In nifti, this is
%   info.PixelDimensions

Markers = [];
LMmm  = round(LM);

TT = LM(2,:) - LM(3,:); % Vector between left and right tragus
TTnorm = TT/norm(TT);

sagorthog = cross(LM(1,:) - LM(4,:), [0,0,1]);
sagorthog = sagorthog/norm(sagorthog);
% sagorthog = [0,1,0];

markerstemp = find1020onPlane(V, aRes, sagorthog, LM(1,:), LM(1,:), LM(4,:), [0,0.1,0.3,0.5,0.7,0.9,1], 0);
Markers = [Markers; markerstemp];

% Start Coronal


Cz = markerstemp(4,:);
Fpz = markerstemp(2,:);
Oz = markerstemp(6,:);

cororthog = cross(TT,LM(2,:)-Cz);
cororthognorm = cororthog/norm(cororthog);
   
markerstemp = find1020onPlane(V, aRes, cororthognorm, LM(2,:), LM(2,:), LM(3,:), [0,0.1,0.3,0.7,0.9,1], 0);
Markers = [Markers; markerstemp];

T3 = markerstemp(2,:);
C3 = markerstemp(3,:);
C4 = markerstemp(4,:);
T4 = markerstemp(5,:);


circumorth = cross(T3-T4, Fpz-Oz);
circumorthnorm = circumorth/norm(circumorth);

[markerstemp,circperimline_sorted] = find1020onPlane(V, aRes, circumorthnorm, Fpz, Fpz, Oz, [0.1, 0.3, 0.7, 0.9], 1); 
Markers = [Markers; markerstemp];

% Find Head Circumference
x = circperimline_sorted(:,1);
y = circperimline_sorted(:,2);
Hull = convhull(x, y);
perimeter = 0;
for i = 1:length(Hull)-1
    dx = x(Hull(i+1)) - x(Hull(i));
    dy = y(Hull(i+1)) - y(Hull(i));
    perimeter = perimeter + sqrt(dx^2 + dy^2);
end

Fp2 = Markers(14,:);
Fp1 = Markers(21,:);

O2 = Markers(20,:);
O1 = Markers(15,:);

F4orthog = cross(C3-Fp2, C3-O2);
F3orthognorm = F4orthog/norm(F4orthog);
F3orthog = cross(C4-Fp1, C4-O1);
F4orthognorm = F3orthog/norm(F3orthog);

markerstemp = find1020onPlane(V, aRes, F3orthognorm, C3, Fp2, O2, [0.25, 0.75], 0);
Markers = [Markers; markerstemp];

markerstemp = find1020onPlane(V, aRes, F4orthognorm, C4, Fp1, O1, [0.25, 0.75], 0);
Markers = [Markers; markerstemp]; 

Labels = {'Nz', 'Fpz', 'Fz', 'Cz', 'Pz', 'Oz', 'Iz', 'RHSJ', 'T4', 'C4', 'C3', 'T3', 'LHSJ', 'Fp2', 'O1' 'F8' 'T5' 'T6' 'F7' 'O2' 'Fp1', 'F4', 'P4', 'F3', 'P3'};

viewer = viewer3d;

Volume = volshow(V,Parent=viewer);
for j = 1:length(Markers)
    point{j} = images.ui.graphics3d.roi.Point(Position=Markers(j,:),Label=Labels{j},Color="yellow");
end

viewer.Annotations = [point{:}];

waitfor(viewer)