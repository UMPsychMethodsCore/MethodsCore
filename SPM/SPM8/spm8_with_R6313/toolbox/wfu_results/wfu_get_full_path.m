function [fullPath, existFullPath] = wfu_get_full_path(dirName)
%
% PURPOSE:  If a relative path is given the function returns the full path.
%           If the full path is given the function does nothing
%
% CATEGORY: Utility
%
% INPUTS: 
%
%       dirName
%
% OUTPUTS:
%
%       fullPath: Full path of the directory requested.
%
%       existFullPath : Flag indicating whether the full path directory exists or not.
%
% EXAMPLE:
%
%       >> fullDir = wfu_get_full_path('\raid\neuro\bkraft\..\pasl_rr\.\tmp')
%
%       fullDir =
%
%             \raid\neuro\pasl_rr\tmp
%

%==========================================================================
% C H A N G E   L O G
% 
%--------------------------------------------------------------------------
%
% $Id: wfu_get_full_path.m,v 1.1 2009/10/09 17:11:35 bwagner Exp $ 
%
% $Log: wfu_get_full_path.m,v $
% Revision 1.1  2009/10/09 17:11:35  bwagner
% PickAtlas Release Pre-Alpha 1
%
% Revision 1.2  2005/12/13 16:19:45  bkraft
% Added an example to comments.
%
% Revision 1.1  2005/12/13 16:13:40  bkraft
% Returns the full path of a directory.
%
%

disk     = '';  % Only used for PCs.  

if isunix

    if strcmp(dirName(1),filesep) % Absolute path
        fullPath = dirName;
    else
        fullPath = fullfile(pwd,dirName);
    end

else  % PC mkdir

    if regexp(dirName,'^[A-Za-Z]:\')
        disk     = dirName(1:2);
        fullPath = dirName(3:end);
    elseif strcmp(dirName(1),filesep)
        fullPath = dirName;        
    else
        fullPath = fullfile(pwd,dirName);
    end
end



%
%  The next set of commands removes relative paths with respect to the
%  root directory.  For example, /raid/neuro/bkraft/.. is by the
%  logic above is full path even though it is a relative path. To remove the
%  correct absolute path the full path is built up recursively. When a '..'
%  the up directory is saved. When '.' is encounted the '.' is removed.
%

pathArray =  wfu_split_string_array(fullPath, filesep);

fullPath  = strcat( filesep, pathArray{1});

for ii=2:length(pathArray)

    if strcmp('..',pathArray(1,ii));
        fileSepPosition = strfind(fullPath,filesep);
        fullPath = fullPath(1:fileSepPosition(end));
    elseif strcmp('.',pathArray{ii});
    else
        fullPath = strcat(fullPath, filesep, pathArray{ii});
    end

    %
    % Remove last file separator
    %

    if(strcmp(fullPath(end),filesep))
        fullPath = fullPath(1:end-1);
    end
end

%
% Add disk extension back onto directory if known
%

fullPath = strcat(disk, fullPath);

%
% Check to see if full path exists
%

existFullPath = (exist(fullPath) == 7);

