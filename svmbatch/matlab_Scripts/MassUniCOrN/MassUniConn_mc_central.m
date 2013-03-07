%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%                   MassUnivariate Connectomme Analysis                % 
%                           Central Script                             %
%                                                                      %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
DKinit

%% Create the output path

mkdir(outputPath);

%% Design Matrix
%%% R System Call
cd(outputPath)
Rcmd = ['Rscript --vanilla --args ' des.csvpath ' ' des.IncludeCol ' ' des.model ' < MDF_Parser.R'];
system(Rcmd);

%%% Load Design Matrix
s = load('FixedFX.mat');

%%% Clean up Design Matrix
s.subs(:,2) = num2cell(1); % add a second column
s.design(:,2:end) = mc_SweepMean(s.design(:,2:end)); % mean center covariates except for first column

if des.FxFlip == 1; % flip the effect of interest, if desired
    s.design(:,des.FxCol) = -1 * s.design(:,des.FxCol);
end


%% Load Connectomes
CorrPathCheck = struct('Template',CorrTemplate,'mode','check');
CorrPath = mc_GenPath(CorrPathCheck);
% need to add switch here for paired vs unpaired

switch paired
  case 0
    data = mc_load_connectomes_unpaired(s.subs,CorrPath,matrixtype); 
    data = mc_connectome_clean(data);
% if paired, need to calculate deltas
  case 1
    [data savail] = mc_load_connectomes_paired(s.subs,CorrPath,RunDir,matrixtype);
    data = mc_calc_deltas_paired(data, savail, pairedContrast);
end
%% Figure out Network Structure
%%% Load parameter File
ParamPathCheck = struct('Template',ParamTemplate,'mode','check');
ParamPath = mc_GenPath(ParamPathCheck);
param = load(ParamPath);

%%% Look up ROI Networks
roiMNI = param.parameters.rois.mni.coordinates;
nets = mc_NearestNetworkNode(roiMNI,5);
sq_blanks = zeros(size(roiMNI,1));


%%% Build Netmask
% need to generalize this to support cPPI and resting


switch matrixtype
    case 'upper'

      for iNet = 0:max(nets)
          for jNet = iNet:max(nets)
              csq_blanks = sq_blanks;
              csq_blanks(nets==iNet,nets==jNet) = 1;  % csq: current square
              csq_blanks(nets==jNet,nets==iNet) = 1;
              csq_blanks=triu(csq_blanks,1);
              csq = mc_flatten_upper_triangle(csq_blanks);
              netmask{iNet+1,jNet+1} = logical(csq); % network index starts from zero
          end    
      end
  case 'nodiag'
% for yoke 1
    for iNet = 0:max(nets)
        for jNet = iNet:max(nets)
            csq_blanks = sq_blanks;
            csq_blanks(nets==iNet,nets==jNet) = 1;
            csq_blanks(nets==jNet,nets==iNet) = 1;
            csq_blanks=triu(csq_blanks,1);
            csq = reshape(csq_blanks,size(roiMNI,1)^2,1);
            netmask{iNet+1,jNet+1,1} = logical(csq);
        end    
    end

% for yoke 2
    for iNet = 0:max(nets)
        for jNet = iNet:max(nets)
            csq_blanks = sq_blanks;
            csq_blanks(nets==iNet,nets==jNet) = 1;
            csq_blanks(nets==jNet,nets==iNet) = 1;
            csq_blanks=tril(csq_blanks,-1);
            csq = reshape(csq_blanks,size(roiMNI,1)^2,1);
            netmask{iNet+1,jNet+1,2} = logical(csq);
        end    
    end
end
      
%% Fit Real Model

%%% Do the GLM
[~, ~, ~, ~, t, p] = mc_CovariateCorrection(data,s.design,3,des.FxCol);

ts = sign(t(2,:)); % figure out the sign

%%% Figure out the subthreshold edges and their sign
% will want to be able to loop over threshold probably? we rarely use that, so maybe we don't need to support?
prune = p(2,:) < thresh(1);

% will want to allow swap of positive to negative values depending on coding here? or should we fix up at design matrix level?
ts(ts==+1) = 3; % map the positive values to 3 (flip the direction since autism is 1)
ts(ts==-1) = 2; % map the negative values to 2 (flip direction)
ts(ts==+0) = 1;

%%% Construct Option for CellCount Function
a.pruneColor.values = ts;
a.prune = prune;
a.NetworkLabels = nets;
a.DotDilateMat = [1 0; -1 0; 0 1; 0 -1; % cross
                   -1 1; 1 1; -1 -1; 1 -1; %fill out square
                   -2 0; 0 2; 2 0; 0 -2]; % cross around square

a.pruneColor.map = [1 1 1; % make 1 white
                    1 0 0; % make 2 red
                    0 0 1; % make 3 blue
                    ];
a.shading.enable = enable;


%%% Count Cells
a = mc_Network_mediator(a);
a = mc_Network_Cellcount(a);

celltot = a.cellcount.celltot;     % Count Edges Per Cell
cellpos = a.cellcount.cellpos; %%% count of positive
cellneg = a.cellcount.cellneg; %%% count of negative

%% Permutations

% for perms.count
%First two dimensions will index the network structure. 
%Third dimension will index different threshold values. 
%Fourth dimension will index repetitions of the permutation test

% for perms.mean
% First two dimensions will index nework structure
% Third dimension will index repetitions of permutation test

nNet   =  numel(unique(nets));  % Number of unique networks

perms = zeros(nNet,nNet,1,numel(thresh),nRep); %5D object, permutation, cppi needs 5th dimension
pos = zeros(nNet,nNet,1,numel(thresh),nRep); %5D object, count how many positive
neg = zeros(nNet,nNet,1,numel(thresh),nRep); %5D object, count how many negative

% Quick timing test   %%% need this or not?
tic
mc_uni_permute(data,netmask,thresh,des.FxCol,s.design);  % do a permutation
toc

for i=1:nRep
    [perms(:,:,:,:,i), pos(:,:,:,:,i), ~] = mc_uni_permute(data,netmask,thresh,des.FxCol,s.design,1);
    fprintf(1,'%g\n',i)
end

save(permSave,'perms','pos','-v7.3');  %%%%  Backup, save perms and pos (you can get neg from the two), instead of everything

a.perms = perms;
%% Cell-Level Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Calc Cell-Level Statistics %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a.NetworkInclude = NetInclude;

a.stats.FDRrate  = FDRrate;

a.stats.FDRmode  = FDRmode;

a.stats.CalcP    = CalcP;

a = mc_Network_CellLevelstats(a);

a.stats.SignAlpha = SignAlpha;

a = mc_Network_SignTest(a);

%% Generate TakGraph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Call TakGraph_lowlevel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(a,'DotDilateMat')
    a = mc_TakGraph_enlarge(a);
end

[h,a] = mc_TakGraph_plot(a);

if isfield(a,'shading') && isfield(a.shading,'enable') && a.shading.enable==1
    
    a.shading.transmode = transmode;
    
    a.shading.trans0    = SingleTrans;
    
    a = mc_TakGraph_shadingtrans(a);
    
    mc_TakGraph_addshading(a);
    
end

%% Network Contingency Visualizations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Network Contingency Analyses
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
edgemat = mc_unflatten_upper_triangle(ts);
roimat = [roiMNI nets'];
nROI = size(roimat,1);
mask = zeros(nROI);

% Assign edges 
for iNet=1:length(net1)
    for i1=1:length(net2)
        mask(nets==net1(iNet),nets==net2(i1)) = 1;
        mask(nets==net2(i1), nets==net1(iNet)) = 1;
    end
end

edgemat_temp = edgemat .* mask;
roimat(:,5) = sum([sum(edgemat_temp,1) ; sum(edgemat_temp,2)']);

% Write node file
nodefile = fopen([sprintf(netName),'.node'],'w');
fprintf(nodefile,'%d\t%d\t%d\t%d\t%d\t-\n',roimat'); %Transpose is necessary b/c it will use elements in a row-major order

% Write edge file
dlmwrite([sprintf(netName),'.edge'],edgemat_temp,'\t');





              
