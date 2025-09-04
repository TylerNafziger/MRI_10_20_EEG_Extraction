function [Markers, hc, Labels] = FilterAndGet1020(LM, nifti_filepath)
% Extracts 10-20 markers from a threshold filtered MRI volume, and it's
% principal landmarks
% 
% Inputs:
%   LM: 4x3 array of 3D coordinates where rows are nasion, right ear, left
%   ear, and inion, in that order. Columns should be in order of Anterior,
%   Right, and Superior, as this is the coordinate order from annotating on a
%   MATLAB RAS volume
%
%   nifti_filepath: path to the nifti file containing the MRI volume to use
%
% Output:
%   Markers: Contains the 3D coordinates of the full set of 10-20 points.
%       Ordered in order of Labels
%   hc: computed head circumference at the circumferential line
%   Labels: Contains the order the markers are given in. Correspond to rows
%       in Markers



info = niftiinfo(nifti_filepath);
aRes = info.PixelDimensions;
v = niftiread(info);
v = v*info.MultiplicativeScaling + info.AdditiveOffset;
uif = uifigure('HandleVisibility','on','WindowState','maximized');
viewer = viewer3d(uif);
volume = volshow(v,Parent=viewer);

uif.UserData.sliderValue = 0;
sld = uislider(uif,'ValueChangedFcn',@(src,event)updatenoise(v,event,volume,uif),Orientation='Vertical');
sld.Position = [100 100 3 0.8*uif.Position(4)];

btn = uibutton(uif, 'Text', 'Continue', ...
    'Position', [150 100 100 30], ...
    'ButtonPushedFcn', @(btn,event) uiresume(uif));

uiwait(uif);
scaling = uif.UserData.sliderValue;
v_filt = volume.Data;

[Markers, hc, Labels] = Get1020(v_filt,LM, aRes);

close(uif)

function updatenoise(v,event,volume, uif)
    maxsignal = double(max(v(:)));
    thresh = maxsignal*event.Value/100;
    v_filt = v;
    v_filt(v<thresh) = 0;
    volume.Data = v_filt;

    uif.UserData.sliderValue = event.Value;
end
end