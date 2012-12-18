function [FD, FDjudge] = mc_FD_calculation(MotionParameters, FDcriteria)
% MC_FD_CALCULATION    calculating the FD from the motion record for
%   each timepoint, of x,y,z,pitch,roll and yaw. 
%   The calculation is based on 
%   FD_i=|d_(i-1)x-d_ix|+|d_(i-1)y-d_iy|+|d_(i-1)z-d_iz|+|alpha_(i-1)-alpha_i|
%   +|beta_(i-1)-beta_i|+|gamma_(i-1)-gamma_i|, where i is each time point,
%   and when i = 1, the six subtractions = 0.
%   Rotational displacement was calculated as:
%   2*pi*50*(degrees/360) for each rotational axis.
%   As FSL calculates rotation in radians, the above euqation could thus be
%   simplified to: 2*pi*50*(radians*360/(2*pi)/360) = 50*radians. 
%   The results will be compared to FDcriteria, any results bigger than the
%   criteria will be set to 1(meaning it will be omitted later), otherwise
%   set to 0 (meaning keep this time point)
%   INPUT
% 
%       MotionParameters                   - the Matrix that contains the
%                                            motion information on 6 
%                                            directions for each time point
% 
%       FDcriteria                         - the value set as the criteria
%                                            of FD result
% 
%   OUTPUT
% 
%       FD                                 - the 1D matrix that contains FD
%                                            value for each time point
% 
%       FDjudge                            - the 1D matrix that contains
%                                            the information that whether 
%                                            the FD value is above the 
%                                            criteria or not (1/0)
%   Yu Fang 12/10/2012

% Extract the time point length
[TimeLength, Dimension] = size(MotionParameters);

% Check the data
if Dimension~=6
    warning('You probably do not have the correct input: not enough dimensions here')
end

% Initialize the result vectors:FD value, FDjudge(1/0)
FD = zeros(TimeLength,1);
FDjudge = zeros(TimeLength,1);

% Calculate FD
for i = 2:TimeLength
    temp = 0;
    % x,y,z
    for j = 1:3
        temp = temp + abs(MotionParameters(i-1,j)-MotionParameters(i,j));
    end
    % roll,pitch,yaw
    for j = 4:6
        temp = temp + abs(MotionParameters(i-1,j)*50-MotionParameters(i,j)*50);
    end
    % Final Result for this time point
    FD(i) = temp;
end

% Compare to the Criteria
for i = 1:TimeLength
    if FD(i)>=FDcriteria
        FDjudge(i)=1;
    end
end

