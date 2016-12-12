function [outstring, status] = jsonFiles(Files,varargin)

outstring = [];
status = 0;
fid = -1;
if (nargin>0)
    fid = varargin{1};
end

if (nargin>1)
    Portkeys = varargin{2};
else
    Portkeys = [1:size(Files,1)];
end

for iFile = 1:size(Files,1)
    [sss ooo] = system(['sha256sum ' Files{iFile}]);
    oooo = strsplit(ooo);
    hash = oooo{1};
    outstring{iFile} = sprintf('{"Hash":"%s",\n"Path":"%s",\n"PortKey":"%d"}',hash,Files{iFile},Portkeys(iFile));  
    if (iFile < size(Files,1))
        outstring{iFile} = [outstring{iFile} ','];
    end
    outstring{iFile} = sprintf('%s\n',outstring{iFile});
    if (fid>0)
        fprintf(fid,'%s',outstring{iFile}); %need to error check here
    end
end
