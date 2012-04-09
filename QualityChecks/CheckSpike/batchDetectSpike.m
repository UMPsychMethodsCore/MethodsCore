%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
%  batchDetectSpike
% 
%  A routine that calculates the AJKZ score values for a set of 4D images.
%  The final result is expected to be used to create a distribution of the
%  values.
% 
%   function results = dSpike(TextFile,DetrendOpt)
% 
%   To Make this work you need to provide the following input:
% 
%      TextFile   = name of text file where each line is an image
%      DetrendOpt = polynomial order used in spm_detrend (OPTIONAL)
% 
%   Output
%   
%      results   
%        = -1 if failure
%               OR
%        = an Nx2 cell array
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function results = batchDetectSpike(TextFile,DetrendOpt)

results = -1;
fid     = fopen(TextFile,'r');

if fid == -1
    fprintf('Invalid textfile: %s\n',TextFile);
    fprintf('   * * * A B O R T I N G * * *\n');
    results = -1;
end

