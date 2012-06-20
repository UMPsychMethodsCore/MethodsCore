function LOOCV_discrimpower_consensus_square = mc_unflatten_upper_triangle (LOOCV_discrimpower_consensus, nROI)
% [SquareMatrix] = unflatten (flatmatrix, nROI)
% 
% This function will undo what flatten_upper_triangle did. It assumes that
% it's working with 

%% Reconstruct Consensus Discrim Power into Edges File

    % Identify linear indices of elements that survive flattening
    connectomeIDx=zeros(nROI);
    connectomeIDx(:)=1:(nROI^2);
    connectomeIDx_flat = mc_flatten_upper_triangle(connectomeIDx,ones(nROI));

    % Build square matrix, and use linear indices above to insert discrim power
    LOOCV_discrimpower_consensus_square = zeros(nROI);
    LOOCV_discrimpower_consensus_square(connectomeIDx_flat) = LOOCV_discrimpower_consensus;
%     LOOCV_discrimpower_consensus_square_binarized = LOOCV_discrimpower_consensus_square;
%     LOOCV_discrimpower_consensus_square_binarized(LOOCV_discrimpower_consensus_square_binarized~=0) = 1 ;
    
end
