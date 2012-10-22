function icatb_batch_file_run(inputFiles)
spm_get_defaults('cmdline',true);
load UserSettings.mat;

%% Batch file for running group ICA
%
% Inputs:
% inputFiles - location of the inputFiles (fullfile path incase file is not
% on MATLAB search path)
%
%

if (~exist('inputFiles', 'var'))
    inputFiles = icatb_selectEntry('typeEntity', 'file', 'typeSelection', 'multiple', 'filter', '*.m', 'title', 'Select input batch file/files ...');
    drawnow;
end

if (isempty(inputFiles))
    error('Input M file is not selected for batch analysis');
end

%% Turn off finite warning
warning('off', 'MATLAB:FINITE:obsoleteFunction');

%% Delete previous figures
%icatb_delete_gui({'groupica', 'eegift', 'gift'});

%% Check version and run this to display pushbuttons with right background
% on Matlab version 14 and later
try
    % add this statement to fix the button color
    feature('JavaFigures', 0);
catch
end

%% Open Matlab server
icatb_openMatlabServer;

inputFiles = cellstr(inputFiles);

inputFiles = formFullPaths(inputFiles);

for nFile = 1:length(inputFiles)
    
    %% Set up ICA
    param_file = icatb_setup_analysis(inputFiles{nFile});
    
    load(param_file);
    
    %% Run Analysis (All steps)
    icatb_runAnalysis(sesInfo, 1);
    
    clear sesInfo;
    
end

%% added for template matching
if doTemplateMatching
    %% unzip files
    nSubj = size(SubjDir,1);
    
    OutPath = mc_GenPath(OutTemplate);
    
    %%%%%%%%%%%%%%% component
    % all session info
    compfileinfo(nSess+1) = dir ([OutPath, '/*mean_component_ica_s_all*zip*']);
    if size(compfileinfo,1)
        compfile{nSess+1} = fullfile(OutPath,compfileinfo(nSess+1).name);
    else
        fprintf('cannot find all session group components info...\n');
    end
    [path, name, ext] = fileparts(compfile{nSess+1});
    comppath{nSess+1}.Template = [path,'/',name];   comppath{nSess+1}.mode = 'makedir';
    comppath{nSess+1} = mc_GenPath(comppath{nSess+1});
    unzip(compfile{nSess+1}, comppath{nSess+1});
    
    % define component file needs to be extracted; 1xnSess+1: the last one is
    % the concatenated group info
    for iSess = 1:nSess
        for iSubj = 1:nSubj
        compfileinfo= dir ([OutPath, '/*sub',num2strN(iSubj,3),'_component_ica_s',num2str(iSess),'*zip*']);
        if size(compfileinfo,1)
            compfile{iSess}{iSubj} = fullfile(OutPath,compfileinfo.name);
        else
            fprintf('cannot find group components info of session %d, subject %d...\n', iSess, iSubj);
        end
        
        % unzip compfile
        [path, name, ext] = fileparts(compfile{iSess}{iSubj});
        comppath{iSess}{iSubj}.Template = [path,'/',name];   comppath{iSess}{iSubj}.mode = 'makedir';
        comppath{iSess}{iSubj} = mc_GenPath(comppath{iSess}{iSubj});
        unzip(compfile{iSess}{iSubj}, comppath{iSess}{iSubj});
        end
    end
    
    
    %%%%%%%%%%%%%%%%% single subject time course
    % is a cell array contains the path contains the swra*.nii
    % of each subject's single session (nSubj x nSess)
    

    for iSubj = 1: nSubj
        for iSess = 1: nSess
            Subj = SubjDir{iSubj,1};
            Run = RunDir{iSess, 1};
            subjpath{iSubj,iSess} = mc_GenPath(InTemplate);
        end
    end
    
    %% calculate template matching fit index
    compPath = comppath;    % 1xnSess cell array contains group component info for each session
    subjPath = subjpath;    % nSubjxnSess cell array contains back projected component info for each subj and each session
    NWTemplatePath = mc_GenPath(NWTemplate);        %expand network template path
    
    mc_template_matching(TempMatchAlg, NWTemplatePath, compPath, subjPath, OutPath);
    
    % remove the unzipped file used before
    for irm = 1:size(compPath,2)
        if irm ~= size(compPath,2)
            for j = 1: nSubj
                cmd = ['rm -r ', compPath{irm}{j}];
            end
        else
            cmd = ['rm -r ', compPath{irm}];
        end
        system(cmd);
    end
    
    %% write out component summary file
    if TempMatchAlg == 2
        mc_components_summary(NWTemplatePath, OutPath, nSess, nSubj, numOfPC2);
    end
end


function inputFiles = formFullPaths(inputFiles)
%% Form full paths

oldDir = pwd;

for nFile = 1:length(inputFiles)
    
    cF = inputFiles{nFile};
    [p, fN, extn] = fileparts(deblank(cF));
    
    if (isempty(p))
        p = fileparts(which(cF));
        if (isempty(p))
            error('Error:InputFile', 'File %s doesn''t exist\n', cF);
        end
    end
    
    cd(p);
    
    inputFiles{nFile} = fullfile(pwd, [fN, extn]);
    
    if ~exist ('oldDir', 'dir') 
        mkdir(oldDir)
    end
    cd(oldDir);
    
end


