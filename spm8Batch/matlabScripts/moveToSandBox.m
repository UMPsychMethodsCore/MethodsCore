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
% 2013-03-17 
% Added a call to "validateSandBoxMove" due to an error in "cp" as it MATLAB tries to use "cp -p" with their
% copy to preserve the flags and on some systems the chflags error is generated but the copy succeeded.
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

if exist(SandBoxPID,'dir')
    if ~isempty(strfind(sourceExtension,'img'))
        fprintf('Only nifti files are supported for use with the sandbox\n');
        fprintf('Turning off sandbox\n');
        CS=0;
        SandBoxPID='';
    else
        %
        % First we have to make sure the sandbox is empty, if not we empty if, if we
        % fail at emptying then we turn on the sandbox. This is critical
        %
        [CSmyCheck CMmyCheck] = preenSandBox(SandBoxPID);
        % Empty?
        if CSmyCheck
            % SandBox is empty and clean.
            FILESTOMOVE=dir([sourceDir '/' sourceVolume sourceExtension(2:end)]);
            %
            % Big assumption is one nifti file per directory
            %
            tic;
            % This can only handle one file at a time, and WILL break with multiple - RCWelsh 2012-04-07
            if length(FILESTOMOVE) > 1
                fprintf('More than one nifti file in source directory %s, sandbox method can only handle a single.\n',sourceDir);
                fprintf('Turning off sandbox\n');
                CS=0;
                SandBoxPID='';
            else
                fprintf('Moving %s to sandbox:%s',FILESTOMOVE(1).name,SandBoxPID);
                [CS CM CMID] = copyfile(fullfile(sourceDir,FILESTOMOVE(1).name),SandBoxPID);
                % Now run my own validation code to see if successful -- a work around for the MAC.
                [CSmyCheck CMmyCheck] = validateSandBoxMove(sourceDir,FILESTOMOVE(1).name,SandBoxPID);
                xtoc=toc;
                fprintf('; It took %f seconds\n',xtoc);
                if ( CS && CSmyCheck ) || ( ~CS && CSmyCheck && strfind(CM,'chflags') && strfind(computer,'MAC'))
                    Images2Write = spm_select('ExtFPList',SandBoxPID,['^' sourceVolume sourceExtension],inf);
                    % Log in the process log that we are using the sand box.
                    UMBatchLogProcess(sourceDir,sprintf('Using sandbox : %s to work on file %s',SandBoxPID,FILESTOMOVE(1).name));
                    % Need to now use my status.
                    CS = CSmyCheck;
                    CM = CMmyCheck;
                else
                    fprintf('Failed to move to sandbox, turning off sandbox. Error (%d,%d) : %s/%s\n',CS,CSmyCheck,CM,CMmyCheck);
                    SandBoxPID='';
                end
            end
        else
            fprintf('Sandbox is not preen and I can not preen it, thus turning it off\n');
            SandBoxPID = '';
        end
    end
else
    fprintf('Not using sandbox, nothing to move into it.\n');
end

return

%
% all done.
%