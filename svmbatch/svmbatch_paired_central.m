function out = svmbatch_paired_central(Opt);
%% Central Part

conPathTemplate.Template = Opt.DataTemplate;
conPathTemplate.mode='check';

%% Set defaults

Opt = mc_svmbatchParseDefaults(Opt);

%% Confirm that you are running on an allowed host

mc_svmbatchCheckHost;


%% Read and ID Valid Features (Same feature set will be used across all
%% contrasts)

fprintf('\nLoading Data...');
nSubs=size(SubjDir,1);

switch DataType
    case '3D'
        superflatmat_grouped = load_3D();
        
    case 'Matrix'
        [superflatmat_grouped savail] = mc_load_connectomes_paired(Opt.SubjDir,Opt.DataTemplate,Opt.RunDir,Opt.matrixtype);
        superflatmat_grouped = mc_connectome_clean(superflatmat_grouped);
end

fprintf('Done!\n');

if ztrans == 1
    superflatmat_grouped = mc_FisherZ(superflatmat_grouped);
end

[superflatmat_paired labels SubIDS ContrastAvail] = mc_calc_deltas_paired(data, savail, Opt.pairedContrast);


%% Do LOOCV pruning, etc

models_train={};
models_test={};

% Prune based on contrast availability

% correct for nuisance regressors if they exist
if isfield(Opt,'DoNuisanceCorrection') && DoNuisanceCorrection==1
    superflatmat_paired = NuisanceCorrect();
end

superflatmat_p1 = superflatmat_paired(labels==1);
superflatmat_p2 = superflatmat_paired(labels==2);

nSubs = size(superflatmat_p1,1); % redefine nSubs in case some subjects were dropped

LOOCV_featurefitness = zeros(nSubs,nfeat);
LOOCV_pruning = zeros(nSubs,nfeat);


for iL=1:nSubs
    fprintf(1,'\nCurrently running LOOCV on subject %.0f of %.0f.\n',iL,nSubs)
    alltrue = logical(repmat(1,nSubs,1));
    allfalse = logical(repmat(0,nSubs,1));
    
    train_idx = alltrue;
    train_idx(iL) = 0;
    train_idx = [train_idx; train_idx];
    
    train=superflatmat_paired(train_idx,:);
    train_unpaired = superflatmat_unpaired(train_idx,:);
    trainlabels= labels(train_idx);
    
    test_idx = allfalse;
    test_idx(iL) = 0;
    
    
    test=superflatmat_paired([iL*2-1 iL*2],:);
    test_unpaired = superflatmat_unpaired([iL*2-1 iL*2],:);
    testlabels=repmat([1; -1],size(test,1)/2,1);
    
    [fitness prune trainPrune testPrune] = PruneData();
    LOOCV_featurefitness(iL,:) = fitness;
    LOOCV_prune(iL,:) = prune;
    
    if binarize == 1
        trainPrune = sign(trainPrune);
        testPrune = sign(testPrune);
    end
    
    out = mc_svmCV(Opt,trainPrune,trainlabels,testPrune,testlabels);
    
    
    models_train{iL} = out.modelTrain;
    models_test(iL) = out.modelTest;
    fprintf(1,'\nLOOCV performance thus far is %.0f out of %.0f.\n\n',...
        iL-sum(models_test),...
        iL);
    
    
end


%% Summarize performance over gridsearch


%% Save results to file
% Stash the setup parameters into the results structure
SVM_ConnectomeResults.SVMSetup = Opt;

% Store the model trained in each LOOCV fold
SVM_ConnectomeResults.models_train = models_train;

% Store the uncensored fractions (discrim power) from each LOOCV fold
SVM_ConnectomeResults.LOOCV_featurefitness = LOOCV_featurefitness;

% Store the binarized logic of which features were retained from each LOOCV fold
SVM_ConnectomeResults.LOOCV_pruning = LOOCV_pruning;

% Store the performance of LOOCV on each fold
SVM_ConnectomeResults.models_test = models_test;

% Prepare path for writing results file
OutputPathTemplate.Template= Opt.OutputTemplate ;
OutputPathTemplate.mode = 'makeparentdir' ;
OutputPathTemplate.suffix = 'SVMresults.mat';

OutputMatPath = mc_GenPath(OutputPathTemplate);

% Save SVM Parameters and Results
save(OutputMatPath,'SVM_ConnectomeResults');

% Use same directory to prepare to write out nodes file
OutputPathTemplate.suffix = 'nodes.node';

% Use same directory to prepare to write out edges file
OutputNodePath = mc_GenPath(OutputPathTemplate);

OutputPathTemplate.suffix = 'edges.edge';

OutputEdgePath = mc_GenPath(OutputPathTemplate);

%% Visualization Write-out
if (exist('Vizi','var') &&  Vizi==1)
    %% Load ROIs file from representative subject
    
    roiPathTemplate.Template = Opt.ROITemplate;
    roiPathTemplate.mode='check';
    
    roiPath=mc_GenPath(roiPathTemplate);
    roimat=load(roiPath);
    roiMNI=roimat.parameters.rois.mni.coordinates;
    
    for i=1:size(ContrastVec,1)
        
        OutputPathTemplate.suffix = [ContrastNames{i} '.node'];
        OutputNodePath = mc_GenPath(OutputPathTemplate);
        OutputPathTemplate.suffix = [ContrastNames{i} '.edge'];
        OutputEdgePath = mc_GenPath(OutputPathTemplate);
        
        mc_BNV_writer(OutputEdgePath,OutputNodePath,LOOCV_pruning{i},...
            LOOCV_featurefitness{i},roiMNI,nFeatPlot,...
            '/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr');
        
    end
end



    function [data nfeat] = load_3D();
        condNum = size(SubjDir{1,2},2);
        maskhdr = spm_vol(MaskPath);
        maskdata = spm_read_vols(maskhdr);
        maskidx = find(maskdata);
        nfeat = nnz(maskdata);
        data = zeros(nSubs,nfeat,condNum);
        condAvail = zeros(nSubs,condNum);
        
        for iSub=1:size(SubjDir,1) % loop over subjects
            Subject = SubjDir{iSub,1}; % loop over conditions. if data is available, stick it in array
            for iCond = 1:condNum
                curRunID = SubjDir{iSub,2}(iCond);
                if curRunID ~= 0
                    Run = RunDir{curRunID};
                    conPath=mc_GenPath(conPathTemplate);
                    chdr = spm_vol(conPath);
                    cvol = spm_read_vols(chdr);
                    data(iSub,:,iCond) = cvol(maskidx);
                    condAvail(iSub,iCond)=1;
                end % end if block
            end % end condition loop
        end
    end

    function [data nfeat] = load_matrix()
        unsprung=0; %counter to identify when you encounter the first valid case
        condNum = size(SubjDir{1,2},2);
        condAvail = zeros(nSubs,condNum);
        for iSub=1:size(SubjDir,1) % loop over
            Subject = SubjDir{iSub,1};
            for iCond = 1:condNum
                curRunID = SubjDir{iSub,2}(iCond);
                if curRunID ~= 0
                    Run = RunDir{curRunID};
                    conPath=mc_GenPath(conPathTemplate);
                    conmat=load(conPath);
                    rmat=conmat.rMatrix;
                    if ~exist('unsprung','var') || unsprung==0
                        censor_square=zeros(size(rmat));
                        nfeat=size(rmat(:));
                        unsprung=1;
                    end % end if block for initialization
                    condAvail(iSub,iCond)=1;
                end % end if block for condition availability
                censor_square(isnan(rmat) | isinf(rmat) | rmat==0) = 1; %For all indices in rmat that are NaN, zero out cleanconMat
            end % end loop over conditions
            
        end % end loop over subjects
        if (strcmp(matrixtype,'nodiag'))
            censor_square(logical(eye(size(censor_square)))) = 1;
        end
        
        if (strcmp(matrixtype,'upper'))
            censor_flat = mc_flatten_upper_triangle(censor_square);
        else
            censor_flat = reshape(censor_square,1,prod(size(censor_square)));
        end
        fprintf('Done\n');
        
        
        
        %% Read and flatten valid features
        
        fprintf('\nLooping over all files to flatten the matrices into one super matrix....');
        
        unsprung=0;
        
        % ID Number of Groups
        condNum = size(SubjDir{1,2},2);
        
        
        for iSub=1:size(SubjDir,1)
            Subject = SubjDir{iSub,1};
            for iCond = 1:condNum
                curRunID = SubjDir{iSub,2}(iCond);
                if curRunID ~= 0
                    Run = RunDir{curRunID};
                    conPath=mc_GenPath(conPathTemplate);
                    conmat=load(conPath);
                    rmat=conmat.rMatrix;
                    if ~exist('unsprung','var') || unsprung==0
                        superflatmat_grouped=zeros(nSubs,size(censor_flat,2),condNum);
                        unsprung=1;
                    end
                    
                    if (strcmp(matrixtype,'upper'))
                        superflatmat_grouped(iSub,:,iCond) = mc_flatten_upper_triangle(rmat);
                    else
                        superflatmat_grouped(iSub,:,iCond) = reshape(rmat,1,prod(size(rmat)));
                    end
                end
                
            end
        end
        
        %Zero out censored elements
        
        superflatmat_grouped(:,logical(censor_flat),:)=0;
    end




    function data = NuisanceCorrect()
        nuisance_paired = mc_calc_deltas_paired(Opt.NuisanceRegressors,savail,Opt.pairedContrast);
        vals.cor = 1;
        stat = mc_CovariateCorrectionFast(superflatmat_paired(labels==1,:),nuisance_paired,0,vals);
        superflatmat_p1 = stat.res;
        superflatmat_p2 = superflatmat_p1 * -1;
        superflatmat_paired = [superflatmat_p1; superflatmat_p2);
    end


    function [fitness prune trainPrune testPrune] = PruneData();
        
        fitness = zeros(1,nfeat);
        prune = zeros(1,nfeat);
        if nFeatPrune~=0
            
            if(strcmp(pruneMethod,'2sampleT'))
                fitness=mc_calc_discrim_power_unpaired(train_unpaired,trainlabels,'t-test');
            else
                fitness=mc_calc_discrim_power_paired(train,trainlabels,pruneMethod);
            end
            
            if (~strcmp(matrixtype,'upper'))
                fitness = mc_prune_discrim_power(featurefitness);
            end
            
            [d keepID] = mc_bigsmall(fitness,nFeatPrune,1);
            
            prune(keepID) = 1;
            
            trainPrune=train(:,keepID);
            testPrune=test(:,keepID);
            
            
        elseif nFeatPrune==0
            prune(:) = 1;
            
        end % end nFeatPrune
    end % end PruneData function
end % end parent function
