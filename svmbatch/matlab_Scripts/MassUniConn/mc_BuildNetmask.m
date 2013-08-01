function netmask = mc_BuildNetmask(roiMNI,nets,matrixtype)
sq_blanks = zeros(size(roiMNI,1));


%%% Build Netmask
% need to generalize this to support cPPI and resting
netSort = sort(unique(nets)); % identify the unique networks

nNet   =  numel(netSort); % how many unique nets do you have?



switch matrixtype
  case 'upper'
    for iN = 1:nNet;
        for jN = iN:nNet;
            iNet = netSort(iN);
            jNet = netSort(jN);
            csq_blanks = sq_blanks;
            csq_blanks(nets==iNet,nets==jNet) = 1;  % csq: current square
            csq_blanks(nets==jNet,nets==iNet) = 1;
            csq = mc_flatten_upper_triangle(csq_blanks);
            netmask{iN,jN} = logical(csq);
        end
    end
  case 'nodiag'
    for iN = 1:nNet;
        for jN = iN:nNet;
            iNet = netSort(iN);
            jNet = netSort(jN);
            csq_blanks = sq_blanks;
            csq_blanks(nets==iNet,nets==jNet) = 1;
            csq_blanks(nets==jNet,nets==iNet) = 1;
            csq_blanks = csq_blanks - diag(diag(csq_blanks)); % zero out the diagonal
            csq = reshape(csq_blanks,size(roiMNI,1)^2,1);
            netmask{iN,jN} = logical(csq);
        end
    end
end
