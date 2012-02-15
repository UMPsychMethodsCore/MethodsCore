%function [Y] = permutation_test(Pt,Pdir,name)
% Calculate nonparametric distributions based on svm permutation tests
% Pt   - filename of weight vector from real model
% Pdir - file directory in which to search for results of permutation test
% img/hdr pairs
% name - string of name to write out (without .img extension)

%% Make list of files
Pp=spm_select('List',Pdir,'[0-9]+\.hdr');

%% Read in files
th=spm_vol(Pt);
tvol=spm_read_vols(th);


cd(Pdir);
ph=spm_vol(Pp);
pvol=spm_read_vols(ph);
cd ..

%% Create dumping space for comparisons

rvol=zeros(size(tvol));
rh=th;
rh.fname=[name '.img'];
rh.descrip='SPM{T_[10000000]}';

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

%% Replace Inf and -Inf values with prior min and max, respectively
% rvol(find(rvol==Inf))=max(rvol(~isinf(rvol)));
% rvol(find(rvol==-Inf))=min(rvol(~isinf(rvol)));

rvol(find(rvol==Inf))=norminv((1-1/size(pvol,4)));
rvol(find(rvol==-Inf))=norminv((1/size(pvol,4)));

%Fix the origin for 

rh.mat(:,4)=[-81 -115 -53 1];


%% Write out the resulting p values in one giant file
spm_write_vol(rh,rvol);

%%Slice up the file into its sub-totems, and write them out separately from
%%bottom up

for i=1:(th.dim(3)/46)
    cth_range=[1:46] + (i-1)*46;
    cth=rh;
    cth.fname=sprintf('%s%s%s%.3d%s',pwd,'/', name ,i,'.img');
    cth.dim(3)=[46];
    ctvol=rvol(:,:,cth_range);
    spm_write_vol(cth,ctvol);
end