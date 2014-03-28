%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%        Graph Theory Measurements of connectivity matrix              % 
%                           Central Script                             %
%                                                                      %
% Yu Fang 2013/01                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%
%%% Display infomation
%%%%%%%%%%%%%%%%%%%%%%%
display ('-----')

display('I am going to compute the graph theory measurements');
OutputPathFile = mc_GenPath( struct('Template',OutputPathTemplate,...
    'suffix','.csv',...
    'mode','makeparentdir') );

display(sprintf('The global csv will be outputed to: %s', OutputPathFile));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurement flags
% 1 - include this measure
% 0 - do not include this measure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(graph,'measures')
    graph.measures = 'E';
    warning('Measure not selected, only measure degree, change the settings in template script if this is not correct');
end

FullMetrics = {'Smallworldness','Clustering','CharacteristicPathLength','GlobalDegree','GlobalStrength','Density','Transitivity',...
    'GlobalEfficiency','Modularity','Assortativity','Betweenness','Entropy','EigValue',...
    'lambda','gamma','Hierarchy','Synchronization'};    % A list of full names of possible global metrics
FieldMetrics = {'smallworld','cluster','pathlength','glodeg','glostr','density','trans',...
    'eglob','modu','assort','btwn','etpy','eigvalue',...
    'lambda','gamma','hier','sync'};  % The corresponding list of the fieldnames for each global metric
AbbMetrics = {'S','C','P','E','E','D','T',...
    'F','M','A','B','Y','V',...
    'L','G','H','O'};

for m = 1:length(FullMetrics)
    Fname = FieldMetrics{m};
    Aname = AbbMetrics{m};
    Flag.(Fname)=any(strfind(upper(graph.measures), Aname));
end
Flag.eccentricity  = any(strfind(upper(graph.measures),'N'));
if ~graph.weighted
    Flag.glostr=0;   % controlled by E, but not necessarily be true
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load Name and Type Info 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MDFCheck   = struct('Template',MDF.path,'mode','check');
MDFPath    = mc_GenPath(MDFCheck);
MDFData    = dataset('File',MDFPath,'Delimiter',',');

MDFData.(MDF.include)=nominal(MDFData.(MDF.include));
MDFInclude = MDFData(MDFData.(MDF.include)=='TRUE',:);

switch class(MDFInclude.(MDF.Subject))
    case 'double'
        Names = cellstr(strcat(NamePre,num2str(MDFInclude.(MDF.Subject))));
    case 'cell'
        Names = MDFInclude.(MDF.Subject);
end  
Types = char(MDFInclude.(MDF.Type));
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure out Network Structure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(graph,'netinclude')
    graph.netinclude = -1;
    warning('Network not selected, do wholebrain measurement');
end


%%% Load parameter File

ParamPathCheck = struct('Template',NetworkParameter,'mode','check');
ParamPath = mc_GenPath(ParamPathCheck);
param = load(ParamPath);

%%% Look up ROI Networks
roiMNI = param.parameters.rois.mni.coordinates;

%%% Figure out network label
if graph.netinclude ~= -1
    % add if graph.net
    if ~isfield(graph,'nettype')
        graph.nettype = 'Yeo';
        warning('Network parcellation type not selected, defaults to Yeo network')
    end
    switch graph.nettype
        case 'Yeo'
            nets = mc_NearestNetworkNode(roiMNI,5);  % Yeo network
        case 'WashU'
            nets = mc_WashUNetworkNode(length(roiMNI));  % WashU parcellation
    end
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialization
%%%%%%%%%%%%%%%%%%%%%%%

clear CombinedOutput

nNet = length(graph.netinclude);
nSub = length(Names);
nThresh = length(graph.thresh);

OutputMatPath = mc_GenPath(OutputMat);
existflag=0;

% Check if the measure has already been done
if exist(OutputMatPath,'file')
    LoadResult=load(OutputMatPath);
    if (isfield(LoadResult,'CombinedOutput') && isfield(LoadResult,'SubUse') && isfield(LoadResult,'nROI'))
        existflag=1;
    end
end
    
if existflag   % Use existing results if there is one   
    fprintf('Found existing file at %s, will use this directly',OutputMatPath);
    
    CombinedOutput = LoadResult.CombinedOutput;
    SubUse         = LoadResult.SubUse;
    SubUseMark     = SubUse(1:length(graph.thresh):length(graph.thresh)*length(Names));
    nROI           = LoadResult.nROI;
    if isfield(LoadResult,'AUC')
        AUC            = LoadResult.AUC;
    end
else  % Start fresh new calculation
    CombinedOutput = cell(nThresh,length(Names),nNet);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Initialize some graph default settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if ~isfield(graph,'directed')
        graph.directed = 0;
        warning('Defaults to undirected graph, change the settings in template script if this is not correct.');
    end    
    
    if ~isfield(graph,'weighted')
        graph.weighted = 0;
        warning('Defaults to create binary graph, change the settings in template script if this is not correct');
    end
    
    if ~isfield(graph,'partial')
        graph.partial=0;
        warning('Defaults not to use partial correlation, change the settings in template script if this is not correct');
    end
    
    if ~isfield(graph,'ztransform')
        graph.ztransform = 1;
        warning('Defaults to do z transform, change the settings in template script if this is not correct');
    end
    
    if ~isfield(graph,'ztransdone')
        graph.ztransdone = 0;
        warning('Assuming z transform not being done yet, change the settings in template script if this is not correct');
    end
    
    if ~isfield(graph,'value')
        graph.value = 1;
        warning('Defaults to use positive values only, change the settings in template script if this is not correct');
    end
    
    if ~isfield(graph,'threshmode')
        graph.threshmode = 'value';
        warning('Defaults to use edge value to threshold the graph, change the settings in template script if this is not correct');
    end
    
    if ~isfield(graph,'thresh')
        graph.thresh = -Inf;
        warning('Thresholding value not assigned, use unthresholded graph, change the settings in template script if this is not correct');
    end
    
    if ~isfield(graph,'FDR')
        graph.FDR = 0;
        warning('Defaults to turn off FDR correction');
    end
    
    if ~isfield(graph,'expand')
        graph.FDR = 0;
        warning('Defaults to turn off voxel expansion in 3D maps');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Load Files one by one and do the calculation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    SubUseMark = ones(1,length(Names));
    if (graph.netinclude ~= -1)
                subnROI = zeros(length(graph.netinclude),1);
    end
    for Sub = 1:nSub
        tic
        Subject = Names{Sub};
        display(sprintf('Loading Number %s Subject %s',num2str(Sub),Subject));
        SubjWiseCheck = struct('Template',SubjWiseTemp,'mode','check');
        SubjWisePath  = mc_GenPath(SubjWiseCheck);
        SubjWiseFile  = load(SubjWisePath);
        SubjWiseEdgePath   = mc_GenPath('SubjWiseFile.[EdgeField]');
        SubjWiseThreshPath = mc_GenPath('SubjWiseFile.[ThreshField]');
        eval(sprintf('%s=%s;','SubjWiseEdge',SubjWiseEdgePath));
        eval(sprintf('%s=%s;','SubjWiseThresh',SubjWiseThreshPath));
        
        if (graph.amplify~=1)
            SubjWiseEdge   = SubjWiseEdge/graph.amplify;
            SubjWiseThresh = SubjWiseThresh/graph.amplify;
        end
        
        % Exclude out of range(-1 ~ 1) values
        SubjWiseEdge(abs(SubjWiseEdge)>1)=0;
        SubjWiseThresh(abs(SubjWiseThresh)>1)=0;
        
        % Exclude the NaN elements
        SubjWiseEdge(isnan(SubjWiseEdge)) = 0;
        SubjWiseThresh(isnan(SubjWiseThresh))=0;
        
        
        switch graph.value   
            case 0
                % no change
            case 2 % Take absolute value
                SubjWiseEdge = abs(SubjWiseEdge);
                SubjWiseThresh = abs(SubjWiseThresh);
            case 1 % Only keep positive correlations
                SubjWiseEdge(SubjWiseEdge<0)=0;
                SubjWiseThresh(SubjWiseEdge<0)=0;
            case -1 % Only keep negative correlations
                SubjWiseEdge(SubjWiseEdge>0)=0;
                SubjWiseThresh(SubjWiseEdge>0)=0;
                SubjWiseEdge = abs(SubjWiseEdge);     % Then take the absolute value
                SubjWiseThresh = abs(SubjWiseThresh);
        end
        
        % partial and ztransform options only apply to pearson's r correlation
        
        switch graph.partial
            case 0
                if (graph.ztransform == 1 && graph.ztransdone == 0)
                    if graph.weighted
                        SubjWiseEdge(SubjWiseEdge==1)=0.99999; % avoid Inf after z-trans
                        SubjWiseEdge(SubjWiseEdge==-1)=-0.99999; % avoid -Inf after z-trans
                    end
                    SubjWiseEdge  = mc_FisherZ(SubjWiseEdge);   % Fisher'Z transform                    
                end
            case 1     % Use Moore-Penrose pseudoinverse of r matrix to calculate the partial correlation matrix
                SubjWiseEdge = pinv(SubjWiseEdge);
                SubjWiseThresh  = pinv(SubjWiseThresh);
        end
                
        for kNetwork = 1:length(graph.netinclude)
            
            if (graph.netinclude == -1)             % Keep the whole brain to snow white, or split to 7 dishes of dwarfs
                GraphConnectRaw = SubjWiseEdge;
                GraphThresh     = SubjWiseThresh;
            else
                networklabel = graph.netinclude(kNetwork);
                GraphConnectRaw = SubjWiseEdge(nets==networklabel,nets==networklabel);
                GraphThresh     = SubjWiseThresh(nets==networklabel,nets==networklabel);
            end                       
            
            for tThresh = 1:nThresh
                
                fprintf('Computing number %s Subject',num2str(Sub));
                switch graph.threshmode
                    case 'value'
                        fprintf(' under threshold %.2f',graph.thresh(tThresh));
                    case 'sparsity'
                        if graph.thresh(tThresh)>100
                            graph.thresh(tThresh) = 100;
                        elseif graph.thresh(tThresh)<0
                            graph.thresh(tThresh) = 0;
                        end
                        fprintf('with target density %.2f percent',graph.thresh(tThresh));
                    otherwise
                        graph.threshmode = 'value';
                        fprintf(' under threshold %.2f',graph.thresh(tThresh));
                        warning('Cannot recognize threshold mode name, default to value mode');
                end
                if (graph.netinclude == -1)
                    fprintf(' in whole brain\n');
                else
                    fprintf(' in network %d\n',networklabel);
                end    
                
                GraphConnect      = zeros(size(GraphConnectRaw));
                switch graph.threshmode
                    case 'value'
                        if graph.weighted
                            GraphConnect(GraphThresh>graph.thresh(tThresh))=GraphConnectRaw(GraphThresh>graph.thresh(tThresh));   % Create weighted matrix
                        else
                            GraphConnect(GraphThresh>graph.thresh(tThresh))=1;                                                    % Create binary matrix
                        end
                    case 'sparsity'
                        density = graph.thresh(tThresh)/100;
                        lGraph = length(GraphThresh);
                        nUpper = lGraph*(lGraph-1)/2;
                        % want to make keep-lGraph to be even
                        keep  = round(nUpper*density)*2+length(GraphThresh); % For sorting convinience, include the diagonal, which will be excluded later 
                        [~,index] = sort(GraphThresh(:));
                        if graph.weighted
                            GraphConnect(index(end-keep+1:end))=GraphConnectRaw(index(end-keep+1:end));    % Create weighted matrix
                        else
                            GraphConnect(index(end-keep+1:end))=1;                                         % Create binary matrix
                        end
                end
                
                if nnz(GraphConnect)~=0   % Add this if to avoid all 0 matrix (sometimes caused by all NaN matrix) errors when calculating modularity
                    
                    [GraphMeasures]   = mc_graphtheory_measures(GraphConnect,graph,Flag);   %%%% MAIN MEASURE PART %%%
                    Output                   = GraphMeasures;
                    
                    % Comupte the smallworldness
                    if Flag.smallworld
                        display('Calculating Smallworldness');
                        randcluster    = zeros(100,1);
                        randpathlength = zeros(100,1);
                        % Compute the averaged clustering coefficient and characteristic path length of 100 randomized version of the tested graph with the
                        % preserved degree distribution, which is used in the smallworldness computing.
                        if ~exist('smallworlditer','var')
                            smallworlditer = 100;
                            warning('Smallworldness iteration time set to 100');
                        end
                        for k = 1:smallworlditer   
                            display(sprintf('loop %d',k));
                            [GraphRandom,~] = randmio_und(GraphConnect,5); % random graph with preserved degree distribution
                            drand         = distance_bin(GraphRandom);
                            [lrand,~]     = charpath(drand);
                            if graph.directed
                                crand = clustering_coef_bd(GraphRandom);
                            else
                                crand = clustering_coef_bu(GraphRandom);
                            end
                            randcluster(k)    = mean(crand);
                            randpathlength(k) = lrand;
                        end
                        RandomMeasures.cluster    = mean(randcluster);
                        RandomMeasures.pathlength = mean(randpathlength);
                        gamma                     = GraphMeasures.cluster / RandomMeasures.cluster;
                        lambda                    = GraphMeasures.pathlength / RandomMeasures.pathlength;
                        if Flag.lambda
                            Output.lambda = lambda;
                        end
                        if Flag.gamma
                            Output.gamma = gamma;
                        end
                        Output.smallworld         = gamma / lambda;
                    end
                else 
                    for m=1:length(FieldMetrics)
                        Fname = FieldMetrics{m};
                        if Flag.(Fname) == 1
                            Output.(Fname)=0;
                        end
                    end
                    Output.deg        = [];
                    if graph.weighted
                        Output.strength = [];
                    end
                    Output.nodebtwn   = [];
                    Output.eloc       = [];
                    Output.nodecluster= [];
                    Output.eigenvector= [];
                    Output.ecc        = [];
                    SubUseMark(Sub) = 0;
                end
                
                CombinedOutput{tThresh,Sub,kNetwork} = Output;
                toc
            end
            
            subnROI(kNetwork) = length(GraphConnect);
            clear GraphConnectRaw
        end
        
    end
    
    if length(graph.thresh)>=2        
        AUC = mc_graphtheory_AUC(CombinedOutput,graph); % Calculate AUC for global metrics             
        SubUse = repmat(kron(SubUseMark,ones(1,nThresh+1)),1,length(graph.netinclude))'; % +1 for AUC
    else        
        SubUse = repmat(kron(SubUseMark,ones(1,nThresh)),1,length(graph.netinclude))'; % +1 for AUC
    end
    
    if graph.netinclude == -1
        nROI = length(GraphConnect);
    else
        nROI = subnROI;
    end
    
    display('Saving first level global measure results');
    
    
    %%%%%%%%%%%%%  Save the whole results to a mat file %%%%%%%%%%%%%
    if length(graph.thresh)>=2
        save(OutputMatPath,'CombinedOutput','SubUse','nROI','graph','AUC','-v7.3');
    else
        save(OutputMatPath,'CombinedOutput','SubUse','nROI','graph','-v7.3');
    end
end

%%%%%%%%%%% Some heads-up steps %%%%%%%%%%%%%%%%%%
sample = CombinedOutput{1,1,1};
UsedMetrics = fieldnames(sample);
statsMetrics = structfun(@numel,sample);
lGMetrics = find(statsMetrics==1);
nGMetrics = sum(statsMetrics==1);
if length(graph.thresh)>=2
    pThresh = nThresh+1;
else
    pThresh = nThresh;
end

%%%%%%% Output Global Measure Values for each Run of each Subject %%%%%%%%%%

theFID = fopen(OutputPathFile,'w');

if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return;
end

% header
switch graph.threshmode
    case 'value'
        fprintf(theFID,'Subject,Type,Network,Threshold');
    case 'sparsity'
        fprintf(theFID,'Subject,Type,Network,TargetDensity(in percent)');
end

for u = 1:nGMetrics
    pMetric  = num2str(cell2mat(UsedMetrics(lGMetrics(u))));   % Metric to print, short name is pMetric
    pFullMet = num2str(cell2mat(FullMetrics(strcmp(FieldMetrics,pMetric)==1)));   % Full name to print
    fprintf(theFID,',');
    fprintf(theFID,pFullMet);
end
 
fprintf(theFID,'\n');

% contents
for tThresh = 1:(pThresh)  % Output results for each threshold and also AUC
    for kNetwork = 1:length(graph.netinclude);
        networklabel = graph.netinclude(kNetwork);
        for iSubject = 1:nSub
            Subject = Names{iSubject};
            Type    = Types(iSubject);            
            if tThresh~=(nThresh+1)
                if (graph.netinclude == -1)
                    fprintf(theFID,'%s,%s,WholeBrain,%s',Subject,Type,num2str(graph.thresh(tThresh)));
                else
                    fprintf(theFID,'%s,%s,%s,%s',Subject,Type,num2str(networklabel),num2str(graph.thresh(tThresh)));
                end
                for u = 1:nGMetrics
                    pMetric  = num2str(cell2mat(UsedMetrics(lGMetrics(u))));
                    fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.(pMetric));
                end
            else
                if (graph.netinclude == -1)
                    fprintf(theFID,'%s,%s,WholeBrain,AUC',Subject,Type);
                else
                    fprintf(theFID,'%s,%s,%s,AUC',Subject,Type,num2str(networklabel));
                end
                for u = 1:nGMetrics
                    pMetric  = num2str(cell2mat(UsedMetrics(lGMetrics(u))));
                    fprintf(theFID,',%.4f',AUC{iSubject,kNetwork}.(pMetric));
                end                
            end                        
            fprintf(theFID,'\n');            
        end  
    end
end

fclose(theFID);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Second Level
%%% 1.Re-arrangement of global measure data to a 2d matrix 
%%% column is thresh label, net label and metrics, 
%%% row is each subject/thresh/net subset;
%%% 2. t-test; 3. permutation test.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(graph,'ttest')
    graph.ttest = 0;
    warning('No t-test for global measure if not assigned, change the settings in template script if this is not correct');
end
if ~isfield(graph,'perm')
    graph.perm = 0;
    warning('No permutation test for global measure if not assigned, change the settings in template script if this is not correct');
end
if (graph.ttest || graph.perm)
    
%%%% begin of reorganizing data %%%%
       
    % Column of network
    MatNet        = repmat(graph.netinclude,length(CombinedOutput)*pThresh,1);
    ColNet        = MatNet(:);
    ColNet        = ColNet(SubUse==1);
    
    % Column of threshold
    if length(graph.thresh)>=2
        MatThresh     = repmat([graph.thresh,200]',length(CombinedOutput)*nNet,1); % 200 is for AUC
    else
        MatThresh     = repmat(graph.thresh',length(CombinedOutput)*nNet,1);
    end
    ColThresh     = MatThresh(SubUse==1);
    
    % Initialization
    data = [];
    FrontCol = [ColNet ColThresh];
    Metrics = {};
    nMetric = 0;
    
    input.netcol    = 1;  % in reorganized data, first column is network number
    input.threshcol = 2;  % in reorganized data, second column is threshold
    input.metcol    = 3;  % in reorganized data, third column is metric 
    input.col = 3;
    
    
    for m = 1:length(FullMetrics)
        Fname = FieldMetrics{m};
        if Flag.(Fname)
            nMetric = nMetric + 1;
            OutResult = zeros(pThresh,nSub,nNet);
            for iThresh = 1:(pThresh)
                for iSub = 1:nSub
                    for jNet = 1:nNet
                        if iThresh~=(nThresh+1)
                            OutResult(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.(Fname);
                        else
                            OutResult(iThresh,iSub,jNet) = AUC{iSub,jNet}.(Fname);
                        end
                    end
                end
            end
            ColResult = OutResult(:);
            ColResult = ColResult(SubUse==1);
            ColMetric = repmat(nMetric,length(ColResult),1);
            SecResult = [FrontCol ColMetric ColResult];
            data = [data;SecResult];
            Metrics{end+1} = FullMetrics{m};
        end
    end     
    
%%%% end of reorganizing data %%%%
    
    input.types=Types(SubUseMark==1);
    input.unitype=unique(input.types);
    if ~exist('ttype','var')
        ttype='2-sample';
        warning('t-test type set to 2-sample ttest, please change ttype if this is not what you want');
    end
    input.ttype=ttype;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% t-test of global measure data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if graph.ttest
    
    p      = zeros(pThresh,nNet,nMetric);
    t      = zeros(pThresh,nNet,nMetric);
    meancl = zeros(pThresh,nNet,nMetric);
    meanep = zeros(pThresh,nNet,nMetric);
    secl   = zeros(pThresh,nNet,nMetric);
    seep   = zeros(pThresh,nNet,nMetric);
    
    display('t-test for global measures');
    for iThresh = 1:(pThresh)
        if iThresh~=(nThresh+1)
            input.subdata = data(data(:,input.threshcol)==graph.thresh(iThresh),:);
        else
            input.subdata = data(data(:,input.threshcol)==200,:);  % 200 is for AUC
        end
        [tresults]=mc_graphtheory_ttest(graph,input,nNet,nMetric);
        p(iThresh,:,:)      = tresults.p;
        t(iThresh,:,:)      = tresults.t;
        meancl(iThresh,:,:) = tresults.meancontrol;
        meanep(iThresh,:,:) = tresults.meanexp;
        secl(iThresh,:,:)   = tresults.secontrol;
        seep(iThresh,:,:)   = tresults.seexp;
        
    end
    
    display('Saving t-test results of global measures');
    [r,c,v]=ind2sub(size(p),find(p<siglevel));
    tOut.sigloc=[r c v];
    tOut.siglevel=siglevel;
    tOut.p=p;
    tOut.t=t;
    tOut.meancl=meancl;
    tOut.meanep=meanep;
    tOut.direction = sign(meanep-meancl);
    tOut.secl=secl;
    tOut.seep=seep;
    tOut.metricorder=Metrics;
    if (graph.netinclude==-1)
        tOut.networkorder='WholeBrain';
    else
        tOut.networkorder=graph.netinclude;
    end
    tOut.SigMtxOrder='Column1 - Threshold;Column2 - BrainNetwork;Column3 - Metrics';
    tresultsave=mc_GenPath(struct('Template',ttestOutMat,'mode','makeparentdir'));
    save(tresultsave,'tOut','-v7.3');
    
    % output p value to csv
    ttestOutPath=mc_GenPath(struct('Template',ttestOutPathTemplate,'mode','makeparentdir'));
    theFID = fopen(ttestOutPath,'w');
    if theFID < 0
        fprintf(1,'Error opening the csv file!\n');
        return;
    end
    switch graph.threshmode
        case 'value'
    fprintf(theFID,'Threshold,Network,Metric,tVal,pVal,direction\n');
        case 'sparsity'
            fprintf(theFID,'TargetDensity(in percent),Network,Metric,tVal,pVal,direction\n');
    end
    for i=1:pThresh
        for j=1:nNet
            for k=1:nMetric
                if i~=(nThresh+1)
                    fprintf(theFID,'%.4f,',graph.thresh(i));
                else
                    fprintf(theFID,'AUC,');
                end
                if (graph.netinclude(j)==-1)
                    fprintf(theFID,'WholeBrain,');
                else
                    fprintf(theFID,'%s,',num2str(graph.netinclude(j)));
                end
                fprintf(theFID,'%s,',tOut.metricorder{k});
                fprintf(theFID,'%.4f,',tOut.t(i,j,k));
                fprintf(theFID,'%.4f,',tOut.p(i,j,k));
                if tOut.p(i,j,k)<siglevel
                    switch tOut.direction(i,j,k)
                        case 1
                            fprintf(theFID,'%s\n','increase');
                        case -1
                            fprintf(theFID,'%s\n','decrease');
                        case 0
                            fprintf(theFID,'%s\n','nodiff');
                    end
                else
                    fprintf(theFID,'%s\n','nodiff');
                end
                
            end
        end
    end
    fclose(theFID);    
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Permutation Test Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if graph.perm
    permOut.RealSig=[];
    permpVal = zeros(nThresh,nNet,nMetric);
    meandiff = zeros(nThresh,nNet,nMetric);
    meancl   = zeros(nThresh,nNet,nMetric);
    meanep   = zeros(nThresh,nNet,nMetric);
    secl     = zeros(nThresh,nNet,nMetric);
    seep     = zeros(nThresh,nNet,nMetric);
    for iThresh = 1:nThresh
        switch graph.threshmode
            case 'value'
                if graph.thresh(iThresh)==-Inf
                    ThreValue = 'NoThreshold';
                else
                    ThreValue = ['threshold_' num2str(graph.thresh(iThresh))];
                end
            case 'sparsity'
                ThreValue = ['TargetDensity_' num2str(graph.thresh(iThresh)) '%'];
        end        
        
        input.subdata = data(data(:,input.threshcol)==graph.thresh(iThresh),:);
               
        [permresults]=mc_graphtheory_meandiff(graph,input,nNet,nMetric);
        meandiff(iThresh,:,:) = permresults.meandiff;
        meancl(iThresh,:,:)   = permresults.meancl;
        meanep(iThresh,:,:)   = permresults.meanep;
        secl(iThresh,:,:)     = permresults.secl;
        seep(iThresh,:,:)     = permresults.seep;        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Permutation Test
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%% Permutation %%%%%%%%%%%%%%%%%%%%%%%
        fprintf('Permutation test for global measure with %d times\n',nRep);
        if ~permDone            
            perm = zeros(nNet,nMetric,nRep);
            if permCores ~= 1
                try
                    matlabpool('open',permCores)
                    parfor i = 1:nRep
                        perm(:,:,i) = mc_graphtheory_permutation(graph,input,nNet,nMetric);
                        fprintf(1,'%g\n',i);
                    end
                    matlabpool('close') 
                catch
                    matlabpool('close')
                    for i = 1:nRep
                        perm(:,:,i) = mc_graphtheory_permutation(graph,input,nNet,nMetric);
                        fprintf(1,'%g\n',i);
                    end
                end
            else
                for i = 1:nRep
                    perm(:,:,i) = mc_graphtheory_permutation(graph,input,nNet,nMetric);
                    fprintf(1,'%g\n',i);
                end
            end
            permLoc = mc_GenPath(struct('Template',permSave,'mode','makeparentdir'));
            save(permLoc,'perm','-v7.3');
        else
            permLoc = mc_GenPath(struct('Template',permSave,'mode','check'));
            load(permLoc);
        end            
        
        %%%%%%%%%%%%%%%%%% See the order and find significant difference subset%%%%%%%%%%%%%%%%%%
        realn = 0;
        RealSigNet = [];
        RealSigMetric = [];
        for i = 1:nNet
            for j = 1:nMetric
                perma = single(abs(meandiff(iThresh,i,j)));  % convert to single type to avoid very small differneces
                permb = single(abs(squeeze(perm(i,j,:))));
                permpVal(iThresh,i,j) = sum(perma<=permb)/nRep;
                if permpVal(iThresh,i,j)<permlevel
                    realn = realn+1;
                    RealSigNet(realn)=i;
                    RealSigMetric(realn)=j;
                end
            end
        end       
    end
    %%%%%%%%%%%%% Save results to mat file and csv file %%%%%%%%%%%%%%%%%%%%%%  
    permOut.rawp = permpVal;
    permOut.meancl=meancl;
    permOut.meanep=meanep;
    permOut.secl=secl;
    permOut.seep=seep;
    permOut.direction = sign(meandiff);
    permOut.siglevel = permlevel;
    permOut.metricorder=Metrics;
    if (graph.netinclude==-1)
        permOut.networkorder='WholeBrain';
    else
        permOut.networkorder=graph.netinclude;
    end
    
    
    display('Saving permutation results of global measures');
    permOutSave = mc_GenPath(struct('Template',permOutMat,'mode','makeparentdir'));
    save(permOutSave,'permOut','-v7.3');    
    
    permOutPath = mc_GenPath(struct('Template',permOutPathTemplate,'mode','makeparentdir'));
    theFID = fopen(permOutPath,'w');
    if theFID < 0
        fprintf(1,'Error opening the csv file!\n');
        return;
    end
    switch graph.threshmode
        case 'value'
            fprintf(theFID,'Threshold,Network,Metric,rawpVal,direction\n');
        case 'sparsity'
            fprintf(theFID,'TargetDensity(in percent),Network,Metric,rawpVal,direction\n');
    end
    for i=1:nThresh
        for j=1:nNet
            for k=1:nMetric
                fprintf(theFID,'%.4f,',graph.thresh(i));
                if (graph.netinclude(j)==-1)
                    fprintf(theFID,'WholeBrain,');
                else
                    fprintf(theFID,'%s,',num2str(graph.netinclude(j)));
                end
                fprintf(theFID,'%s,',permOut.metricorder{k});
                fprintf(theFID,'%.4f,',permpVal(i,j,k));
                if permOut.rawp(i,j,k)<permlevel
                    switch permOut.direction(i,j,k)
                        case 1
                            fprintf(theFID,'%s\n','increase');
                        case -1
                            fprintf(theFID,'%s\n','decrease');
                        case 0
                            fprintf(theFID,'%s\n','nodiff');
                    end
                else
                    fprintf(theFID,'%s\n','nodiff');
                end
            end
        end
    end
    fclose(theFID); 
end

fprintf('Global Measures All Done\n\n')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% node-wise measurements 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(graph,'node')
    graph.node = 0;
    warning('No node-wise measure analysis as it is not assigned, change the settings in template script if this is not correct');
end

if graph.node
    if ~isfield(graph,'nodezscore')
        graph.nodezscore = 1;
        warning('Defaultly use z score for nodewise measures, change the settings in template script if this is not correct');
    end
    if ~isfield(graph,'nodettest')
        graph.nodettest = 0;
        warning('No t-test for node-wise measure as it is not assigned, change the settings in template script if this is not correct');
    end
    if ~isfield(graph,'nodeperm')
        graph.nodeperm = 0;
        warning('No permutation test for node-wise measure as it is not assigned, change the settings in template script if this is not correct');
    end
    if graph.nodettest
        if ~exist('ttype','var')
            ttype='2-sample';
            warning('t-test type set to 2-sample ttest, please change ttype if this is not what you want');
        end
        input.ttype   = ttype;
    end
       
    if (graph.nodettest||graph.nodeperm)
        input.col    = 2;  
        input.netcol = 1;
        input.metcol = 2;
        input.types   = Types(SubUseMark==1);
        input.unitype = unique(Types);        
    end
    
    TDtemplatePath = mc_GenPath(struct('Template',TDtemplate,'mode','makeparentdir'));
    TDmaskPath     = mc_GenPath(struct('Template',TDmask,'mode','makeparentdir'));
        
    
    for tThresh = 1:nThresh
        
        switch graph.threshmode
            case 'value'
                if graph.thresh(tThresh)==-Inf
                    ThreValue = 'NoThreshold';
                else
                    ThreValue = ['threshold_' num2str(graph.thresh(tThresh))];
                end
            case 'sparsity'
                ThreValue = ['TargetDensity_' num2str(graph.thresh(tThresh)) '%'];
        end
        
        for kNet=1:nNet
            if graph.netinclude==-1
                Netname = 'WholeBrain';
            else
                Netname = ['network' num2str(graph.netinclude(kNet))];
                Netnum = graph.netinclude(kNet);
            end
            
            for nMetric=1:length(graph.voxelmeasures)
                MetricLabel=graph.voxelmeasures(nMetric);
                if (graph.netinclude==-1)
                    iniNodeFL = zeros(nSub,nROI(kNet));
                else
                    iniNodeFL = zeros(nSub,sum(nets==graph.netinclude(kNet)));
                end
                
                switch MetricLabel
                    case 'E'
                        Metricname = 'degree';
                    case 'G'                       
                        Metricname = 'strength';
                    case 'B'                        
                        Metricname = 'betweenness';
                    case 'F'                        
                        Metricname = 'efficiency';
                    case 'C'                        
                        Metricname = 'clustering';
                    case 'V'                        
                        Metricname = 'eigenvector';
                    case 'N'                        
                        Metricname = 'eccentricity';
                    otherwise
                        display(sprintf('%s is not in the measure list yet, please add it',MetricLabel));
                end
                    
                
                fprintf('Computing and saving results for node-wise %s under %s in %s\n',Metricname,ThreValue,Netname);
                
                for iSub = 1:nSub
                    if SubUseMark(iSub)
                        Subjname=Names{iSub};
                        switch MetricLabel
                            case 'E'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.deg;
                            case 'G'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.strength;
                            case 'B'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.nodebtwn;
                            case 'F'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.eloc;
                            case 'C'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.nodecluster;
                            case 'V'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.eigvector;
                            case 'N'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.ecc;
                            otherwise
                                display(sprintf('%s is not in the measure list yet, please add it',MetricLabel));
                        end
                        if graph.nodezscore
                            meanv   = mean2(OutData);
                            sdv     = std2(OutData);
                            NodeFLsub = (OutData - meanv)./sdv;
                        else
                            NodeFLsub = OutData;
                        end
                        %%%%%%%%%%%% save nii image of first level node wise measure results %%%%%%%%%%%%%
                        group = Types(iSub);
                        TDgptempPath = mc_GenPath(struct('Template',TDgptemp,'mode','makeparentdir'));
                        if (graph.netinclude==-1)
                            mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDgptempPath,NodeFLsub,roiMNI);
                        else
                            longOutSave = zeros(1,length(nets));
                            longOutSave(nets==Netnum)=NodeFLsub;
                            mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDgptempPath,longOutSave,roiMNI);
                        end
                        iniNodeFL(iSub,:)=NodeFLsub;
                    end
                end
                NodeFL=iniNodeFL(SubUseMark==1,:);
                %%%%%%%%%%%% t-test %%%%%%%%%%%%%
                if graph.nodettest
                    fprintf('t-test for node-wise %s under %s in %s\n',Metricname,ThreValue,Netname);
                    input.subdata = [ones(size(NodeFL,1),1)*graph.netinclude(1) ones(size(NodeFL,1),1) NodeFL];
                    [tresults]=mc_graphtheory_ttest(graph,input,1,1);
                    nodet=squeeze(tresults.t);
                    fprintf('saving t-test results for node-wise %s under %s in %s\n',Metricname,ThreValue,Netname);
                    TDttempPath = mc_GenPath(struct('Template',TDttemp,'mode','makeparentdir'));
                    if (graph.netinclude==-1)
                        mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDttempPath,nodet,roiMNI,graph.expand);
                    else
                        longnodet=zeros(1,length(nets));
                        longnodet(nets==Netnum)=nodet;
                        mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDttempPath,longnodet,roiMNI,graph.expand);
                    end
                end
                %%%%%%%%%%% permutation %%%%%%%%%
                if graph.nodeperm
                    nodepermpval = zeros(1,nROI(kNet));
                    nodemeandiff = zeros(1,nROI(kNet));
                    nodeperm     = zeros(nRep,nROI(kNet));
                    fprintf('permutation test for node-wise %s under %s in %s with %d times\n',Metricname,ThreValue,Netname,nodenRep);
                    % calculate real mean difference
                    input.subdata = [ones(size(NodeFL,1),1)*graph.netinclude(1) ones(size(NodeFL,1),1) NodeFL];
                    [permresults] = mc_graphtheory_meandiff(graph,input,1,1);
                    nodemeandiff = squeeze(permresults.meandiff);
                    
                    if nodepermCores ~=1
                        try
                            matlabpool('open',nodepermCores)
                            parfor i = 1:nodenRep
                                fprintf(1,'perm %g\n',i);
                                nodeperm(i,:) = squeeze(mc_graphtheory_permutation(graph,input,1,1));
                            end
                            matlabpool('close')
                        catch
                            matlabpool('close')
                            for i = 1:nodenRep
                                fprintf(1,'perm %g\n',i);
                                nodeperm(i,:) = squeeze(mc_graphtheory_permutation(graph,input,1,1));
                            end              
                        end
                    else
                        for i = 1:nodenRep
                            fprintf(1,'perm %g\n',i);
                            nodeperm(i,:) = squeeze(mc_graphtheory_permutation(graph,input,1,1));
                        end
                    end
                    
                    for iCol = 1:nROI(kNet)
                        perma = single(abs(nodemeandiff(iCol)));
                        permb = single(abs(nodeperm(:,iCol)));
                        nodepermpval(iCol) = sum(perma<=permb)/nodenRep;
                    end
                                       
                    if graph.FDR
                        if ~exist('FDR','var')
                            FDR.rate = 0.05;
                            FDR.mode = 'dep';
                        else
                            if ~isfield(FDR,'rate')
                                FDR.rate = 0.05;
                            end
                            if ~isfield(FDR,'mode')
                                FDR.mode = 'dep';
                            end
                        end
                        [~,~,nodepermadjp]=fdr_bh(nodepermpval,FDR.rate,FDR.mode,[],1);
                        nodepermpval = nodepermadjp;
                    end
                    fprintf('saving permutation results for node-wise %s under %s in %s with %d times\n',Metricname,ThreValue,Netname,nodenRep);
                    TDpermtempPath = mc_GenPath(struct('Template',TDpermtemp,'mode','makeparentdir'));
                    if (graph.netinclude==-1)
                        mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDpermtempPath,nodepermpval,roiMNI,graph.expand);
                    else
                        longnpp=ones(1,length(nets));
                        longnpp(nets==Netnum)=nodepermpval;
                        mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDpermtempPath,longnpp,roiMNI,graph.expand);
                    end
                end
                
                clear NodeFL
            end
        end
    end   
end

display('Node-wise Measures All Done')

