% - - - - - - - - - - - - - - - - - - - - 
%
% Robert C Welsh
% Ann Arbor
%
% Copyright 2011-2012
%
% Adding ability to pass the file extension for the source.
%
% function [CS SandBoxPID Images2Write] = moveToSandBox(sourceDir,sourceVolume,SandBoxPID,sourceExtension)
%
% - - - - - - - - - - - - - - - - - - - - 

function [CS SandBoxPID Images2Write] = moveToSandBox(sourceDir,sourceVolume,SandBoxPID,sourceExtension)

% Check to see if sourceExtension was specified

if exist('sourceExtension') == 0
  sourceExtension = '.*.nii';
end

% Default is to use what we have on the source directory

Images2Write = spm_select('ExtFPList',sourceDir,['^' sourceVolume sourceExtension],inf);
CS           = 0;

% Does the sandbox even exist?

% The tricky thing here is that if sourceVolume is a 4D file, then
% we move the whole thing -- though we are only geared up for a
% single file as we use "FILESTOMOVE(1)" below. Not sure on the
% impact of other code? 

if exist(SandBoxPID) == 7
  if length(findstr('img',sourceExtension)) > 0
    fprintf('Only nifti files are supported for use with the sandbox\n');
    fprintf('Turning off sandbox\n');
    CS=0
    SandBoxPID='';
  else    
    FILESTOMOVE=dir([sourceDir '/' sourceVolume sourceExtension]);
    %
    % Big assumption is one nifti file per directory
    %
    tic;
    % This can only handle one file at a time, and WILL break with multiple - RCWelsh 2012-04-07
    if length(FILESTOMOVE) > 1
      fprintf('More than one nifti file in source directory %s, sandbox method can only handle a single.\n',sourceDir);
      fprintf('Turning off sandbox\n');
      CS=0
      SandBoxPID='';
    else
      fprintf('Moving %s to sandbox:%s',FILESTOMOVE(1).name,SandBoxPID);
      [CS CM CMID] = copyfile(fullfile(sourceDir,FILESTOMOVE(1).name),SandBoxPID);
      xtoc=toc;
      fprintf('; It took %f seconds\n',xtoc);
      if CS == 1
	Images2Write = spm_select('ExtFPList',SandBoxPID,['^' sourceVolume sourceExtension],inf);
	% Log in the process log that we are using the sand box.
	UMBatchLogProcess(sourceDir,sprintf('Using sandbox : %s to work on file %s',SandBoxPID,FILESTOMOVE(1).name));
      else
	fprintf('Failed to move to sandbox, turning off sandbox\n');      
	SandBoxPID='';
      end
    end
  end
else
  fprintf('Not using sandbox, nothing to move into it.\n');
end

return

%
% all done.
%