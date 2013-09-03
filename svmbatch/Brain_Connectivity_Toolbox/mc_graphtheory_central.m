%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%        Graph Theory Measurements of connectivity matrix              % 
%                           Central Script                             %
%                                                                      %
% Yu Fang 2013/01                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
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
%%% Load Name and Type Info %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MDFCheck   = struct('Template',MDF.path,'mode','check');
MDFPath    = mc_GenPath(MDFCheck);
MDFData    = dataset('File',MDFPath,'Delimiter',',');

MDFData.(MDF.include)=nominal(MDFData.(MDF.include));
MDFInclude = MDFData(MDFData.(MDF.include)=='TRUE');

Names = num2str(MDFInclude.(MDF.Subject));
Types = num2str(MDFInclude.(MDF.Type));
  
%%
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
    
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure out Network Structure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (network.netinclude~=-1)  % If the netinclude is set to -1, then means whole brain, no need to figure out the net structure then
    
    %%% Load parameter File
        
    ParamPathCheck = struct('Template',NetworkParameter,'mode','check');
    ParamPath = mc_GenPath(ParamPathCheck);
    param = load(ParamPath);
    
    %%% Look up ROI Networks
    roiMNI = param.parameters.rois.mni.coordinates;
    nets = mc_NearestNetworkNode(roiMNI,5);
    
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load Files one by one and do the calculation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SubUseMark = ones(1,length(Names));
    for Sub = 1:nSub
        tic
        Subject = Names{Sub};
        Subject = Subject(1:SubjNameLength);
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


%%
%%%%%%% Save the global results to CSV file %%%%%%%%%%

theFID = fopen(OutputPathFile,'w');

if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return;
end

%%%%%% Output Global Measure Values for each Run of each Subject %%%%%%%%%%%
% Header

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

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save subject wise results of node-wise measurements results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Multiple thresholding %%%%%%%%%%%
for tThresh = 1:nThresh
    Threname = ['threshold' num2str(network.thresh(tThresh))];
    for kNet=1:nNet
        if network.netinclude==-1
            Netnum = -1;
        else
            Netnum  = network.netinclude(kNet);
        end
        Netname = ['network' num2str(Netnum)];
        for n=1:length(network.voxelmeasures)
            Metricname=network.voxelmeasures{n};
            SaveData = zeros(length(CombinedOutput),nSub);
            for iSub = 1:nSub
                if SubUse(iSub)
                    Subjectfl=Names{iSub};
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
                    SaveData(iSub,:)=OutSave;
                end
            end
            NodeflSave=mc_GenPath(struct('Template',NodeflMat,'mode','makeparentdir'));
            save(NodeflSave,'SaveData','-v7.3');
            clear SaveData
        end       
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Re-arrangement of global measure data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (network.ttest || network.perm)
    OutCluster    = zeros(nThresh,length(CombinedOutput),nNet);
    OutPathLength = zeros(nThresh,length(CombinedOutput),nNet);
    OutTrans      = zeros(nThresh,length(CombinedOutput),nNet);
    OutEglob      = zeros(nThresh,length(CombinedOutput),nNet);
    OutModu       = zeros(nThresh,length(CombinedOutput),nNet);
    OutAssort     = zeros(nThresh,length(CombinedOutput),nNet);
    OutBtwn       = zeros(nThresh,length(CombinedOutput),nNet);
    OutEtpy       = zeros(nThresh,length(CombinedOutput),nNet);
    OutDegree     = zeros(nThresh,length(CombinedOutput),nNet);
    OutDensity    = zeros(nThresh,length(CombinedOutput),nNet);
    OutEigValue   = zeros(nThresh,length(CombinedOutput),nNet);
    for iThresh = 1:nThresh
        for iSub = 1:length(CombinedOutput)
            for jNet = 1:nNet
                %Degree
                OutDegree(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.glodeg;
                
                %Density
                OutDensity(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.density;
                
                %Clustering
                OutCluster(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.cluster;
                
                %CharacteristicPathLength
                OutPathLength(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.pathlength;
                
                %Transitivity
                OutTrans(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.trans;
                
                %GlobalEfficiency
                OutEglob(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.eglob;
                
                %Modularity
                OutModu(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.modu;
                
                %Assortativity
                OutAssort(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.assort;
                
                %Betweenness
                OutBtwn(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.btwn;
                
                %Entropy
                OutEtpy(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.etpy;
                
                %Eigenvector
                OutEigValue(iThresh,iSub,jNet) = CombinedOutput{iThresh,iSub,jNet}.eigvalue;
                
            end
        end
    end
    
    %%%%%%%%%%%%%% Rearrange the data %%%%%%%%%%%%%%%%%%
    ColCluster    = OutCluster(:);     ColCluster    = ColCluster(SubUse==1);
    ColPathLength = OutPathLength(:);  ColPathLength = ColPathLength(SubUse==1);
    ColTrans      = OutTrans(:);       ColTrans      = ColTrans(SubUse==1);
    ColEglob      = OutEglob(:);       ColEglob      = ColEglob(SubUse==1);
    ColModu       = OutModu(:);        ColModu       = ColModu(SubUse==1);
    ColAssort     = OutAssort(:);      ColAssort     = ColAssort(SubUse==1);
    ColBtwn       = OutBtwn(:);        ColBtwn       = ColBtwn(SubUse==1);
    ColEtpy       = OutEtpy(:);        ColEtpy       = ColEtpy(SubUse==1);
    ColDeg        = OutDegree(:);      ColDeg        = ColDeg(SubUse==1);
    ColDens       = OutDensity(:);     ColDens       = ColDens(SubUse==1);
    ColEig        = OutEigValue(:);    ColEig        = ColEig(SubUse==1);
    
    % Column of network
    MatNet        = repmat(network.netinclude,length(CombinedOutput)*nThresh,1);
    ColNet        = MatNet(:);
    ColNet        = ColNet(SubUse==1);
    
    % Column of threshold
    if network.ztransform
        ColThresh     = repmat(network.zthresh,1,length(CombinedOutput)*nNet)';
    else
        ColThresh     = repmat(network.rthresh,1,length(CombinedOutput)*nNet)';
    end
    ColThresh     = ColThresh(SubUse==1);
    
    % Combine to 2d matrix (column is thresh label, net label and metrics, row is each subject/thresh/net subset)
    data     = [ColThresh ColNet ColCluster ColPathLength ColTrans ColEglob ColModu ColAssort ColBtwn ColEtpy ColDeg ColDens ColEig];
    Metrics   = {'Clustering','CharPathLength','Transitivity','GlobEfficiency','Modularity','Assortativity','Betweenness','Entropy','GlobalDegree','Density','EigValue'};
    input.netcol = 2;
    
    nMetric = length(Metrics);
    
    input.types=Types(SubUseMark==1);
    input.unitype=unique(Types);
end

%%
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
    if ~exist('ttype','var')
        ttype='2-sample';
        warning('t-test type set to 2-sample ttest, please change ttype if this is not what you want');
    end
    input.ttype=ttype;
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
    OutpvaluePath=mc_GenPath(struct('Template',ttestOutPathTemplate,'suffix','.csv','mode','makeparentdir'));
    theFID = fopen(OutpvaluePath,'w');
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
 
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Permutation Test Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if network.perm
    for iThresh = 1:nThresh
        
        ThreshValue = num2str(network.rthresh(iThresh));
        
        meandiff = zeros(nThresh,nNet,nMetric);
        meanhc   = zeros(nThresh,nNet,nMetric);
        meanep   = zeros(nThresh,nNet,nMetric);
        secl     = zeros(nThresh,nNet,nMetric);
        seep     = zeros(nThresh,nNet,nMetric);
        if network.ztransform
            subdata = data(data(:,1)==network.zthresh(iThresh),:);
        else
            subdata = data(data(:,1)==network.rthresh(iThresh),:);
        end
        [submeandiff,submeanhc,submeands,subsehc,subseds]=mc_graphtheory_meandiff(types,unitype,covtype,subdata,network.netinclude,netcol,nNet,nMetric);
        meandiff(iThresh,:,:) = submeandiff;
        meanhc(iThresh,:,:)   = submeanhc;
        meanep(iThresh,:,:)   = submeands;
        secl(iThresh,:,:)     = subsehc;
        seep(iThresh,:,:)     = subseds;
        
        
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
                        perm(:,:,i) = mc_graphtheory_permutation(types,unitype,covtype,subdata,network.netinclude,netcol,nNet,nMetric);
                        fprintf(1,'%g\n',i);
                    end
                    matlabpool('close')
                catch
                    matlabpool('close')
                    for i = 1:nRep
                        perm(:,:,i) = mc_graphtheory_permutation(types,unitype,covtype,subdata,network.netinclude,netcol,nNet,nMetric);
                        fprintf(1,'%g\n',i);
                    end
                end
            else
                for i = 1:nRep
                    perm(:,:,i) = mc_graphtheory_permutation(types,unitype,covtype,subdata,network.netinclude,netcol,nNet,nMetric);
                    fprintf(1,'%g\n',i);
                end
            end
            permLoc = mc_GenPath(struct('Template',fullfile(PermOutput,permSave),'mode','makeparentdir'));
            save(permLoc,'perm','-v7.3');
        else
            permLoc = mc_GenPath(struct('Template',fullfile(PermOutput,permSave),'mode','check'));
            load(permLoc);
        end
        
        
        
        %%%%%%%%%%%%%% Computation %%%%%%%%%%%%%%%%%%%%%%%
        
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
        
        
        %%%%%%%%%%%%%%%%%% See the order %%%%%%%%%%%%%%%%%%
        RealOrder = zeros(nThresh,nNet,nMetric);
        RealLevel = zeros(nThresh,nNet,nMetric);
        for i = 1:nNet
            for j = 1:nMetric
                vector = sort(abs(squeeze(perm(i,j,:))),'descend');
                N      = length(vector);
                for k = 1:N
                    if abs(meandiff(iThresh,i,j))>vector(k)
                        RealOrder(iThresh,i,j)=k;
                        RealLevel(iThresh,i,j)=k/N;
                        break
                    end
                end
            end
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Output result
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if network.ztransform
            disp(sprintf('Under threshold %.2f, The significant differences from permutation test happens in:\n',network.zthresh(iThresh)));
        else
            disp(sprintf('Under threshold %.2f, The significant differences from permutation test happens in:\n',network.rthresh(iThresh)));
        end
        
        for i = 1:realn
            disp(sprintf('Network %d with %s',network.netinclude(RealSigNet(i)),Metrics{RealSigMetric(i)}));
            disp(sprintf('meanhc - meands: %.5f',meandiff(iThresh,RealSigNet(i),RealSigMetric(i))));
            disp(sprintf('Mean of control group: %.5f +/- %.5f',meanhc(iThresh,RealSigNet(i),RealSigMetric(i)),secl(iThresh,RealSigNet(i),RealSigMetric(i))));
            disp(sprintf('Mean of disease group: %.5f +/- %.5f \n',meanep(iThresh,RealSigNet(i),RealSigMetric(i)),seep(iThresh,RealSigNet(i),RealSigMetric(i))));
        end
    end
end




%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Over thresholds
% For each metric in each network that has been selected,
% the plot part expects vectors with the size of 1xnThresh:
%   meanhc, meands, sdhc, sdds, pval
%   nNet x nMetric x nThresh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n     = length(network.plotNet)*length(network.plotMetric);
plotorder = 0;


figure;
if network.plot
    for iNet = 1:length(network.plotNet)
        for jMetric = 1:length(network.plotMetric)
            
            NetNum    = find(network.netinclude==network.plotNet(iNet));
            MetricNum = find(strcmp(network.plotMetric{jMetric},Metrics));
            
            plotorder = plotorder+1;
            hcline = meanhc(:,NetNum,MetricNum);
            dsline = meanep(:,NetNum,MetricNum);
            hcbar  = secl(:,NetNum,MetricNum);
            dsbar  = seep(:,NetNum,MetricNum);
            subplot(2,ceil(n/2),plotorder);
            hold on;
            title(['network ' num2str(network.plotNet(iNet)) network.plotMetric{jMetric}])
            hold on;
            errorbar(hcline,hcbar,'r');
            hold on;
            errorbar(dsline,dsbar);
        end
    end
    
end


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUC of Metric - Threshold curve  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% if ~isempty(network.AUC)
%     
%     aucflag.transitivity = any(strfind(upper(network.AUC),'T'));
%     aucflag.gefficiency = any(strfind(upper(network.AUC),'G'));
%     aucflag.modularity = any(strfind(upper(network.AUC),'M'));
%     aucflag.assortativity = any(strfind(upper(network.AUC),'A'));
%     aucflag.pathlength = any(strfind(upper(network.AUC),'P'));
%     aucflag.degree = any(strfind(upper(network.AUC),'E'));
%     aucflag.clustering = any(strfind(upper(network.AUC),'C'));
%     aucflag.betweenness = any(strfind(upper(network.AUC),'B'));
%     aucflag.smallworldness = any(strfind(upper(network.AUC),'S'));
%     
%     
%     if aucflag.transitivity
%         for kNetwork = 1:length(network.netinclude)
%             auc.trans(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'trans');
%         end
%     end
%     
%     if aucflag.gefficiency
%         for kNetwork = 1:length(network.netinclude)
%             auc.eglob(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'eglob');
%         end
%     end
%     
%     if aucflag.modularity
%         for kNetwork = 1:length(network.netinclude)
%             auc.modu(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'modu');
%         end
%     end
%     
%     if aucflag.assortativity
%         for kNetwork = 1:length(network.netinclude)
%             auc.assort(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'assort');
%         end
%     end
%     
%     if aucflag.pathlength
%         for kNetwork = 1:length(network.netinclude)
%             auc.pathlength(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'pathlength');
%         end
%     end
%     
%     if aucflag.degree
%         if network.weighted
%             for kNetwork = 1:length(network.netinclude)
%                 auc.glostr(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'glostr');
%             end
%         else
%             for kNetwork = 1:length(network.netinclude)
%                 auc.glodeg(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'glodeg');
%             end
%         end
%     end
%     
%     if aucflag.clustering
%         for kNetwork = 1:length(network.netinclude)
%             auc.cluster(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'cluster');
%         end
%     end
%     
%     if aucflag.betweenness
%         for kNetwork = 1:length(network.netinclude)
%             auc.btwn(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'cluster');
%         end
%     end
%     
%     if aucflag.smallworldness
%         for kNetwork = 1:length(network.netinclude)
%             auc.smallworld(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'smallworld');
%         end
%     end
%     
%     
%     
%     save(AUCMatFile,'auc','-v7.3');
%     
%     
%     theFID = fopen(AUCPathFile,'w');
%     if theFID < 0
%         fprintf(1,'Error opening the csv file!\n');
%         return;
%     end
%     
%     fprintf(theFID,...
%         'metric');
%     for kNetwork = 1:length(network.netinclude)
%         fprintf(theFID,...
%             [',Network',num2str(network.netinclude(kNetwork))]);
%     end
%     fprintf(theFID,'\n');
%     
%     names = fieldnames(auc);
%     for nMetric = 1:length(names)
%         subname = names{nMetric};
%         fprintf(theFID,subname);
%         for kNetwork = 1:length(network.netinclude)
%             fprintf(theFID,[',',num2str(auc.(subname)(kNetwork))]);
%         end
%         fprintf(theFID,'\n');
%     end
%     
%     display('AUC results saved.')
%     
%     
%     
% end




    
    



    
    
    



