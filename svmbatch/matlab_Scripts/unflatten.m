function LOOCV_discrimpower_consensus_square = unflatten (LOOCV_discrimpower_consensus, nROI)

%% Reconstruct Consensus Discrim Power into Edges File

    % Identify linear indices of elements that survive flattening
    connectomeIDx=zeros(nROI);
    connectomeIDx(:)=1:(nROI^2);
    connectomeIDx_flat = connectivity_grid_flatten(connectomeIDx,ones(nROI));

    % Build square matrix, and use linear indices above to insert discrim power
    LOOCV_discrimpower_consensus_square = zeros(nROI);
    LOOCV_discrimpower_consensus_square(connectomeIDx_flat) = LOOCV_discrimpower_consensus;
%     LOOCV_discrimpower_consensus_square_binarized = LOOCV_discrimpower_consensus_square;
%     LOOCV_discrimpower_consensus_square_binarized(LOOCV_discrimpower_consensus_square_binarized~=0) = 1 ;
    
end