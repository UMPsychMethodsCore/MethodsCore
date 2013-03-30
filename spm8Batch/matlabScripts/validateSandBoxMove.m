% - - - - - - - - - - - - - - - - - - - -
%
% Robert C Welsh
% Ann Arbor
%
% Copyright 2011-2013
%
% My own check to see if the file made it to the sandbox.
%
% NOTE : If you wish to check to see if a file made it out of the sandbox then just 
%        swap the sourceDir and SandBoxPID. The first directory is the source and the 
%        second is the destination directory.
%
% function [CSmyCheck CMmyCheck] = validateSandBoxMove(sourceDir,sandBoxVolume,SandBoxPID)
%
% Input
%  
%    sourceDir        -- string    -- location of original file.
%    sandBoxVolume    -- string    -- name of the original file that has been moved
%    SandBoxPID       -- string    -- location of the sandbox. 
%
% 
% Output
% 
%    CSmyCheck        -- scalar    -- 1 = okay, 0 = failure
%    CMmyCheck        -- string    -- error message.
%
% - - - - - - - - - - - - - - - - - - - -

function [CSmyCheck CMmyCheck] = validateSandBoxMove(sourceDir,sandBoxVolume,SandBoxPID)


%
% Some code to check really if it copied, as the MAC has problem with network
% drive (READYNAS and permissions). So we will check for existence and size matching.
%
% Then we check to see if file is open and closable.
%
sourceStats = dir(fullfile(sourceDir,sandBoxVolume));
% Default my checking to be successful
CSmyCheck = 1;
CMmyCheck = 'SandBox Okay';

%
% Does the destination exist?
%
if exist(fullfile(SandBoxPID,sandBoxVolume),'file')
    destiStats = dir(fullfile(SandBoxPID,sandBoxVolume));
    % Size okay?
    if sourceStats.bytes ~= destiStats.bytes
        fprintf('Failed to properly move to sandbox, sizes do not match\n');
        CSmyCheck = 0;
        CMmyCheck = 'SANDBOX ERROR : SIZE MISMATCH';
    else
        % Can I open for read?
        openReadTest = fopen(fullfile(SandBoxPID,sandBoxVolume),'r');
        if openReadTest < 1
            fprintf('Failed to properly move to sandbox, can not open for reading\n');
            CSmyCheck = 0;
            CMmyCheck = 'SANDBOX ERROR : CAN NOT OPEN FOR READ';
        else
            % Success, now the write?
            fclose(openReadTest);
            openWriteTest = fopen(fullfile(SandBoxPID,sandBoxVolume),'a');
            if openWriteTest < 1
                fprintf('Failed to properly move to sandbox, can not open for writing\n');
                CSmyCheck = 0;
                CMmyCheck = 'SANDBOX ERROR : CAN NOT OPEN FOR WRITE';
            else
                fclose(openWriteTest);
            end
        end
    end
else
    CSmyCheck = 0
    fprintf('Failed to properly move to sandbox, copy failed.\n');
    CMmyCheck = 'SANDBOX ERROR : FILE DID NOT MAKE IT TO SANDBOX';
end

return

%
% all done
%
