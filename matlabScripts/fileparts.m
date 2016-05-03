function [pathstr, name, ext, ver] = fileparts(file)
%FILEPARTS Filename parts.
%   This is a modified version of fileparts.m from matlab R2012b
%   It has been modified to take an optional 4th output argument in order
%   to maintain backwards compatibility with legacy code writen when
%   matlab's fileparts did take 4 output arguments.
%
%   [PATHSTR,NAME,EXT] = FILEPARTS(FILE) returns the path, file name, and
%   file name extension for the specified FILE. The FILE input is a string
%   containing the name of a file or folder, and can include a path and
%   file name extension. The function interprets all characters following
%   the right-most path delimiter as a file name plus extension.
%
%   If the FILE input consists of a folder name only, be sure that the
%   right-most character is a path delimiter (/ or \). Othewise, FILEPARTS
%   parses the trailing portion of FILE as the name of a file and returns
%   it in NAME instead of in PATHSTR.
%
%   FILEPARTS only parses file names. It does not verify that the file or
%   folder exists. You can reconstruct the file from the parts using
%      fullfile(pathstr,[name ext])
%
%   FILEPARTS is platform dependent.
%
%   On Microsoft Windows systems, you can use either forward (/) or back
%   (\) slashes as path delimiters, even within the same string. On Unix
%   and Macintosh systems, use only / as a delimiter.
%
%   See also FULLFILE, PATHSEP, FILESEP.

%   Copyright 1984-2012 The MathWorks, Inc.
%   $Revision: 1.18.4.18 $ $Date: 2012/04/14 04:15:41 $

pathstr = '';
name = '';
ext = '';
ver = '';

if ~ischar(file)
    error('MATLAB:fileparts:MustBeChar', 'Input must be a row vector of characters.');
elseif isempty(file) % isrow('') returns false, do this check first
    return;
elseif size(file,1)>1
    error('MATLAB:fileparts:MustBeChar', 'Input must be a row vector of characters.');
end

if ispc
    ind = find(file == '/'|file == '\', 1, 'last');
    if isempty(ind)
        ind = find(file == ':', 1, 'last');
        if ~isempty(ind)       
            pathstr = file(1:ind);
        end
    else
        if ind == 2 && (file(1) == '\' || file(1) == '/')
            %special case for UNC server
            pathstr =  file;
            ind = length(file);
        else 
            pathstr = file(1:ind-1);
        end
    end
    if isempty(ind)       
        name = file;
    else
        if ~isempty(pathstr) && pathstr(end)==':' && ...
                (length(pathstr)>2 || (length(file) >=3 && file(3) == '\'))
                %don't append to D: like which is volume path on windows
            pathstr = [pathstr '\'];
        elseif isempty(deblank(pathstr))
            pathstr = '\';
        end
        name = file(ind+1:end);
    end
else    % UNIX
    ind = find(file == '/', 1, 'last');
    if isempty(ind)
        name = file;
    else
        pathstr = file(1:ind-1); 

        % Do not forget to add filesep when in the root filesystem
        if isempty(deblank(pathstr))
            pathstr = '/';
        end
        name = file(ind+1:end);
    end
end

if isempty(name)
    return;
end

% Look for EXTENSION part
ind = find(name == '.', 1, 'last');

if isempty(ind)
    return;
else
    ext = name(ind:end);
    name(ind:end) = [];
end
