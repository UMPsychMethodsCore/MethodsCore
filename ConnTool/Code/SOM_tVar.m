% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% A routine to calculate the temporal variance map of a time-series
% data set. 
% 
% This is useful for creating a mask on-the-fly for regressor of 
% physio nuiscance.
%
% function results = SOM_tVar(NIFTI4DFILE,outputName)
%
% Input  --  is times-series data, and masking image
% 
%         NIFTI4DFILE - name of ".nii" file to calculate variance.
%
%         outputName  - name of output variance map
%                       if absoluate path is given that will be
%                       used else it will be written in relative 
%                       path to the NIFTI4DFILE
%
% Output --
% 
%         results     - name of output file written. A nifti file.
% 
%
% 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_tVar(NIFTI4DFILE,outputName)

results = -1;

% Open the file, but catch any error.

try
  vol4D = nifti(NIFTI4DFILE);
catch
  SOM_LOG(sprintf('WARNING : input file can not be opened : %s',NIFT4DFILE));
  return
end

% Now calculate the variance map.

% First some sanity checks.

if length(vol4D.dat.dim) < 4
  SOM_LOG(sprintf('WARNING : Input file must be 4D! : %s',NIFT4DFILE));
  return
end

if vol4D.dat.dim(4) < 2
  SOM_LOG(sprintf('WARNING : Input file must be 4D! : %s',NIFT4DFILE));
  return
end
  
% Okay, we are good to go.

t_VarMap = var(vol4D.dat(:,:,:,:),[],4);

% Get the path of the 4D file.

[fp fn fe] = fileparts(NIFTI4DFILE);

if outputName(1) ~= '/'
  results = fullfile(fp,outputName);
end

[fpO fnO feO] = fileparts(outputName);

% Now write it out.

SOM_WriteNII(NIFTI4DFILE,results,t_VarMap,'FLOAT32-LE');

return
