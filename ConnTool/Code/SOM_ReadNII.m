% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% A routine to read the 4D file
% and shape to match the output of Luis'
% code
%
% function results = SOM_ReadNII(P);
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_ReadNII(P);

results = -1;

if exist(P) ~= 2
  SOM_LOG(sprintf('ERROR : File does not exist : %s',P));
  return
end

try
  DATA4D = nifti(P);
catch
  SOM_LOG(sprintf('ERROR : Error reading file : %s',P));
  return
end

if ndims(DATA4D.dat(:,:,:,:)) ~= 4
  SOM_LOG(sprintf('ERROR : %s does not appear to be time-series data',P));
  return
end

results = reshape(DATA4D.dat(:,:,:,:),[prod(size(DATA4D.dat(:,:,:,1))) size(DATA4D.dat(:,:,:,:),4)])';

clear DATA4D;

return

%
% all done
%
