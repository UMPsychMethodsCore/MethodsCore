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

%% Confirm that you are running on an allowed host

goodlist={
'psyche.psych.med.umich.edu';
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
    end

    fprintf('Done\n');

    % Flatten censor matrix
    
    censor_flat = mc_flatten_upper_triangle(censor_square);
    
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
            superflatmat=zeros(nSubs,size(mc_flatten_upper_triangle(rmat),2));
        end
        superflatmat(iSub,:)=mc_flatten_upper_triangle(rmat);
        superlabel(iSub,1)=Example;

    end
    
    % Zero out censored elements
    superflatmat(:,logical(censor_flat))=0;
    
    fprintf('Done\n');

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

            switch pruneMethod  % Do different types of pruning based on user-specified option
                case 'ttest'% In ttest mode, do a 2-sample (groupwise) t-test on all features

                    [h,p] = ttest2(train(trainlabels==+1,:),train(trainlabels==-1,:));

                    % Clean out NaNs by setting to 1 (no significance)
                    p(isnan(p))=1;


                    % To keep the direction of discriminative power consistent,
                    % (i.e larger values indicate MORE discriminant power),
                    % take complement of p-values so small values (more
                    % significant) become large (more discriminant)
                    featurefitness=1-p;



                case 'tau-b'
                    % Initialize the fractions object which will store the
                    % tau-b's
                    featurefitness=zeros(1,size(train,2));

                    % Loop over features
                    for iFeat=1:size(train,2)

                        if any(diff(train(:,iFeat))) % Check to be sure that all elements aren't the same
                            featurefitness(iFeat)=ktaub([trainlabels(:,1) train(:,iFeat)],.05,0);

                        end
                    end
                    featurefitness = abs(featurefitness);

                case 'mutualinfo'
                    %|------------------- Mutual Information ----------------------------------------|%

                    featurefitness = mc_compute_mi( train, trainlabels );
                    %%

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

        elseif nFeatPrune==0
            LOOCV_pruning(iL,:)=1;

        end
        
        if advancedkernel==1
            if kernelsearchmode==1
                searchgrid=mc_svm_define_searchgrid(gridstruct);
            end

            result=mc_svm_gridsearch(train,trainlabels,test,testlabels,kernel,searchgrid);
            models_test{iL,1}=vertcat(searchgrid,result);

        end
        
        if advancedkernel==0

            models_train{iL}=svmlearn(train,trainlabels,'-o 100 -x 0');

            models_test{iL,1}=svmclassify(test,testlabels,models_train{iL});

            fprintf(1,'\nLOOCV performance thus far is %.0f out of %.0f.\n\n',...
                iL-sum(cell2mat(models_test),2),...
                iL);
            if iL==size(superflatmat,1) %If done looping, report final performance
                fprintf(1,'\nLOOCV performance is %.0f out of %.0f, for %.0f%% accuracy.\n\n',...
                    size(models_test,2)-sum(models_test),...
                    size(models_test,2),...
                    100*(size(models_test,2)-sum(models_test))/size(models_test,2));
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
        
        censor_flat = mc_flatten_upper_triangle(censor_square);


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
                    superflatmat_grouped=zeros(nSubs,size(mc_flatten_upper_triangle(rmat),2),condNum);
                    unsprung=1;
                end

                superflatmat_grouped(iSub,:,iCond) = mc_flatten_upper_triangle(rmat);
            end

        end
    end

    %Zero out censored elements
    
    superflatmat_grouped(:,logical(censor_flat),:)=0;
    
    fprintf('Done\n');


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
            trainlabels=repmat([1; -1],size(train,1)/2,1);
            test=superflatmat_paired([iL*2-1 iL*2],:);
            testlabels=repmat([1; -1],size(test,1)/2,1);
            
            if nFeatPrune~=0

                % Identify the fraction of features that are greater than zero, or
                % less than zero (whichever is larger). This indicates a consistent
                % signed direction. Do it just for one pair, since the second pair
                % is the first * -1

                featurefitness=max(  [sum(train(1:2:end,:)>0,1)/size(train(1:2:end,:),1) ;sum(train(1:2:end,:)<0,1)/size(train(1:2:end,:),1)]  );

                LOOCV_featurefitness{iContrast}(iL,:) = featurefitness;

                [d keepID] = mc_bigsmall(featurefitness,nFeatPrune,1);

                LOOCV_pruning{iContrast}(iL,keepID) = 1;

                train=train(:,keepID);
                test=test(:,keepID);

            elseif nFeatPrune==0
                LOOCV_pruning{iContrast}(iL,:)=1;
            end

            if advancedkernel==1
                if kernelsearchmode==1
                    searchgrid=mc_svm_define_searchgrid(gridstruct);
                end
                
                result=mc_svm_gridsearch(train,trainlabels,test,testlabels,kernel,searchgrid);
                models_test{iL,iContrast}=vertcat(searchgrid,result);
                
            end
            
            if advancedkernel==0
            
                models_train{iL,iContrast}=svmlearn(train,trainlabels,'-o 100 -x 0');

                models_test{iL,iContrast}=svmclassify(test,testlabels,models_train{iL,iContrast});

                fprintf(1,'\nLOOCV performance thus far is %.0f out of %.0f.\n\n',...
                    iL-sum(cell2mat(models_test(:,iContrast))),...
                    iL);
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
    
    for iContrast=1:size(models_test,2)
        gridsearch_performance{iContrast,1}=zeros(nLOOCV(iContrast),size(models_test{1,iContrast},2)-1); %Preallocate
        for iL=1:size(models_test,1)
            gridsearch_performance{iContrast,1}(iL,:)=cell2mat(models_test{iL,iContrast}(end,2:end));
        end
    end
    
    SVM_ConnectomeResults.gridsearch_performance=gridsearch_performance;
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