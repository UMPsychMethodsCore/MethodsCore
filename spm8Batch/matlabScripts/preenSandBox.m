% - - - - - - - - - - - - - - - - - - - -
%
% Robert C Welsh
% Ann Arbor
%
% Copyright 2011-2013
%
% Clean out the sandbox.
%
% function [CSmyCheck CMmyCheck] = preenToSandBox(SandBoxPID)
%
% - - - - - - - - - - - - - - - - - - - -

function [CSmyCheck CMmyCheck] = preenSandBox(SandBoxPID)

CSmyCheck = 1;
CMmyCheck = 'SANDBOX PREENED';

% Check to see if SandBoxPID exists

% First make sure the name has a name that contains 'sandbox' and that it exists.

if ~isempty(strfind(SandBoxPID,'sandbox')) && exist(SandBoxPID,'dir')
    %
    % let's look for stuff in it
    %
    SandBoxContents = dir(SandBoxPID);
    for iItem = 1:length(SandBoxContents)
        % We have to skip over . and ./
        if ~isdir(fullfile(SandBoxPID,SandBoxContents(iItem).name))
            fprintf('Found %s in the sandbox %s, going to remove\n',SandBoxContents(iItem).name,SandBoxPID);
            try
                delete(fullfile(SandBoxPID,SandBoxContents(iItem).name));
            catch
                fprintf('Can not delete the item\n');
                CSmyCheck = 0;
                CMmyCheck = 'SANDBOX ERROR : Sand not box empty and can not delete';
            end
        end
    end
    %
    % Now one last check to make sure it's empty.
    %
    SandBoxContents = dir(SandBoxPID);
    for iItem = 1:length(SandBoxContents)
        % We have to skip over . and ./
        if ~isdir(fullfile(SandBoxPID,SandBoxContents(iItem).name))
            fprintf('Found %s in the sandbox %s, going to remove\n',SandBoxContents(iItem).name,SandBoxPID);
            fprintf('Can not delete the item\n');
            CSmyCheck = 0;
            CMmyCheck = 'SANDBOX ERROR : Sand box not empty and can not delete';
        end
    end
    
else
    CSmyCheck = 0;
    CMmyCheck = 'SANDBOX IS NOT PRESENT';
end

