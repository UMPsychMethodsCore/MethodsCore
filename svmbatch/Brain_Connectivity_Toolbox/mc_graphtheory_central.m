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
OutputPathFile1 = mc_GenPath( struct('Template',OutputPathTemplate1,...
    'suffix','.csv',...
    'mode','makeparentdir') );
OutputPathFile2 = mc_GenPath( struct('Template',OutputPathTemplate2,...
    'suffix','.csv',...
    'mode','makeparentdir') );
                                
display('I am going to compute the graph theory measurements');
display(sprintf('The output will be stored here: %s and %s', OutputPathFile1,OutputPathFile2));
display('These are the subjects:')
display(SubjDir)
display ('-----')

%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialization
%%%%%%%%%%%%%%%%%%%%%%%
clear CombinedOutput
clear NetworkPath

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Flag for smallworldness
%%%%%%%%%%%%%%%%%%%%%%%%%%%
tempflag = any(strfind(upper(network.measures),'S'));

for iSubject = 1:size(SubjDir,1)    % Loop over subjects
    Subject = SubjDir{iSubject,1};
    for jRun = 1:size(SubjDir{iSubject,3},2)   % Loop over runs
        RunNum = SubjDir{iSubject,3}(jRun);
        Run    = RunDir{RunNum};
        display(sprintf('Now computing %s',Run));
        display(sprintf('of %s',Subject)); 
        tic
        
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

        % Generate the binary adjacency matrix, do the computation
        switch network.datatype
            case 'p'
                NetworkParameters = load(NetworkPath,'pMatrix');
                NetworkConnect    = double(NetworkParameters.pMatrix<network.adjacency);
            case 't'                
                switch TemplateType
                    case 'single'                        
                        NetworkParameters = load(NetworkPath,'cppi_grid');
                        
                        [sizex, sizey]=size(NetworkParameters.cppi_grid{TRow,Column(1)});
                        NetworkTscore = zeros(sizex,sizey);                        
                        for i = 1:length(Column)
                            NetworkTscore = NetworkTscore+NetworkParameters.cppi_grid{TRow,Column(i)};                            
                        end
                        clear i;
                        NetworkTscore = NetworkTscore./length(Column);                        

                    case 'averaged'
                        for i = 1:TemplateAverageRun
                            NetworkParameters{i} = load(NetworkPath{i});
                        end
                        clear i
                        [sizex,sizey] = size(NetworkParameters{1}.RecoverTscore);
                        NetworkTscore = zeros(sizex,sizey);
                        for j = 1:TemplateAverageRun
                            NetworkTscore = NetworkTscore + NetworkParameters{j}.RecoverTscore;
                        end
                        clear j;
                        NetworkTscore = NetworkTscore./TemplateAverageRun;
                    otherwise
                        error('TemplateType should be single or averaged, other type names are not accepted');
                end
                
                NetworkTscore(isnan(NetworkTscore)) = 0; % Exclude the NaN elements            
                 
                switch network.loc
                    case 0
                        NetworkTscoreint  = (triu(NetworkTscore)+triu(NetworkTscore.'))./2; % Average over upper and lower triangulars
                        NetworkConnectint = triu(NetworkTscoreint,1)+NetworkTscoreint.'; % Padding to the whole matrix
                    case 1
                        NetworkConnectint = triu(NetworkTscore,1)+tril(NetworkTscore.'); % Use upper triangular values
                    case 2
                        NetworkConnectint = tril(NetworkTscore,1)+triu(NetworkTscore.'); % Use lower triangular values
                end
                
                NetworkConnect    = double(NetworkConnectint>=network.adjacency);  % Thresholding the Tscore to get binary matrix
                               
            case 'r'
                NetworkPvalue     = load(NetworkPath,'pMatrix');
                NetworkParameters = load(NetworkPath,'rMatrix');   
                if (network.ztransform == 1)
                     %%% NEED EDIT %%%
                end
                NetworkConnect    = (NetworkParameters.rMatrix).*(double(NetworkPvalue.pMatrix<network.adjacency));
                NetworkConnect(isnan(NetworkConnect))=0; % Exclude the NaN elments
                if (network.value == 1)
                    NetworkConnect(NetworkConnect<0)=0;   % Only keep positive values if option is set so
                end
                NetworkConnect    = abs(NetworkConnect); % Take the absolute value of correlation to fit the following computing
                                                         % requirements (convert the value range from (-1,1) to (0,1), the positive 
                                                         % and negative correlation with the same absolute value are as meaningful 
                                                         % as each other. If the 'positive' step was done, then this step is just 
                                                         % reassuring
                
            case 'b'
                NetworkParameters = load(NetworkPath,'cppi_grid');
                [sizex, sizey]=size(NetworkParameters.cppi_grid{TRow,Column(1)});
                NetworkTscore = zeros(sizex,sizey);
                NetworkBeta   = zeros(sizex,sizey);
                for i = 1:length(Column)
                    NetworkTscore = NetworkTscore+NetworkParameters.cppi_grid{TRow,Column(i)};
                end
                clear i;
                NetworkTscore = NetworkTscore./length(Column);
                
                for j = 1:length(Column)
                    NetworkBeta = NetworkBeta + NetworkParameters.cppi_grid{BRow,Column(j)};
                end
                clear j;
                NetworkBeta = NetworkBeta./length(Column);
              
                NetworkTscore(isnan(NetworkTscore)) = 0; % Exclude the NaN elements  
                NetworkBeta(isnan(NetworkBeta)) = 0; % Exclude the NaN elements  
                                             
                switch network.loc
                    case 0
                        NetworkTscoreint  = (triu(NetworkTscore)+triu(NetworkTscore.'))./2; % Average t-score over upper and lower triangulars
                        NetworkTscoreAve  = triu(NetworkTscoreint,1)+NetworkTscoreint.'; % T-score shouldn't take absolute value
                        NetworkBetaint    = (triu(NetworkBeta)+triu(NetworkBeta.'))./2; % Average standardized beta over upper and lower triangulars
                        NetworkBetaAve    = triu(NetworkBetaint,1)+NetworkBetaint.';
                    case 1
                        NetworkTscoreint = triu(NetworkTscore,1)+tril(NetworkTscore.');
                        NetworkBetaint   = triu(NetworkBeta,1)+tril(NetworkBeta.');
                    case 2
                        NetworkTscoreint = tril(NetworkTscore,1)+triu(NetworkTscore.');
                        NetworkBetaint   = tril(NetworkBeta,1)+triu(NetworkBeta.');
                end
                if (network.value == 1)
                    NetworkBetaAve(NetworkBetaAve<0) = 0;  % Only keep positive values if option is set so
                end
                NetworkBetaAve    = abs(NetworkBetaAve);   % Take absolute value for beta, if 'positive' step is done, then this step is just reassuring
                NetworkConnect = NetworkBetaAve.*double(NetworkTscoreAve>=network.adjacency); % masking over the Beta
             
        end
        
        [NetworkMeasures,Flag]   = mc_graphtheory_measures(NetworkConnect,network.directed,network.weighted,network.measures);
        Output                   = NetworkMeasures;
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
        
        CombinedOutput{iSubject,jRun} = Output;  
        toc
    end

end
   


%%%%%%% Save the global results to CSV file %%%%%%%%%%
theFID = fopen(OutputPathFile1,'w');
if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return;
end

%%%%%% Output Global Measure Values for each Run of each Subject %%%%%%%%%%%
% Header
if network.weighted
    fprintf(theFID,...
        'Subject,Run,Smallworldness,ClusteringCoef,CharacetristicPathLength,GlobalDegree,GlobalStrength,Density,Transitivity,GlobalEfficiency,Modularity,Assortativity\n');
else
    fprintf(theFID,...
        'Subject,Run,Smallworldness,ClusteringCoef,CharacetristicPathLength,GlobalDegree,Density,Transitivity,GlobalEfficiency,Modularity,Assortativity\n');
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
        fprintf(theFID,'%s,%s,',Subject,RunString);
        
               
        if Flag.smallworld
            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.smallworld);
        else
            fprintf(theFID,'%s,','NA');
        end
        
        if Flag.clustering
            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.cluster);
        else
            fprintf(theFID,'%s,','NA');
        end
        
        if Flag.pathlength
            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.pathlength);
        else
            fprintf(theFID,'%s,','NA');
        end
        
        if Flag.degree
            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.glodeg);
            if network.weighted
                fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.glostr);
            end
        else
            fprintf(theFID,'%s,','NA');
            if network.weighted
                fprintf(theFID,'%s,','NA');
            end
        end        
        
        
        if Flag.density
            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.density);
        else
            fprintf(theFID,'%s,','NA');
        end
        
        if Flag.transitivity
            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.trans);
        else
            fprintf(theFID,'%s,','NA');
        end
        
        if Flag.gefficiency
            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.eglob);
        else
            fprintf(theFID,'%s,','NA');
        end
        
        if Flag.modularity
            fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.modu);
        else
            fprintf(theFID,'%s,','NA');
        end
        
        if Flag.assortativity
            fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,jRun}.assort);
        else
            fprintf(theFID,'%s\n','NA');
        end
                      
    end
end

fclose(theFID);
display('Global Measures All Done')

%%%%%%% Save the local results to CSV file %%%%%%%%%%
NetworkParamPath  = mc_GenPath(struct('Template',NetworkParameter,'mode','check'));
param      = load(NetworkParamPath);
NodeCoord  = param.parameters.rois.mni.coordinates;
NodeSelect = mc_node_select(NodeCoord,NodeList);

theFID = fopen(OutputPathFile2,'w');
if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return;
end

%%%%%% Output Local Measure Values for each selected node, each Run of each Subject %%%%%%%%%%%
% Header
fprintf(theFID,...
    'Subject,Run');
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
        fprintf(theFID,'%s,%s,',Subject,RunString);
                  
               
        
        if Flag.degree
            intdeg = CombinedOutput{iSubject,jRun}.deg;
            for p = 1:length(NodeSelect)
                fprintf(theFID,'%.4f,',intdeg(NodeSelect(p)));
            end
            if network.weighted
                intstr = CombinedOutput{iSubject,jRun}.strength;
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
            inteloc = CombinedOutput{iSubject,jRun}.eloc;
            for p = 1:length(NodeSelect)
                fprintf(theFID,'%.4f,',inteloc(NodeSelect(p)));
            end
        else
            for p = 1:length(NodeSelect)
                fprintf(theFID,'%s,','NA');
            end
        end
        
        if Flag.clustering
            intenc = CombinedOutput{iSubject,jRun}.nodecluster;
            for p = 1:length(NodeSelect)
                fprintf(theFID,'%.4f,',intenc(NodeSelect(p)));
            end
        else
            for p = 1:length(NodeSelect)
                fprintf(theFID,'%s,','NA');
            end
        end
        
        if Flag.pathlength
            intecc = CombinedOutput{iSubject,jRun}.ecc.nodes;
            for p = 1:length(NodeSelect)
                fprintf(theFID,'%.4f,',intecc(NodeSelect(p)));
            end
        else
            for p = 1:length(NodeSelect)
                fprintf(theFID,'%s,','NA');
            end
        end
        
        if Flag.betweenness
            intbtwn = CombinedOutput{iSubject,jRun}.btwn;
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

fclose(theFID);
display('Local Measures All Done')


