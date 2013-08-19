% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -cd
%
% Robert C. Welsh
% Copyright 2013
%
% Ann Arbor, MI
%
% SOM_DeSpikeTimeSeries
%
% DeSpike a time-series, allowing for removal of time-points
%
% function D1 = SOM_SmoothTimeSeries(D0,despikeVector,smoothParameters)
%
% Input
% 
% D0           = data that is space x time
%
% censorVector = string of 1's and 0's, one element per time
%                point on what to keep and throw away in
%                time-series data.
%
%                1 = keep
%                0 = toss
%
%
% smoothParameters
% 
%     .span         = fractional span
%
%     .method       = method to smooth
% 
%     .interpMethod = interpolation method for missing time points.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function D1 = SOM_DeSpikeTimeSeries(D0,despikeVector,despikeParameters)

% Fill our return

D1 = D0;

% Is there anything to despike?

if isempty(despikeVector) || sum(despikeVector) == 0
    return
end

% Unfortunately we have to process linearly all voxels.

nVox          = size(D0,1);
xBase         = 1:size(D0,2);
xBaseKeep     = find(despikeVector~=0);
xBaseReplace  = find(despikeVector==0);

for iVox = 1:nVox
    
    D1Temp = smooth(xBaseKeep,D0(iVox,xBaseKeep),despikeParameters.span,despikeParameters.method);
    
    % Now do the interpolation back to the full time-course.
    
    D1Temp                = interp1(xBaseKeep(:),D1Temp(:),xBase(:),despikeParameters.interpMethod);
    D1(iVox,xBaseReplace) = D1Temp(xBaseReplace);
    
end

return

