function [Output,Flag] = mc_graphtheory_measures(mtrx,network)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
directed = network.directed;
weighted = network.weighted;
measures = network.measures;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurement Flags
% 1 - include this measure
% 0 - do not include this measure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Flag.density       = any(strfind(upper(measures),'D'));
Flag.transitivity  = any(strfind(upper(measures),'T'));
Flag.efficiency    = any(strfind(upper(measures),'F'));
Flag.modularity    = any(strfind(upper(measures),'M'));
Flag.assortativity = any(strfind(upper(measures),'A'));
Flag.pathlength    = any(strfind(upper(measures),'P'));
Flag.degree        = any(strfind(upper(measures),'E'));
Flag.clustering    = any(strfind(upper(measures),'C'));
Flag.betweenness   = any(strfind(upper(measures),'B'));
Flag.entropy       = any(strfind(upper(measures),'Y'));






%%%%%%%%%%%%%%%%%% Global Measurements (Networkwise) %%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Density-
% The fraction of present connections to possible connections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.density
    if directed
        [kden,~] = density_dir(mtrx);
    else
        [kden,~] = density_und(mtrx); 
        % for both weighted and unweighted matrix
    end
    
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
    if directed
        cluster = clustering_coef_bd(mtrx);
    else
        if weighted
            cluster = clustering_coef_wu(mtrx); 
        else
            cluster = clustering_coef_bu(mtrx);
        end
    end    
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
    if directed
        trans = transitivity_bd(mtrx);
    else
        if weighted
            trans = transitivity_wu(mtrx); 
        else
            trans = transitivity_bu(mtrx);
        end
    end
    
    Output.trans = trans;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Global Efficiency-
% It is the average inverse shortest path length in the network, and it is
% inversely related to the characeristic path length
% -Local Efficiency-
% The global efficiency of the neighborhood of a node
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.efficiency
    if directed
        eglob = 0; % no code for directed matrix
        eloc = [];
        
    else
        if weighted
            eglob = efficiency_wei(mtrx,0); 
            eloc = efficiency_bin(mtrx,1);
            
        else
            eglob = efficiency_bin(mtrx,0);
            eloc = efficiency_bin(mtrx,1);
            
        end
    end
    
    Output.eglob = eglob;
    Output.eloc  = eloc;
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
    if directed
        [~,modu] = modularity_dir(mtrx);
    else
        [~,modu] = modularity_und(mtrx);
        % same code for weighted and unweighted matrix
    end
    
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
    if weighted
        % distance_wei function asks for connection-length matrix, as in a
        % weighted correlation network, typically higher correlations are
        % interpreted as shorter distances, here we use the inverse of the
        % weighted connection matrix as the connection-length matrix,
        % except for that at the diagonal the lengths are set to 0.
        lengthmtrx                = 1./mtrx;  
        nmtrx                     = size(mtrx);
        lengthmtrx(1:nmtrx+1:end) = 0;
        D = distance_wei(lengthmtrx);     
    else
        D = distance_bin(mtrx);
    end
    [lambda,~,~,~,~] = charpath(D); % same code for weighted and unweighted matrix
    Output.pathlength = lambda;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Betweenness Centrality-
% The fraction of all shortest paths in the network that contain a given
% node. Nodes with high values of betweenness centrality participate in a
% large number of shortest paths.
% The global betweenness centrality is the average of centralities of all nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.betweenness
    if weighted
        % betweenness_wei function asks for connection-length matrix, as in a
        % weighted correlation network, typically higher correlations are
        % interpreted as shorter distances, here we use the inverse of the
        % weighted connection matrix as the connection-length matrix,
        % except for that at the diagonal the lengths are set to 0.
        lengthmtrx                = 1./mtrx;
        nmtrx                     = size(mtrx);
        lengthmtrx(1:nmtrx+1:end) = 0;
        bc = betweenness_wei(lengthmtrx);
    else
        bc = betweenness_bin(mtrx);
    end
    
    Output.btwn     = mean(bc);
    Output.nodebtwn = bc;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Spectral Entropy -
% Spectral Entropy is a measure of the 'uncertainty' of the graph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.entropy
    Output.etpy = mc_spectral_entropy(mtrx);
end
    




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -Node Degree-
% The number of edges connected to the node
% -Network Degree-
% The average degree over all nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Flag.degree
    if directed
        deg = degrees_dir(mtrx);
    else
        if weighted
            [deg,glodeg,strength,glostr] = degrees_wei(mtrx);
            Output.strength = strength;
            Output.glostr   = glostr;
        else
            [deg,glodeg] = degrees_und(mtrx);
        end
    end
    Output.deg    = deg;
    Output.glodeg = glodeg;
end
    

    
    
end


