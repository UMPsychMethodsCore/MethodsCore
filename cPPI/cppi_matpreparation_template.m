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
    
    fprintf('%s\n',Subject)
    load(mc_GenPath(ConnTemplate));   

    for iOut = 1:size(OutputTemplate,1)
        clear rMatrix wp cprow include weights;
        cprow = ConditionWeights{iOut,1};
        include = ConditionWeights{iOut,2};
        weights = ConditionWeights{iOut,3};
        for iCond = 1:size(include,2)
            wp(:,:,iCond) = cppi_grid{cprow,include(iCond)} .* weights(iCond);
        end
        
        rMatrix = sum(wp,3);
        
        mc_GenPath(struct('Template',OutputTemplate{iOut},'mode','makeparentdir'));
        save(mc_GenPath(OutputTemplate{iOut}),'rMatrix');
    end
end