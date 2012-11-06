function qc_WriteScanCsv(csvName,loc,tp)
%
% Input:
%   csvName - full path name to output csv file
%   loc   - scans > threshold value
%   tp    - number of timepoints
%

fid = fopen(csvName,'w');
if fid == -1
    fprintf(1,'WARNING: Cannot write %s file.\n',csvName);
    fprintf(1,'         Please check scanReport.pdf for outliers.\n');
    return;
end

numBad = 2*length(loc);
allLoc = zeros(numBad,1);
allLoc(1:2:end) = loc - 1;
allLoc(2:2:end) = loc;
allLoc = unique(allLoc);
numBad = length(allLoc);
output = zeros(tp,numBad);
ind = sub2ind(size(output),allLoc',1:length(allLoc));
output(ind) = 1;

str = '';
for i = allLoc'
    str = strcat(str,sprintf('scan%d,',i));
end

fprintf(fid,'%s\n',str(1:end-1));

for i = 1:tp
    str = sprintf('%d,',output(i,:));
    fprintf(fid,'%s\n',str(1:end-1));
end
fclose(fid);