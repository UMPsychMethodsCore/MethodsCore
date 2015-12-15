function result = mc_Usage(str,funcFolder)
%
% Input:
%   str - message to be printed in text file
%   funcFolder - name of function folder
%

% Output: 
%   result - true if successful, false if not.
% 

global mcRoot;

result = false;

if isempty(mcRoot)
    temp = mfilename('fullpath');
    [mcRoot fileName ext] = fileparts(temp);
end

hostName = 'NotUnix';
userName = 'NotUnix';

if isunix
    hostName = getenv('HOSTNAME');
    userName = getenv('USER');
end

% create usage folder and change permissions
OutputDir = mcRoot;
CreateDirs = {'.Usage', hostName, datestr(date, 'yyyy_mm'), funcFolder};
for i = 1:size(CreateDirs, 2)
    OutputDir = fullfile(OutputDir, CreateDirs{i});
    if exist(OutputDir, 'dir') ~= 7
        [Success Mes Mid] = mkdir(OutputDir);
        if ~Success
            fprintf(1, 'Unable to make dir %s\n', OutputDir);
            return;
        end
        fileattrib(OutputDir, '+w +x', 'o g');
    end
end

fileDate = datestr(clock,'yymmdd_HH_MM_SS');
outputfile = [fileDate '_' userName '_' hostName];
fid = fopen(fullfile(OutputDir,outputfile),'a+');
if fid == -1; return; end;

result = true;

fprintf(fid,str);
fclose(fid);

return
