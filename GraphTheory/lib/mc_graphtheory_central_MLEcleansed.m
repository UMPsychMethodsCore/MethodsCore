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

switch network.stream
    
    case 'm'
        
        display('I am going to compute the graph theory measurements');
        OutputPathFile1 = mc_GenPath( struct('Template',OutputPathTemplate1,...
            'suffix','.csv',...
            'mode','makeparentdir') );
        OutputPathFile2 = mc_GenPath( struct('Template',OutputPathTemplate2,...
            'suffix','.csv',...
            'mode','makeparentdir') );
        display(sprintf('The output will be stored here: %s and %s', OutputPathFile1,OutputPathFile2));
    
    case 't'
    
        display('I am going to test the threshold values');
        OutputPathFile = mc_GenPath( struct('Template',OutputPathTemplate1,...
            'suffix','.csv',...
            'mode','makeparentdir') );
        display(sprintf('The output will be stored here: %s', OutputPathFile));
    
    otherwise
        
        error('You should be either measure the metrics or selecting the threshold, check your network.stream setting');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Flag for smallworldness
%%%%%%%%%%%%%%%%%%%%%%%%%%%

tempflag = any(strfind(upper(network.measures),'S'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load Name and Type Info %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if network.cleansed

ResultsCheck = struct('Template',ResultTemp,'mode','check');
ResultsPath  = mc_GenPath(ResultsCheck);
ResultsFile  = load(ResultsPath);

Names = ResultsFile.master.Subject;
Types = ResultsFile.master.TYPE;

else
    Names = SubjDir(:,1);
    Types = SubjDir(:,2);

end
  
%%
%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialization
%%%%%%%%%%%%%%%%%%%%%%%
clear CombinedOutput
clear NetworkPath

nNet = length(network.netinclude);

nThresh = length(network.rthresh);

% NetworkConnectRaw = cell(length(Names), nNet); #####

NetworkConnectSub = cell(nNet,1);

% CombinedOutput    = cell(length(Names),nNet,length(network.sparsity));
CombinedOutput    = cell(nThresh,length(Names),nNet);

OutputMatPath = mc_GenPath( struct('Template',network.save,...
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



if ~network.subjwise
    Sub = 0;
    SubUseMark = ones(1,length(Names));   % A vector to mark whether to use data of each subject. If NetworkConnect of one subject is all zeros, will mark it as 0.
                                            % Then the data won't be selected in the following stats analysis.
                                            
    for i = 1:PartNum
        
        m = num2str(i);
        ConCatCheck = struct('Template',ConCatTemp,'mode','check');
        ConCatPath  = mc_GenPath(ConCatCheck);
        if ~network.voxel  
            ConCatFile  = load(ConCatPath);
%             Cleansed      = mc_GenPath('CleansedFile.Cleansed_Part[m]');
            ConCat      = mc_GenPath('ConCatFile.[ConCatField]');
            if PartNum>1
                ConCat = mc_GenPath(ConCat);
            end
            eval(sprintf('%s=%s;','ConCatCorr',ConCat));
            population = size(ConCatCorr,1);
        else
            MassObj = matfile(ConCatPath);
            sizecorr = size(MassObj,ConCatField);
            population = sizecorr(1);
            nFeat      = sizecorr(2);                        
        end
        
        for j = 1:population
            
            if ~network.voxel
                Sub           = Sub+1;
                flat          = ConCatCorr(j,:);                
            else
                Sub           = Sub+1;
                flat = MassObj.Corrected_R(j,1:nFeat);
            end
            if network.uptri
                uppertri            = mc_unflatten_upper_triangle(flat);
                NetworkRvalue    = uppertri + uppertri';
            else
                NetworkRvalue    = flat;
            end          
            
            NetworkRvalue(isnan(NetworkRvalue)) = 0;     % Exclude the NaN elments
            NetworkValue = zeros(size(NetworkRvalue));
            switch network.positive
                case 0
                    NetworkValue = abs(NetworkRvalue);  % Take absolute value of correlations
                case 1
                    NetworkValue = NetworkRvalue;
                    NetworkValue(NetworkValue<eps)=0;       % Only keep positive correlations
                case 2
                    NetworkValue = NetworkRvalue;
                    NetworkValue(NetworkValue>0)=0;       % Only keep negative correlations
                    NetworkValue = abs(NetworkValue);     % Then take the absolute value
            end 
            
            switch network.partial
                case 0
                    if (network.ztransform == 1 && network.ztransdone == 0)
                        NetworkValue  = mc_FisherZ(NetworkValue);   % Fisher'Z transform
                    end                    
                case 1     % Use Moore-Penrose pseudoinverse of r matrix to calculate the partial correlation matrix
                    NetworkValue = pinv(NetworkValue);
                    
            end                     
                     
            for kNetwork = 1:length(network.netinclude)
                if (network.netinclude == -1)             % Keep the whole brain to snow white, or split to 7 dishes of dwarfs
                    %                 NetworkConnectRaw{Sub,1} = NetworkValue;
                    
                    NetworkConnectRaw = NetworkValue;
                else
                    networklabel = network.netinclude(kNetwork);
                    NetworkConnectRaw = NetworkValue(nets==networklabel,nets==networklabel);
                end
                for tThresh = 1:nThresh
                    display(sprintf('Now computing Number %s Subject',num2str(Sub)));
                    display(sprintf('under threshold %.2f',network.rthresh(tThresh)));
                    display(sprintf('in network %d',network.netinclude(kNetwork)));
                    tic
                    NetworkConnectInt   = NetworkConnectRaw;
                    % Create binary matrix if being set so
                    if ~network.weighted
                        NetworkConnect      = zeros(size(NetworkConnectInt));
                        if (network.ztransform == 1)
                            NetworkConnect(NetworkConnectInt>network.zthresh(tThresh))=1;
                        else
                            NetworkConnect(NetworkConnectInt>network.rthresh(tThresh))=1;
                        end
                    else
                        NetworkConnect      = NetworkConnectInt;
                        if (network.ztransform == 1)
                            NetworkConnect(NetworkConnectInt<network.zthresh(tThresh))=0;
                        else
                            NetworkConnect(NetworkConnectInt<network.rthresh(tThresh))=0;
                        end
                    end
                    
                    
                    
                    if nnz(NetworkConnect)~=0   % Add this if to avoid all 0 matrix (sometimes caused by all NaN matrix) errors when calculating modularity
                        
                        [NetworkMeasures,Flag]   = mc_graphtheory_measures(NetworkConnect,network);   %%%% MAIN MEASURE PART %%%
                        Output                   = NetworkMeasures;
                        
                        if network.stream == 't'
                            Output.degreeLine = 2*log10(size(NetworkConnect,1));
                        end
                        
                        % Comupte the smallworldness
                        Flag.smallworld    = tempflag;
                        if Flag.smallworld
                            randcluster    = zeros(100,1);
                            randpathlength = zeros(100,1);
                            % Compute the averaged clustering coefficient and characteristic path length of 100 randomized version of the tested network with the
                            % preserved degree distribution, which is used in the smallworldness computing.
                            for k = 1:100
                                display(sprintf('loop %d',k));
                                [NetworkRandom,~] = randmio_und(NetworkConnect,network.iter); % random graph with preserved degree distribution
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
                    
                    %                 CombinedOutput{iSubject,kNetwork,mThresh} = Output; % saved variables each time
                    CombinedOutput{tThresh,Sub,kNetwork} = Output;
                    toc
                end
                clear NetworkConnectRaw
            end
                
                
              
        end
        
    end
    
else
    SubUseMark = ones(1,length(Names));
    for Sub = 1:length(Names)
        tic
        Subject = Names{Sub};
%         Subject = Subject(1:SubjNameLength);
        display(sprintf('Now loading Number %s Subject %s',num2str(Sub),Subject));
        SubjWiseCheck = struct('Template',SubjWiseTemp,'mode','check');
        SubjWisePath  = mc_GenPath(SubjWiseCheck);
        SubjWiseFile  = load(SubjWisePath);
        SubjWise      = mc_GenPath('SubjWiseFile.[SubjWiseField]');
        eval(sprintf('%s=%s;','SubjWiseCorrOri',SubjWise));
        
%         SubjWiseCorr = padarray(SubjWiseCorrOri,[0 nFlat-length(SubjWiseCorrOri)],'post');
          SubjWiseCorr=SubjWiseCorrOri;        

        if network.int
            SubjWiseCorr = SubjWiseCorr/network.amplify;
        end
        
        if network.uptri
            uppertri            = mc_unflatten_upper_triangle(SubjWiseCorr);
            NetworkRvalue    = uppertri + uppertri';
        else
            if MASfix
                NetworkRvalue = SubjWiseCorr + SubjWiseCorr';
            else
            NetworkRvalue    = SubjWiseCorr;
            end           
                
        end
        NetworkRvalue(isnan(NetworkRvalue)) = 0;           % Exclude the NaN elements
        NetworkValue     = zeros(size(NetworkRvalue));
        
        switch network.positive
            case 0
                NetworkValue = NetworkRvalue;
                NetworkValue = abs(NetworkValue);  % Take absolute value of correlations
            case 1
                NetworkValue = NetworkRvalue;
                NetworkValue(NetworkValue<0)=0;       % Only keep positive correlations
            case 2
                NetworkValue = NetworkRvalue;
                NetworkValue(NetworkValue>0)=0;       % Only keep negative correlations
                NetworkValue = abs(NetworkValue);     % Then take the absolute value
        end
        
        switch network.partial
            case 0
                if (network.ztransform == 1 && network.ztransdone == 0)
                    NetworkValue  = mc_FisherZ(NetworkValue);   % Fisher'Z transform
                end
                
            case 1     % Use Moore-Penrose pseudoinverse of r matrix to calculate the partial correlation matrix
                NetworkValue = pinv(NetworkValue);
        end        
        
        toc
        
        for kNetwork = 1:length(network.netinclude)
            if (network.netinclude == -1)             % Keep the whole brain to snow white, or split to 7 dishes of dwarfs
                %                 NetworkConnectRaw{Sub,1} = NetworkValue;
                NetworkConnectRaw = NetworkValue;
            else
                networklabel = network.netinclude(kNetwork);
                NetworkConnectRaw = NetworkValue(nets==networklabel,nets==networklabel);
            end
            for tThresh = 1:nThresh
                display(sprintf('Now computing number %s Subject',num2str(Sub)));
                display(sprintf('under threshold %.2f',network.rthresh(tThresh)));
                display(sprintf('in network %d',network.netinclude(kNetwork)));
                tic
                NetworkConnectInt   = NetworkConnectRaw;
                NetworkConnect      = zeros(size(NetworkConnectInt));
                % Create binary matrix
                if (network.ztransform == 1)
                    NetworkConnect(NetworkConnectInt>network.zthresh(tThresh))=1;
                else
                    NetworkConnect(NetworkConnectInt>network.rthresh(tThresh))=1;
                end
                % Create binary matrix if being set so
%                 if ~network.weighted
%                     NetworkConnect(NetworkConnect>0) = 1;
%                 end
                if nnz(NetworkConnect)~=0   % Add this if to avoid all 0 matrix (sometimes caused by all NaN matrix) errors when calculating modularity
                    
                    [NetworkMeasures,Flag]   = mc_graphtheory_measures(NetworkConnect,network);   %%%% MAIN MEASURE PART %%%
                    Output                   = NetworkMeasures;
                    
                    if network.stream == 't'
                        Output.degreeLine = 2*log10(size(NetworkConnect,1));
                    end
                    
                    % Comupte the smallworldness
                    Flag.smallworld    = tempflag;
                    if Flag.smallworld
                        randcluster    = zeros(100,1);
                        randpathlength = zeros(100,1);
                        % Compute the averaged clustering coefficient and characteristic path length of 100 randomized version of the tested network with the
                        % preserved degree distribution, which is used in the smallworldness computing.
                        for k = 1:100
                            display(sprintf('loop %d',k));
                            [NetworkRandom,~] = randmio_und(NetworkConnect,network.iter); % random graph with preserved degree distribution
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
                
                %                 CombinedOutput{iSubject,kNetwork,mThresh} = Output; % saved variables each time
                CombinedOutput{tThresh,Sub,kNetwork} = Output;
                toc
            end
            clear NetworkConnectRaw
        end
        
    end
    
end
        
       
SubUse = repmat(SubUseMark,1,length(network.netinclude)*nThresh);



%%%%%%%%%%%%%  Save the whole results to a mat file %%%%%%%%%%%%%

save(OutputMatPath,'CombinedOutput','-v7.3');




%%
%%%%%%% Save the global results to CSV file %%%%%%%%%%

switch network.stream
    case 'm'
        theFID = fopen(OutputPathFile1,'w');
        if theFID < 0
            fprintf(1,'Error opening the csv file!\n');
            return;
        end
    case 't'
        theFID = fopen(OutputPathFile,'w');
        if theFID < 0
            fprintf(1,'Error opening the csv file!\n');
            return;
        end
    otherwise
        error('You should be either measure the metrics or selecting the threshold, check your network.stream setting');
end

%%%%%% Output Global Measure Values for each Run of each Subject %%%%%%%%%%%
% Header
switch network.stream
    case 't'
        if network.weighted
            fprintf(theFID,...
                'Subject,Type,Network,Sparsity,Smallworldness,GlobalDegree,GlobalStrength,Density,2*log(N)\n');
        else
            fprintf(theFID,...
                'Subject,Type,Network,Sparsity,Smallworldness,GlobalDegree,Density,2*log(N)\n');
        end
    case 'm'
        if network.weighted
            fprintf(theFID,...
                'Subject,Type,Network,Threshold,Smallworldness,Clustering,CharateristicPathLength,GlobalDegree,GlobalStrength,Density,Transitivity,GlobalEfficiency,Modularity,Assortativity,Betweenness,Entropy,EigValue\n');
        else
            fprintf(theFID,...
                'Subject,Type,Network,Threshold,Smallworldness,Clustering,CharateristicPathLength,GlobalDegree,Density,Transitivity,GlobalEfficiency,Modularity,Assortativity,Betweenness,Entropy,EigValue\n');
        end
    otherwise
        error('You should be either measure the metrics or selecting the sparsity, check your network.stream setting');
end


for tThresh = 1:length(network.rthresh)
    for iSubject = 1:Sub
      
            Subject = Names{iSubject};
            Type    = Types(iSubject);        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for kNetwork = 1:length(network.netinclude);
            %         for mThresh = 1:length(network.sparsity)
            %             fprintf(theFID,'%s,%s,%s,%s,',Subject,Type,num2str(network.netinclude(kNetwork)),num2str(network.sparsity(mThresh)));
            if network.ztransform
                fprintf(theFID,'%s,%s,%s,%s,',Subject,Type,num2str(network.netinclude(kNetwork)),num2str(network.zthresh(tThresh)));
            else
                fprintf(theFID,'%s,%s,%s,%s,',Subject,Type,num2str(network.netinclude(kNetwork)),num2str(network.rthresh(tThresh)));
            end
            
            switch network.stream
                case 'm'
                    if Flag.smallworld
                        %                         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,kNetwork,mThresh}.smallworld);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.smallworld);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.clustering
                        %                         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,kNetwork,mThresh}.cluster);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.cluster);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.pathlength
                        %                         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,kNetwork,mThresh}.pathlength);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.pathlength);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.degree
                        %                         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,kNetwork,mThresh}.glodeg);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.glodeg);
                        if network.weighted
%                             fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork,mThresh}.glostr);
                            fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.glostr);
                        end
                    else
                        fprintf(theFID,'%s,','NA');
                        if network.weighted
                            fprintf(theFID,'%s,','NA');
                        end
                    end
                    
                    if Flag.density
                        %                         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,kNetwork,mThresh}.density);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.density);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.transitivity
                        %                         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,kNetwork,mThresh}.trans);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.trans);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.efficiency
                        %                         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,kNetwork,mThresh}.eglob);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.eglob);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.modularity
                        %                         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,kNetwork,mThresh}.modu);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.modu);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.assortativity
                        %                         fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,kNetwork,mThresh}.assort);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.assort);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.betweenness
                        %                         fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,kNetwork,mThresh}.btwn);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.btwn);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.entropy
                        %                         fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,kNetwork,mThresh}.etpy);
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork}.etpy);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.eigenvector
                        fprintf(theFID,'%.4f\n',CombinedOutput{tThresh,iSubject,kNetwork}.eigvalue);
                    else
                        fprintf(theFID,'%s\n','NA');
                    end
                    
                case 't'
                    
                    if Flag.smallworld
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork,mThresh}.smallworld);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.degree
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork,mThresh}.glodeg);
                        if network.weighted
                            fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork,mThresh}.glostr);
                        end
                    else
                        fprintf(theFID,'%s,','NA');
                        if network.weighted
                            fprintf(theFID,'%s,','NA');
                        end
                    end
                    
                    if Flag.density
                        fprintf(theFID,'%.4f,',CombinedOutput{tThresh,iSubject,kNetwork,mThresh}.density);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    fprintf(theFID,'%.4f\n',CombinedOutput{tThresh,iSubject,kNetwork,mThresh}.degreeLine);
                    
                otherwise
                    error('You should be either measure the metrics or selecting the sparsity, check your network.stream setting');
            end
            %         end
        end
        
        
    end
end

fclose(theFID);

switch network.stream
    case 'm'        
        display('Global Measures All Done')
    case 't'
        display('Threshold Test All Done')
    otherwise
        error('You should be either measure the metrics or selecting the sparsity, check your network.stream setting');
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save subject wise results of voxel-wise measurements results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% for now only do this under single threshold %%%%%%%%%%%

if network.netinclude==-1
        Netnum = -1;
        Netname = ['network' num2str(Netnum)];        
        for n=1:length(network.voxelmeasures)
            Metricname=network.voxelmeasures{n};
            SaveData = zeros(length(CombinedOutput),length(NetworkConnect));
            for iSub = 1:length(CombinedOutput)
                if SubUse(iSub)
                    Subjectfl=Names{iSub};
                    OutflPath  = mc_GenPath( struct('Template',network.flsave,...
                        'suffix','.mat',...
                        'mode','makeparentdir'));
                    switch Metricname
                        case 'degree'
                            OutData = CombinedOutput{1,iSub,1}.deg;
                        case 'betweenness'
                            OutData = CombinedOutput{1,iSub,1}.nodebtwn;
                        case 'efficiency'
                            OutData = CombinedOutput{1,iSub,1}.eloc;
                        case 'clustering'
                            OutData = CombinedOutput{1,iSub,1}.nodecluster;
                        case 'eigenvector'
                            OutData = CombinedOutput{1,iSub,1}.eigvector;
                        case 'eccentricity'
                            OutData = CombinedOutput{1,iSub,1}.ecc;
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
                    save(OutflPath,'OutSave','-v7.3');
                end
            end
            OutflConcat=mc_GenPath(struct('Template',network.flconcat,'mode','makeparentdir'));
            save(OutflConcat,'SaveData','-v7.3');
            clear SaveData
        end              
    
else
    for kNet=1:nNet
        
        Netnum  = network.netinclude(kNet);
        Netname = ['network' num2str(Netnum)];
         for n=1:length(network.voxelmeasures)
            Metricname=network.voxelmeasures{n};
            SaveData = zeros(length(CombinedOutput),length(NetworkConnect));
            for iSub = 1:length(CombinedOutput)
                if SubUse(iSub)
                    Subjectfl=Names{iSub};
                    OutflPath  = mc_GenPath( struct('Template',network.flsave,...
                        'suffix','.mat',...
                        'mode','makeparentdir'));
                    switch Metricname
                        case 'degree'
                            OutData = CombinedOutput{1,iSub,kNet}.deg;
                        case 'betweenness'
                            OutData = CombinedOutput{1,iSub,kNet}.nodebtwn;
                        case 'efficiency'
                            OutData = CombinedOutput{1,iSub,kNet}.eloc;
                        case 'clustering'
                            OutData = CombinedOutput{1,iSub,kNet}.nodecluster;
                        case 'eigenvector'
                            OutData = CombinedOutput{1,iSub,kNet}.eigvector;
                        case 'eccentricity'
                            OutData = CombinedOutput{1,iSub,kNet}.ecc;
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
                    save(OutflPath,'OutSave','-v7.3');
                end
            end
            OutflConcat=mc_GenPath(struct('Template',network.flconcat,'mode','makeparentdir'));
            save(OutflConcat,'SaveData','-v7.3');
            clear SaveData
        end        
    end
end
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% re-arrangement of the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%  Average Over Sparsities %%%%%%%%%%%%%%%%%%
%     if SparAve
%         AveCluster    = zeros(length(CombinedOutput),size(CombinedOutput,2));
%         AvePathLength = zeros(length(CombinedOutput),size(CombinedOutput,2));
%         AveTrans      = zeros(length(CombinedOutput),size(CombinedOutput,2));
%         AveEglob      = zeros(length(CombinedOutput),size(CombinedOutput,2));
%         AveModu       = zeros(length(CombinedOutput),size(CombinedOutput,2));
%         AveAssort     = zeros(length(CombinedOutput),size(CombinedOutput,2));
% %         AveBtwn       = zeros(length(CombinedOutput),size(CombinedOutput,2));
%         n = length(network.sparsity);
%         for iSub = 1:length(CombinedOutput)
%             for jNet = 1:size(CombinedOutput,2)
%                 %Clustering
%                 sub = 0;
%                 for kSpar = 1:n
%                     sub = sub+CombinedOutput{iSub,jNet,kSpar}.cluster;
%                 end
%                 AveCluster(iSub,jNet) = sub/n;
%                 
%                 %CharacteristicPathLength
%                 sub = 0;
%                 for kSpar = 1:n
%                     sub = sub+CombinedOutput{iSub,jNet,kSpar}.pathlength;
%                 end
%                 AvePathLength(iSub,jNet) = sub/n;
%                 
%                 %Transitivity
%                 sub = 0;
%                 for kSpar = 1:n
%                     sub = sub+CombinedOutput{iSub,jNet,kSpar}.trans;
%                 end
%                 AveTrans(iSub,jNet) = sub/n;
%                 
%                 %GlobalEfficiency
%                 sub = 0;
%                 for kSpar = 1:n
%                     sub = sub+CombinedOutput{iSub,jNet,kSpar}.eglob;
%                 end
%                 AveEglob(iSub,jNet) = sub/n;
%                 
%                 %Modularity
%                 sub = 0;
%                 for kSpar = 1:n
%                     sub = sub+CombinedOutput{iSub,jNet,kSpar}.modu;
%                 end
%                 AveModu(iSub,jNet) = sub/n;
%                 
%                 %Assortativity
%                 sub = 0;
%                 for kSpar = 1:n
%                     sub = sub+CombinedOutput{iSub,jNet,kSpar}.assort;
%                 end
%                 AveAssort(iSub,jNet) = sub/n;
%                 
%                 %Betweenness
% %                 sub = 0;
% %                 for kSpar = 1:n
% %                     sub = sub+CombinedOutput{iSub,jNet,kSpar}.btwn;
% %                 end
% %                 AveBtwn(iSub,jNet) = sub/n;
%                 
%             end
%         end
%     end

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
    % Transfer matrix to vector (order: network1 for all subs, network2 for all subs....)
%     ColCluster    = AveCluster(:);
%     ColPathLength = AvePathLength(:);
%     ColTrans      = AveTrans(:);
%     ColEglob      = AveEglob(:);
%     ColModu       = AveModu(:);
%     ColAssort     = AveAssort(:);
% %     ColBtwn       = AveBtwn(:);
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

%% 2 Sample t-test Stream
if network.ttest
    p      = zeros(nThresh,nNet,nMetric);
    t      = zeros(nThresh,nNet,nMetric);
    meanhc = zeros(nThresh,nNet,nMetric);
    meands = zeros(nThresh,nNet,nMetric);
    sehc   = zeros(nThresh,nNet,nMetric);
    seds   = zeros(nThresh,nNet,nMetric);
    input.ttype = '2-sample';
    for iThresh = 1:nThresh
        if network.ztransform
            input.subdata = data(data(:,1)==network.zthresh(iThresh),:);
        else
            input.subdata = data(data(:,1)==network.rthresh(iThresh),:);
        end
        [tresults]=mc_graphtheory_ttest(network,input,nNet,nMetric);
         p(iThresh,:,:)      = tresults.p;
         t(iThresh,:,:)      = tresults.t;
         meanhc(iThresh,:,:) = tresults.meancontrol;
         meands(iThresh,:,:) = tresults.meanexp;
         sehc(iThresh,:,:)   = tresults.secontrol;
         seds(iThresh,:,:)   = tresults.seexp;
    end
end

%% paired t-test Stream
if network.ttest
    p      = zeros(nThresh,nNet,nMetric);
    t      = zeros(nThresh,nNet,nMetric);
    meanpb = zeros(nThresh,nNet,nMetric);
    meandg = zeros(nThresh,nNet,nMetric);
    sepb   = zeros(nThresh,nNet,nMetric);
    sedg   = zeros(nThresh,nNet,nMetric);
    input.ttype = 'paired';
    for iThresh = 1:nThresh
        if network.ztransform
            input.subdata = data(data(:,1)==network.zthresh(iThresh),:);
        else
            input.subdata = data(data(:,1)==network.rthresh(iThresh),:);
        end
        [tresults]=mc_graphtheory_ttest(network,input,nNet,nMetric);
         p(iThresh,:,:)      = tresults.p;
         t(iThresh,:,:)      = tresults.t;
         meanpb(iThresh,:,:) = tresults.meancontrol;
         meandg(iThresh,:,:) = tresults.meanexp;
         sepb(iThresh,:,:)   = tresults.secontrol;
         sedg(iThresh,:,:)   = tresults.seexp;
         
    end
end
[r,c,v]=ind2sub(size(p),find(p<siglevel));
result.sigloc=[r c v];
result.siglevel=siglevel;
result.p=p;
result.t=t;
result.meanpb=meanpb;
result.meandg=meandg;
result.direction=sign(meandg-meanpb);
result.sepb=sepb;
result.sedg=sedg;
result.metricorder=Metrics;
result.networkorder=network.netinclude;
tresultsave=mc_GenPath(struct('Template',network.tsave,'mode','makeparentdir'));
save(tresultsave,'result','-v7.3');

% output p value to csv
OutpvaluePath=mc_GenPath(struct('Template',OutpvaluePathTemplate,'suffix','.csv','mode','makeparentdir'));
theFID = fopen(OutpvaluePath,'w');
if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return;
end
fprintf(theFID,'Threshold,Network,Metric,pVal,direction\n');
for i=1:nThresh
    for j=1:nNet
        for k=1:nMetric
            fprintf(theFID,'%.4f,',network.zthresh(i));
            fprintf(theFID,'%d,',network.netinclude(j));
            fprintf(theFID,'%s,',result.metricorder{k});
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
 
%% Permutation Test Stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% mean difference for real label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if network.perm
    for iThresh = 1:nThresh
        
        ThreshValue = num2str(network.rthresh(iThresh));
        
        meandiff = zeros(nThresh,nNet,nMetric);
        meanhc   = zeros(nThresh,nNet,nMetric);
        meands   = zeros(nThresh,nNet,nMetric);
        sehc     = zeros(nThresh,nNet,nMetric);
        seds     = zeros(nThresh,nNet,nMetric);
        if network.ztransform
            subdata = data(data(:,1)==network.zthresh(iThresh),:);
        else
            subdata = data(data(:,1)==network.rthresh(iThresh),:);
        end
        [submeandiff,submeanhc,submeands,subsehc,subseds]=mc_graphtheory_meandiff(types,unitype,covtype,subdata,network.netinclude,netcol,nNet,nMetric);
        meandiff(iThresh,:,:) = submeandiff;
        meanhc(iThresh,:,:)   = submeanhc;
        meands(iThresh,:,:)   = submeands;
        sehc(iThresh,:,:)     = subsehc;
        seds(iThresh,:,:)     = subseds;
        
        
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
            disp(sprintf('Mean of control group: %.5f +/- %.5f',meanhc(iThresh,RealSigNet(i),RealSigMetric(i)),sehc(iThresh,RealSigNet(i),RealSigMetric(i))));
            disp(sprintf('Mean of disease group: %.5f +/- %.5f \n',meands(iThresh,RealSigNet(i),RealSigMetric(i)),seds(iThresh,RealSigNet(i),RealSigMetric(i))));
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
            dsline = meands(:,NetNum,MetricNum);
            hcbar  = sehc(:,NetNum,MetricNum);
            dsbar  = seds(:,NetNum,MetricNum);
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

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Network-wise Measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SubUseMark = ones(1,length(SubjDir));   % A vector to mark whether to use data of each subject. 
% % If NetworkConnect of one subject is all zeros, will mark it as 0.
% % Then the data won't be selected in the following stats analysis.
% 
% 
% 
% for tThresh = 1:nThresh
%     for iSubject = 1:Sub
%         for kNetwork = 1:length(network.netinclude)
%             
%             
%             display(sprintf('Now computing Number %s Subject',num2str(iSubject)));
%             display(sprintf('under threshold %.2f',network.rthresh(tThresh)));
%             display(sprintf('in network %d',network.netinclude(kNetwork)));
%             
%             %         for mThresh = 1:length(network.sparsity)
%             
%             % Generate the binary adjacency matrix, do the computation
%             %             display(sprintf('with sparsity %.2g',network.sparsity(mThresh)));
%             tic
%             
%             
%             % Keep most siginificant connections based on sparsity
%             NetworkConnectInt   = NetworkConnectRaw{iSubject,kNetwork};
%             NetworkConnect      = zeros(size(NetworkConnectInt));
%             if (network.ztransform == 1)
%                 NetworkConnect(NetworkConnectInt>network.zthresh(tThresh))=1;
%             else
%                 NetworkConnect(NetworkConnectInt>network.rthresh(tThresh))=1;
%             end
%             
%             %             keep                = round(network.sparsity(mThresh) * numel(NetworkConnectInt));
%             
%             %             NetworkValue_flat   = reshape(NetworkConnectInt,[],1);
%             
%             %             [~,index]           = sort(NetworkValue_flat,'descend');
%             
%             %             NetworkValue_pruned = zeros(length(NetworkValue_flat),1);
%             
%             %             NetworkValue_pruned(index(1:keep)) = NetworkValue_flat(index(1:keep));
%             
%             %             NetworkConnect                     = reshape(NetworkValue_pruned,size(NetworkConnectInt,1),size(NetworkConnectInt,2));
%             
%             
%             % Create binary matrix if being set so
%             
%             if ~network.weighted
%                 NetworkConnect(NetworkConnect>0) = 1;
%             end
%             
%             
%             if nnz(NetworkConnect)~=0   % Add this if to avoid all 0 matrix (sometimes caused by all NaN matrix) errors when calculating modularity
%                 
%                 [NetworkMeasures,Flag]   = mc_graphtheory_measures(NetworkConnect,network);
%                 Output                   = NetworkMeasures;
%                 
%                 
%                 if network.stream == 't'
%                     Output.degreeLine = 2*log10(size(NetworkConnect,1));
%                 end
%                 
%                 % Comupte the smallworldness
%                 Flag.smallworld    = tempflag;
%                 if Flag.smallworld
%                     randcluster    = zeros(100,1);
%                     randpathlength = zeros(100,1);
%                     % Compute the averaged clustering coefficient and characteristic path length
%                     % of 100 randomized version of the tested network with the
%                     % preserved degree distribution, which is used in the
%                     % smallworldness computing.
%                     for k = 1:100
%                         display(sprintf('loop %d',k));
%                         [NetworkRandom,~] = randmio_und(NetworkConnect,network.iter); % random graph with preserved degree distribution
%                         drand         = distance_bin(NetworkRandom);
%                         [lrand,~]     = charpath(drand);
%                         if network.directed
%                             crand = clustering_coef_bd(NetworkRandom);
%                         else
%                             crand = clustering_coef_bu(NetworkRandom);
%                         end
%                         randcluster(k)    = mean(crand);
%                         randpathlength(k) = lrand;
%                     end
%                     RandomMeasures.cluster    = mean(randcluster);
%                     RandomMeasures.pathlength = mean(randpathlength);
%                     gamma                     = NetworkMeasures.cluster / RandomMeasures.cluster;
%                     lambda                    = NetworkMeasures.pathlength / RandomMeasures.pathlength;
%                     Output.smallworld         = gamma / lambda;
%                 end
%             else
%                 Output.smallworld = 0;
%                 Output.cluster    = 0;
%                 Output.pathlength = 0;
%                 Output.glodeg     = 0;
%                 Output.glostr     = 0;
%                 Output.density    = 0;
%                 Output.trans      = 0;
%                 Output.eglob      = 0;
%                 Output.modu       = 0;
%                 Output.assort     = 0;
%                 Output.btwn       = 0;
%                 Output.etpy       = 0;
%                 Output.glodeg     = 0;
%                 
%                 Output.deg        = [];
%                 Output.nodebtwn   = [];
%                 Output.eloc       = [];
%                 Output.nodecluster= [];
%                 
%                 SubUseMark(iSubject) = 0;
%                 
%             end
%             
%             
%             %                 CombinedOutput{iSubject,kNetwork,mThresh} = Output; % saved variables each time
%             CombinedOutput{tThresh,iSubject,kNetwork} = Output; % saved variables each time
%             
%             
%             
%             
%             %             save(OutputMatPath,'CombinedOutput','-v7.3'); % Save to a mat file each loop for safe
%             
%             toc
%             %         end
%         end
%     end
% end
% 
% SubUse = repmat(SubUseMark,1,length(network.netinclude)*nThresh);



    
    


    
    



    
    
    



