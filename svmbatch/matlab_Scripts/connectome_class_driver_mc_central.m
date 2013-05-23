
%% Central Part

% Gather option variables into single struct variable
WSVARS = evalin('base','who');
for wscon=1:size(WSVARS,1)
    if ~strcmpi(WSVARS{wscon},'WSVARS') && ~strcmpi(WSVARS{wscon},'wscon')
        thisvar=evalin('caller',WSVARS{wscon});
        SVMSetup.(WSVARS{wscon})=thisvar;
    end
end

clear WSVARS

conPathTemplate.Template = ConnTemplate;
conPathTemplate.mode='check';

%% Set defaults

if(~exist('svmlib','var'))
    svmlib=1;
end

if(~exist('matrixtype','var'))
    matrixtype='upper';
end

if (~exist('ztrans','var'))
    ztrans = 0;
end

if (~exist('binarize','var'))
    binarize = 0;
end

%% Confirm that you are running on an allowed host

goodlist={
'psyche.psych.med.umich.edu';'freewill';
};

[d,curhost]=system('hostname');

if ~any(strcmpi(strtrim(curhost),goodlist));
	error('You are not running svm on an approved host!');
end

%% Unpaired SVM
if strcmpi(svmtype,'unpaired')

    %% Read and ID Valid Features

    fprintf('\nLooping over all files to identify those with valid values....');
    nSubs=size(SubjDir,1);

    for iSub=1:size(SubjDir,1)

        Subject = SubjDir{iSub,1};
        conPath=mc_GenPath(conPathTemplate);
        conmat=load(conPath);
        rmat=conmat.rMatrix;
        if iSub==1
            censor_square=zeros(size(rmat));
            nfeat=size(rmat(:));
        end
        censor_square(isnan(rmat) | isinf(rmat) | rmat==0) = 1; % For all bad elements, flag with 1 in censor_square
        
        if (strcmp(matrixtype,'nodiag'))
            censor_square = censor_square + eye(size(censor_square));
        end
    end

    fprintf('Done\n');

    % Flatten censor matrix
    
    if (strcmp(matrixtype,'upper'))
        censor_flat = mc_flatten_upper_triangle(censor_square);
    else
        censor_flat = reshape(censor_square,1,prod(size(censor_square)));
    end
    
    %% Read and flatten valid features
    
    fprintf('\nLooping over all files to flatten the matrices into one super matrix....');

    superlabel=zeros(nSubs,1);

    for iSub=1:size(SubjDir,1)
        Subject = SubjDir{iSub,1};
        Example=SubjDir{iSub,2};
        conPath=mc_GenPath(conPathTemplate);
        conmat=load(conPath);
        rmat=conmat.rMatrix;
        %     sprintf('Subject %s has variance %s',Subject,var(rmat(~isnan(rmat))))
        if iSub==1
            superflatmat=zeros(nSubs,size(censor_flat,2));
        end
        if(strcmp(matrixtype,'upper'))
            superflatmat(iSub,:)=mc_flatten_upper_triangle(rmat);
        else
            superflatmat(iSub,:) = reshape(rmat,1,prod(size(rmat)));
        end
        superlabel(iSub,1)=Example;

    end
    
    % Zero out censored elements
    superflatmat(:,logical(censor_flat))=0;
    
    if ztrans == 1
        superflatmat = mc_FisherZ(superflatmat);
    end
    
    fprintf('Done\n');
    
    %% Regress out Nuisance Regressors
    if DoNuisanceCorrection
        superflatmat = mc_CovariateCorrection(superflatmat,NuisanceRegressors);
    end
    %% LOOCV

    fprintf('Doing LOOCV pruning. More results will pop up on your screen soon\n');


    labels=cell2mat(SubjDir(:,2));

    LOOCV_featurefitness=zeros(size(superflatmat));
    LOOCV_pruning=zeros(size(superflatmat));


    for iL=1:(size(superflatmat,1))
        fprintf(1,'\nCurrently running LOOCV on subject %.0f of %.0f.\n',iL,size(superflatmat,1))

        train_idx=[1:(iL-1) (iL+1):size(superflatmat,1)];



        train=superflatmat(train_idx,:);
        trainlabels=labels(train_idx,:);
        test=superflatmat(iL,:);
        testlabels=labels(iL);
        
        
        if nFeatPrune~=0
            
            featurefitness=mc_calc_discrim_power_unpaired(train,trainlabels,pruneMethod);
            if (~strcmp(matrixtype,'upper'))
                featurefitness = mc_prune_discrim_power(featurefitness);
            end
            
            % Store this LOO fold's feature-wise discriminant power
            LOOCV_featurefitness(iL,:) = featurefitness;

            % Grab the largest nFeatPrune Elements of FeatureFitness
            [d keepID] = mc_bigsmall(featurefitness,nFeatPrune,1);

            % Record a logical mapping of those indices
            LOOCV_pruning(iL,keepID) = 1;

            % Restrict the training and test sets to only include the non-pruned features
            train=train(:,keepID);
            test=test(:,keepID);
            
            if binarize == 1
                train = sign(train);
                test = sign(test);
            end

        elseif nFeatPrune==0
            LOOCV_pruning(iL,:)=1;
            
            if binarize == 1
                train = sign(train);
                test = sign(test);
            end

        end
        
        if advancedkernel==1
            if kernelsearchmode==1
                searchgrid=mc_svm_define_searchgrid(gridstruct);
            end

            result=mc_svm_gridsearch(train,trainlabels,test,testlabels,kernel,searchgrid,svmlib);
            models_test{iL,1}=vertcat(searchgrid,result);

        end
        
        if advancedkernel==0
            
            switch svmlib
                case 1
                    models_train{iL}=svmlearn(train,trainlabels,'-o 100 -x 0');

                    models_test{iL,1}=svmclassify(test,testlabels,models_train{iL});
                    
                    fprintf(1,'\nLOOCV performance thus far is %.0f out of %.0f.\n\n',...
                        iL-sum(cell2mat(models_test),1),...
                        iL);
                    if iL==size(superflatmat,1) %If done looping, report final performance
                        cnt = 0;
                        for icnt = 1: size(models_test,2)
                            if models_test{icnt} == 1
                                cnt = cnt+1;
                            end
                        end
                        fprintf(1,'\nLOOCV performance is %.0f out of %.0f, for %.0f%% accuracy.\n\n',...
                            size(models_test,2)-cnt,...
                            size(models_test,2),...
                            100*(size(models_test,2)-cnt)/size(models_test,2));

                    end

                case 2

                    svm_light_c = 1/mean(sum(train.*train,2),1);

                    models_train{iL}=svmtrain(trainlabels,train,['-s 0 -t 0 -c ' num2str(svm_light_c)]);


                    [model.pred_lab, model.acc, model.dec_val] = svmpredict(testlabels,test,models_train{iL});

                    models_test{iL,1}=1-model.acc(1)/100;

            end
        end
    end
    fprintf(1,'\nLOOCV Done\n\n');

    %% End Unpaired SVM

end


%% New paired approach

if strcmpi(svmtype,'paired')

    %% Read and ID Valid Features (Same feature set will be used across all
    %% contrasts)

    fprintf('\nLooping over all files to identify those with valid values....');
    nSubs=size(SubjDir,1);

    unsprung=0; %counter to identify when you encounter the first valid case

    condNum = size(SubjDir{1,2},2);

    condAvail = zeros(nSubs,condNum);

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
                    censor_square=zeros(size(rmat));
                    nfeat=size(rmat(:));
                    unsprung=1;
                end
                condAvail(iSub,iCond)=1;


            end
            censor_square(isnan(rmat) | isinf(rmat) | rmat==0) = 1; %For all indices in rmat that are NaN, zero out cleanconMat
            

        end

        % Flatten censor matrix
        



    end
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
    
    if ztrans == 1
        superflatmat_grouped = mc_FisherZ(superflatmat_grouped);
    end
    
    fprintf('Done\n');

    %Arrange data as if it were unpaired (and interleave it, cuz that's what downstream stuff expects)
    superflatmat_unpaired(1:2:(size(superflatmat_grouped,1)*2),:) = squeeze(superflatmat_grouped(:,:,1));
    superflatmat_unpaired(2:2:(size(superflatmat_grouped,1)*2),:) = squeeze(superflatmat_grouped(:,:,2));
    
    %% Figure out subject availability for contrasts

    contrastAvail = zeros(nSubs,size(ContrastVec,1));

    for iContrast = 1:size(ContrastVec,1);
        curContrast=ContrastVec(iContrast,:);
        contrastAvail(:,iContrast) = all(condAvail(:,find(curContrast)),2);
    end


    % If running in listwise mode, clear out the contrastAvailability matrix
    % listwise
    if exist('listwise','var') && listwise==1
        contrastAvail = repmat(all(contrastAvail,2),1,size(ContrastVec,1)) ;
    end

    %% Do LOOCV pruning, etc



    models_train={};
    models_test={};

    for iContrast=1:size(ContrastVec,1);

        % Create the difference map
        
        fprintf('Beginning LOOCV work on contrast #%.0f\n', iContrast);

        curContrast = ContrastVec(iContrast,:);

        weighted_superflatmat_grouped = zeros(size(superflatmat_grouped));

        for iCond = 1:condNum
            weighted_superflatmat_grouped(:,:,iCond) = superflatmat_grouped(:,:,iCond) * curContrast(iCond);
        end

        % Prune based on contrast availability
        weighted_superflatmat_grouped = weighted_superflatmat_grouped(logical(contrastAvail(:,iContrast)),:,:);

        superflatmat_p1 = sum(weighted_superflatmat_grouped,3);
        
        % correct for nuisance regressors if they exist
        if exist('DoNuisanceCorrection','var') && DoNuisanceCorrection==1
            for iCond = 1:condNum
                weighted_nuisance(:,:,iCond)=NuisanceRegressors(:,:,iCond) * curContrast(iCond); % weight by contrasting info
            end
            weighted_nuisance=weighted_nuisance(logical(contrastAvail(:,iContrast)),:,:); %prune based on contrast availability
            nuisance = sum(weighted_nuisance,3); % calculate delta or whatever contrast wants
            superflatmat_p1_old=superflatmat_p1;
            superflatmat_p1 = mc_CovariateCorrection(superflatmat_p1,nuisance); % correction for nuisance regressors
        end
        
        superflatmat_p2 = -1 * superflatmat_p1;

        superflatmat_paired(1:2:(size(superflatmat_p1)*2),:)=superflatmat_p1;
        superflatmat_paired(2:2:(size(superflatmat_p1)*2),:)=superflatmat_p2;

        LOOCV_featurefitness{iContrast}=zeros(size(superflatmat_p1));
        LOOCV_pruning{iContrast}=zeros(size(superflatmat_p1));


        for iL=1:size(superflatmat_p1,1)
            fprintf(1,'\nCurrently running LOOCV on subject %.0f of %.0f.\n',iL,size(superflatmat_p1,1))

            train_idx=[1:(iL-1) (iL+1):size(superflatmat_p1,1)];
            train_idx=sort([train_idx*2 train_idx*2-1]);



            train=superflatmat_paired(train_idx,:);
            train_unpaired = superflatmat_unpaired(train_idx,:);
            trainlabels=repmat([1; -1],size(train,1)/2,1);
            test=superflatmat_paired([iL*2-1 iL*2],:);
            test_unpaired = superflatmat_unpaired([iL*2-1 iL*2],:);
            testlabels=repmat([1; -1],size(test,1)/2,1);
            
            if nFeatPrune~=0

                % Identify the fraction of features that are greater than zero, or
                % less than zero (whichever is larger). This indicates a consistent
                % signed direction. Do it just for one pair, since the second pair
                % is the first * -1

                
                if(strcmp(pruneMethod,'2sampleT'))
                    featurefitness=mc_calc_discrim_power_unpaired(train_unpaired,trainlabels,'t-test');
                else
                    featurefitness=mc_calc_discrim_power_paired(train,trainlabels,pruneMethod);
                end

                if (~strcmp(matrixtype,'upper'))
                    featurefitness = mc_prune_discrim_power(featurefitness);
                end
                
                LOOCV_featurefitness{iContrast}(iL,:) = featurefitness;

                [d keepID] = mc_bigsmall(featurefitness,nFeatPrune,1);

                LOOCV_pruning{iContrast}(iL,keepID) = 1;

                train=train(:,keepID);
                test=test(:,keepID);
                
                if binarize == 1
                    train = sign(train);
                    test = sign(test);
                end

            elseif nFeatPrune==0
                LOOCV_pruning{iContrast}(iL,:)=1;
                
                if binarize == 1
                    train = sign(train);
                    test = sign(test);
                end
            end

            if advancedkernel==1
                if kernelsearchmode==1
                    searchgrid=mc_svm_define_searchgrid(gridstruct);
                end
                
                result=mc_svm_gridsearch(train,trainlabels,test,testlabels,kernel,searchgrid,svmlib);
                models_test{iL,iContrast}=vertcat(searchgrid,result);
                
            end
            
            if advancedkernel==0
                switch  svmlib

                    case 1

                        models_train{iL,iContrast}=svmlearn(train,trainlabels,'-o 100 -x 0');

                        models_test{iL,iContrast}=svmclassify(test,testlabels,models_train{iL,iContrast});

                        fprintf(1,'\nLOOCV performance thus far is %.0f out of %.0f.\n\n',...
                            iL-sum(cell2mat(models_test(:,iContrast))),...
                            iL);

                    case 2
                        svm_light_c = 1/mean(sum(train.*train,2),1);

                        models_train{iL}=svmtrain(trainlabels,train,['-s 0 -t 0 -c ' num2str(svm_light_c)]);

                        [model.pred_lab, model.acc, model.dec_val] = svmpredict(testlabels,test,models_train{iL});

                        models_test{iL,1}=1-model.acc(1)/100;
                        
                end
            end


        end
    end


    %% End new paired SVM approach

end

%% Summarize performance over gridsearch

if advancedkernel==1
    
    models_train='No trained models stored';
    
    gridsearch_performance=cell(size(models_test,2),1);
    
    nLOOCV=sum(~cellfun(@isempty,models_test),1); %Count how many LOOCV folds in each contrast
    try
    for iContrast=1:size(models_test,2)
        gridsearch_performance{iContrast,1}=zeros(nLOOCV(iContrast),size(models_test{1,iContrast},2)-1); %Preallocate
        for iL=1:size(models_test,1)
            gridsearch_performance{iContrast,1}(iL,:)=cell2mat(models_test{iL,iContrast}(end,2:end));
        end
    end
    
    SVM_ConnectomeResults.gridsearch_performance=gridsearch_performance;
    catch
    end
end

%% Save results to file
% Stash the setup parameters into the results structure
SVM_ConnectomeResults.SVMSetup = SVMSetup;

% Store the model trained in each LOOCV fold
SVM_ConnectomeResults.models_train = models_train;

% Store the uncensored fractions (discrim power) from each LOOCV fold
SVM_ConnectomeResults.LOOCV_featurefitness = LOOCV_featurefitness;

% Store the binarized logic of which features were retained from each LOOCV fold
SVM_ConnectomeResults.LOOCV_pruning = LOOCV_pruning;

% Store the performance of LOOCV on each fold
SVM_ConnectomeResults.models_test = models_test;

% Prepare path for writing results file
OutputPathTemplate.Template= OutputTemplate ;
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
    
    roiPathTemplate.Template = ROITemplate;
    roiPathTemplate.mode='check';

    roiPath=mc_GenPath(roiPathTemplate);
    roimat=load(roiPath);
    roiMNI=roimat.parameters.rois.mni.coordinates;

    if strcmpi(svmtype,'paired')
        for i=1:size(ContrastVec,1)
            
            OutputPathTemplate.suffix = [ContrastNames{i} '.node'];
            OutputNodePath = mc_GenPath(OutputPathTemplate);
            OutputPathTemplate.suffix = [ContrastNames{i} '.edge'];
            OutputEdgePath = mc_GenPath(OutputPathTemplate);
            
            mc_BNV_writer(OutputEdgePath,OutputNodePath,LOOCV_pruning{i},...
                LOOCV_featurefitness{i},roiMNI,nFeatPlot,...
                '/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr');
            
        end
    else
        mc_BNV_writer(OutputEdgePath,OutputNodePath,LOOCV_pruning,...
            LOOCV_featurefitness,roiMNI,nFeatPlot,...
            '/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr');
    end
    
    
end
