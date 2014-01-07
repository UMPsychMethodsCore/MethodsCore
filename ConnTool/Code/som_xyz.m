% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2006
%
%
% Returns the XYZ matrix for a 3D volumes
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function XYZ = SOM_XYZ(varargin)

XYZ = [];

if nargin < 1
    fprintf('You must specify a file name or header or dimensions.\n');
    return
end

% Now see if a header, file name, or dimensions.

if isa(varargin{1},'char')               % File name
    if exist(varargin{1}) == 2           % Yup a file name.)
        theHeader = spm_vol(varargin{1});
        theDIM = theHeader.dim(1:3);
    else
        fprintf('Seems like you specified a file, but doesn''t exist.\n');
        return
    end
elseif isa(varargin{1},'double')         % Specified dimensions.
    if length(varargin{1}) == 3          % Must be 3-d.
        theDIM = varargin{1};
    else
        fprintf('You must specify 3 axes.\n');
        return
    end
elseif isa(varargin{1},'struct')         % Header structure.
    if isfield(varargin{1}.dim)          % Does the dimension exist.
        theDIM = varargin{1}.dim(1:3);
    else
        fprintf('Dimensions are missing.\n');
        return
    end
end

%
% Now make the matrix.
%

XYZx = [1:theDIM(1)]'*ones(theDIM(2),1)';
XYZy = ones(theDIM(1),1)*[1:theDIM(2)];

XYZ = zeros(3,prod(theDIM(1:3)));

for iZ = 1:theDIM(3)
    XYZz = iZ*ones(theDIM(1),theDIM(2));
    XYZ(:,(iZ-1)*prod(theDIM(1:2))+1:iZ*prod(theDIM(1:2))) = ...
        [reshape(XYZx,[1 prod(size(XYZx))]);...
        reshape(XYZy,[1 prod(size(XYZy))]);...
        reshape(XYZz,[1 prod(size(XYZz))])];
end

%
% All done.
%

