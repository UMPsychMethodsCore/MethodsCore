function outFile = wfu_uncompress_nifti(inFile)
% outFile = wfu_uncompress_nifti(inFile)
% 
% takes in a nifti file (nii.gz), uncompresses it in the system's tmp
% directory, and returns the name of the uncompressed file.
%
% Uncompressed nifti's are registered in the global var
% WFU_UNCOMPRESSED_NITFI.  If inFile is replaced with the action string
% 'cleanup', then all uncompressed nifti's that have been registered 
% with this function will be deleted.  The orginal compressed files will
% not be modified.
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.5 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.5 $');
  
  
  inFile=cellstr(inFile);
  outFile=cell(0);
  for i=1:length(inFile)
    outFile{i}=uncompress(inFile{i});
  end
  if length(inFile)==1
    outFile=outFile{1};
  end
return

function outFile=uncompress(inFile)
  global WFU_LOG;
  global WFU_UNCOMPRESSED_NIFTI;

  if strcmpi(inFile,'cleanup')
    WFU_LOG.minutia('Cleaning up Uncompressed NiFTIs');
    for i=1:length(WFU_UNCOMPRESSED_NIFTI)
      lastwarn('');
      try
        delete(WFU_UNCOMPRESSED_NIFTI{i});
        if isempty(lastwarn)
          WFU_LOG.info(sprintf('Delete temporary file %s ... ',WFU_UNCOMPRESSED_NIFTI{i}));
        end
      catch
        WFU_LOG.error(sprintf('Unable to delete temporary file %s ... ',WFU_UNCOMPRESSED_NIFTI{i}));
      end
    end
    WFU_UNCOMPRESSED_NIFTI={};
    outFile=[];
  else
   	[fPath fName fExt] = fileparts(inFile);
    WFU_LOG.minutia(sprintf('Uncompressed NiFTI: %s',[fName fExt]));
    if strcmpi(fExt,'.gz')
      t = [tempname '.nii.gz'];
      copyfile(inFile,t);
      outFile = char(gunzip(t));
      delete(t);
      WFU_UNCOMPRESSED_NIFTI{end+1}=outFile;
      WFU_LOG.info(sprintf('There are %d file(s) registered with wfu_uncompress_nifti.',length(WFU_UNCOMPRESSED_NIFTI)));
    else
      outFile=inFile;
    end
  end
return

%% Revision Log at end

%{
$Log: wfu_uncompress_nifti.m,v $
Revision 1.5  2015/02/23 14:05:56  fmri
removed try/catch fileparts mess

Revision 1.4  2011/10/10 16:56:57  bwagner
Matlab 2011b changes to fileparts

Revision 1.3  2010/07/29 18:23:12  bwagner
Removed line ending from info call stating number of files registered with function.

Revision 1.2  2010/07/19 20:21:08  bwagner
WFU_LOG implemented.

revision 1.1  2009/10/09 17:11:38  bwagner
PickAtlas Release Pre-Alpha 1
%}
