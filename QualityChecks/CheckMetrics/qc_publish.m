if exist('results.mat','file') ~= 2
    ermsg = sprintf('FATAL ERROR: results.mat file does not exist.\n * * * A B O R T I N G * * *\n');
    error(ermsg);
end

load('results.mat');
if exist('QC_metrics','var') ~= 1
    ermsg = sprintf('FATAL ERROR: results.mat does not contain ''Out''\n * * * A B O R T I N G * * *\n');
    error(ermsg);
end

% Assume Out is correct structure for now
qc_report(QC_metrics);
