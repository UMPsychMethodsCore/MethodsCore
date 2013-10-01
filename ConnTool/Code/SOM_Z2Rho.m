% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
% A routine to transform  Z to Pearson's Rho value.
%
% http://en.wikipedia.org/wiki/Fisher_transformation
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function Rho = SOM_Z2Rho(Z)

Rho = (exp(2*Z)-1)./(exp(2*Z)+1);

return

%
% All done.
%

