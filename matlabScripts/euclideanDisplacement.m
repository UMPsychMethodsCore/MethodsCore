% - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Ann Arbor, MI  
%
% Copyright 2012 - Use by permission only
%
% function results = euclideanDisplacement(motionParameters,leverArm)
%
%  Input : 
% 
%     motion - motion parameters, time x parametes
%              columns 1-3 are angles in RADIANS
%              columns 4-6 are diplacement in mm
%           
%     leveArm - distance from folcrum of head to furthest edge
%               good guess is 50-100mm
%
%  Output:
% 
%    results  -- a structure
%
%        .maxSpace  = maximum of the differiential euclidean distance
%        .meanSpace = mean of all of the differential euclidean distances
%        .sumSpace  = sum of all of the differential euclidean distances
%        .maxAngle  = maximum distance as above but calculated or angles
%                     using "leverArm"
%        .meanAngle = mean of the above.
%        .sumAngle  = sum of the above.
%        .meanFD = mean of all of the framewise displacements
%        .nonzeroFD = number of time points whose FD is above certain criteria   
%
%  If results == -1 then you have an error in your input!!!
%
%
% Code supported by NIH grant R01-NS052514
%
% - - - - - - - - - - - - - - - - - - - - -


function results = euclideanDisplacement(motionParameters,leverArm,FDLeverArm,FDcriteria)

% default return

results = -1;

if exist('leverArm') == 0
   fprintf('Assuming "leverArm=50mm"\n');
   leverArm = 50;
end

if exist('FDLeverArm') == 0
   fprintf('Assuming "FDleverArm=50mm"\n');
   FDLeverArm = 50;
end

if length(size(motionParameters)) ~= 2
    fprintf('"motion" must be a 2-d array, time x param\n');
    return
end

if size(motionParameters,2) ~= 6
    fprintf('"motion" must have 6-columns!\n');
    return
end

if size(motionParameters,1) < 2
    fprintf('"motion" must have at least 2 time-points!\n');
    return
end

clear results

% All sanity checks passed.

% Take the first derivative along the first dimension.

dMotion           = diff(motionParameters);

% Pull out the spatial part.
dMotionSpace      = dMotion(:,4:6);

% Pull out angular part.
displacementSpace = sqrt(sum(dMotionSpace.*dMotionSpace,2));

% Calculate summarizing statistics.
results.maxSpace  = max(displacementSpace);
results.meanSpace = mean(displacementSpace);
results.sumSpace  = sum(displacementSpace);

% Now calculate for the rotation assuming a lever arm.

dMotionAngle      = dMotion(:,1:3);

folcrum           = leverArm*sin(dMotionAngle);

displacementAngle = sqrt(sum(folcrum.*folcrum,2));

% Now calculate for angles.
results.maxAngle  = max(displacementAngle);
results.meanAngle = mean(displacementAngle);
results.sumAngle  = sum(displacementAngle);

% Now calculate for FD values
[FD,FDjudge]=mc_FD_calculation(motionParameters,FDcriteria,FDLeverArm);
results.meanFD = mean(FD);
results.nonzeroFD = nnz(FDjudge);

return
