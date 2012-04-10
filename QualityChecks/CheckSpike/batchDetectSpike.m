%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
%  batchDetectSpike
% 
%  A routine that calculates the AJKZ score values for a set of 4D images.
%  The final result is expected to be used to create a distribution of the
%  values.
% 
%  function results = dSpike(TextFile,DetrendOpt)
% 
%  To Make this work you need to provide the following input:
% 
%    TextFile   = name of text file where each line is an image
%    DetrendOpt = polynomial order used in spm_detrend (OPTIONAL)
% 
%  Output
%   
%    success = seconds for operation is success; otherwise, -1
%    data    = Nx2 cell array where column1:ImageName, column2:Results
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function [success data only_data] = batchDetectSpike(TextFile,DetrendOpt)

success = -1;
data    = [];
fid     = fopen(TextFile,'r');
tic;

if fid == -1
    fprintf('Invalid textfile: %s\n',TextFile);
    fprintf('   * * * A B O R T I N G * * *\n');
    return;
end

images = textscan(fid,'%s');
images = images{1};
fclose(fid);

data = cell( size(images,1),2 );
totalSlices = 0;
for i=1:size(images,1)
    [SpikeSuccess results] = dSpike(images{i,:},DetrendOpt);
    
    if SpikeSuccess == -1
        data = [];
        return;
    end
    
    data{i,2} = results;
    totalSlices = totalSlices + numel(results); 
end

only_data  = zeros(totalSlices,1);
BeginIndex = 1;
for i=1:size(data,1)
    EndIndex = numel(data{i,2}) + BeginIndex - 1;
    only_data(BeginIndex:EndIndex) = data{i,2}(:);
    BeginIndex = EndIndex + 1;
end

success = toc;