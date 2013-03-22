function [tot meanT meanB] = mc_uni_permute(data, netmask, thresh,permcol, design, funchand)
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
% NOTE - If the permcol is a constant, then we will flip the sign of the residuals, as this is what FSL's RANDOMIZE appears to do
% after reading the source code
%
%
%
%       INPUTS
%               data    -       nExample * nFeature Matrix
%               netmask -       Cell array holding masks to apply to data. You choose dimensionality, what you get
%                               back will match the dimensions you put in
%               thresh  -       row matrix of alpha thresholds to apply. Will index last dimension of output variables
%               permcol -       Which column of design matrix to permute in each simulation. If this column
%                               looks like a constant, we will randomly multiply each entry by +1 or -1
%               design  -       Design matrix. This will be used AS IS so do any mean centering, intercept adding, beforehand
%
%       NOT YET IMPLEMENTED
%               funchand-       Pass a function handle that will control how the results are aggregated.
%                               Give it any arguments you may need. By default it will do counting using
%                               thresh and iterating over netmask
%
%       OUTPUTS
%               tot     -       Array. Counts how many edges were subthreshold for a given netmask. Dimensionality is as follows
%                                       nD      -       Dimensions of netmask
%                                       Thresh  -       Indexes values of thresh
%               meanT   -       Identical structure to tot, but counts mean value of t scores in cell
%               meanB   -       Identical structure to tot, but counts mean value of beta scores in cell

nuisance.design = design;
nuisance.design(:,permcol) = []; %nuisance only version of design

if numel(nuisance.design) ~= 0;
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
else % if there are no nuisance elements
if any(diff(design(:,permcol))) % if permcol is not a constant, permute it
    newseq = randsample(size(design,1),size(design,1));
    rand_data = data(newseq,:);
else % if permcol is a constant, swap its sign around. Bummer if it's zero
    swap = sign(rand(size(design,1),1) - .5);
    swap = repmat(swap,1,size(nuisance.res,2));
    rand_data = swap .* data;
end
end %end the if block for nuisance correction

    
[~, ~, b, ~, t, p] = mc_CovariateCorrection(rand_data,design,3,permcol);

t = t(permcol,:);
p = p(permcol,:);
b = b(permcol,:);

%% figure out the threshold stuff

tot = zeros([size(netmask),numel(thresh)]);
meanB = zeros([size(netmask),numel(thresh)]);
meanT = zeros([size(netmask),numel(thresh)]);

for i = 1:numel(thresh)
    supra = p<thresh(i);
    for x = 1:numel(netmask)
        tot(x + (i-1)*numel(netmask)) = sum(supra(netmask{x})); %do assignment, jumping over the first dimensions for thresh
        meanT(x + (i-1)*numel(netmask)) = mean(t(netmask{x})); %do assignment, jumping over the first dimensions for thresh
        meanB(x + (i-1)*numel(netmask)) = mean(b(netmask{x})); %do assignment, jumping over the first dimensions for thresh
    end
end
