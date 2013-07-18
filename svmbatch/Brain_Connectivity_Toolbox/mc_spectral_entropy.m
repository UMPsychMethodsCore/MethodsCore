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

lambda = eig(CIJ); % get the eigenvalues
n = length(lambda);
% unilambda = sort(unique(lambda));
% d = diff(unilambda);
% ind = abs(d)<eps;  % To cancel out the round up error caused by numeric method of calculating eigenvalues
% unilambda(ind)=[];
% n = zeros(1,length(unilambda));
rou = zeros(1,n);
roulrou = zeros(1,n);
p = nnz(CIJ)/(n*(n-1));
s = n*p*(1-p);
for i = 1:n
    if abs(lambda(i))>=2*sqrt(s);
%         rou(i) = 0;
        roulrou(i)=0;
    else
        rou(i) = (1/(2*pi*s))*sqrt(4*s-lambda(i)^2); 
        roulrou(i) = rou(i)*log(rou(i));
    end
    
end


H = -sum(roulrou);



end

