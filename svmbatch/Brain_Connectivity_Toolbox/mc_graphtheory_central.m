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

if ~isfield(network,'measures')
    network.measures = 'E';
    warning('Measure not selected, so only measure degree');
end

Flag.smallworld    = any(strfind(upper(network.measures),'S'));
Flag.density       = any(strfind(upper(network.measures),'D'));
Flag.transitivity  = any(strfind(upper(network.measures),'T'));
Flag.efficiency    = any(strfind(upper(network.measures),'F'));
Flag.modularity    = any(strfind(upper(network.measures),'M'));
Flag.assortativity = any(strfind(upper(network.measures),'A'));
Flag.pathlength    = any(strfind(upper(network.measures),'P'));
Flag.degree        = any(strfind(upper(network.measures),'E'));
Flag.clustering    = any(strfind(upper(network.measures),'C'));
Flag.betweenness   = any(strfind(upper(network.measures),'B'));
Flag.entropy       = any(strfind(upper(network.measures),'Y'));
Flag.eccentricity  = any(strfind(upper(network.measures),'N'));
Flag.eigenvector   = any(strfind(upper(network.measures),'V'));

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
        Names = cellstr(strcat(MDF.NamePre,num2str(MDFInclude.(MDF.Subject))));
    case 'cell'
        Names = MDFInclude.(MDF.Subject);
end  
Types = char(MDFInclude.(MDF.Type));
  
%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialization
%%%%%%%%%%%%%%%%%%%%%%%
clear CombinedOutput
clear NetworkPath

nNet = length(network.netinclude);
nSub = length(Names);
nThresh = length(network.thresh);

CombinedOutput = cell(nThresh,length(Names),nNet);
OutputMatPath = mc_GenPath( struct('Template',OutputMat,...
        'suffix','.mat',...
        'mode','makeparentdir'))
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure out Network Structure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(network,'netinclude')
    network.netinclude = -1;
    warning('Network not selected, so do wholebrain measurement');
end

if (network.netinclude~=-1)  % If the netinclude is set to -1, then means whole brain, no need to figure out the net structure then
    
    %%% Load parameter File
        
    ParamPathCheck = struct('Template',NetworkParameter,'mode','check');
    ParamPath = mc_GenPath(ParamPathCheck);
    param = load(ParamPath);
    
    %%% Look up ROI Networks
    roiMNI = param.parameters.rois.mni.coordinates;
    nets = mc_NearestNetworkNode(roiMNI,5);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load Files one by one and do the calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SubUseMark = ones(1,length(Names));
    for Sub = 1:nSub
        tic
        Subject = Names{Sub};
        display(sprintf('Now loading Number %s Subject %s',num2str(Sub),Subject));
        SubjWiseCheck = struct('Template',SubjWiseTemp,'mode','check');
        SubjWisePath  = mc_GenPath(SubjWiseCheck);
        SubjWiseFile  = load(SubjWisePath);
        SubjWiseEdgePath   = mc_GenPath('SubjWiseFile.[EdgeField]');
        SubjWiseThreshPath = mc_GenPath('SubjWiseFile.[ThreshField]');
        eval(sprintf('%s=%s;','SubjWiseEdge',SubjWiseEdgePath));
        eval(sprintf('%s=%s;','SubjWiseThresh',SubjWiseThreshPath));
        
        if (network.amplify~=1)
            SubjWiseEdge   = SubjWiseEdge/network.amplify;
            SubjWiseThresh = SubjWiseThresh/network.amplify;
        end        
        
        % Exclude the NaN elements
        SubjWiseEdge(isnan(SubjWiseEdge)) = 0;           
        SubjWiseThresh(isnan(SubjWiseThresh))=0;
        
        if isfield(network,'positive')
            network.positive = 1;
            warning('Default to use positive values only');
        end
        switch network.positive
            case 0 % Take absolute value 
                SubjWiseEdge = abs(SubjWiseEdge);  
            case 1 % Only keep positive correlations
                SubjWiseEdge(SubjWiseEdge<0)=0;       
                SubjWiseThresh(SubjWiseEdge<0)=0;   
            case 2 % Only keep negative correlations
                SubjWiseEdge(SubjWiseEdge>0)=0;       
                SubjWiseThresh(SubjWiseEdge>0)=0;
                SubjWiseEdge = abs(SubjWiseEdge);     % Then take the absolute value
                SubjWiseThresh = abs(SubjWiseThresh);
        end
        
        % partial and ztransform options only apply to pearson's r
        % correlation
        if isfield(network,'partial')
            network.partial=0;
            warning('Default not to use partial correlation');
        end
        if isfield(network,'ztransform')
            network.ztransform = 1;
            warning('Default to do z transform');
        end
        switch network.partial
            case 0
                if (network.ztransform == 1 && network.ztransdone == 0)
                    SubjWiseEdge  = mc_FisherZ(SubjWiseEdge);   % Fisher'Z transform
                    SubjWiseThresh  = mc_FisherZ(SubjWiseThresh);
                end                
            case 1     % Use Moore-Penrose pseudoinverse of r matrix to calculate the partial correlation matrix
                SubjWiseEdge = pinv(SubjWiseEdge);
                SubjWiseThresh  = pinv(SubjWiseThresh);
        end  
        
        if isfield(network,'weighted')
            network.weighted = 0;
            warning('Default to create binary graph');
        end
        
        toc
        
        for kNetwork = 1:length(network.netinclude)
            if (network.netinclude == -1)             % Keep the whole brain to snow white, or split to 7 dishes of dwarfs
                NetworkConnectRaw = SubjWiseEdge;
                NetworkThresh     = SubjWiseThresh;
            else
                networklabel = network.netinclude(kNetwork);
                NetworkConnectRaw = SubjWiseEdge(nets==networklabel,nets==networklabel);
                NetworkThresh     = SubjWiseThresh(netw==networklabel,nets==networklabel);
            end
            for tThresh = 1:nThresh
                display(sprintf('Now computing number %s Subject',num2str(Sub)));
                display(sprintf('under threshold %.2f',network.rthresh(tThresh)));
                display(sprintf('in network %d',network.netinclude(kNetwork)));
                
                tic
                
                NetworkConnect      = zeros(size(NetworkConnectRaw));
                
                if network.weighted
                    % Create weighted matrix
                    NetworkConnect(NetworkThresh>network.thresh(tThresh))=NetworkConnectRaw(NetworkThresh>network.thresh(tThresh));
                else
                    % Create binary matrix
                    NetworkConnect(NetworkThresh>network.thresh(tThresh))=1;
                end
               
                if nnz(NetworkConnect)~=0   % Add this if to avoid all 0 matrix (sometimes caused by all NaN matrix) errors when calculating modularity
                    
                    [NetworkMeasures]   = mc_graphtheory_measures(NetworkConnect,network,Flag);   %%%% MAIN MEASURE PART %%%
                    Output                   = NetworkMeasures;
                                
                    % Comupte the smallworldness
                    if Flag.smallworld
                        randcluster    = zeros(100,1);
                        randpathlength = zeros(100,1);
                        % Compute the averaged clustering coefficient and characteristic path length of 100 randomized version of the tested network with the
                        % preserved degree distribution, which is used in the smallworldness computing.
                        for k = 1:100
                            display(sprintf('loop %d',k));
                            [NetworkRandom,~] = randmio_und(NetworkConnect,5); % random graph with preserved degree distribution
                            drand         = distance_bin(NetworkRandom);
                            [lrand,~]     = charpath(drand);
                            if network.directed
                                crand = clustering_coef_bd(NetworkRandom);
                            else
                                crand = clustering_coef_bu(NetworkRandom);
                            end
                            randcluster(k)    = mean(crand);
                            randpathlength(k) = lrand;
                        end
                        RandomMeasures.cluster    = mean(randcluster);
                        RandomMeasures.pathlength = mean(randpathlength);
                        gamma                     = NetworkMeasures.cluster / RandomMeasures.cluster;
                        lambda                    = NetworkMeasures.pathlength / RandomMeasures.pathlength;
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
            clear NetworkConnectRaw
        end
        
    end        
       
SubUse = repmat(SubUseMark,1,length(network.netinclude)*nThresh);

%%%%%%%%%%%%%  Save the whole results to a mat file %%%%%%%%%%%%%

save(OutputMatPath,'CombinedOutput','-v7.3');



%%%%%%% Output Global Measure Values for each Run of each Subject %%%%%%%%%%

theFID = fopen(OutputPathFile,'w');

if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return;
end

if network.weighted
    fprintf(theFID,...
        'Subject,Type,Network,Threshold,Smallworldness,Clustering,CharateristicPathLength,GlobalDegree,GlobalStrength,Density,Transitivity,GlobalEfficiency,Modularity,Assortativity,Betweenness,Entropy,EigValue\n');
else
    fprintf(theFID,...
        'Subject,Type,Network,Threshold,Smallworldness,Clustering,CharateristicPathLength,GlobalDegree,Density,Transitivity,GlobalEfficiency,Modularity,Assortativity,Betweenness,Entropy,EigValue\n');
end

for tThresh = 1:nThresh
    for iSubject = 1:nSub        
        Subject = Names{iSubject};
        Type    = Types(iSubject);        
        for kNetwork = 1:length(network.netinclude);            
            fprintf(theFID,'%s,%s,%s,%s,',Subject,Type,num2str(network.netinclude(kNetwork)),num2str(network.thresh(tThresh)));                      
            
            if Flag.smallworld
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.smallworld);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.clustering
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.cluster);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.pathlength
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.pathlength);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.degree
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.glodeg);
                if network.weighted
                    fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.glostr);
                end
            else
                fprintf(theFID,'%s,','NA');
                if network.weighted
                    fprintf(theFID,'%s,','NA');
                end
            end
            
            if Flag.density
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.density);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.transitivity
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.trans);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.efficiency
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.eglob);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.modularity
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.modu);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.assortativity
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.assort);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.betweenness
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.btwn);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.entropy
                fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.etpy);
            else
                fprintf(theFID,'%s,','NA');
            end
            
            if Flag.eigenvector
                fprintf(theFID,'%.4f\n',CombinedOutput{tThresh,iSubject,kNetwork}.eigvalue);
            else
                fprintf(theFID,'%s\n','NA');
            end        
        end  
    end
end

fclose(theFID);
      
display('Global Measures All Done')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Second Level
%%% 1.Re-arrangement of global measure data to a 2d matrix 
%%% column is thresh label, net label and metrics, 
%%% row is each subject/thresh/net subset;
%%% 2. t-test; 3. permutation test.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(network,'ttest')
    network.ttest = 0;
    warning('No t-test for global measure if not assigned');
end
if isfield(network,'perm')
    network.perm = 0;
    warning('No permutation test for global measure if not assigned');
end
if (network.ttest || network.perm)
       
    % Column of network
    MatNet        = repmat(network.netinclude,length(CombinedOutput)*nThresh,1);
    ColNet        = MatNet(:);
    ColNet        = ColNet(SubUse==1);
    
    % Column of threshold
    ColThresh     = repmat(network.thresh,1,length(CombinedOutput)*nNet)';
    ColThresh     = ColThresh(SubUse==1);
    
    % Initialization
    data = [ColNet ColThresh];
    Metrics = {};
    input.netcol = 2;
    
    % Column of Degree
    if Flag.degree
        OutDegree     = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutDegree(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.glodeg;
                end
            end
        end
        ColDeg = OutDegree(:);      
        ColDeg = ColDeg(SubUse==1);
        data   = [data ColDeg];
        Metrics{end+1} ='GlobalDegree';
    end
                
    % Column of Density
    if Flag.density
        OutDensity    = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutDensity(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.density;
                end
            end
        end
        ColDens = OutDensity(:);     
        ColDens = ColDens(SubUse==1);
        data    = [data ColDens];
        Metrics{end+1} ='Density';
    end
    
    % Column of Clustering
    if Flag.clustering
        OutCluster    = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutCluster(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.cluster;
                end
            end
        end
        ColCluster = OutCluster(:);     
        ColCluster = ColCluster(SubUse==1);
        data       = [data ColCluster];
        Metrics{end+1} = 'Clustering';
    end
    
    % Column of CharacteristicPathLength
    if Flag.pathlength
        OutPathLength = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutPathLength(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.pathlength;
                end
            end
        end
        ColPathLength = OutPathLength(:);  
        ColPathLength = ColPathLength(SubUse==1);
        data          = [data ColPathLength];
        Metrics{end+1} = 'CharPathLength';
    end
    
    % Column of Transitivity
    if Flag.transitivity
        OutTrans      = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutTrans(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.trans;
                end
            end
        end
        ColTrans = OutTrans(:);       
        ColTrans = ColTrans(SubUse==1);
        data     = [data ColTrans];
        Metrics{end+1} = 'Transitivity';
    end
    
    % Column of GlobalEfficiency
    if Flag.efficiency
        OutEglob      = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutEglob(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.eglob;
                end
            end
        end
        ColEglob = OutEglob(:);       
        ColEglob = ColEglob(SubUse==1);
        data     = [data ColEglob];
        Metrics{end+1} = 'GlobEfficiency';
    end
    
    % Column of Modularity
    if Flag.modularity
        OutModu       = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutModu(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.modu;
                end
            end
        end
        ColModu = OutModu(:);        
        ColModu = ColModu(SubUse==1);
        data    = [data ColModu];
        Metrics{end+1} = 'Modularity';
    end
    
    % Column of Assortativity
    if Flag.assortativity
        OutAssort     = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutAssort(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.assort;
                end
            end
        end
        ColAssort = OutAssort(:);      
        ColAssort = ColAssort(SubUse==1);
        data      = [data ColAssort];
        Metrics{end+1} = 'Assortativity';
    end
    
    % Column of Betweenness
    if Flag.betweenness
        OutBtwn       = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutBtwn(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.btwn;
                end
            end
        end
        ColBtwn = OutBtwn(:);        
        ColBtwn = ColBtwn(SubUse==1);
        data    = [data ColBtwn];
        Metrics{end+1} = 'Betweenness';
    end
    
    % Column of Entropy
    if Flag.entropy
        OutEtpy       = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutEtpy(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.etpy;
                end
            end
        end
        ColEtpy = OutEtpy(:);        
        ColEtpy = ColEtpy(SubUse==1);
        data    = [data ColEtpy];
        Metrics{end+1} = 'Entropy';
    end
    
    % Column of Eigenvector
    if Flag.eigenvector
        OutEigValue   = zeros(nThresh,nSub,nNet);
        for iThresh = 1:nThresh
            for iSub = 1:nSub
                for jNet = 1:nNet
                    OutEigValue(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.eigvalue;
                end
            end
        end
        ColEig = OutEigValue(:);    
        ColEig = ColEig(SubUse==1);
        data   = [data ColEig];
        Metrics{end+1} = 'EigValue';
    end       
    
    nMetric = length(Metrics);
    
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

if network.ttest
    
    p      = zeros(nThresh,nNet,nMetric);
    t      = zeros(nThresh,nNet,nMetric);
    meancl = zeros(nThresh,nNet,nMetric);
    meanep = zeros(nThresh,nNet,nMetric);
    secl   = zeros(nThresh,nNet,nMetric);
    seep   = zeros(nThresh,nNet,nMetric);
    
    for iThresh = 1:nThresh
        input.subdata = data(data(:,1)==network.thresh(iThresh),:);
        [tresults]=mc_graphtheory_ttest(network,input,nNet,nMetric);
        p(iThresh,:,:)      = tresults.p;
        t(iThresh,:,:)      = tresults.t;
        meancl(iThresh,:,:) = tresults.meancontrol;
        meanep(iThresh,:,:) = tresults.meanexp;
        secl(iThresh,:,:)   = tresults.secontrol;
        seep(iThresh,:,:)   = tresults.seexp;
        
    end
    
    [r,c,v]=ind2sub(size(p),find(p<siglevel));
    result.sigloc=[r c v];
    result.siglevel=siglevel;
    result.p=p;
    result.t=t;
    result.meanpb=meancl;
    result.meandg=meanep;
    result.direction=sign(meanep-meancl);
    result.sepb=secl;
    result.sedg=seep;
    result.metricorder=Metrics;
    result.networkorder=network.netinclude;
    tresultsave=mc_GenPath(struct('Template',ttestOutMat,'mode','makeparentdir'));
    save(tresultsave,'result','-v7.3');
    
    % output p value to csv
    ttestOutPath=mc_GenPath(struct('Template',ttestOutPathTemplate,'mode','makeparentdir'));
    theFID = fopen(ttestOutPath,'w');
    if theFID < 0
        fprintf(1,'Error opening the csv file!\n');
        return;
    end
    fprintf(theFID,'Threshold,Network,Metric,tVal,pVal,direction\n');
    for i=1:nThresh
        for j=1:nNet
            for k=1:nMetric
                fprintf(theFID,'%.4f,',network.thresh(i));
                fprintf(theFID,'%d,',network.netinclude(j));
                fprintf(theFID,'%s,',result.metricorder{k});
                fprintf(theFID,'%.4f,',result.t(i,j,k));
                fprintf(theFID,'%.4f,',result.p(i,j,k));
                switch result.direction(i,j,k)
                    case 1
                        fprintf(theFID,'%s\n','increase');
                    case -1
                        fprintf(theFID,'%s\n','decrease');
                end
                
            end
        end
    end
    fclose(theFID);    
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Permutation Test Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if network.perm
    for iThresh = 1:nThresh
        ThreValue = num2str(network.thresh(iThresh));
        meandiff = zeros(nThresh,nNet,nMetric);
        meancl   = zeros(nThresh,nNet,nMetric);
        meanep   = zeros(nThresh,nNet,nMetric);
        secl     = zeros(nThresh,nNet,nMetric);
        seep     = zeros(nThresh,nNet,nMetric);
        
        input.subdata = data(data(:,1)==network.thresh(iThresh),:);
               
        [permresults]=mc_graphtheory_meandiff(network,input,nNet,nMetric);
        meandiff(iThresh,:,:) = permresults.submeandiff;
        meancl(iThresh,:,:)   = permresults.submeancl;
        meanep(iThresh,:,:)   = permresults.submeanep;
        secl(iThresh,:,:)     = permresults.subsecl;
        seep(iThresh,:,:)     = permresults.subseep;        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Permutation Test
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%% Permutation %%%%%%%%%%%%%%%%%%%%%%%
        if ~permDone            
            perm = zeros(nNet,nMetric,nRep);
            if permCores ~= 1
                try
                    matlabpool('open',permCores)
                    parfor i = 1:nRep
                        perm(:,:,i) = mc_graphtheory_permutation(network,input,nNet,nMetric);
                        fprintf(1,'%g\n',i);
                    end
                    matlabpool('close') 
                catch
                    matlabpool('close')
                    for i = 1:nRep
                        perm(:,:,i) = mc_graphtheory_permutation(network,input,nNet,nMetric);
                        fprintf(1,'%g\n',i);
                    end
                end
            else
                for i = 1:nRep
                    perm(:,:,i) = mc_graphtheory_permutation(network,input,nNet,nMetric);
                    fprintf(1,'%g\n',i);
                end
            end
            permLoc = mc_GenPath(struct('Template',permOutMat,'mode','makeparentdir'));
            save(permLoc,'perm','-v7.3');
        else
            permLoc = mc_GenPath(struct('Template',permOutMat,'mode','check'));
            load(permLoc);
        end            
        
        %%%%%%%%%%%%%%%%%% See the order %%%%%%%%%%%%%%%%%%
        permOrder = zeros(nThresh,nNet,nMetric);
        permpVal = zeros(nThresh,nNet,nMetric);
        for i = 1:nNet
            for j = 1:nMetric
                vector = sort(abs(squeeze(perm(i,j,:))),'descend');
                for kperm = 1:nRep
                    if abs(meandiff(iThresh,i,j))>vector(kperm)
                        permOrder(iThresh,i,j)=kperm;
                        permpVal(iThresh,i,j)=kperm/N;                        
                        break
                    end                    
                end
            end
        end
        permDirection = sign(meandiff);
        
        %%%%%%%%%%%%%% Find significant difference subset %%%%%%%%%%%%%%%%%%%%%%%
        realn=0;
        for i = 1:nNet
            for j = 1:nMetric                
                vector = sort(squeeze(perm(i,j,:)),'descend');
                N      = length(vector);
                pos    = floor(permlevel*N)+1;
                if abs(meandiff(iThresh,i,j))>abs(vector(pos))
                    realn = realn+1;
                    RealSigNet(realn)=i;
                    RealSigMetric(realn)=j;
                end
            end
            
        end                 
        %%%%%%%%%%%%%% Display Significant difference subset %%%%%%%%%%%%%%%%%%%%%%%
        disp(sprintf('Under threshold %.2f, The significant differences from permutation test happens in:\n',network.thresh(iThresh)));        
        for i = 1:realn
            disp(sprintf('Network %d with %s',network.netinclude(RealSigNet(i)),Metrics{RealSigMetric(i)}));
            disp(sprintf('meanhc - meands: %.5f',meandiff(iThresh,RealSigNet(i),RealSigMetric(i))));
            disp(sprintf('Mean of control group: %.5f +/- %.5f',meanhc(iThresh,RealSigNet(i),RealSigMetric(i)),secl(iThresh,RealSigNet(i),RealSigMetric(i))));
            disp(sprintf('Mean of disease group: %.5f +/- %.5f \n',meanep(iThresh,RealSigNet(i),RealSigMetric(i)),seep(iThresh,RealSigNet(i),RealSigMetric(i))));
        end
    end
    %%%%%%%%%%%%% Save results to mat file and csv file %%%%%%%%%%%%%%%%%%%%%%   
    permOutSave = mc_GenPath(struct('Template',permOutMat,'mode','makeparentdir'));
    save(permOutSave,'RealLevel','-v7.3');
    permOutPath = mc_GenPatn(struct('Template',permOutPathTemplate','mode','makeparentdir'));
    theFID = fopen(permOutPath,'w');
    if theFID < 0
        fprintf(1,'Error opening the csv file!\n');
        return;
    end
    fprintf(theFID,'Threshold,Network,Metric,permpVal,direction\n');
    for i=1:nThresh
        for j=1:nNet
            for k=1:nMetric
                fprintf(theFID,'%.4f,',network.thresh(i));
                fprintf(theFID,'%d,',network.netinclude(j));
                fprintf(theFID,'%s,',result.metricorder{k});
                fprintf(theFID,'%.4f,',permpVal(i,j,k));
                switch permDirection(i,j,k)
                    case 1
                        fprintf(theFID,'%s\n','increase');
                    case -1
                        fprintf(theFID,'%s\n','decrease');
                end
            end
        end
    end
    fclose(theFID); 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% node-wise measurements 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isfield(network,'node')
    network.node = 0;
    warning('No node-wise measure analysis if not assigned');
end
if isfield(network,'nodettest')
    network.nodettest = 0;
    warning('No t-test for node-wise measure if not assigned');
end
if isfield(network,'nodeperm')
    network.nodeperm = 0;
    warning('No permutation test for node-wise measure if not assigned');
end
if network.node
    if network.nodettest
        if ~exist('ttype','var')
            ttype='2-sample';
            warning('t-test type set to 2-sample ttest, please change ttype if this is not what you want');
        end
        input.ttype   = ttype;
    end
       
    if (network.nodettest||network.nodeperm)
        input.netcol  = 1;         
        input.types   = Types(SubUseMark==1);
        input.unitype = unique(Types);        
    end
    
    TDtemplatePath = mc_GenPath(struct('Template',TDtemplate,'mode','makeparentdir'));
    TDmaskPath     = mc_GenPath(struct('Template',TDmask,'mode','makeparentdir'));
    
    for tThresh = 1:nThresh
        ThreValue = ['threshold' num2str(network.thresh(tThresh))];
        for kNet=1:nNet
            if network.netinclude==-1
                Netnum = -1;
            else
                Netnum  = network.netinclude(kNet);
            end
            Netname = ['network' num2str(Netnum)];
            for nMetric=1:length(network.voxelmeasures)
                Metricname=network.voxelmeasures{n};
                SaveData = zeros(length(CombinedOutput),nSub);
                for iSub = 1:nSub
                    if SubUse(iSub)
                        Subjname=Names{iSub};
                        switch Metricname
                            case 'degree'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.deg;
                            case 'betweenness'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.nodebtwn;
                            case 'efficiency'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.eloc;
                            case 'clustering'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.nodecluster;
                            case 'eigenvector'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.eigvector;
                            case 'eccentricity'
                                OutData = CombinedOutput{tThresh,iSub,kNet}.ecc;
                            otherwise
                                display(sprintf('%s is not in the measure list yet, please add it',Metricname));
                        end
                        if network.voxelzscore
                            meanv   = mean2(OutData);
                            sdv     = std2(OutData);
                            OutSave = (OutData - meanv)./sdv;
                        else
                            OutSave = OutData;
                        end
                        %%%%%%%%%%%% save nii image of node wise measure results for doing second level in SPM %%%%%%%%%%%%%
                        if ~(network.nodettest||network.nodeperm)
                            group = Types(iSub);
                            TDgptempPath = mc_GenPath(struct('Template',TDgptemp,'mode','makeparentdir'));                          
                            mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDgptempPath,OutSave,roiMNI);
                        end              
                        SaveData(iSub,:)=OutSave;
                    end                    
                end
                NodeflSave=mc_GenPath(struct('Template',NodeflMat,'mode','makeparentdir'));
                save(NodeflSave,'SaveData','-v7.3');
                nROI = size(SaveData,2);                  
                %%%%%%%%%%%% t-test %%%%%%%%%%%%%
                if network.nodettest
                    nodet = zeros(1,nROI);
                    for iCol = 1:nROI
                        input.subdata = [ones(size(SaveData,1),1)*network.netinclude(1);SaveData(:,iCol)];                        
                        [tresults]=mc_graphtheory_ttest(network,input,1,1);
                        nodet(iCol)=tresults.t;
                    end                    
                    TDttempPath = mc_GenPath(struct('Template',TDttemp,'mode','makeparentdir'));
                    mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDttempPath,nodet,roiMNI);
                end
                %%%%%%%%%%% permutation %%%%%%%%%
                if network.nodeperm
                    nodepermpval = zeros(1,nROI);
                    nodemeandiff = zeros(1,nROI);
                    nodeperm     = zeros(1,nRep);
                    for iCol = 1:nROI
                        fprintf(1,'ROI %g\n',iCol);
                        input.subdata = [ones(size(SaveData,1),1)*network.netinclude(1);SaveData(:,iCol)];
                        [permresults] = mc_graphtheory_meandiff(network,input,1,1);
                        nodemeandiff(iCol) = permresults.submeandiff;
                        if nodepermCores ~=1
                            try
                                matlabpool('open',nodepermCores)
                                parfor i = 1:nodenRep
                                    nodeperm(i) =mc_graphtheory_permutation(network,input,1,1);
                                end
                                matlabpool('close')
                            catch
                                matlabpool('close')
                                for i = 1:nodenRep
                                    nodeperm(i) =mc_graphtheory_permutation(network,input,1,1);
                                end
                            end
                        else
                            for i = 1:nodenRep
                                nodeperm(i) =mc_graphtheory_permutation(network,input,1,1);
                            end
                        end
                        vector = sort(abs(nodeperm),'descend');
                        for kperm = 1:nodenRep
                            if abs(nodemeandiff(iCol))>vector(kperm)
                                nodepermpval(iCol)=kperm/nodenRep;
                                break
                            end
                        end
                    end
                    TDpermtempPath = mc_GenPath(struct('Template',TDpermtemp,'mode','makeparentdir'));
                    mc_graphtheory_threedmap(TDtemplatePath,TDmaskPath,TDpermtempPath,nodepermpval,roiMNI);
                end
                
                clear SaveData
            end
        end
    end   
end
