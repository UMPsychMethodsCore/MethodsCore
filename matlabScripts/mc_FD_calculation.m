function [FD, FDjudge] = mc_FD_calculation(MotionParameters, FDcriteria, FDLeverArm, ScansBefore, ScansAfter)
% MC_FD_CALCULATION    calculating the FD from the motion record for
%   each timepoint, of x,y,z,pitch,roll and yaw. 
%   The calculation is based on 
%   FD_i=|d_(i-1)x-d_ix|+|d_(i-1)y-d_iy|+|d_(i-1)z-d_iz|+|alpha_(i-1)-alpha_i|
%   +|beta_(i-1)-beta_i|+|gamma_(i-1)-gamma_i|, where i is each time point,
%   and when i = 1, the six subtractions = 0.
%   Rotational displacement was calculated as:
%   2*pi*FDLeverArm*(degrees/360) for each rotational axis.
%   As FSL calculates rotation in radians, the above euqation could thus be
%   simplified to: 2*pi*FDLeverArm*(radians*360/(2*pi)/360) = FDLeverArm*radians. 
%   The results will be compared to FDcriteria, any results bigger than the
%   criteria will be set to 1(meaning it will be omitted later), otherwise
%   set to 0 (meaning keep this time point)
%   INPUT
% 
%       MotionParameters                   - motion parameters, time x parametes
%                                            columns 1-3 are angles in RADIANS
%                                            columns 4-6 are diplacement in mm
%
%       FDcriteria                         - the value set as the criteria
%                                            of FD result
% 
%       FDLeverArm                         - The mean distance from the cerebral cortex to the center of the head, used to convert
%                                            rotational displacements from
%                                            radians/degrees to millimeters
%       
%       ScansBefore                        - Number of scans to censor before scans exceeding the FDcriteria
%
%       ScansAfter                         - Number of scans to censor after scans exceeding the FDCriteria
% 
%   OUTPUT
% 
%       FD                                 - the 1D matrix that contains FD value for each time point
% 
%       FDjudge                            - the 1D matrix that contains the information that whether 
%                                            the FD value is above the criteria or not (1/0)
%   Yu Fang 12/10/2012
 

% Check the data
if exist('FDcriteria') == 0
   fprintf('Assuming "FDcriteria=2mm"\n');
   FDcriteria = 0.2;
end

if exist('FDLeverArm') == 0
   fprintf('Assuming "FDleverArm=50mm"\n');
   FDLeverArm = 50;
end

if length(size(MotionParameters)) ~= 2
    fprintf('"motion" must be a 2-d array, time x param\n');
    return
end

if size(MotionParameters,2) ~= 6
    fprintf('"motion" must have 6-columns!\n');
    return
end

if size(MotionParameters,1) < 2
    fprintf('"motion" must have at least 2 time-points!\n');
    return
end

% Calculate FD

% Convert rotational displacements from radian to millimeters.
MotionParameters(:,1:3) = MotionParameters(:,1:3).*FDLeverArm;

% Take the first derivative along the first dimension.
FDMotion = diff(MotionParameters);

% Take the absolute values
FDMotion = abs(FDMotion);

% Sum up the difference along the second dimension.
FD = sum(FDMotion,2);

% Add a zero in the front to represent the first frame
FD = [0;FD];
FDjudge = [];

% Compare to the Criteria
badScans = find(FD > FDcriteria);
cellBadScans = num2cell(badScans);
numScans = length(FD);

if ~isempty(badScans)
    if ScansBefore > 0
        for i = 1:size(badScans, 1)
            tmpBeforeScans = badScans(i) - [ScansBefore:-1:1];
            tmpBeforeScans(tmpBeforeScans <= 0) = [];
            cellBadScans{i} = [tmpBeforeScans cellBadScans{i}];
        end
    end
    
    if ScansAfter > 0
        for i = 1:size(badScans, 1)
            tmpAfterScans = badScans(i) + [1:1:ScansAfter];
            tmpAfterScans(tmpAfterScans > numScans) = [];
            cellBadScans{i} = [cellBadScans{i} tmpAfterScans];
        end
    end
    
    allBadScans = unique([cellBadScans{:}]);
    FDjudge = zeros(numScans, length(allBadScans));
    ind = sub2ind(size(FDjudge), allBadScans, 1:length(allBadScans));
    FDjudge(ind) = 1;
end        
        
