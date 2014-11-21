function cleansed=cleanse(mcRoot,des,cvals,SubjWiseTemp,EdgeField,Exp,NamePre)

% mcRoot = '~/users/yfang/MethodsCore/';
% DKinit


%% set options
outputPath = '~/users/yfang/temp';

cd(outputPath)

FixedFxPath = fullfile(outputPath,'FixedFX.mat');
Rcmd = ['Rscript --vanilla ' mcRoot '/svmbatch/matlab_Scripts/MassUniConn/MDF_Parser.R --args ' '"'  des.csvpath   '"' ' ' '"' des.IncludeCol '"' ' ' '"' des.model '"' ' ' '"' FixedFxPath '"' ' #&> /dev/null'];
Rstatus = system(Rcmd);

if Rstatus ~= 0
    error('Something went wrong in the call to R')
end

%%%% Load Design Matrix
s = load(FixedFxPath);

% clean it since Yu did not arrange them by session
s.subs = cellfun(@(x) x(1:length(s.subs{1})),s.subs,'UniformOutput',false);

%% load your data

% ***your code goes here, assume it is called "data" and is nSub * nEdges ***

for iSub=1:length(s.subs)
    Subject=s.subs{iSub};
    Subject=strcat(NamePre,Subject);
    disp(Subject);
    SubjWiseFile   = load(mc_GenPath(struct('Template',SubjWiseTemp,'mode','check')));
    SubjWiseEdgePath   = mc_GenPath('SubjWiseFile.[EdgeField]');
    eval(sprintf('%s=%s;','SubjWiseEdge',SubjWiseEdgePath));
    data(iSub,:)=mc_flatten_upper_triangle(SubjWiseEdge);    
end

%% cleanse the data


cleanse = mc_CovariateCorrectionFast(data,s.design,1,cvals);

nSub = size(s.design,1);
nPred = size(s.design,2);

clean_design = [cleanse.x(:,1:2) repmat(0,nSub,nPred - 2)]; % add only Dx back

cleansed = clean_design * cleanse.b  + cleanse.res;

%% backup
% des.model = '~ TYPE + meanFD + meanFDquad + varGS + IQMeasure + AGE + I(AGE^2) + GENDER + SITE_ID ' ; 
% des.FxCol = 2;
% des.FxFlip = 1;
% % des.model = '~ TYPE + meanFD + meanFDquad + IQMeasure + AGE + GENDER + SITE_ID ' ; 
% cvals.b = 1;
% cvals.res = 1;
% cvals.int = 1;
% cvals.x = 1;
% 
% des.csvpath = '/net/pizza/ADHD/Scripts/slab/GraphTheory/MasterData_ADHD_rePreprocess_Cleansed_varGS.csv';
% des.IncludeCol = 'Include_Overall_Censor';

end

