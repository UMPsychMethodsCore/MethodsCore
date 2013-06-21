function H = mc_spectral_entropy( CIJ )
%MC_SPECTRAL_ENTROPY    spectral entropy of a network
%
%   H = mc_spectral_entropy(CIJ)
% 
%  The spectral entropy is the measure of 'uncertainty' of a random graph
%  
%  Inputs:   CIJ,      adjacency matrix (binary)
% 
%  Outputs:    H,      spectral adjacency
%
%  Reference: Sato et al. Measuring network's entropy in ADHD: 
%             A new approach to investigate neuropsychiatric disorders. 
%             NeuroImage (2013) pp. 1-8
%  Yu Fang, UM, 2013

CIJ(eye(size(CIJ))~=0)=0;
n = length(CIJ);
k = nnz(triu(CIJ,1));
p = k/((n^2-n)/2);
H = (1/2)*log(4*pi*pi*p*(1-p))-(1/2);

end

