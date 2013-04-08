%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%                   MassUnivariate Connectomme Analysis                % 
%                           Central Script                             %
%                                                                      %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Create the output path
if ~exist(outputPath,'file')
    mkdir(outputPath);
end

%% Design Matrix
%%% R System Call
cd(outputPath)

FixedFxPath = fullfile(outputPath,'FixedFX.mat');
Rcmd = ['Rscript --vanilla ' mcRoot '/svmbatch/matlab_Scripts/MassUniConn/MDF_Parser.R --args ' '"'  des.csvpath   '"' ' ' '"' des.IncludeCol '"' ' ' '"' des.model '"' ' ' '"' FixedFxPath '"' ' &> /dev/null'];
Rstatus = system(Rcmd);

if Rstatus ~= 0
    error('Something went wrong in the call to R')
end

%%% Load Design Matrix
s = load(FixedFxPath);

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
%% Figure out Network Structure
%%% Load parameter File
Subject = s.subs{1};
if paired==1
    Run = RunDir{1};
end
ParamPathCheck = struct('Template',ParamTemplate,'mode','check');
ParamPath = mc_GenPath(ParamPathCheck);
param = load(ParamPath);

%%% Look up ROI Networks
roiMNI = param.parameters.rois.mni.coordinates;
nets = mc_NearestNetworkNode(roiMNI,5);
sq_blanks = zeros(size(roiMNI,1));


%%% Build Netmask
% need to generalize this to support cPPI and resting
netSort = sort(unique(nets)); % identify the unique networks

nNet   =  numel(netSort); % how many unique nets do you have?



switch matrixtype
    case 'upper'
        for iN = 1:nNet;
            for jN = iN:nNet;
                iNet = netSort(iN);
                jNet = netSort(jN);
                csq_blanks = sq_blanks;
                csq_blanks(nets==iNet,nets==jNet) = 1;  % csq: current square
                csq_blanks(nets==jNet,nets==iNet) = 1;
                csq = mc_flatten_upper_triangle(csq_blanks);
                netmask{iN,jN} = logical(csq);
            end
        end
    case 'nodiag'
        for iN = 1:nNet;
            for jN = iN:nNet;
                iNet = netSort(iN);
                jNet = netSort(jN);
                csq_blanks = sq_blanks;
                csq_blanks(nets==iNet,nets==jNet) = 1;
                csq_blanks(nets==jNet,nets==iNet) = 1;
                csq_blanks = csq_blanks - diag(diag(csq_blanks)); % zero out the diagonal
                csq = reshape(csq_blanks,size(roiMNI,1)^2,1);
                netmask{iN,jN} = logical(csq);
            end
        end
end
      
%% Fit Real Model

%%% Do the GLM
[~, ~, ~, ~, t, p] = mc_CovariateCorrection(data,s.design,3,des.FxCol);

ts = sign(t(des.FxCol,:)); % figure out the sign
ps = p(des.FxCol,:);



%%% Figure out the subthreshold edges and their sign
% will want to be able to loop over threshold probably? we rarely use that, so maybe we don't need to support?
prune = ps < thresh;
ts(~prune) = 0; % mask out everything that didn't survive pruning

ts(ts==+1) = 2; % map the positive values to 2 per mc_network_FeatRestruct standard
ts(ts==-1) = 3; % map the negative values to 3 per mc_network_FeatRestruct standard
ts(ts==+0) = 1; % map the nonsig values to 1 per mc_network_FeatRestruct standard

%%% Do CellCounting
switch matrixtype
  case 'upper'
    a.values = ts;
    a.NetworkLabels = nets;
    a = mc_Network_CellCount(mc_Network_FeatRestruct(a));
    
  case 'nodiag'
    ts_twin = mc_twinstack(ts);
    b.values = squeeze(ts_twin(:,:,1));
    b.NetworkLabels = nets;
    c.values = squeeze(ts_twin(:,:,2));
    c.NetworkLabels = nets;
    b = mc_Network_CellCount(mc_Network_FeatRestruct(b));
    c = mc_Network_CellCount(mc_Network_FeatRestruct(c));
    
    prune_up = squeeze(ts_twin(:,:,1) ~= 1); % find all of the upper diag elements that are nonone (sig)
    prune_dn = squeeze(ts_twin(:,:,2) ~= 1); % find all of the lower diag elements that are nonone (sig)
    
    overlap = all([prune_up; prune_dn],1); % identify cases where both elements were pruned
    disagree = ts_twin(:,1) - ts_twin(:,2); % calculate degree of disagreement
    disagree(~overlap) = 0; % throw out disagreements where there is no overlap
    disagreeID = find(disagree);
    
    a.values = max([b.values; c.values],[],1); % take the max. This should preserve 2s or 3s over 1s
    a.values(disagreeID) = 4; % in places with disagreements, set it to yellow
    a.NetworkLabels = nets;
    a = mc_Network_FeatRestruct(a); % get stuff resorted
    
    %combine b and c results from CellCount
    a.cellcount.cellsize = b.cellcount.cellsize + c.cellcount.cellsize;
    a.cellcount.celltot = b.cellcount.celltot + c.cellcount.celltot;
    a.cellcount.cellpos = b.cellcount.cellpos + c.cellcount.cellpos;
    a.cellcount.cellneg = b.cellcount.cellneg + c.cellcount.cellneg;
end
    

celltot = a.cellcount.celltot; % Count Edges Per Cell
cellpos = a.cellcount.cellpos; % count of positive
cellneg = a.cellcount.cellneg; % count of negative

edgemat = a.mediator.square; %snag edgemat for use down in network contingency stuff

%% Permutations

% for perms.count
%First two dimensions will index the network structure. 
%Third dimension will index different threshold values. 
%Fourth dimension will index repetitions of the permutation test

if permDone ~= 1

    perms = zeros(nNet,nNet,numel(thresh),nRep); %4D object: nNet x nNet x thresh x reps

% attempt parallel

    if permCores ~= 1
        try
            matlabpool('open',permCores)
            parfor i=1:nRep
                [count(:,:,:,i), meanT(:,:,:,i), meanB(:,:,:,i)] = mc_uni_permute(data,netmask,thresh,des.FxCol,s.design,1);
                fprintf(1,'%g\n',i)
            end
            
            perms.count = count;
            perms.meanT = meanT;
            perms.meanB = meanB;
            clear count meanT meanB
            
            matlabpool('close')
        catch
            matlabpool('close')
            for i=1:nRep
                [perms.count(:,:,:,i), perms.meanT(:,:,:,i), perms.meanB(:,:,:,i)] = mc_uni_permute(data,netmask,thresh,des.FxCol,s.design,1);
                fprintf(1,'%g\n',i)
            end
        end
    else
        for i=1:nRep
            [perms.count(:,:,:,i), perms.meanT(:,:,:,i), perms.meanB(:,:,:,i)] = mc_uni_permute(data,netmask,thresh,des.FxCol,s.design,1);
            fprintf(1,'%g\n',i)
        end
    end
    

    save(permSave,'perms','-v7.3');  %%%%  Backup
else
    load(permSave);
end


a.perms = squeeze(perms.count(:,:,1,:)); % only give it one threshold to work with
%% Cell-Level Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Calc Cell-Level Statistics %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a.stats.FDR.NetIn = NetInclude;

a.stats.FDR.Enable = 1;

a.stats.FDR.rate  = FDRrate;

a.stats.FDR.mode  = FDRmode;

a.stats.FDR.CalcP    = CalcP;

a = mc_Network_CellLevelStats(a);

%% Generate TakGraph

%%% Enlarge Dots

a.DotDilateMat = [1 0; -1 0; 0 1; 0 -1; % cross
                   -1 1; 1 1; -1 -1; 1 -1; %fill out square
                   -2 0; 0 2; 2 0; 0 -2]; % cross around square

a.colormap = [1 1 1; % make 1 white
              1 0 0; % make 2 red
              0 0 1; % make 3 blue
              1 1 0; % make 4 yellow (blended)
                    ];
if TakGraphNetSubsetEnable == 1
    a.mediator.NetSubset = TakGraphNetSubset;
end

a = mc_TakGraph_enlarge(a); % enlarge dots

%%% plot the actual graph

a = mc_TakGraph_plot(a);

%%% add shading

a = mc_TakGraph_CalcShadeColor(a);
    
a = mc_TakGraph_AddShading(a);

%%% Save the Figure

print -dbmp -r300 TakGraph.bmp

%% Network Contingency Visualizations

%%% Grab the final edgemat and roiMat
% edgemat was snagged way above, before risk of dilation
roimat = [roiMNI nets'];
roimat = roimat(a.mediator.sortIDX,:);
nets_sorted = nets(a.mediator.sortIDX);
nROI = size(roimat,1);

%%% Identify the cells that survived FDR (and were actually included in FDR)
[GoodX GoodY] = find(a.stats.FDR.hypo==1);

edgemat(edgemat==1) = 0; % set all of the nonsig edges to zero

for iCell = 1:size(GoodX,1)
    mask = zeros(nROI); % build a mask
    iNet = netSort(GoodX(iCell)); % figure out the first network's actual label
    jNet = netSort(GoodY(iCell)); % figure out the second network's label
    mask(nets_sorted == iNet, nets_sorted == jNet) = 1;
    edgemat_temp = edgemat .* mask;
    roimat_temp = roimat;
    roimat_temp(:,5) = sum([sum(logical(edgemat_temp),1) ; sum(logical(edgemat_temp),2)']); % use logical in there cuz we just want to count
    nodefile = fopen([num2str(iNet) '-' num2str(jNet),'.node'],'w');
    fprintf(nodefile,'%d\t%d\t%d\t%d\t%d\t-\n',roimat_temp'); %Transpose is necessary b/c it will use elements in a row-major order
    dlmwrite([num2str(iNet) '-' num2str(jNet) '.edge'],edgemat_temp,'\t'); % Write edge file
end

%% Cellwise Laterality

if strcmp(matrixtype,'nodiag') % if cPPI
    uplatin.roiMM = roiMNI;
    uplatin.nets = b.mediator.sorted;
    uplatin.edgemat = b.mediator.square ~= 0 & b.mediator.square ~=1;
    
    uplat = mc_LateralityCrossTabs(uplatin);
    
    dnlatin.roiMM = roiMNI;
    dnlatin.nets = c.mediator.sorted;
    dnlatin.edgemat = c.mediator.square ~= 0 & c.mediator.square ~=1;
    
    dnlat = mc_LateralityCrossTabs(dnlatin);
    
    lat = bsxfun(@plus,uplat,dnlat);
    
else
    latin.roiMM = roiMNI;
    latin.nets = a.mediator.sorted;
    latin.edgemat = a.mediator.square ~=0 & a.mediator.square ~=1;
    
    lat = mc_LateralityCrossTabs(latin);
end

%% Store Laterality and TakGraph Plotting Object
save('Results.mat','lat','a','-v7.3');  %%%%  Backup
