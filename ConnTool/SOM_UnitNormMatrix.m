% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
%
% A function to norm a matrix along a given direction.
%
% This is for the SOM ToolBox.
%
% theMatrix = theMatrix(dim1,dim2);
% whichType = 1 for dim1 = time dimension
%                   dim2 = space dimension
%
%           = 2 for dim1 = space dimension
%                   dim2 = time dimension
%
%
% Version 1.0
%
%    function results = SOM_UnitNormMatrix(theMatrix,whichType)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_UnitNormMatrix(theMatrix,whichType)

%if ndims(theMatrix) ~= 2 || (ndims(theMatrix) == 2 && size(theMatrix,1) == 1  )
%    results = theMatrix;
%    fprintf('This is specifically for 2 dim data [time and space]\n');
%    return
%end

M2 = theMatrix.*theMatrix;

SM2 = sum(M2,whichType);

if whichType == 2
    SM2 = SM2';
end

SM = SM2.^(1/2);

NM = ones(size(theMatrix,whichType),1)*SM;

if whichType == 2
    NM = NM';
end

results = theMatrix./(NM+.000001);
    if(any(any(isnan(results))))
         keyboard;
    end
return

%
% All done.
%
