% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
%
% newData = SOM_Detrend(data,polyorder);
%
%
% Input Parameters that we need for preparing the data
%
% polyorder = order of the polynomial, 0 is mean centered.
%
% data      = data (space x time);
%
% This we operate on the 2nd dimension.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_Detrend(Y,polyorder)

% Check to see if they specified the polynomial order.

if nargin == 1
  polyorder = 0;
end

% 
% If polyorder = 0 then we are just mean centering the data.
% 
% Okay they specified something, and actually we only recommend
% linear detrending due to the definition of zero in time.
%

X = zeros(polyorder+1,size(Y,2));

% This handles the mean.

X(1,:) = 1;

% Now the other terms.

for iP = 1:polyorder
  X(iP+1,:) = ([1:size(X,2)].^iP);
end

% We solve the GLM that is written in matrix form as
%
%     Y = Beta X
%
%         Beta = space x regressor
%         X    = regressor x time
%   
%     Beta = Y * pinv(X)
%   
%         and thus
%     
%     Yp = Y - Beta X = Y - ( Y pinv(X) ) X
%

results = Y - ( Y * pinv(X) ) * X;

return
