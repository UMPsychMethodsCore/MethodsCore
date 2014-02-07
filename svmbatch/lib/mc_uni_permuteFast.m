function [stat] = mc_uni_permuteFast(data, design,permcol,vals)
%
% See the related function mc_uni_permute_count which does permutations, plus counts number of
% suprathreshold edges in a given cell
%
% Per the model in FSL's RANDOMISE function and described in Freedman & Lane (1983).
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
%                               looks like a constant, we will randomly multiply each entry by +1 or -1
%               design  -       Design matrix. This will be used AS IS so do any mean centering, intercept adding, beforehand
%               permcol -       Which column of design matrix to permute in each simulation. If this column
%               vals    -       OPTIONAL - see mc_CovariateCorrectionFast help for details. By default, I will
%                               turn all of the fields on.
%
%
%       OUTPUTS
%               stat    -       Result of refitting original design matrix to "permuted" data

nuisance.design = design;
nuisance.design(:,permcol) = []; %nuisance only version of design

if numel(nuisance.design) ~= 0;
    nuisancevals.pred = 1;
    nuisancevals.res = 1;
    nuisancestat = mc_CovariateCorrectionFast(data,nuisance.design,3,nuisancevals);
    



    %% do the permutation part
    if any(diff(design(:,permcol))) % if permcol is not a constant, permute it
        newseq = randsample(size(design,1),size(design,1));
        rand_data = nuisancestat.pred + nuisancestat.res(newseq,:);
    else % if permcol is a constant, swap its sign around. Bummer if it's zero
        swap = sign(rand(size(design,1),1) - .5);
        swap = repmat(swap,1,size(nuisancestat.res,2));
        rand_data = nuisancestat.pred + swap .* nuisancestat.res;
    end
else % if there are no nuisance elements
    if any(diff(design(:,permcol))) % if permcol is not a constant, permute it
        newseq = randsample(size(design,1),size(design,1));
        rand_data = data(newseq,:);
    else % if permcol is a constant, swap its sign around. Bummer if it's zero
        swap = sign(rand(size(design,1),1) - .5);
        swap = repmat(swap,1,size(data,2));
        rand_data = swap .* data;
    end
end %end the if block for nuisance correction

if ~exist('vals','var')    
    vals.t=1;
    vals.p=1;
    vals.int=1;
    vals.pred=1;
    vals.res=1;
    vals.cor=1;
end
stat = mc_CovariateCorrectionFast(rand_data,design,3,vals);


    
