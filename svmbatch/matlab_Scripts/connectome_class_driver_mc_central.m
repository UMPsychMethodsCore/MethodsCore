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
            cleanconMat=ones(size(rmat));
            nfeat=size(rmat(:));
        end
        cleanconMat(isnan(rmat) | isinf(rmat) | rmat==0) = 0; %For all indices in rmat that are NaN, zero out cleanconMat
    end

    fprintf('Done\n');

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
            superflatmat=zeros(nSubs,size(connectivity_grid_flatten(rmat,cleanconMat),2));
        end
        superflatmat(iSub,:)=connectivity_grid_flatten(rmat, cleanconMat);
        superlabel(iSub,1)=Example;

    end
    fprintf('Done\n');

    %% LOOCV


    fprintf('Doing LOOCV pruning. More results will pop up on your screen soon\n');


    pruneLOO=zeros(size(superflatmat));

    models_train={};
    models_test=[];

    labels=cell2mat(SubjDir(:,2));

    LOOCV_fractions=zeros(size(superflatmat));
    LOOCV_pruning=zeros(size(superflatmat));

    if ~exist('pruneMethod','var') ; pruneMethod='ttest'; end

    for iL=1:(size(superflatmat,1))
        fprintf(1,'\nCurrently running LOOCV on subject %.0f of %.0f.\n',iL,size(superflatmat,1))

        subjects=[1:(iL-1) (iL+1):size(superflatmat,1)];
        indices=subjects;



        train=superflatmat(indices,:);
        trainlabels=labels(indices,:);

        switch pruneMethod  % Do different types of pruning based on user-specified option
            case 'ttest'% In ttest mode, do a 2-sample (groupwise) t-test on all features

                [h,p] = ttest2(train(trainlabels==+1,:),train(trainlabels==-1,:));

                % Clean out NaNs by setting to 1 (no significance)
                p(isnan(p))=1;


                % To keep the direction of discriminative power consistent,
                % (i.e larger values indicate MORE discriminant power),
                % take complement of p-values so small values (more
                % significant) become large (more discriminant)
                p=1-p;

                % Store this in variable fractions to keep with old
                % conventions
                fractions=p;

                % Store this LOO fold's feature-wise discriminant power
                LOOCV_fractions(iL,:) = fractions;

                % Return pruneID as the sort indices of the discriminative
                % power, from least to greatest
                [d pruneID] = sort(fractions);

            case 'tau-b'
                tic
                % Initialize the fractions object which will store the
                % tau-b's
                fractions=zeros(1,size(train,2));

                % Loop over features
                for iFeat=1:size(train,2)

                    if any(diff(train(:,iFeat))) % Check to be sure that all elements aren't the same
                        fractions(iFeat)=ktaub([trainlabels(:,1) train(:,iFeat)],.05,0);

                    end
                end
                fractions = abs(fractions);
                [d pruneID] = sort(fractions);
                toc

        end

        % Grab the final nFeatPrune elements of pruneID (these are the
        % greatest)
        pruneID=pruneID((end-(nFeatPrune-1)):end);

        % Record a logical mapping of those indices
        LOOCV_pruning(iL,pruneID) = 1;

        % Restrict the training and test sets to only include the non-pruned features
        train=train(:,pruneID);
        test=superflatmat(iL,pruneID);

        models_train{iL}=svmlearn(train,trainlabels,'-o 100 -x 0');

        models_test(iL)=svmclassify(test,labels(iL),models_train{iL});

        fprintf(1,'\nLOOCV performance thus far is %.0f out of %.0f.\n\n',...
            iL-sum(models_test),...
            iL);

    end
    fprintf(1,'\nLOOCV Done\n\n');

    
    %% Report performance

    fprintf(1,'\nLOOCV performance is %.0f out of %.0f, for %.0f%% accuracy.\n\n',...
        size(models_test,2)-sum(models_test),...
        size(models_test,2),...
        100*(size(models_test,2)-sum(models_test))/size(models_test,2));

    %% End Unpaired SVM

end


%% New paired approach

if strcmpi(svmtype,'paired')

    %% Read and ID Valid Features (Same feature set will be used across all
    %% contrasts)

    fprintf('\nLooping over all files to identify those with valid values....');
    nSubs=size(SubjDir,1);

    unsprung=0;

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
                    cleanconMat=ones(size(rmat));
                    nfeat=size(rmat(:));
                    unsprung=1;
                end
                condAvail(iSub,iCond)=1;


            end
            cleanconMat(isnan(rmat) | isinf(rmat) | rmat==0) = 0; %For all indices in rmat that are NaN, zero out cleanconMat
        end




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
                    superflatmat_grouped=zeros(nSubs,size(connectivity_grid_flatten(rmat,cleanconMat),2),condNum);
                    unsprung=1;
                end

                superflatmat_grouped(iSub,:,iCond) = connectivity_grid_flatten(rmat,cleanconMat);
            end

        end
    end

    fprintf('Done\n');


    %% Figure out subject availability for contrasts

    contrastAvail = zeros(nSubs,size(ContrastVec));

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

        LOOCV_fractions{iContrast}=zeros(size(superflatmat_p1));
        LOOCV_pruning{iContrast}=zeros(size(superflatmat_p1));


        for iL=1:size(superflatmat_p1,1)
            fprintf(1,'\nCurrently running LOOCV on subject %.0f of %.0f.\n',iL,size(superflatmat_p1,1))

            subjects=[1:(iL-1) (iL+1):size(superflatmat_p1,1)];
            indices=sort([subjects*2 subjects*2-1]);



            train=superflatmat_paired(indices,:);
            trainlabels=repmat([1; -1],size(train,1)/2,1);

            % Identify the fraction of features that are greater than zero, or
            % less than zero (whichever is larger). This indicates a consistent
            % signed direction. Do it just for one pair, since the second pair
            % is the first * -1

            fractions=max(  [sum(train(1:2:end,:)>0,1)/size(train(1:2:end,:),1) ;sum(train(1:2:end,:)<0,1)/size(train(1:2:end,:),1)]  );

            LOOCV_fractions{iContrast}(iL,:) = fractions;

            [d pruneID] = sort(fractions);

            pruneID=pruneID((end-(nFeatPrune-1)):end);

            LOOCV_pruning{iContrast}(iL,pruneID) = 1;

            train=train(:,pruneID);
            test=superflatmat_paired([iL*2-1 iL*2],pruneID);

            models_train{iL,iContrast}=svmlearn(train,trainlabels,'-o 100 -x 0');

            models_test{iL,iContrast}=svmclassify(test,[1 ; -1],models_train{iL,iContrast});

            fprintf(1,'\nLOOCV performance thus far is %.0f out of %.0f.\n\n',...
                iL-sum(cell2mat(models_test(:,iContrast))),...
                iL);



        end
    end


    %% End new paired SVM approach

end
    
%% Save results to file
% Stash the setup parameters into the results structure
SVM_ConnectomeResults.SVMSetup = SVMSetup;

% Store the model trained in each LOOCV fold
SVM_ConnectomeResults.models_train = models_train;

% Store the uncensored fractions (discrim power) from each LOOCV fold
SVM_ConnectomeResults.LOOCV_fractions = LOOCV_fractions;

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
if (exist('Vizi') &&  Vizi==1)
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
    
    % Ensure number of consensus features is less than number of features
    % to plot
    
    nFeatPlot=min(sum(LOOCV_consensus),nFeatPlot);
    
    % ID top nFeatPlot features, and zero out all else
    [d discrimpower_sort_ind] = sort(LOOCV_discrimpower_consensus);
    discrimpower_sort_ind = discrimpower_sort_ind(1:(end-nFeatPlot)); %grab indices of all but top nFeatPlot elements
    
    LOOCV_discrimpower_consensus(discrimpower_sort_ind) = 0; %zero out all but top nFeatPlot features
    

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
    dlmwrite(OutputEdgePath,LOOCV_discrimpower_consensus_square,'\t');

    %% Build the ROI list

    % Add color labels for roiMNI object. For now, just set to 1 until we have
    % a network atlas
    roiMNI(:,4) = 1 ;

    % Count how many times ROIs are touched by an edge, append to roiMNI object
    roi_RegionWeights=sum([sum(LOOCV_discrimpower_consensus_square_binarized,1) ; sum(LOOCV_discrimpower_consensus_square_binarized,2)']) ;
    roiMNI(:,5)=roi_RegionWeights;

    % Write out nodes file
    dlmwrite(OutputNodePath,roiMNI,'\t');

    % Apend tab and - to indicate no label, for now...
    eval(['! sed -i ''s/$/\t-/'' ' OutputNodePath])
end