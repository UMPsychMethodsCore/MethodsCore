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

Flag.smallworld    = any(strfind(upper(graph.measures),'S'));
Flag.density       = any(strfind(upper(graph.measures),'D'));
Flag.transitivity  = any(strfind(upper(graph.measures),'T'));
Flag.efficiency    = any(strfind(upper(graph.measures),'F'));
Flag.modularity    = any(strfind(upper(graph.measures),'M'));
Flag.assortativity = any(strfind(upper(graph.measures),'A'));
Flag.pathlength    = any(strfind(upper(graph.measures),'P'));
Flag.degree        = any(strfind(upper(graph.measures),'E'));
Flag.clustering    = any(strfind(upper(graph.measures),'C'));
Flag.betweenness   = any(strfind(upper(graph.measures),'B'));
Flag.entropy       = any(strfind(upper(graph.measures),'Y'));
Flag.eccentricity  = any(strfind(upper(graph.measures),'N'));
Flag.eigenvector   = any(strfind(upper(graph.measures),'V'));

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

% add if graph.net
nets = mc_NearestNetworkNode(roiMNI,5);

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
    SubUseMark     = SubUse(1:length(Names));
    nROI           = LoadResult.nROI;
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Load Files one by one and do the calculation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    SubUseMark = ones(1,length(Names));
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
                    case 'percent'
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
                            % Create weighted matrix
                            GraphConnect(GraphThresh>graph.thresh(tThresh))=GraphConnectRaw(GraphThresh>graph.thresh(tThresh));
                        else
                            % Create binary matrix
                            GraphConnect(GraphThresh>graph.thresh(tThresh))=1;
                        end
                    case 'percent'
                        density = graph.thresh(tThresh)/100;
                        nedge = numel(GraphThresh);
                        keep  = round(nedge*density);
                        [~,index] = sort(GraphThresh(:));
                        if graph.weighted
                            % Create weighted matrix
                            GraphConnect(index(end-keep+1:end))=GraphConnectRaw(index(end-keep+1:end));
                        else
                            % Create binary matrix
                            GraphConnect(index(end-keep+1:end))=1;
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
                        Output.smallworld         = gamma / lambda;
                    end
                else
                    Output.smallworld = 0;
                    Output.cluster    = 0;
                    Output.pathlength = 0;
                    Output.glodeg     = 0;
                    Output.glostr     = 0;
                    Output.density    = 0;
                    Output.trans      = 0;
                    Output.eglob      = 0;
                    Output.modu       = 0;
                    Output.assort     = 0;
                    Output.btwn       = 0;
                    Output.etpy       = 0;
                    Output.glodeg     = 0;
                    Output.eigvalue   = 0;
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
            clear GraphConnectRaw
        end
        
    end
    
    SubUse = repmat(SubUseMark,1,length(graph.netinclude)*nThresh);
    
    nROI = length(GraphConnect);
    
    display('Saving first level global measure results');
    
    %%%%%%%%%%%%%  Save the whole results to a mat file %%%%%%%%%%%%%
    
    save(OutputMatPath,'CombinedOutput','SubUse','nROI','-v7.3');
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
    case 'percent'
        fprintf(theFID,'Subject,Type,Network,TargetDensity(in percent)');
end
if Flag.smallworld
    fprintf(theFID,',Smallworldness');
end
if Flag.clustering
    fprintf(theFID,',Clustering');
end
if Flag.pathlength
    fprintf(theFID,',CharacteristicPathLength');
end
if Flag.degree
    fprintf(theFID,',GlobalDegree');
    if graph.weighted
        fprintf(theFID,',GlobalStrength');
    end
end
if Flag.density
    fprintf(theFID,',Density');
end
if Flag.transitivity
    fprintf(theFID,',Transitivity');
end
if Flag.efficiency
    fprintf(theFID,',GlobalEfficiency');
end
if Flag.modularity
    fprintf(theFID,',Modularity');
end
if Flag.assortativity
    fprintf(theFID,',Assortativity');
end
if Flag.betweenness
    fprintf(theFID,',Betweenness');
end
if Flag.entropy
    fprintf(theFID,',Entropy');
end
if Flag.eigenvector
    fprintf(theFID,',EigValue');
end    
fprintf(theFID,'\n');

% contents
for tThresh = 1:nThresh
    for iSubject = 1:nSub        
        Subject = Names{iSubject};
        Type    = Types(iSubject);        
        for kNetwork = 1:length(graph.netinclude);
            if (graph.netinclude == -1)
                fprintf(theFID,'%s,%s,WholeBrain,%s',Subject,Type,num2str(graph.thresh(tThresh)));
            else
                fprintf(theFID,'%s,%s,%s,%s',Subject,Type,num2str(networklabel),num2str(graph.thresh(tThresh)));
            end
            if Flag.smallworld
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.smallworld);
            end
            
            if Flag.clustering
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.cluster);
            end
            
            if Flag.pathlength
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.pathlength);
            end
            
            if Flag.degree
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.glodeg);
                if graph.weighted
                    fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.glostr);
                end
            end
            
            if Flag.density
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.density);
            end
            
            if Flag.transitivity
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.trans);
            end
            
            if Flag.efficiency
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.eglob);
            end
            
            if Flag.modularity
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.modu);      
            end
            
            if Flag.assortativity
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.assort);         
            end
            
            if Flag.betweenness
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.btwn);
            end
            
            if Flag.entropy
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.etpy);
            end
            
            if Flag.eigenvector
                fprintf(theFID,',%.4f',CombinedOutput{tThresh,iSubject,kNetwork}.eigvalue);
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
    MatNet        = repmat(graph.netinclude,length(CombinedOutput)*nThresh,1);
    ColNet        = MatNet(:);
    ColNet        = ColNet(SubUse==1);
    
    % Column of threshold
    ColThresh     = repmat(graph.thresh,1,length(CombinedOutput)*nNet)';
    ColThresh     = ColThresh(SubUse==1);
    
    % Initialization
    data = [];
    FrontCol = [ColNet ColThresh];
    Metrics = {};
    nMetric = 0;
    
    input.netcol    = 1;  % in reorganized data, first column is network number
    input.threshcol = 2;  % in reorganized data, second column is threshold
    input.metcol    = 3;  % in reorganized data, third column is metric 
    input.col = 3;
    
    % Column of Degree
    if Flag.degree
        OutDegree = zeros(nThresh,nSub,nNet);
        nMetric   = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutDegree(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.glodeg;
                end
            end
        end
        ColDeg = OutDegree(:);      
        ColDeg = ColDeg(SubUse==1);
        ColMetric = repmat(nMetric,length(ColDeg),1);
        SecDeg = [FrontCol ColMetric ColDeg];        
        data   = [data;SecDeg];
        Metrics{end+1} ='GlobalDegree';
    end
    
    % Column of Strength
    if (Flag.degree && graph.weighted)
        OutStrength = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutStrength(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.glostr;
                end
            end
        end
        ColStr = OutStrength(:);      
        ColStr = ColStr(SubUse==1);
        ColMetric = repmat(nMetric,length(ColStr),1);
        SecStr = [FrontCol ColMetric ColStr];        
        data   = [data;SecStr];
        Metrics{end+1} ='GlobalStrength';        
    end
                
    % Column of Density
    if Flag.density
        OutDensity    = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutDensity(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.density;
                end
            end
        end
        ColDens = OutDensity(:);     
        ColDens = ColDens(SubUse==1);
        ColMetric = repmat(nMetric,length(ColDens),1);
        SecDens = [FrontCol ColMetric ColDens];        
        data   = [data;SecDens];
        Metrics{end+1} ='Density';
    end
    
    % Column of Clustering
    if Flag.clustering
        OutCluster    = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutCluster(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.cluster;
                end
            end
        end
        ColCluster = OutCluster(:);     
        ColCluster = ColCluster(SubUse==1);
        ColMetric = repmat(nMetric,length(ColCluster),1);
        SecCluster = [FrontCol ColMetric ColCluster];        
        data   = [data;SecCluster];
        Metrics{end+1} = 'Clustering';
    end
    
    % Column of CharacteristicPathLength
    if Flag.pathlength
        OutPathLength = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutPathLength(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.pathlength;
                end
            end
        end
        ColPathLength = OutPathLength(:);  
        ColPathLength = ColPathLength(SubUse==1);
        ColMetric = repmat(nMetric,length(ColPathLength),1);
        SecPathLength = [FrontCol ColMetric ColPathLength];        
        data   = [data;SecPathLength];
        Metrics{end+1} = 'CharPathLength';
    end
    
    % Column of Transitivity
    if Flag.transitivity
        OutTrans      = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutTrans(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.trans;
                end
            end
        end
        ColTrans = OutTrans(:);       
        ColTrans = ColTrans(SubUse==1);
        ColMetric = repmat(nMetric,length(ColTrans),1);
        SecTrans = [FrontCol ColMetric ColTrans];        
        data   = [data;SecTrans];
        Metrics{end+1} = 'Transitivity';
    end
    
    % Column of GlobalEfficiency
    if Flag.efficiency
        OutEglob      = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutEglob(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.eglob;
                end
            end
        end
        ColEglob = OutEglob(:);       
        ColEglob = ColEglob(SubUse==1);
        ColMetric = repmat(nMetric,length(ColEglob),1);
        SecEglob = [FrontCol ColMetric ColEglob];        
        data   = [data;SecEglob];
        Metrics{end+1} = 'GlobEfficiency';
    end
    
    % Column of Modularity
    if Flag.modularity
        OutModu       = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutModu(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.modu;
                end
            end
        end
        ColModu = OutModu(:);        
        ColModu = ColModu(SubUse==1);
        ColMetric = repmat(nMetric,length(ColModu),1);
        SecModu = [FrontCol ColMetric ColModu];        
        data   = [data;SecModu];
        Metrics{end+1} = 'Modularity';
    end
    
    % Column of Assortativity
    if Flag.assortativity
        OutAssort     = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutAssort(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.assort;
                end
            end
        end
        ColAssort = OutAssort(:);      
        ColAssort = ColAssort(SubUse==1);
        ColMetric = repmat(nMetric,length(ColAssort),1);
        SecAssort = [FrontCol ColMetric ColAssort];        
        data   = [data;SecAssort];
        Metrics{end+1} = 'Assortativity';
    end
    
    % Column of Betweenness
    if Flag.betweenness
        OutBtwn       = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutBtwn(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.btwn;
                end
            end
        end
        ColBtwn = OutBtwn(:);        
        ColBtwn = ColBtwn(SubUse==1);
        ColMetric = repmat(nMetric,length(ColBtwn),1);
        SecBtwn = [FrontCol ColMetric ColBtwn];        
        data   = [data;SecBtwn];
        Metrics{end+1} = 'Betweenness';
    end
    
    % Column of Entropy
    if Flag.entropy
        OutEtpy       = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutEtpy(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.etpy;
                end
            end
        end
        ColEtpy = OutEtpy(:);        
        ColEtpy = ColEtpy(SubUse==1);
        ColMetric = repmat(nMetric,length(ColEtpy),1);
        SecEtpy = [FrontCol ColMetric ColEtpy];        
        data   = [data;SecEtpy];
        Metrics{end+1} = 'Entropy';
    end
    
    % Column of Eigenvector
    if Flag.eigenvector
        OutEigValue   = zeros(nThresh,nSub,nNet);
        nMetric     = nMetric+1;
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutEigValue(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.eigvalue;
                end
            end
        end
        ColEig = OutEigValue(:);    
        ColEig = ColEig(SubUse==1);
        ColMetric = repmat(nMetric,length(ColEig),1);
        SecEig = [FrontCol ColMetric ColEig];        
        data   = [data;SecEig];
        Metrics{end+1} = 'EigValue';
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
    
    p      = zeros(nThresh,nNet,nMetric);
    t      = zeros(nThresh,nNet,nMetric);
    meancl = zeros(nThresh,nNet,nMetric);
    meanep = zeros(nThresh,nNet,nMetric);
    secl   = zeros(nThresh,nNet,nMetric);
    seep   = zeros(nThresh,nNet,nMetric);
    
    display('t-test for global measures');
    for iThresh = 1:nThresh
        input.subdata = data(data(:,input.threshcol)==graph.thresh(iThresh),:);
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
        case 'percent'
            fprintf(theFID,'TargetDensity(in percent),Network,Metric,tVal,pVal,direction\n');
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
            case 'percent'
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
        case 'percent'
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
            case 'percent'
                ThreValue = ['TargetDensity_' num2str(graph.thresh(tThresh)) '%'];
        end
        
        for kNet=1:nNet
            if graph.netinclude==-1
                Netname = 'WholeBrain';
            else
                Netname = ['network' num2str(graph.netinclude(kNet))];
            end
            
            for nMetric=1:length(graph.voxelmeasures)
                MetricLabel=graph.voxelmeasures(nMetric);
                if (graph.netinclude==-1)
                    NodeFL = zeros(nSub,nROI);
                else
                    NodeFL = zeros(nSub,sum(nets==graph.netinclude(kNet)));
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
                    if SubUse(iSub)
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
                        NodeFL(iSub,:)=NodeFLsub;
                    end
                end
                %%%%%%%%%%%% t-test %%%%%%%%%%%%%
                if graph.nodettest
                    fprintf('t-test for node-wise %s under %s in %s\n',Metricname,ThreValue,Netname);
                    input.subdata = [ones(size(NodeFL,1),1)*graph.netinclude(1) ones(size(NodeFL,1),1) NodeFL];
                    [tresults]=mc_graphtheory_ttest(graph,input,1,1);
                    nodet=squeeze(tresults.t);
                    fprintf('saving t-test results for node-wise %s under %s in %s\n',Metricname,ThreValue,Netname);
                    TDttempPath = mc_GenPath(struct('Template',TDttemp,'mode','makeparentdir'));
                    if (graph.netinclude==-1)
                        mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDttempPath,nodet,roiMNI);
                    else
                        longnodet=zeros(1,length(nets));
                        longnodet(nets==Netnum)=nodet;
                        mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDttempPath,longnodet,roiMNI);
                    end
                end
                %%%%%%%%%%% permutation %%%%%%%%%
                if graph.nodeperm
                    nodepermpval = zeros(1,nROI);
                    nodemeandiff = zeros(1,nROI);
                    nodeperm     = zeros(nRep,nROI);
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
                    
                    for iCol = 1:nROI
                        nodepermpval(iCol) = sum(abs(nodemeandiff(iCol))<=abs(nodeperm(:,iCol)))/nodenRep;
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
                        mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDpermtempPath,nodepermpval,roiMNI);
                    else
                        longnpp=ones(1,length(nets));
                        longnpp(nets==Netnum)=nodepermpval;
                        mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDpermtempPath,longnpp,roiMNI);
                    end
                end
                
                clear NodeFL
            end
        end
    end   
end

display('Node-wise Measures All Done')

