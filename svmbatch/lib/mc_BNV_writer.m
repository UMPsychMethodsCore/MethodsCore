function [ Status ] = mc_BNV_writer( OutputEdgePath, OutputNodePath, FPruning, FFitness, ROI_mni, nFeatPlot, NetworkMap )
%MC_BNV_WRITER Write out a node/edge file, suitable for use in BrainNet Viewer
%   Input Args
%       OutputEdgePath  -   Target path for writing edge file. Parent
%                           directory should already exist.
%       OutputNodePath  -   Target path for writing node file. Parent
%                           directory should already exist.
%       FPruning        -   Foldwise pruning. Should be nLOOCV * nFeat
%       FFitness        -   OPTIONAL | Foldwise feature fitness. Should be
%                           nLOOCV * nFeat
%       ROI_mni         -   List of MNI coordinates of ROIs. Should be nROI *
%                           3. Any additional columns will be ignored
%       nFeatPlot       -   OPTIONAL | If there are more consensus features than
%                           nFeatPlot, this routine will subset them to the top
%                           nFeatPlot features based on FFitness, but only if
%                           it is supplied.
%       NetworkMap      -   OPTIONAL | A path to an img/hdr file, ideally sliced at 1mm^3,
%                           where each value has an integer value that
%                           represents network membership. This is used for
%                           colorizing the nodes file for BNV. If not defined,
%                           all nodes will have the same color


% Count ROIs
nROI = size(ROI_mni,1);

% Identify consensus features across LOOCV folds
LOOCV_consensus=all(FPruning,1);

% Ensure number of consensus features is less than consensus
if exist('nFeatPlot','var')
    nFeatPlot=min(sum(LOOCV_consensus),nFeatPlot);
else
    nFeatPlot = sum(LOOCV_consensus);
end


% Calculate featurewise discriminative power
if exist('FFitness','var')
    LOOCV_discrimpower=mean(FFitness,1); %Calculate mean discrim power for all features
    LOOCV_discrimpower(~logical(LOOCV_consensus))=0; % Zero out discrim power for features not in consensus set
    LOOCV_discrimpower=mc_bigsmall(LOOCV_discrimpower,nFeatPlot,3); % Zero out all but the top nFeatPlot features
else
    LOOCV_discrimpower=LOOCV_consensus;
end

LOOCV_discrimpower_consensus_square = mc_unflatten_upper_triangle (LOOCV_discrimpower, nROI);
LOOCV_discrimpower_consensus_square_binarized = LOOCV_discrimpower_consensus_square~=0;

% Write out the edge files
dlmwrite(OutputEdgePath,LOOCV_discrimpower_consensus_square,'\t');


% Build ROI list

ROI_mni = ROI_mni(:,1:3); %Prune off any extra columns before starting

% Colorize ROIs
if exist('NetworkMap','var')
    ROI_mni = mc_network_lookup(NetworkMap,ROI_mni);
    ROI_mni(:,4) = round(ROI_mni(:,4));
else
    ROI_mni(:,4) = 1;
end

ROI_mni(:,5) = sum([sum(LOOCV_discrimpower_consensus_square_binarized,1) ; sum(LOOCV_discrimpower_consensus_square_binarized,2)']);

% Write out the node file

nodefile = fopen(OutputNodePath,'w');

fprintf(nodefile,'%d\t%d\t%d\t%d\t%d\t-\n',ROI_mni'); %Transpose is necessary b/c it will use elements in a column-major order

Status=1;

end
