function [fnames, dnames] = wfu_find_files(regExpression, searchDirectories,recurseDepth, options )
%
% PURPOSE:   Finds all files matching the regular expression in the specified 
%            directory and subdirectories (recursive). Returns a cell array
%            with the fully specified file names.
%
% CATEGORY: Utility
%
% INPUTS: regExpression - A regular expression. For more information search
%                         for Regular Expression in Matlab help.
%
%         searchDirectories - List of directories to search. Default is
%                             current directory.
%
%         recurseDepth - Depth of recursive search.  If the depth flag is
%                        0 or false then only current directory is searched. If flag is true
%                        then directories up to 256 deep are searched. If the recurseDepth
%                        is a positive number than directories are searched to that
%                        directory depth.
%         
% KEYWORD PARAMETERS:
%
%         options.displayFiles       - Displays a list of files found in order.
%
%         options.displayDirectories - Displays a list of directories
%                                      where files were found that matched 
%                                      the regular expression.
%
% OUTPUTS: 
%
%    fnames - List of Files that match regular expression.
%    dnames - List of Directories containing files that match the regular
%             expression.
%
% EXAMPLE:
%
%    files = wfu_find_files('.*mat')
%       searches in the current directory for files that match the regular
%       expression.
%
%    files = findfiles( 'P\d{5}$', [], 2)
%       searches in the current directory and two levels deep for files that
%       match the regular expression (end in P followed by 5 numbers).
%

% $Id: wfu_find_files.m,v 1.1 2009/10/09 17:11:35 bwagner Exp $

% $Log: wfu_find_files.m,v $
% Revision 1.1  2009/10/09 17:11:35  bwagner
% PickAtlas Release Pre-Alpha 1
%
% Revision 1.10  2007/03/24 09:21:29  bkraft
% Modified these files to support searching for directories that match a regular expression.
%
% Revision 1.9  2006/10/03 20:58:30  bkraft
% Added the ability to display search progress via an option.
%
% Revision 1.8  2006/01/27 14:41:53  bkraft
% Added some logic to control the recursion depth better.
%
% Revision 1.6  2005/10/11 12:39:30  bkraft
% Fixed bug in specifying the recursion depth correctly.  Added better comments.
%
% Revision 1.5  2005/10/06 14:35:08  bkraft
% Added functionality to display directories.
%
% Revision 1.4  2005/07/12 16:16:15  bkraft
% Changed default of listing directories to false.
%
% Revision 1.3  2005/04/22 19:43:39  bkraft
% Recursion limit incorrectly set. The bug was fixed so recursion by default is now off.
%
% Revision 1.2  2004/12/06 03:01:48  bkraft
% Allow the first input argument to contain a list of directories to search.
%
% Revision 1.1  2004/11/03 14:25:07  bkraft
% wfu_find_files has been moved from the WFU_geToolbox to here so that it can be used by the entire BPM project
%
% Revision 1.1.1.1  2004/11/02 18:09:06  bkraft
% Initial BPM import
%
% Revision 1.1  2004/11/02 18:02:10  bkraft
% Added the ability to return a list of directories.
%
% Revision 1.2  2004/10/25 17:24:05  bkraft
% Updated merge of files for 11.0 platform.  This working directory has been tested 
% to work after a checkout. All dependecies have been resolved.
%
% Revision 1.1  2004/10/25 16:38:51  bkraft
% Added a function to find the pfiles in a current directory and return a cell list.
%

%
% Call wfu_find_files_recursive to generate list
%

%
% Set options
%

recursionMaximumDepth = 256;

defaultOptions = struct('recursionDepth',0,'recursionMaximumDepth',recursionMaximumDepth, ...
                        'displayFiles', true, 'displayDirectories', false, ...
                        'displayProgress', false, 'findDirectories', false);

if nargin < 4	
    options = [];
end

options = wfu_set_function_options(options,defaultOptions);

%
% Set input parameters if they are not defined
%

startingDirectory = cd;

if nargin < 1 || isempty(regExpression)
    regExpression = '\w+';
end

if nargin < 2 || isempty(searchDirectories)
    searchDirectories = startingDirectory;
end

if nargin < 3 || isempty(recurseDepth) || (recurseDepth == false)
    recurseDepth = 0;
end

if islogical(recurseDepth) && (recurseDepth == false)
    options.recursionMaximumDepth = 0;
end

if islogical(recurseDepth) && (recurseDepth == true)
    options.recursionMaximumDepth = recursionMaximumDepth;    
end

if isnumeric(recurseDepth) && recurseDepth >= 0
    options.recursionMaximumDepth = recurseDepth;
end



if ~iscell(searchDirectories)
    searchDirectories = {searchDirectories};
end

%
% Loop over all directories
%

dnames = {};
fnames = {};

for ii=1:length(searchDirectories)

    options.recursionDepth = 0;
    
    [recursiveFileNames, recursiveDirectoryNames] = wfu_find_files_recursive(regExpression,searchDirectories{ii}, options );

    fnames = [fnames recursiveFileNames];       %#ok<AGROW>
    dnames = [dnames recursiveDirectoryNames];  %#ok<AGROW>
    
end


%
% Display files
%

if options.displayFiles

    nStartingDirectory = length(startingDirectory);
    
    disp(' ');
    disp('Files:');
    disp(' ');
    
    for ii=1:length(fnames)
        tmp = char(fnames{ii});
        if length(tmp) > 80            
            tmp = strcat('.', tmp(nStartingDirectory+1:end));
        end
        
        disp(sprintf('%2d) %s', ii, tmp));
    end

    disp(' ');
end

%
% Display Directories
%

if options.displayDirectories

    disp(' ');
    disp('Directories:');
    disp(' ');
    
    for i=1:length(dnames)
        disp([ '   ' num2str(i) ') ' char(dnames{i}) ]);
    end

    disp(' ');
end


% Return to starting directory
cd(startingDirectory);




%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


function [fnames, dnames] = wfu_find_files_recursive(regExpression,directory, options )

%
% Set options
%
defaultOptions = struct('recursionDepth',0,'recursionMaximumDepth',256);

if nargin < 3	
    options = [];
end

options = wfu_set_function_options(options,defaultOptions);

%
% Set input parameters if they are not defined
%

oldDirectory = cd;

if nargin < 2 || isempty(directory)
    directory = cd;
end

%
% Perform search
%

d = dir(directory);

dnames = {};
fnames = {};
numMatches = 0;
numDirectoryMatches = 0;

for i=1:length(d)
    % look for occurences of regular expression in the file name
    expressionIndices = regexp(d(i).name, regExpression,'ONCE');

    % if the file is not a directory, and the file has at least one occurence
    if ( (~d(i).isdir || ((d(i).isdir)&&options.findDirectories)) && ~isempty(expressionIndices))

        numMatches = numMatches + 1;

        fullFileName = fullfile( wfu_get_full_path(directory),d(i).name);
        fileDirectory = fileparts( fullFileName );
        fnames{numMatches} = fullFileName;

        if numMatches == 1
            dnames{1} = fileDirectory;
            numDirectoryMatches = 1;
        else
            if ~strcmp(fileDirectory,dnames{numDirectoryMatches})
                numDirectoryMatches = numDirectoryMatches + 1;
                dnames{numDirectoryMatches} = fileDirectory;
            end
        end

        % otherwise, descend directories appropriately.
        % note that this could result in a recursion limit error if it tries to
        % follow symbolic links that loop back on themselves...

    elseif  (options.recursionMaximumDepth > options.recursionDepth) && d(i).isdir && ~strcmp(d(i).name,'.') && ~strcmp(d(i).name,'..')

        if options.displayProgress == true
           display(sprintf('\t%d) Searching %s ...',  options.recursionDepth, d(i).name));
        end
        
        options.recursionDepth = options.recursionDepth + 1;

        %
        % TODO:  There should be a better way of reporting the recursion
        % depth
        %
        if options.recursionDepth > options.recursionMaximumDepth
            % warning('wfu_find_files: Recursion limit reached maximum recursion depth');
        else

            [ recursiveFileNames recursiveDirectoryNames] = ...
                wfu_find_files_recursive(regExpression,fullfile(directory,d(i).name), options);

            options.recursionDepth = options.recursionDepth-1;  %Reset recursion depth

            fnames = [fnames recursiveFileNames];
            dnames = [dnames recursiveDirectoryNames];

            numMatches = length(fnames);
            numDirectoryMatches = length(dnames);
        end
    end
end

