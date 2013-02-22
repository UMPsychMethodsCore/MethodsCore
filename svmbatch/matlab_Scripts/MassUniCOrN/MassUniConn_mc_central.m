%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%                   MassUnivariate Connectomme Analysis                % 
%                           Central Script                             %
%                                                                      %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Load the design matrix data %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DesMtrxPathCheck  = struct('Template',DesMtrxTemplate,'mode','check');
DesMtrxPath  = mc_GenPath(DesMtrxPath);
s  = load(DesMtrxPath);
s.subs(:,2) = num2cell(1); % add a second column
s.design(:,2:end) = mc_SweepMean(s.design(:,2:end)); % mean center covariates of the first column

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
%%%%% Load subjects data %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CorrPathCheck = struct('Template',CorrTemplate,'mode','check');
CorrPath = mc_GenPath(CorrPathCheck);
data = mc_load_connectomes_unpaired(s.subs,CorrPath);  % input: subject list
data = mc_connectome_clean(data);

%%%%%%%%%%%%%%%%%%%
%%%%% Network %%%%%
%%%%%%%%%%%%%%%%%%%

ParamPathCheck = struct('Template',ParamTemplate,'mode','check');
ParamPath = mc_GenPath(ParamPathCheck);
param = load(ParamPath);


roiMNI = param.parameters.rois.mni.coordinates;
nets = mc_NearestNetworkNode(roiMNI,5);
sq_blanks = zeros(size(roiMNI,1));

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Fit the real model %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~, ~, ~, ~, t, p] = mc_CovariateCorrection(data,s.design,1,2); % 2: tell the code which column we care about 

ts = sign(t(2,:)); % figure out the sign

ts(ts==+1) = 3; % map the positive values to 3 (flip the direction since autism is 1)
ts(ts==-1) = 2; % map the negative values to 2 (flip direction)
ts(ts==+0) = 1;

a.pruneColor.values = ts;
a.prune = p(2,:) < thresh(1);
a.NetworkLabels = nets;
a.DotDilateMat = [1 0; -1 0; 0 1; 0 -1; % cross
                   -1 1; 1 1; -1 -1; 1 -1; %fill out square
                   -2 0; 0 2; 2 0; 0 -2]; % cross around square

a.pruneColor.map = [1 1 1; % make 1 white
                    1 0 0; % make 2 red
                    0 0 1; % make 3 blue
                    ];
a.shading.enable = enable;
a.shading.statMode = statmode;


a = mc_Network_mediator(a);
a = mc_Network_Cellcount(a);

celltot = a.cellcount.celltot;     % Count Edges Per Cell
cellpos = a.cellcount.cellpos; %%% count of positive
cellneg = a.cellcount.cellneg; %%% count of negative

%%%%%%%%%%%%%%%%%%%%%%%
%%%% Permutations %%%%%
%%%%%%%%%%%%%%%%%%%%%%%

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
mc_uni_permute(data,netmask,thresh,permcol,s.design);  % do a permutation
toc

for i=1:nRep
    [perms(:,:,:,:,i) pos(:,:,:,:,i) ~] = mc_uni_permute(data,netmask,thresh,permcol,s.design,1);
    fprintf(1,'%g\n',i)
end

save(permSave,'perms','pos','-v7.3');  %%%%  Backup, save perms and pos (you can get neg from the two), instead of everything

a.shading.ePDF = squeeze(perms(:,:,1,1,:));
a.perms = perms;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Calc Cell-Level Statistics %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a.NetworkInclude = NetInclude;

a = mc_Network_CellLevelstats(a);

a = mc_Network_SignTest(a);

% work directly with celltot

% permstot = perms;
% 
% for i = 1:size(celltot,1)
%     for j = i:size(celltot,2)
%         epval.full(i,j) = sum(celltot(i,j) <= squeeze(permstot(i,j,1,1,:)))/size(permstot,5);
%     end
% end
% 
% % Subset (Select the networks we want) 
% NetIncludeMat = NetInclude + 1; % shift 1 from network label to matrix label
% epval.mini.sq = epval.full(NetIncludeMat,NetIncludeMat);  % only network 1 - 7 (remember network starts from 0)
% 
% % Unroll(matrix -> vector, only use diagonal and upper triangle)
% ctr = 1;
% for i=1:size(epval.mini.sq,1)
%     for j = i:size(epval.mini.sq,2)
%         epval.mini.flat(ctr) = epval.mini.sq(i,j);
%         ctr = ctr+1;
%     end
% end
% 
% % FDR (get the adjusted p-Values)
% [h, critp, adjp] = fdr_bh(epval.mini.flat,thresh(3),FDRmode,[],CalcP);
% 
% % Reroll (vector -> matrix)
% ctr = 1;
% for i=1:size(epval.mini.sq,1)
%     for j = i:size(epval.mini.sq,2)
%         epval.mini.rebuild(i,j) = h(ctr);
%         epval.mini.adjp(i,j) = adjp(ctr);
%         ctr = ctr+1;
%     end
% end
% 
% epval.mini.rebuild
% epval.mini.adjp        %%% do we want to save them in a file??


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Call TakGraph_lowlevel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(a,'DotDilateMat')
    a = mc_TakGraph_enlarge(a);
end

[h,a] = mc_TakGraph_plot(a);

if isfield(a,'shading') && isfield(a.shading,'enable') && a.shading.enable==1
    
    a = mc_TakGraph_shadingtrans(a);
    
    mc_TakGraph_addshading(a);
    
end


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





              