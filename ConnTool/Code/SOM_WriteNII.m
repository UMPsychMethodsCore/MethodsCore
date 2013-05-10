% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% A routine to more easily write out nifti files
% using the spm routines but adding a layer to copy 
% the head of a template image.
%
% Input 
%
%          TemplateImageName
%          NewName
%          Volume (3D or 4D)
%          
% function results = SOM_WriteNII(TemplateImage,NewName,Volume)
%
% Default is to write in the same directory, have to test
% to see if name can include directory path.
%
% function results = SOM_WriteNII(TemplateImage,NewName,Volume,dtype)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_WriteNII(TemplateImage,NewName,Volume,dtype)

results = -1;

% First get the dimensions of what we want to write, and we need to
% pad with 1's for 3D to become the proper order.

volDIM = size(Volume);

if length(volDIM) < 4
  volDIM = [volDIM 1];
end

try
  niftiIn = nifti(TemplateImage);
catch
  SOM_LOG(sprintf('FATAL ERROR : TemplateImage can''t be read : %s\n',TemplateImage));
  return
end
 
if any(volDIM(1:3)-size(niftiIn.dat(:,:,:,1)))
  SOM_LOG(sprintf('FATAL ERROR : TemplateImage dimension doesn''t match data dimension to be written\n'));
  return 
end

% data area.
niftiOutData          = file_array;

niftiOutData.fname    = NewName;
niftiOutData.dim      = volDIM;

% No error checking on that they pass in!!!
if exist('dtype') == 0
  niftiOutData.dtype    = niftiIn.dat.dtype;
else
  niftiOutData.dtype     = dtype;
end

niftiOutData.offset   = niftiIn.dat.offset;

% header area
niftiOut              = nifti;
niftiOut.mat          = niftiIn.mat;
niftiOut.mat_intent   = niftiIn.mat_intent;
niftiOut.mat0         = niftiIn.mat0;
niftiOut.mat0_intent  = niftiIn.mat0_intent;
niftiOut.descrip      = [niftiIn.descrip ', SOM Create Nifti file']; 
niftiOut.timing       = niftiIn.timing; 

% Clear the hook to the template image.
clear niftiIn;

% Put the data onto disk.
niftiOut.dat          = niftiOutData;

% create the file.
create(niftiOut);

% Actually write the data now, first reserving some zeros. -- Not sure if we 
% need to do this step.
niftiOut.dat(:,:,:,:) = zeros(niftiOutData.dim);

% data to disk.
niftiOut.dat(:,:,:,:) = Volume;

% Close our connection to the output file.
clear niftiOut

% All done

results = NewName;

return

