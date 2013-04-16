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
        OutputPathFile = mc_GenPath( struct('Template',OutputPathTemplate,...
            'suffix','.csv',...
            'mode','makeparentdir') );
        display(sprintf('The output will be stored here: %s', OutputPathFile));
    
    otherwise
        
        error('You should be either measure the metrics or selecting the threshold, check your network.stream setting');
end


display('These are the subjects:')
display(SubjDir)
display ('-----')

    


%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialization
%%%%%%%%%%%%%%%%%%%%%%%
clear CombinedOutput
clear NetworkPath

NetworkConnectRaw = cell(size(SubjDir,1), size(RunDir,1));

NetworkConnectSub = cell(length(network.netinclude),1);

CombinedOutput    = cell(size(SubjDir,1),size(RunDir,1),length(network.netinclude),length(network.sparsity));

OutputMatPath = mc_GenPath( struct('Template',network.save,...
        'suffix','.mat',...
        'mode','makeparentdir'));
    
AUCMatFile = mc_GenPath( struct('Template',network.aucSave,...
        'suffix','.mat',...
        'mode','makeparentdir'));
    
AUCPathFile = mc_GenPath( struct('Template',AUCTemplate,...
        'suffix','.csv',...
        'mode','makeparentdir') );


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Flag for smallworldness
%%%%%%%%%%%%%%%%%%%%%%%%%%%

tempflag = any(strfind(upper(network.measures),'S'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure out Network Structure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (network.netinclude~=-1)  % If the netinclude is set to -1, then means whole brain, no need to figure out the net structure then
    
    %%% Load parameter File
    Subject = SubjDir{1};
    Run = RunDir{1};
    
    ParamPathCheck = struct('Template',NetworkParameter,'mode','check');
    ParamPath = mc_GenPath(ParamPathCheck);
    param = load(ParamPath);
    
    %%% Look up ROI Networks
    roiMNI = param.parameters.rois.mni.coordinates;
    nets = mc_NearestNetworkNode(roiMNI,5);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch network.datatype
    case 'r'
        for iSubject = 1:size(SubjDir,1)
            Subject = SubjDir{iSubject,1};
            for jRun = 1:size(SubjDir{iSubject,3},2)   % Loop over runs
                RunNum = SubjDir{iSubject,3}(jRun);
                Run    = RunDir{RunNum};
                display(sprintf('Now loading files in %s',Run));
                display(sprintf('of %s',Subject));
                
                switch TemplateType                    
                    case 'single'                        
                        NetworkPathCheck  = struct('Template',NetworkTemplate,'mode','check');
                        NetworkPath       = mc_GenPath(NetworkPathCheck);   
                      
                    case 'averaged'
                        for i = 1:TemplateAverageRun
                            %%%%%% MAS MSIT CORRECTED TSCORE %%%%%
                            NetworkPathCheck{i}  = struct('Template',NetworkTemplate{i},'mode','check');
                            NetworkPath{i}      = mc_GenPath(NetworkPathCheck{i});                            
                        end
                        clear i
                    otherwise
                        error('TemplateType should be single or averaged, other type names are not accepted');
                end
                                
                NetworkParameters = load(NetworkPath,'rMatrix');
                NetworkRvalue     = NetworkParameters.rMatrix;
                if (network.ztransform == 1)
                    NetworkValue  = mc_FisherZ(NetworkRvalue);   % Fisher'Z transform
                else
                    NetworkValue  = NetworkRvalue;
                end
                
                if (network.positive == 1)
                    NetworkValue(NetworkValue<0)=0;       % Only keep positive correlations
                else
                    NetworkValue = abs(NetworkValue);     % Take absolute value of correlations
                end
                
                NetworkValue(isnan(NetworkValue))=0;     % Exclude the NaN elments
                
                if (network.netinclude == -1)
                    NetworkConnectRaw{iSubject,jRun,1} = NetworkValue;
                else
                    for kNetwork = 1:length(network.netinclude)
                        networklabel = network.netinclude(kNetwork);
                        NetworkConnectRaw{iSubject,jRun,kNetwork} = NetworkValue(nets==networklabel,nets==networklabel);
                    end
                    
                end             
                
            end
        end
        
    case 'b'
    otherwise 
        error('You need to either load r matrix or beta matrix')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
for iSubject = 1:size(SubjDir,1)    % Loop over subjects
    Subject = SubjDir{iSubject,1};
    for jRun = 1:size(SubjDir{iSubject,3},2)   % Loop over runs
        RunNum = SubjDir{iSubject,3}(jRun);
        Run    = RunDir{RunNum};
        display(sprintf('Now computing %s',Run));
        display(sprintf('of %s',Subject));
        
        for kNetwork = 1:length(network.netinclude)  
            display(sprintf('in network %d',network.netinclude(kNetwork)));
            for mThresh = 1:length(network.sparsity)                               
                % Generate the binary adjacency matrix, do the computation
                display(sprintf('with sparsity %.2g',network.sparsity(mThresh)));
                tic
                switch network.datatype
                    case 'r'                     
                        
                        % Keep most siginificant connections based on sparsity
                        NetworkConnectInt   = NetworkConnectRaw{iSubject,jRun,kNetwork};
                        
                        keep                = round(network.sparsity(mThresh) * numel(NetworkConnectInt));
                        
                        NetworkValue_flat   = reshape(NetworkConnectInt,[],1);
                        
                        [~,index]           = sort(NetworkValue_flat,'descend');
                        
                        NetworkValue_pruned = zeros(length(NetworkValue_flat),1);
                        
                        NetworkValue_pruned(index(1:keep)) = NetworkValue_flat(index(1:keep));
                        
                        NetworkConnect                     = reshape(NetworkValue_pruned,size(NetworkConnectInt,1),size(NetworkConnectInt,2));
                        
                        % Create binary matrix if being set so
                        
                        if ~network.weighted
                            NetworkConnect(NetworkConnect>0) = 1;
                        end
                        
                    case 'b'
%                         switch TemplateType
%                             case 'single'
%                                 NetworkParameters = load(NetworkPath,'cppi_grid');
%                                 [sizex, sizey]=size(NetworkParameters.cppi_grid{BRow,Column(1)});
%                                 NetworkBeta   = zeros(sizex,sizey);
%                                 for j = 1:length(Column)
%                                     NetworkBeta = NetworkBeta + NetworkParameters.cppi_grid{BRow,Column(j)};
%                                 end
%                                 clear j;
%                                 NetworkBeta = NetworkBeta./length(Column);
%                             case 'averaged'
%                                 for i = 1:TemplateAverageRun
%                                     NetworkParameters{i} = load(NetworkPath{i});
%                                 end
%                                 clear i
%                                 [sizex,sizey] = size(NetworkParameters{1}.RecoverTscore);
%                                 NetworkTscore = zeros(sizex,sizey);
%                                 for j = 1:TemplateAverageRun
%                                     NetworkTscore = NetworkTscore + NetworkParameters{j}.RecoverTscore;
%                                 end
%                                 clear j;
%                                 NetworkTscore = NetworkTscore./TemplateAverageRun;
%                             otherwise
%                                 error('TemplateType should be single or averaged, other type names are not accepted');
%                         end
%                         
%                         NetworkBeta(isnan(NetworkBeta)) = 0; % Exclude the NaN elements
%                         
%                         switch network.loc
%                             case 0
%                                 NetworkBetaint    = (triu(NetworkBeta)+triu(NetworkBeta.'))./2; % Average standardized beta over upper and lower triangulars
%                                 NetworkBetaAve    = triu(NetworkBetaint,1)+NetworkBetaint.';
%                                 NetworkValue      = NetworkBetaAve;
%                             case 1
%                                 NetworkBetaint   = triu(NetworkBeta,1)+tril(NetworkBeta.');
%                                 NetworkValue     = NetworkBetaint;
%                             case 2
%                                 NetworkBetaint   = tril(NetworkBeta,1)+triu(NetworkBeta.');
%                                 NetworkValue     = NetworkBetaAve;
%                         end
%                         if (network.positive == 1)
%                             NetworkValue(NetworkValue<0)=0;       % Only keep positive correlations
%                         else
%                             NetworkValue = abs(NetworkValue);     % Take absolute value of correlations
%                         end
%                         
%                         %%%%%%%%%% Need Edit, sparsity %%%%%%%%%%%%
%                         
%                         if ~network.weighted
%                             NetworkConnect(NetworkConnect>0) = 1;
%                         end
                end
                
                [NetworkMeasures,Flag]   = mc_graphtheory_measures(NetworkConnect,network.directed,network.weighted,network.measures);
                Output                   = NetworkMeasures;
                if network.stream == 't'
                    Output.degreeLine = 2*log10(size(NetworkConnect,1));
                end
                
                % Comupte the smallworldness
                Flag.smallworld    = tempflag;
                if Flag.smallworld
                    randcluster    = zeros(100,1);
                    randpathlength = zeros(100,1);
                    % Compute the averaged clustering coefficient and characteristic path length
                    % of 100 randomized version of the tested network with the
                    % preserved degree distribution, which is used in the
                    % smallworldness computing.
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
                
                CombinedOutput{iSubject,jRun,kNetwork,mThresh} = Output; % saved variables each time
                
                save(OutputMatPath,'CombinedOutput','-v7.3'); % Save to a mat file each loop for safe
                
                toc
            end
        end
        
    end
end

%%%%%%%%%%%%%  Save the whole results to a mat file %%%%%%%%%%%%%

save(OutputMatPath,'CombinedOutput','-v7.3');


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
                'Subject,Run,Network,Sparsity,Smallworldness,GlobalDegree,GlobalStrength,Density,2*log(N)\n');
        else
            fprintf(theFID,...
                'Subject,Run,Network,Sparsity,Smallworldness,GlobalDegree,Density,2*log(N)\n');
        end
    case 'm'
        if network.weighted
        fprintf(theFID,...
            'Subject,Run,Network,Sparsity,Smallworldness,Clustering,CharateristicPathLength,GlobalDegree,GlobalStrength,Density,Transitivity,GlobalEfficiency,Modularity,Assortativity\n');
        else
            fprintf(theFID,...
            'Subject,Run,Network,Sparsity,Smallworldness,Clustering,CharateristicPathLength,GlobalDegree,Density,Transitivity,GlobalEfficiency,Modularity,Assortativity\n');
        end
    otherwise
        error('You should be either measure the metrics or selecting the sparsity, check your network.stream setting');
end



for iSubject = 1:size(SubjDir,1)
    Subject = SubjDir{iSubject,1};
    for jRun = 1:size(SubjDir{iSubject,3},2)
        RunNum = SubjDir{iSubject,3}(jRun);
        
        %%%%% Select appropriate output based on h user has set
%         index=strfind(NetworkTemplate,'Run');
%         if size(index)>0
            RunString=RunDir{jRun};
%         else
%             RunString=num2str(jRun);
%         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for kNetwork = 1:length(network.netinclude);
        for mThresh = 1:length(network.sparsity)
            fprintf(theFID,'%s,%s,%s,%s,',Subject,RunString,num2str(network.netinclude(kNetwork)),num2str(network.sparsity(mThresh)));
            
            switch network.stream
                case 'm'
                    if Flag.smallworld
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.smallworld);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.clustering
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.cluster);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.pathlength
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.pathlength);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.degree
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.glodeg);
                        if network.weighted
                            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.glostr);
                        end
                    else
                        fprintf(theFID,'%s,','NA');
                        if network.weighted
                            fprintf(theFID,'%s,','NA');
                        end
                    end                    
                    
                    if Flag.density
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.density);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.transitivity
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.trans);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.gefficiency
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.eglob);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.modularity
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.modu);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.assortativity
                        fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.assort);
                    else
                        fprintf(theFID,'%s\n','NA');
                    end
                                                  
                case 't'
                    
                    if Flag.smallworld
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.smallworld);
                    else
                        fprintf(theFID,'%s,','NA');
                    end
                    
                    if Flag.degree
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.glodeg);
                        if network.weighted
                            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.glostr);
                        end
                    else
                        fprintf(theFID,'%s,','NA');
                        if network.weighted
                            fprintf(theFID,'%s,','NA');
                        end
                    end  
                    
                     if Flag.density
                        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.density);
                    else
                        fprintf(theFID,'%s,','NA');
                     end
                     
                     fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,jRun,kNetwork,mThresh}.degreeLine);
                               
                otherwise
                    error('You should be either measure the metrics or selecting the sparsity, check your network.stream setting');
            end
        end
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

if (network.stream =='m' && network.local==1)
    
    %%%%%%% Save the local results to CSV file %%%%%%%%%%
    
    NodeSelect = mc_node_select(roiMNI,NodeList);
    
    theFID = fopen(OutputPathFile2,'w');
    if theFID < 0
        fprintf(1,'Error opening the csv file!\n');
        return;
    end
    
    %%%%%% Output Local Measure Values for each selected node, each Run of each Subject %%%%%%%%%%%
    % Header
    fprintf(theFID,...
        'Subject,Run,Network,Threshold');
    for p = 1:length(NodeSelect)
        fprintf(theFID,...
            ',LocalDegree_%d',NodeSelect(p));
    end
    if network.weighted
        for p = 1:length(NodeSelect)
            fprintf(theFID,...
                ',LocalStrength_%d',NodeSelect(p));
        end
    end
    for p = 1:length(NodeSelect)
        fprintf(theFID,...
            ',LocalEfficiency_%d',NodeSelect(p));
    end
    for p = 1:length(NodeSelect)
        fprintf(theFID,...
            ',LocalClusteringCoef_%d',NodeSelect(p));
    end
    for p = 1:length(NodeSelect)
        fprintf(theFID,...
            ',NodeEccentricity_%d',NodeSelect(p));
    end
    for p = 1:length(NodeSelect)
        fprintf(theFID,...
            ',NodeBetweenness_%d',NodeSelect(p));
    end
    fprintf(theFID,'\n');
    
    for iSubject = 1:size(SubjDir,1)
        Subject = SubjDir{iSubject,1};
        for jRun = 1:size(SubjDir{iSubject,3},2)
            RunNum = SubjDir{iSubject,3}(jRun);
            
            %%%%% Select appropriate output based on h user has set
            %         index=strfind(NetworkTemplate,'Run');
            %         if size(index)>0
            RunString=RunDir{jRun};
            %         else
            %             RunString=num2str(jRun);
            %         end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for kNetwork = 1:length(network.netinclude)
            for mThresh = 1:length(network.adjacency)
                fprintf(theFID,'%s,%s,%s,%s,',Subject,RunString,network.netinclude(kNetwork),network.adjacency(mThresh));
                
                
                
                if Flag.degree
                    intdeg = CombinedOutput{iSubject,jRun,kNetwork,mThresh}.deg;
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%.4f,',intdeg(NodeSelect(p)));
                    end
                    if network.weighted
                        intstr = CombinedOutput{iSubject,jRun,kNetwork,mThresh}.strength;
                        for p = 1:length(NodeSelect)
                            fprintf(theFID,'%.4f,',intstr(NodeSelect(p)));
                        end
                    end
                else
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%s,','NA');
                    end
                    if network.weighted
                        for p = 1:length(NodeSelect)
                            fprintf(theFID,'%s,','NA');
                        end
                    end
                end
                
                if Flag.lefficiency
                    inteloc = CombinedOutput{iSubject,jRun,kNetwork,mThresh}.eloc;
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%.4f,',inteloc(NodeSelect(p)));
                    end
                else
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%s,','NA');
                    end
                end
                
                if Flag.clustering
                    intenc = CombinedOutput{iSubject,jRun,kNetwork,mThresh}.nodecluster;
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%.4f,',intenc(NodeSelect(p)));
                    end
                else
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%s,','NA');
                    end
                end
                
                if Flag.pathlength
                    intecc = CombinedOutput{iSubject,jRun,kNetwork,mThresh}.ecc.nodes;
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%.4f,',intecc(NodeSelect(p)));
                    end
                else
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%s,','NA');
                    end
                end
                
                if Flag.betweenness
                    intbtwn = CombinedOutput{iSubject,jRun,kNetwork,mThresh}.btwn;
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%.4f,',intbtwn(NodeSelect(p)));
                    end
                    fprintf(theFID,'\n');
                else
                    for p = 1:length(NodeSelect)
                        fprintf(theFID,'%s,','NA');
                    end
                    fprintf(theFID,'\n');
                end
            end
            end
        end
    end
    
    fclose(theFID);
    display('Local Measures All Done')
    
end

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUC of Metric - Threshold curve  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(network.AUC)
    
    aucflag.transitivity = any(strfind(upper(network.AUC),'T'));
    aucflag.gefficiency = any(strfind(upper(network.AUC),'G'));
    aucflag.modularity = any(strfind(upper(network.AUC),'M'));
    aucflag.assortativity = any(strfind(upper(network.AUC),'A'));
    aucflag.pathlength = any(strfind(upper(network.AUC),'P'));
    aucflag.degree = any(strfind(upper(network.AUC),'E'));
    aucflag.clustering = any(strfind(upper(network.AUC),'C'));
    aucflag.smallworldness = any(strfind(upper(network.AUC),'S'));
    
    
    if aucflag.transitivity
        for kNetwork = 1:length(network.netinclude)
            auc.trans(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'trans');
        end
    end
    
    if aucflag.gefficiency
        for kNetwork = 1:length(network.netinclude)
            auc.eglob(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'eglob');
        end
    end
    
    if aucflag.modularity
        for kNetwork = 1:length(network.netinclude)
            auc.modu(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'modu');
        end
    end
    
    if aucflag.assortativity
        for kNetwork = 1:length(network.netinclude)
            auc.assort(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'assort');
        end
    end
    
    if aucflag.pathlength
        for kNetwork = 1:length(network.netinclude)
            auc.pathlength(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'pathlength');
        end
    end
    
    if aucflag.degree
        if network.weighted
            for kNetwork = 1:length(network.netinclude)
                auc.glostr(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'glostr');
            end
        else
            for kNetwork = 1:length(network.netinclude)
                auc.glodeg(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'glodeg');
            end
        end
    end
    
    if aucflag.clustering
        for kNetwork = 1:length(network.netinclude)
            auc.cluster(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'cluster');
        end
    end
    
    if aucflag.smallworldness
        for kNetwork = 1:length(network.netinclude)
            auc.smallworld(kNetwork) = mc_AUCcalculation(CombinedOutput,SubjDir,network.netinclude(kNetwork),network.sparsity,'smallworld');
        end
    end
    
   
    
    save(AUCMatFile,'auc','-v7.3');
       
    
    theFID = fopen(AUCPathFile,'w');
    if theFID < 0
        fprintf(1,'Error opening the csv file!\n');
        return;
    end
    
    fprintf(theFID,...
        'metric');
    for kNetwork = 1:length(network.netinclude)
        fprintf(theFID,...
            [',Network',num2str(network.netinclude(kNetwork))]);
    end
    fprintf(theFID,'\n');
    
    names = fieldnames(auc);
    for nMetric = 1:length(names)
        subname = names{nMetric};
        fprintf(theFID,subname);
        for kNetwork = 1:length(network.netinclude)
            fprintf(theFID,[',',num2str(auc.(subname)(kNetwork))]);
        end
        fprintf(theFID,'\n');
    end
    
    display('AUC results saved.')
    
    
    
end


    
    



    
    
    



