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

[markerstemp, perimeter(1)] = find1020onPlane(V, aRes, sagorthog, LM(1,:), LM(1,:), LM(4,:), [0,0.1,0.3,0.5,0.7,0.9,1], 0);
Markers = [Markers; markerstemp];

% Start Coronal
Cz = markerstemp(4,:);
Fpz = markerstemp(2,:);
Oz = markerstemp(6,:);

cororthog = cross(TT,LM(2,:)-Cz);
cororthognorm = cororthog/norm(cororthog);
   
[markerstemp, perimeter(2)] = find1020onPlane(V, aRes, cororthognorm, LM(2,:), LM(2,:), LM(3,:), [0,0.1,0.3,0.7,0.9,1], 0);
Markers = [Markers; markerstemp];

T3 = markerstemp(2,:);
C3 = markerstemp(3,:);
C4 = markerstemp(4,:);
T4 = markerstemp(5,:);


circumorth = cross(T3-T4, Fpz-Oz);
circumorthnorm = circumorth/norm(circumorth);

[markerstemp,perimeter(3)] = find1020onPlane(V, aRes, circumorthnorm, Fpz, Fpz, Oz, [0.1, 0.3, 0.7, 0.9], 1); 
Markers = [Markers; markerstemp];

F8 = Markers(16,:);
F7 = Markers(19,:);
Fz = Markers(3,:);

T6 = Markers(18,:);
T5 = Markers(17,:);
Pz = Markers(5,:);

Forthog = cross(Fz-F8, Fz-F7);
Fnorm = Forthog/norm(Forthog);

Porthog = cross(Pz-T6, Pz-T5);
Pnorm = Porthog/norm(Porthog);

markerstemp = find1020onPlane(V, aRes, Fnorm, Fz, F8, F7, [0.25, 0.75], 0);
Markers = [Markers; markerstemp];

markerstemp = find1020onPlane(V, aRes, Pnorm, Pz, T6, T5, [0.25, 0.75], 0);
Markers = [Markers; markerstemp]; 

Labels = {'Nz', 'Fpz', 'Fz', 'Cz', 'Pz', 'Oz', 'Iz', 'RHSJ', 'T4', 'C4', 'C3', 'T3', 'LHSJ', 'Fp2', 'O1' 'F8' 'T5' 'T6' 'F7' 'O2' 'Fp1', 'F4', 'F3', 'P4', 'P3'};

viewer = viewer3d;
viewer.Parent.WindowState = 'maximized';

Volume = volshow(V,Parent=viewer);
for j = 1:length(Markers)
    point{j} = images.ui.graphics3d.roi.Point(Position=Markers(j,:),Label=Labels{j},Color="yellow");
end

viewer.Annotations = [point{:}];

waitfor(viewer)