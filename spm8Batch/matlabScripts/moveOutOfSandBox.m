%
% function CSBACK = moveOutOfSandBox(sourceDir,sourceVolume,SandBoxPID,OutputName,CS);
%

function CSBACK = moveOutOfSandBox(sourceDir,sourceVolume,SandBoxPID,OutputName,CS);

CSBACK = 0;

if CS == 1
  %     Now we need to move the file back.
  FILESTOMOVE=dir([SandBoxPID '/' OutputName sourceVolume '*.nii']);
  tic;
  fprintf('Moving %s out of sandbox',FILESTOMOVE(1).name);  
  [CSBACK CM CMID] = copyfile(fullfile(SandBoxPID,FILESTOMOVE(1).name),sourceDir);
  xtoc=toc;
  fprintf('; It took %f seconds\n',xtoc);
  if CSBACK == 1
    % Delete the copy.
    delete(fullfile(SandBoxPID,FILESTOMOVE(1).name));
    % Now remove the original file.
    FILESTOMOVE=dir([SandBoxPID '/' sourceVolume '*.nii']);
    delete(fullfile(SandBoxPID,FILESTOMOVE(1).name));
    % Now remove the original file.
    FILESTOMOVE=dir([SandBoxPID '/' OutputName sourceVolume '*.mat']);
    delete(fullfile(SandBoxPID,FILESTOMOVE(1).name));
  else
    fprintf('* * * * * * * * * * * * * * * * * * * * * * *\n');
    fprintf('I could not move the file out of the sandbox,\n');
    fprintf('this is a fatal error.\n');
    fprintf('%s\n',fullfile(SandBoxPID,FILESTOMOVE(1).name));
    fprintf('%s\n',UMImgDIRS{iSub}{iRun});
    fprintf('* * * * * * * * * * * * * * * * * * * * * * *\n');
    exit
  end	
end

return

%
% all done
%