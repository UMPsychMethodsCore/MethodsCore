function [FD, FDjudge] = mc_FD_calculation(MotionParameters, FDcriteria,FDLeverArm)
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
%                                            rotational displacements from radians/degrees to millimeters
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
   FDcriteria = 2;
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
FD_cv = [0;FD];

% Compare to the Criteria
FDjudgeInt = double(FD_cv>FDcriteria);

% Augement the censor vector FDjudge by remove 1 frame before and 2 frames
% after the problematic frame
n = length(FDjudgeInt);
FDjudge = zeros(n,1);
for i = 2:(n-2)  % the first frame will always have the FD = 0
    if FDjudgeInt(i)==1
        FDjudge(i-1) = 1;
        FDjudge(i)   = 1;
        FDjudge(i+1) = 1;
        FDjudge(i+2) = 1;
    end
end

if FDjudgeInt(n-1)==1
    FDjudge(i-1) = 1;
    FDjudge(i)   = 1;
    FDjudge(i+1) = 1;
end

if FDjudgeInt(n)==1
    FDjudge(i-1) = 1;
    FDjudge(i)   = 1;
end
    



