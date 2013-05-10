% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2007
%
% A routine to transform Pearson's Rho to a Z value.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function Z = SOM_Rho2Z(Rho)

Z = 1/2*log((1+Rho)./(1-Rho));

return

%
% All done.
%

