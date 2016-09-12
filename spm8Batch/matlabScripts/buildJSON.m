function [JSONFile] = buildJSON(OpType, VerHash, CommandLine, ScriptName, InFile, OutFile, varargin)

SubjectRun = '';
InFilePorts = 1:size(InFile,1);
OutFilePorts = 1:size(OutFile,1);
if (nargin>0)
    SubjectRun = varargin{1}
    if (nargin>1)
        InFilePorts = varargin{2}
        if (nargin>2)
            OutFilePorts = varargin{3}
        end
    end
end

JSONFile = [ScriptName '_' SubjectRun '.json'];
fid = fopen(JSONFile,'w');
if (fid<1)
    %error opening JSONFile
    mc_Error('Unable to create JSON file %s for database logging',JSONFile);
end

fprintf(fid,'{"OpType":"%s",\n"VerHash":"%s",\n',OpType,VerHash);

fprintf(fid,'"InFile":[\n');
jsonFiles(InFile,fid,InFilePorts);
fprintf(fid,'],\n');

fprintf(fid,'"OutFile":[\n');
jsonFiles(OutFile,fid,OutFilePorts);
fprintf(fid,']\n}\n');
fclose(fid);
