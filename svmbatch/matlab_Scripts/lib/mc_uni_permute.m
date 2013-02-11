function [out] = mc_uni_permute(data, netmask, thresh,permcol, design, funchand)
%
%Per the model in FSL's RANDOMISE function and described in Freedman & Lane (1983).
%
%
% If we have both an effect of interest AND some nuisance parameters, we first fit a model JUST to the nuisance
% parameters. We take the residuals from that (which presumably represent both the FX of interest + error) and
% we randomly permute them, distributing the effect of interest in a random way. We then add these permuted
% residuals to the unpermuted predicted values arising from the model fit to the nuisance data.
%
% Finally, we fit a full model (nuisance and FX of interest) to the resulting data, and we look at the
% distribution properties of our effect of interest.
%
% NOTE - If the permcol is a constant, then we will flip the sign, as this is what FSL's RANDOMIZE appears to do
% after reading the source code
%
%
%
%       INPUTS
%               data    -       nExample * nFeature Matrix
%               netmask -       Cell array holding masks to apply to data. You choose dimensionality, what you get
%                               back will match the dimensions you put in
%               thresh  -       row matrix of alpha thresholds to apply. Will index last dimension of out
%               permcol -       Which column of design matrix to permute in each simulation. If this column
%                               looks like a constant, we will randomly multiply each entry by +1 or -1
%               design  -       Design matrix. This will be used AS IS so do any mean centering, intercept adding, beforehand
%
%       NOT YET IMPLEMENTED
%               funchand-       Pass a function handle that will control how the results are aggregated.
%                               Give it any arguments you may need. By default it will do counting using
%                               thresh and iterating over netmask
nuisance.design = design;
nuisance.design(:,permcol) = []; %nuisance only version of design

[nuisance.cor nuisance.res nuisance.beta nuisance.int nuisance.t nuisance.p] = mc_CovariateCorrection(data,nuisance.design,3,1);

nuisance.pred = nuisance.design  * nuisance.beta; % calculate your predicted values

%% do the permutation part
if any(diff(design(:,permcol))) % if permcol is not a constant, permute it
    newseq = randsample(size(design,1),size(design,1));
    rand_data = nuisance.pred + nuisance.res(newseq,:);
else % if permcol is a constant, swap its sign around. Bummer if it's zero
    swap = sign(rand(size(design,1),1) - .5);
    swap = repmat(swap,1,size(nuisance.res,2));
    rand_data = nuisance.pred + swap .* nuisance.res;
end
    
[~, ~, ~, ~, ~, p] = mc_CovariateCorrection(rand_data,design,1,permcol);

p = p(permcol,:);

%% figure out the threshold stuff

out = zeros([size(netmask),numel(thresh)]);

for i = 1:numel(thresh)
    supra = p<thresh(i);
    for x = 1:numel(netmask)
        out(x + (i-1)*numel(netmask)) = sum(supra(netmask{x})); %do assignment, jumping over the first dimensions for thresh
    end
end
