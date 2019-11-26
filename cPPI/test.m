%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are the same between Preprocessing and First level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/home/slab/mnt/psyche/net/data4/GO2010/PROJECTS/ERT';

ConnTemplate = '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/ERT_cPPI_norm_amyg_cppi_grid.mat';

OutputTemplate = {
    '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/Look_u/ERT_cPPI_norm_amyg_cppi_grid.mat';
    '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/Maintain_u/ERT_cPPI_norm_amyg_cppi_grid.mat';
    '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/Reappraise_u/ERT_cPPI_norm_amyg_cppi_grid.mat';
%     '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/Look_s/ERT_cPPI_norm_amyg_cppi_grid.mat';
%     '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/Maintain_s/ERT_cPPI_norm_amyg_cppi_grid.mat';
%     '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/Reappraise_s/ERT_cPPI_norm_amyg_cppi_grid.mat';
%     '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/RvM_u/ERT_cPPI_norm_amyg_cppi_grid.mat';
%     '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/RvM_s/ERT_cPPI_norm_amyg_cppi_grid.mat';
%     '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/MvL_u/ERT_cPPI_norm_amyg_cppi_grid.mat';
%     '[Exp]/FirstLevel/[Subject]/ERT_cPPI_norm_amyg/MvL_s/ERT_cPPI_norm_amyg_cppi_grid.mat';
};

ConditionWeights = {
    [2] [6 17] [1/2 1/2];
    [2] [7 18] [1/2 1/2];
    [2] [8 19] [1/2 1/2];
%     [4] [6 17] [1/2 1/2];
%     [4] [7 18] [1/2 1/2];
%     [4] [8 19] [1/2 1/2];
%     [2] [8 19 7 18] [1/2 1/2 -1/2 -1/2];
%     [4] [8 19 7 18] [1/2 1/2 -1/2 -1/2];
%     [2] [7 18 6 17] [1/2 1/2 -1/2 -1/2];
%     [4] [7 18 6 17] [1/2 1/2 -1/2 -1/2];
};


SubjDir = {
%%%'022',1,[1 2],0; %>3mm in both runs
'024',2,[1 2],0;
'046',3,[1 2],0;
'066',4,[1 2],0;
'074',5,[1 2],0;
%%%'076',6,[2],0; %>3mm in run 1
'081',7,[1 2],0;
'084',8,[1 2],0;
'095',9,[1 2],0;
'103',10,[1 2],0;
'107',11,[1 2],0;
'110',12,[1 2],0; 
'111',13,[1 2],0;
'124',14,[1 2],0; 
'133',15,[1 2],0;
'137',16,[1 2],0;
'138',17,[1 2],0; 
'142',18,[1 2],0;
'143',19,[1 2],0;
'148',20,[1 2],0;
'153',21,[1 2],0;
'157',22,[1 2],0;
'158',23,[1 2],0; 
'160',24,[1 2],0;
'162',25,[1 2],0;
'167',26,[1 2],0;
%%%'173',27,[2],0; %>3mm in run 1, large artifact/mvt
'174',28,[1 2],0;
'176',29,[1 2],0; 
'191',30,[1 2],0;
'200',31,[1 2],0;
'202',32,[1 2],0;
'203',33,[1 2],0; 
'206',34,[1 2],0;
'207',35,[1 2],0;
'218',36,[1 2],0;
'219',37,[1 2],0;
'221',38,[1 2],0;
'227',39,[1 2],0;
'229',40,[1 2],0;
'233',41,[1 2],0;
'235',42,[1 2],0;
'237',43,[1 2],0; 
'245',44,[1 2],0;
'251',45,[1 2],0; 
'256',46,[1 2],0;
'268',47,[1 2],0; 
'269',48,[1 2],0; 
'293',49,[1 2],0;
'331',50,[1 2],0;
'332',51,[1 2],0;
'344',52,[1 2],0;      
};

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(genpath(fullfile(mcRoot,'matlabScripts')));

for iSubj = 1:size(SubjDir,1)
    clear cppi_grid Subject;
    
    Subject = SubjDir{iSubj};
    
    fprintf('%s ',Subject)
    load(mc_GenPath(ConnTemplate));   

    nan = 0;
    for iCond = [6 7 8 17 18 19]
        rMatrix = cppi_grid{2,iCond};
        rMatrix = rMatrix(1081:1084,1081:1084);
        nan = nan + sum(isnan(rMatrix(:)));
    end
    fprintf(1,' %d\n',nan);
end