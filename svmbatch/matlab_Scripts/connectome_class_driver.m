%% Template part

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are the same between Preprocessing and First level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Paired mode. Set this to 1 if your data is organized in sequential
%%% pairs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pairedSVM=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Path where your images are located
%
%  Variables you can use in your template are:
%       Exp = path to your experiment directory
%       iSubject = index for subject
%       Subject = name of subject from SubjDir (using iSubject as index of row)
%       iRun = index of run (listed in Column 3 of SubjDir)
%       Run = name of run from RunDir (using iRun as index of row)
%        * = wildcard (can only be placed in final part of template)
% Examples:
% ImageTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/';
% ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ConnTemplate = '[Exp]/FirstLevel/[Subject]/MSIT/HRF/FixDur/TBTGrid/TBTGrid_corr.mat';
% ConnTemplate = '[Exp]/FirstLevel/[Subject]/12mmGrid_19/12mmGrid_19_corr.mat';

ROITemplate = '[Exp]/FirstLevel/[Subject]/MSIT/HRF/FixDur/TBTGrid/TBTGrid_parameters.mat';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A list of run folders where the script can find the images to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = {
	'run_01/';

};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% How many features of each LOOCV iteration should be retained after
%%% pruning?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nFeatPrune = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {

'5001/Tx1',+1;
'5001/Tx2',-1;
% '5002/Tx1',+1;
% '5002/Tx2',-1;
% '5003/Tx1',+1;
% '5003/Tx2',-1;
'5004/Tx1',+1;
'5004/Tx2',-1;
'5005/Tx1',+1;
'5005/Tx2',-1;
'5010/Tx1',+1;
'5010/Tx2',-1;
'5012/Tx1',+1;
'5012/Tx2',-1;
'5014/Tx1',+1;
'5014/Tx2',-1;
'5015/Tx1',+1;
'5015/Tx2',-1;
'5016/Tx1',+1;
'5016/Tx2',-1;
'5017/Tx1',+1;
'5017/Tx2',-1;
'5018/Tx1',+1;
'5018/Tx2',-1;
'5019/Tx1',+1;
'5019/Tx2',-1;
'5020/Tx1',+1;
'5020/Tx2',-1;
'5021/Tx1',+1;
'5021/Tx2',-1;
'5023/Tx1',+1;
'5023/Tx2',-1;
'5024/Tx1',+1;
'5024/Tx2',-1;
'5025/Tx1',+1;
'5025/Tx2',-1;
'5026/Tx1',+1;
'5026/Tx2',-1;
'5028/Tx1',+1;
'5028/Tx2',-1;
'5029/Tx1',+1;
'5029/Tx2',-1;
'5031/Tx1',+1;
'5031/Tx2',-1;
'5032/Tx1',+1;
'5032/Tx2',-1;
'5034/Tx1',+1;
'5034/Tx2',-1;
'5035/Tx1',+1;
'5035/Tx2',-1;
'5036/Tx1',+1;
'5036/Tx2',-1;
'5037/Tx1',+1;
'5037/Tx2',-1;
'5038/Tx1',+1;
'5038/Tx2',-1;
'5039/Tx1',+1;
'5039/Tx2',-1;
'5040/Tx1',+1;
'5040/Tx2',-1;
'5041/Tx1',+1;
'5041/Tx2',-1;
'5042/Tx1',+1;
'5042/Tx2',-1;

 

       };

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'FirstLevel'))
addpath(fullfile(mcRoot,'spm8'))
addpath(genpath(fullfile(mcRoot,'svmbatch')))


%% Central Part

conPathTemplate.Template = ConnTemplate;
conPathTemplate.mode='check';


%% Loop 1 to figure out valid connection points

nSubs=size(SubjDir,1);

for iSub=1:size(SubjDir,1)

    Subject = SubjDir{iSub,1};
    conPath=mc_GenPath(conPathTemplate);
    conmat=load(conPath);
    rmat=conmat.rMatrix;
    if iSub==1
        cleanconMat=ones(size(rmat));
        nfeat=size(rmat(:));
    end
    cleanconMat(isnan(rmat) | isinf(rmat) | rmat==0) = 0; %For all indices in rmat that are NaN, zero out cleanconMat
end

%% Loop 2 to write out flattened results


superlabel=zeros(nSubs,1);

for iSub=1:size(SubjDir,1)
    Subject = SubjDir{iSub,1};
    Example=SubjDir{iSub,2};
    conPath=mc_GenPath(conPathTemplate);
    conmat=load(conPath);
    rmat=conmat.rMatrix;
    %     sprintf('Subject %s has variance %s',Subject,var(rmat(~isnan(rmat))))
    if iSub==1
        superflatmat=zeros(nSubs,size(connectivity_grid_flatten(rmat,cleanconMat),2));
    end
    superflatmat(iSub,:)=connectivity_grid_flatten(rmat, cleanconMat);
    superlabel(iSub,1)=Example;

end

%% Organize your paired data, and deal with pruning and stuff

if pairedSVM==1

    superflatmat_p1=superflatmat(1:2:end,:)-superflatmat(2:2:end,:);
    superflatmat_p2=superflatmat(2:2:end,:)-superflatmat(1:2:end,:);

    superflatmat_paired(1:2:size(superflatmat,1),:) = superflatmat_p1;
    superflatmat_paired(2:2:size(superflatmat,1),:) = superflatmat_p2;

    pruneLOO=zeros(size(superflatmat,1)/2,size(superflatmat,2));

    models_train={};
    models_test=[];
    
    
    LOOCV_fractions=zeros(size(superflatmat,1)/2,size(superflatmat,2));
    LOOCV_pruning=zeros(size(superflatmat,1)/2,size(superflatmat,2));
    
    for iL=1:(size(superflatmat,1)/2)
        fprintf(1,'\nCurrently running LOOCV on subject %.0f of %.0f.\n',iL,size(superflatmat,1)/2)
        
        subjects=[1:(iL-1) (iL+1):30];
        indices=sort([subjects*2 subjects*2-1]);



        train=superflatmat_paired(indices,:);
        trainlabels=repmat([1; -1],size(train,1)/2,1);

        % Identify the fraction of features that are greater than zero, or
        % less than zero (whichever is larger). This indicates a consistent
        % signed direction. Do it just for one pair, since the second pair
        % is the first * -1
        
        fractions=max(  [sum(train(1:2:end,:)>0,1)/size(train(1:2:end,:),1) ;sum(train(1:2:end,:)<0,1)/size(train(1:2:end,:),1)]  );
        
        LOOCV_fractions(iL,:) = fractions;
        
        
        
        LOOCV_fractions(iL,:) = fractions;
        
        [d pruneID] = sort(fractions);
               
        pruneID=pruneID((end-(nFeatPrune-1)):end);
        
        LOOCV_pruning(iL,pruneID) = 1;
        
%         prune=ttest(train(1:2:end,:),0,.00001);
        %% Add tau-b support here
%         prune(isnan(prune))=0;
%         pruneLOO(iL,:)=prune;

        train=train(:,pruneID);
        test=superflatmat_paired([iL*2-1 iL*2],pruneID);

        models_train{iL}=svmlearn(train,trainlabels,'-o 100 -x 0');

        models_test(iL)=svmclassify(test,[1 ; -1],models_train{iL});


    end
     fprintf(1,'\nLOOCV Done\n\n');
end

%% Report performance

fprintf(1,'\nLOOCV performance is %.0f out of %.0f, for %.0f%% accuracy.\n\n',...
    size(models_test,2)-sum(models_test),...
    size(models_test,2),...
    100*(size(models_test,2)-sum(models_test))/size(models_test,2));



%% Visualization Write-out

%% Load ROIs file from representative subject

roiPathTemplate.Template = ROITemplate;
roiPathTemplate.mode='check';

roiPath=mc_GenPath(roiPathTemplate);
roimat=load(roiPath);
roiMNI=roimat.parameters.rois.mni.coordinates;
nROI=size(roiMNI,1);

%% Calc Discriminative Power of Edges

%ID the consensus implicated edges
LOOCV_consensus=all(LOOCV_pruning,1);

%Calc Mean discriminative power for all features
LOOCV_discrimpower=mean(LOOCV_fractions);

%Zero out mean discriminative power for all features not in consensus set
LOOCV_discrimpower_consensus=LOOCV_discrimpower;
LOOCV_discrimpower_consensus(~logical(LOOCV_consensus))=0;

%% Reconstruct Consensus Discrim Power into Edges File

% Identify linear indices of elements that survive flattening
connectomeIDx=zeros(nROI);
connectomeIDx(:)=1:(nROI^2);
connectomeIDx_flat = connectivity_grid_flatten(connectomeIDx,ones(nROI));

% Build square matrix, and use linear indices above to insert discrim power
LOOCV_discrimpower_consensus_square = zeros(nROI);
LOOCV_discrimpower_consensus_square(connectomeIDx_flat) = LOOCV_discrimpower_consensus;
LOOCV_discrimpower_consensus_square_binarized = LOOCV_discrimpower_consensus_square;
LOOCV_discrimpower_consensus_square_binarized(LOOCV_discrimpower_consensus_square_binarized~=0) = 1 ;

% Write out the edge file
dlmwrite('edges.edge',LOOCV_discrimpower_consensus_square,'\t');

%% Build the ROI list

% Add color labels for roiMNI object. For now, just set to 1 until we have
% a network atlas
roiMNI(:,4) = 1 ;

% Count how many times ROIs are touched by an edge, append to roiMNI object
roi_RegionWeights=sum(LOOCV_discrimpower_consensus_square_binarized);
roiMNI(:,5)=roi_RegionWeights;

% Write out nodes file
dlmwrite('nodes.node',roiMNI,'\t');

% Apend tab and - to indicate no label, for now...
! sed -i 's/$/\t-/' nodes.node
