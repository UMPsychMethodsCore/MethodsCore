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
    end
% if paired, need to calculate deltas
  case 1
    s.subs(:,2) = num2cell(1:numel(RunDir),2);
    [data savail] = mc_load_connectomes_paired(s.subs,CorrTemplate,RunDir,matrixtype);
    data = mc_connectome_clean(data);
    if ZTrans == 1
        data = mc_FisherZ(data);
    end
    [data labels] = mc_calc_deltas_paired(data, savail, pairedContrast);
    data = data(labels==1,:); % grab only the positive delta
end

%% Loop over different sets of cross validations

% expect the CrossValidFold is a nSub x nFold matrix.
% should either be a logical or easily coerced to one
% it will indicate which subjects should be included
% in each fold

for iFold = 1:size(s.CrossValidFold,2)
    train.data = data(~logical(s.CrossValidFold(:,iFold)),:);
    test.data = data(logical(s.CrossValidFold(:,iFold)),:);
    train.des = s.design(~logical(s.CrossValidFold(:,iFold)),:);
    test.des = s.design(logical(s.CrossValidFold(:,iFold)),:);
    train.subs = s.subs(~logical(s.CrossValidFold(:,iFold)),:);
    test.subs = s.subs(logical(s.CrossValidFold(:,iFold)),:);

    
    [c r b i] = mc_CovariateCorrection(train.data,train.des,3,[]);
    
    b([1 des.FxCol],:) = []; % only leave nuisance Fx for betas and design matrices
    train.des(:,[1 des.FxCol]) = [];
    test.des(:,[1 des.FxCol]) = [];
    
    train.corrected = train.data - train.des * b; % subtract nuisance from observed
    test.corrected = test.data - test.des * b; % subtract predicted nuisance from observed
    
    train = rmfield(train,'data');
    test = rmfield(test,'data');
    
    Folds.partition  = s.CrossValidFold(:,iFold);
    Folds.train = train;
    Folds.test = test;
    Folds.subs = s.subs;
    Folds.CrossValidFold = s.CrossValidFold;
    Folds.SiteIDS = s.SiteIDS;
    
    save(fullfile(outputPath,['Fold' num2str(iFold) '.mat']),'Folds','-v7.3')
        
end
