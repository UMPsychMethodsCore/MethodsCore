% Least Squares Specific Trial x Trial Beta Method
% Ref: Mumford et al. Deconvolving BOLD activation in event-related designs
% for multivoxel pattern classification analyses. NeuroImage (2012) vol. 59
% (3) pp. 2636-2643
%

% loop over trials in task and build design matrix including first trial as
% one condition and all other trials as a second condition.  Build design 
% matrix and estimate SPM model, then save only the first beta image.
% Iterate over trials, each time including the next trial as one condition
% and all other trials as a seperate condition and saving the appropriate
% beta.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code to create logfile name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogDirectory = mc_GenPath(struct('Template',LogTemplate,'mode','makedir'));
result = mc_Logger('setup',LogDirectory);
if (~result)
    %error with setting up logging
    mc_Error('There was an error creating your logfiles.\nDo you have permission to write to %s?',LogDirectory);
end

global mcLog;
tempLog = mcLog;

%split subject list into chunks
NumSubj = size(SubjDir,1);
if (NumProcesses > 4) 
    NumProcesses = 4;
end

SubjPerChunk = floor(NumSubj / NumProcesses);
SubjDirTotal = SubjDir;
for iChunk = 1:NumProcesses
    %save each piece of SubjDir into a chunkN.mat file in temp location
    offset = (iChunk - 1) * SubjPerChunk;
    tempSubjDir = [];
    if (iChunk < NumProcesses)
        for iSubject = 1+offset:SubjPerChunk+offset
            tempSubjDir{end+1,1} = SubjDir{iSubject,1};
            tempSubjDir{end,2} = SubjDir{iSubject,2};
            tempSubjDir{end,3} = SubjDir{iSubject,3};
            tempSubjDir{end,4} = SubjDir{iSubject,4};
        end
    else
        for iSubject = 1+offset:size(SubjDir,1)
            tempSubjDir{end+1,1} = SubjDir{iSubject,1};
            tempSubjDir{end,2} = SubjDir{iSubject,2};
            tempSubjDir{end,3} = SubjDir{iSubject,3};
            tempSubjDir{end,4} = SubjDir{iSubject,4};
        end
    end
    SubjDir = tempSubjDir;
    chunkFile = fullfile(mc_GenPath(Exp),['chunk_' num2str(iChunk) '.mat']);
    [fd fn fe] = fileparts(mcLog);
    mcLog = fullfile(fd,[fn '_chunk' num2str(iChunk) fe]);
    save(chunkFile);
    mcLog = tempLog;
    SubjDir = SubjDirTotal;
end

%send a system call to start matlab, load a chunk file, and call
%lss_batch_chunk

%spawn NumProcesses-1 other matlab processes
for iChunk = 1:NumProcesses-1
    chunkFile = fullfile(mc_GenPath(Exp),['chunk_' num2str(iChunk) '.mat']);
    systemcall = sprintf('matlab -nosplash -nodesktop -r "addpath(fullfile(''%s'',''matlabScripts''));,addpath(fullfile(''%s'',''LSS''));,addpath(fullfile(''%s'',''SPM/SPM8/spm8_with_R4667''));,lss_batch_chunk(''%s'');,quit;" &',mcRoot,mcRoot,mcRoot,chunkFile);
    [status result] = system(systemcall);
end
%now the last one in this matlab. This one will always be equal to
%or greater in number of subjects to the previous ones.
iChunk = NumProcesses;
chunkFile = fullfile(mc_GenPath(Exp),['chunk_' num2str(iChunk) '.mat']);
lss_batch_chunk(chunkFile);



