function [Y] = permutation_test(Pt,pdir,name)
% Calculate nonparametric distributions based on svm permutation tests
% Pt   - filename of weight vector from real model
% Pdir - file directory in which to search for results of permutation test
% img/hdr pairs
% name - string of name to write out

%% Make list of files
Pp=spm_select('List',pdir,'[0-9].hdr+')

%% Read in files
th=spm_vol(Pt);
cd(pdir);
ph=spm_vol(Pp);

tvol=spm_read_vols(th);
pvol=spm_read_vols(ph);


%% Create dumping space for comparisons

rvol=zeros(size(tvol));
rh=th;
rh.fname=name;

%% Loop over dimensions

% For each voxel, calculate proportion of permutations that resulted in
% smaller or equal value. This returns the nonparametric CDF. We then
% convert this, using norminv, to a z-score. Extremely positive values will
% have high CDF scores, high p scores, and high z scores. Very negative
% values will have very small CDF scores, small p scores, and negative z
% scores. We convert to z for easier visualization in xjview.

for i=1:size(rvol,1), for j=1:size(rvol,2), for k=1:size(rvol,3)
            rvol(i,j,k)=norminv(sum(pvol(i,j,k,:)<=tvol(i,j,k))/size(pvol,4));
        end,end,end

%% Mask based on tvol
% Some voxels that were zero in the real weight vector are out-of-brain
% voxels. Implicit masking during first level testing should have set them
% to 0. All permutation tests will likely also return 0, yielding a bizarre
% value for the CDF. To protect against this, we set the z-score of these
% points to be 0, for a corresponding p of .5

for i=1:size(rvol,1), for j=1:size(rvol,2), for k=1:size(rvol,3)
            if tvol(i,j,k)==0, rvol(i,j,k)=0; end
        end,end,end

%% Write out the resulting p values

rvol=spm_write_vol(rh,rvol);