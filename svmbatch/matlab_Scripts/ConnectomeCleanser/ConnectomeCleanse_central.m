%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Connectome Cleansing Routine %
% Central Script               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Start by borrinw the beginning of the mass connectome analysis

%% Create the output path
if ~exist(outputPath,'file')
    mkdir(outputPath);
end

%% Design Matrix
%%% R System Call
cd(outputPath)

FixedFxPath = fullfile(outputPath,'FixedFX.mat');
Rcmd = ['Rscript --vanilla ' mcRoot '/svmbatch/matlab_Scripts/ConnectomeCleanser/RPart.R --args ' '"'  des.csvpath   '"' ' ' '"' des.IncludeCol '"' ' ' '"' des.model '"' ' ' '"' FixedFxPath '"' ' ' '"' FoldsCol '"' ' &> /dev/null'];
Rstatus = system(Rcmd);

if Rstatus ~= 0
    error('Something went wrong in the call to R')
end

%%% Load Design Matrix
s = load(FixedFxPath);
s.CrossValidFold = logical(s.CrossValidFold);

%%% Clean up Design Matrix
s.subs(:,2) = num2cell(1); % add a second column
if size(s.design,2) > 1
    s.design(:,2:end) = mc_SweepMean(s.design(:,2:end)); % mean center covariates except for first column
end

if des.FxFlip == 1; % flip the effect of interest, if desired
    s.design(:,des.FxCol) = -1 * s.design(:,des.FxCol);
end


%% Load Connectomes
switch paired
  case 0
    data = mc_load_connectomes_unpaired(s.subs,CorrTemplate,matrixtype); 
    data = mc_connectome_clean(data);
    if ZTrans == 1
        data = mc_FisherZ(data);
        data(abs(data) > 2) = NaN;
        data = mc_connectome_clean(data);
    end
% if paired, need to calculate deltas
  case 1
    s.subs(:,2) = num2cell(1:numel(RunDir),2);
    [data savail] = mc_load_connectomes_paired(s.subs,CorrTemplate,RunDir,matrixtype);
    data = mc_connectome_clean(data);
    if ZTrans == 1
        data = mc_FisherZ(data);
        data(abs(data) > 2) = NaN;
        data = mc_connectome_clean(data);
    end
    [data labels] = mc_calc_deltas_paired(data, savail, pairedContrast);
    data = data(labels==1,:); % grab only the positive delta
end

%% Write out the Overall File

Overall.Design.mat = s.design;
Overall.Design.varnames = s.DesignColNames;

Overall.SiteIDs = s.SiteIDS;

if numel(Overall.SiteIDs)==0
    Overall.SiteIDs = repmat('NoSites',size(s.design,1),1);
end

Overall.CrossValidFold = s.CrossValidFold;

Overall.Labels = sign(s.design(:,des.FxCol));

Overall.MDF = s.master;

save(fullfile(outputPath,'Overall.mat'),'Overall','-v7.3');

%% Loop over different sets of cross validations

% expect the CrossValidFold is a nSub x nFold matrix.
% should either be a logical or easily coerced to one
% it will indicate which subjects should be included
% in each fold

for iFold = 1:size(s.CrossValidFold,2)

    %%% Partition your data
    train_logic = ~logical(s.CrossValidFold(:,iFold));
    test_logic = logical(s.CrossValidFold(:,iFold));
    
    train.data = data(train_logic,:);
    train.des = s.design(train_logic,:);
    train.subs = s.subs(train_logic,:);

    test.data = data(test_logic,:);
    test.des = s.design(test_logic,:);
    test.subs = s.subs(test_logic,:);

    %%% Fit the model
    [c r b i] = mc_CovariateCorrection(train.data,train.des,3,[]);
    
    %%% Write the files for training
    
    %%%% Grouplevel training results
    train_Group.SiteIDs = Overall.SiteIDs(train_logic);
    train_Group.Labels = Overall.Labels(train_logic);
    train_Group.BetaHat = b;
    train_Group.Design.mat = train.des;
    train_Group.Design.varnames = s.DesignColNames;
    
    des_lev0 = mean(s.design,1);
    des_lev0(:,des.FxCol) = 0;
    des_lev1 = mean(s.design,1);
    des_lev1(:,des.FxCol) = 1;
    
    train_Group.GroupEstimates.Level0.Design = des_lev0;
    train_Group.GroupEstimates.Level0.Estimates = des_lev0 * b;

    train_Group.GroupEstimates.Level1.Design = des_lev1;
    train_Group.GroupEstimates.Level1.Estimates = des_lev1 * b;

    save(fullfile(outputPath,['TrainGroup_Fold' num2str(iFold) '.mat']),'train_Group','-v7.3')
    %%%% Corrections for training
    
    train_CorrectionDesign = repmat(des_lev0,size(train.des,1),1);
    train_CorrectionDesign(:,1:2) = train.des(:,1:2);
    train_Corrected = train_CorrectionDesign * b + r;

    save(fullfile(outputPath,['TrainCorrected_Fold' num2str(iFold) '.mat']),'train_Corrected','-v7.3')
    %%% Test Files
    %%%% Group Level
    
    test_Group.SiteIDs = Overall.SiteIDs(test_logic);
    test_Group.Labels = Overall.Labels(test_logic);
    test_Group.Design.mat = test.des;
    test_Group.Design.varnames = s.DesignColNames;

    save(fullfile(outputPath,['TestGroup_Fold' num2str(iFold) '.mat']),'test_Group','-v7.3')
    %%%% Test corrections
    b_nuisance = b;
    b_nuisance([1 des.FxCol],:) = []; % only leave nuisance Fx for betas and design matrices

    test.des_nuisance = test.des;
    test.des_nuisance(:,[1 des.FxCol]) = []; % similarly subset
                                             % test design matrix to only nuisance predictors
    
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The logic for the following comes from this:                              %
    % Let I denote anything relating to Fx of interest                          %
    % Let N denote anything relating to Fx of nuiance                           %
    % Y is our data.                                                            %
    % We presume Y = X_I*B_I + X_N*B_N + Error                                  %
    %                                                                           %
    % Our goal is to estimate this as if X_N was at some reference level.       %
    % e.g. Y(ref) = X_I*B_I + X_N(ref)*B_N + Error                              %
    % Fortunately for us, because X_N was mean centered upstream, our reference %
    % level is all zeros. So, X_N(ref) * B_N = 0.                               %
    %                                                                           %
    % Thus, all we need to do to accomplish                                     %
    % Y(ref) = X_I*BI + X_N(ref)*B_N + Error                                    %
    %                                                                           %
    % is Y - X_N*B_N = X_I*B_I + Error                                          %
    % and since X_N(ref)*B_N = 0                                                %
    % Y - X_N*B_N = X_I * B_I + Error + X_N(ref)*B_N                            %
    %                                                                           %
    % so we will do this.                                                       %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    
    test_Corrected = test.data - test.des_nuisance * b_nuisance; % subtract predicted nuisance from observed
                                                                 
    save(fullfile(outputPath,['TestCorrected_Fold' num2str(iFold) '.mat']),'test_Corrected','-v7.3')

        
end
