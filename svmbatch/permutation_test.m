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
ph=spm_vol(Pp);

tvol=spm_read_vols(th);
pvol=spm_read_vols(ph);


%% Create dumping space for comparisons

rvol=zeros(size(tvol));
rh=th;
rh.fname=name;

%% Loop over dimensions

for i=1:size(rvol,1), for j=1:size(rvol,2), for k=1:size(rvol,3)
            rvol(i,j,k)=sum(pvol(i,j,k,:)>tvol(i,j,k))/size(pvol,4);
        end,end,end

%% Write out the resulting p values

rvol=spm_write_vol(rh,rvol);