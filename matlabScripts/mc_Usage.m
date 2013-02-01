function mc_Usage(str,funcFolder)
%
% Input:
%   str - message to be printed in text file
%   funcFolder - name of function folder
%

global mcRoot;
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

folderDate = datestr(date,'yyyy_mm');
outputDir = fullfile(mcRoot,'.Usage',hostName,folderDate,funcFolder);
if exist(outputDir,'dir') ~= 7
    mkdir(outputDir);
    fileattrib(outputDir,'+w','o');
end

fileDate = datestr(clock,'yymmdd_HH_MM_SS');
outputfile = [fileDate '_' userName '_' hostName];
fid = fopen(fullfile(outputDir,outputfile),'w');
if fid == -1; return; end;
fprintf(fid,str);
fclose(fid);