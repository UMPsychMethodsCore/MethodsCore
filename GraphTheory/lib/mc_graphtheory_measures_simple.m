function [Output,Flag] = mc_graphtheory_measures_simple(mtrx,directed,weighted,measures)
% mc_graphtheory_measures: Do the computation of graph theory measurements
% INPUT:
%         mtrx         - A binary 2D network that undergoes the computation
%         directed     - The indicator that shows if the matrix is directed
%                        or not ( 0 is undirected, 1 is directed)
%         measures     - A string that contains which measurements are to
%                        be computed, each letter contains in the string 
%                        represents one measurement
% OUTPUT:
%         Output       - A structure that contains the computation results,
%                        each subfield represents one measurement.
%         Flag         - A logical flag that contains whether or not a
%                        measurement is included ( 0 is not included, 1 is included),
%                        would be useful for the future use, such as writing results in
%                        the assigned file
%
% Yu Fang 2013/01
% This simple version is for undirected, unweighted matrix. 2013/05


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurement Flags
% 1 - include this measure
% 0 - do not include this measure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Flag.density = any(strfind(upper(measures),'D'));
Flag.transitivity = any(strfind(upper(measures),'T'));
Flag.gefficiency = any(strfind(upper(measures),'G'));
Flag.lefficiency = any(strfind(upper(measures),'L'));
Flag.modularity = any(strfind(upper(measures),'M'));
Flag.assortativity = any(strfind(upper(measures),'A'));
Flag.pathlength = any(strfind(upper(measures),'P'));
Flag.degree = any(strfind(upper(measures),'E'));
Flag.clustering = any(strfind(upper(measures),'C'));
Flag.betweenness = any(strfind(upper(measures),'B'));


%%%%%%%%%%%%%%%%%% Global Measurements (Networkwise) %%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Density-
% The fraction of present connections to possible connections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.density
    
        [kden,~] = density_und(mtrx); 
   
    Output.density = kden;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Clustering coefficient-
% One node and its two neighbors which also have connections composes a
% triangle.
% Clustering coefficient is the fraction of triangles around a
% node, equivalent to the fraction of node's neighbors that are neighbors
% of each other.
% Clustering coefficient of a network is the average of the
% clustering coefficients over all nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Flag.clustering
    
    cluster = clustering_coef_bu(mtrx);
         
    cluster_coef = mean(cluster); 
    
    Output.nodecluster = cluster;
    Output.cluster     = cluster_coef;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Transitivity-
% (alternative to the clustering coefficient, a classical version) 
% The ratio of triangles to triplets in the network.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.transitivity
    
    trans = transitivity_bu(mtrx);
        
    Output.trans = trans;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Global Efficiency-
% It is the average inverse shortest path length in the network, and it is
% inversely related to the characeristic path length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.gefficiency
    
    eglob = efficiency_bin(mtrx,0);
       
    Output.eglob = eglob;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Modularity- 
% An optimal community structure is a subdivision of the
% network into nonoverlapping groups of nodes in a way that maximizes the
% number of within-group edges, and minimizes the number of between-group
% edges. Modularity is a statistic that quantifies the degree to which the
% network may be subdivided into such clearly delineated groups.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.modularity
   
    [~,modu] = modularity_und(mtrx);
    
    
    Output.modu = modu;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Assortativity-
% The correlation coefficient between the degrees of all nodes on two
% opposite ends of an edge. A positive assortativity coefficient indicates
% that nodes tend to link to other nodes with the same or similar degree.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if directed: out-degree/in-degree correlation
if Flag.assortativity
    assort = assortativity_bin(mtrx,directed); 
    % The function accepts weighted networks, but all connection weights are ignored.  
    Output.assort = assort;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Characteristic path length-
% The average shortest path length in the network.
% -Eccentricity-
% The maximal shortest path length between a node and any other node 
% -radius-
% min eccentricity
% -diameter-
% max eccentricity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.pathlength
    
    D = distance_bin(mtrx);
    
    [lambda,~,ecc,radius,diameter] = charpath(D); % same code for weighted and unweighted matrix
    Output.pathlength = lambda;
    Output.ecc.nodes = ecc;
    Output.ecc.radius = radius;
    Output.ecc.diameter = diameter;
end




%%%%%%%%%%%%%%%%%% Local Measurements (Nodewise) %%%%%%%%%%%%%%%%%%%%%%%
if network.local==1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % -Node Degree-
    % The number of edges connected to the node
    % -Network Degree-
    % The average degree over all nodes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Flag.degree
        
        [deg,glodeg] = degrees_und(mtrx);
        
        Output.deg    = deg;
        Output.glodeg = glodeg;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % -Local Efficiency-
    % The global efficiency of the neighborhood of a node
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Flag.lefficiency
        
        eloc = efficiency_bin(mtrx,1);
        
        Output.eloc = eloc;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % -Node Betweenness-
    % The fraction of all shortest paths in the network that contain a given
    % node. Nodes with high values of betweenness centrality participate in a
    % large number of shortest paths.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if Flag.betweenness
        
        bc = betweenness_bin(mtrx);
        
        Output.btwn = bc;
    end
end


