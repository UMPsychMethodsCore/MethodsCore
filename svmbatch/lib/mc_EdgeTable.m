function [ EdgeTable ] = mc_EdgeTable( SVM, NetSphereRad )
%MC_EDGETABLE Make an "Edge Table"
%
% Usage 1
%   Provide the results of an SVM run as a struct
%
% Usage 2
%   Provide a path to a file that was the result of an SVM run
%   
% Optionally provide a NetSphereRad. If you do, any unlabeled nodes
% (network 0) will be submitted to a function to try to recover
% label information. It will do this by creating a sphere of radius
% NetSphereRad (in units of your network map volume, typically MNI
% mm) and searching in that.


%% Parse arguments

if isstruct(SVM)
    SVM=SVM;
end

if ischar(SVM)
    SVM=path_EdgeTable(SVM);
end

% Set defaults
if ~exist('NetSphereRad','var')
    NetSphereRad=0;
end
        
SVM=struct_Parse(SVM);
SVM = template_cleaner(SVM);
EdgeTable = struct_EdgeTable(SVM,NetSphereRad);
writepath = set_edgetable_path(SVM.SVMSetup);
result = write_EdgeTable(EdgeTable,writepath);

function out = unpack_struct(in)
%Unpack the fields of a struct in the environment of the caller
SNames = fieldnames(in);
for ii = 1:numel(SNames)
    assignin('caller',SNames{ii},in.(SNames{ii}));
end

function out = set_edgetable_path(in)
%This function expects you to pass it the SVMSetup field. It will
%return an output path where it will write the edge table
unpack_struct(in);
abspath=mc_GenPath(in.OutputTemplate);
out = [abspath '/EdgeTable.csv'];

function out = struct_CheckMatrixType(in)
out='upper';
if isfield(in.SVMSetup,'matrixtype')
    out = in.SVMSetup.matrixtype;
end


function out = path_EdgeTable(in)
out = load(in);



function out = struct_Parse(in)
out=in;
if isfield(in,'SVM_ConnectomeResults');
    out=in.SVM_ConnectomeResults;
end


function abspath = build_first_param_path(in)
unpack_struct(in);
Subject=SubjDir{1,1};
Run=RunDir{1};
abspath=mc_GenPath(ROITemplate);

function out = pathclean(oldpath,pattern,newpattern);
out=regexprep(oldpath,pattern,newpattern);

function out =  template_cleaner(in)
out = in;
environ = in.SVMSetup;
retaincells = {'Exp','Subject','Run'};
out.SVMSetup.ConnTemplate = mc_GenPath_helper(in.SVMSetup.ConnTemplate,environ,retaincells);
out.SVMSetup.OutputTemplate = mc_GenPath_helper(in.SVMSetup.OutputTemplate,environ,retaincells);
out.SVMSetup.ROITemplate = mc_GenPath_helper(in.SVMSetup.ROITemplate,environ,retaincells);


function out = mc_GenPath_helper(template,environ,retaincells)
% This function will protect the strings specified
unpack_struct(environ);

orstr='';

for ii=1:numel(retaincells)
    orstr=strcat(orstr,'|',retaincells{ii});
end
orstr(1) = []; % Get rid of the first pipe

srstr = [ '\[(' orstr ')\]' ] ;
repstr = '\0$1\0';

protected_template = regexprep(template,srstr,repstr);
filled_template = mc_GenPath(protected_template);

nsrstr = [ '\0(' orstr ')\0' ] ;
nrepstr = '\[$1\]';

out = regexprep(filled_template,nsrstr,nrepstr);

function out = struct_EdgeTable(in,NetSphereRad) % Heavy lifting happens here

%% Check matrix mode
matrixtype = struct_CheckMatrixType(in); 

if strcmp(matrixtype,'nodiag')
    in = struct_nodiagHelper_pre(in);
end

%% Figure out pruned subset
prune = all(in.LOOCV_pruning{1},1);

%% Get ROI's in MNI space
parameters=load(build_first_param_path(in.SVMSetup));

ROI=parameters.parameters.rois.mni.coordinates;

%% Clean the path to avoid Exp

in.SVMSetup.ConnTemplate=pathclean(in.SVMSetup.ConnTemplate,'\[Exp\]',in.SVMSetup.Exp);

%% Load up, clean, and delta the paired data

[data SubjAvail]=mc_load_connectomes_paired(in.SVMSetup.SubjDir,in.SVMSetup.ConnTemplate,in.SVMSetup.RunDir,matrixtype);

data=mc_connectome_clean(data);

[data_baseline label]=mc_calc_deltas_paired(data,SubjAvail,[1 0]);
data_baseline=mean(data_baseline(label==1,:));
[data_delta label]=mc_calc_deltas_paired(data,SubjAvail,[-1 1]);
data_delta=mean(data_delta(label==1,:));

%% Create the tables

TblBaseLine=mc_connectome_tablewriter(prune,ROI,data_baseline,0,'/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr',matrixtype);
TblDelta=mc_connectome_tablewriter(prune,ROI,data_delta,0,'/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr',matrixtype);

out=[TblBaseLine TblDelta(:,5)];

out{1,5}='Pearson R Baseline';
out{1,end}='Pearson R Con2 - Con1';

if strcmp(matrixtype,'nodiag')
    TblTwinCt=mc_connectome_tablewriter(prune,ROI,in.twincount,0,'/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr',matrixtype);
    out = [out TblTwinCt(:,5)];
    out{1,end}='TwinCount';
end

if NetSphereRad~=0 % Recover otherwise zero-labeled nodes if radius is specified
    ROI1 = cell2mat(out(2:end,1));
    ROI2 = cell2mat(out(2:end,2));
    
    ROI1relabel = mc_NearestNetworkNode(ROI1,NetSphereRad)';
    ROI2relabel = mc_NearestNetworkNode(ROI2,NetSphereRad)';
    
    out{1,end+1}='Node1Relabel';
    out{1,end+1}='Node2Relabel';
    
    out(2:end,end-1) = mat2cell(ROI1relabel,ones(size(out,1)-1,1),1);
    out(2:end,end) = mat2cell(ROI2relabel,ones(size(out,1)-1,1),1);
    
end

function out = write_EdgeTable(edgetable,path) % Write the edge tab
fid = fopen(path,'w');
for iE=1:size(edgetable,1)
    for iL=1:size(edgetable,2)
        thing=edgetable{iE,iL};
        if ischar(thing)
            fprintf(fid,'"%s",',edgetable{iE,iL});
        elseif isnumeric(thing) & size(thing,2)==1
            fprintf(fid,'"%f",',edgetable{iE,iL});
        else
            fprintf(fid,'"[%d, %d, %d]",',thing);
        end
    end
    fprintf(fid,'\n');
end
fclose(fid);
out=1;

function out = struct_nodiagHelper_pre(in)
% Clean up prune object so that ties are broken. We'll find the consensus our own way

%initialize 
out = in;

%% Make upper and lower version

prunes=in.LOOCV_pruning{1};
[nrow ncol]=size(prunes);

nroi=sqrt(ncol);

for iR = 1:nrow
    up(iR,:) = mc_flatten_upper_triangle(reshape(prunes(iR,:),nroi,nroi));
    dn(iR,:) = mc_flatten_upper_triangle(reshape(prunes(iR,:),nroi,nroi)');
    
end

%% Figure out the consensus

threed(:,:,1) = up;
threed(:,:,2) = dn;

twins = any(threed,3);
supertwins=all(threed,3);


consensus = all(twins,1);

%% Figure out the twin winners

upct = sum(up,1);
dnct = sum(dn,1);

% Remove all but the consensus
upct(~consensus)=0;
dnct(~consensus)=0;

% Store an overall twincount measure
twinct_sq = mc_unflatten_upper_triangle(upct) + mc_unflatten_upper_triangle(dnct)';
twinct_flat = reshape(twinct_sq,1,nroi^2);

out.twincount = twinct_flat;

% Identify preference
stack=[upct; dnct];

ministack=stack(:,any(stack))';


[stackmax, pref] = max(stack);

pref(~consensus)=0;

uppref=pref==1;
dnpref=pref==2;

uppref_sq=mc_unflatten_upper_triangle(uppref);
dnpref_sq=mc_unflatten_upper_triangle(dnpref);

fullpref_sq=uppref_sq+dnpref_sq';

fullpref_flat = reshape(fullpref_sq,1,numel(fullpref_sq));

%% Make Overall Edge Table
out.LOOCV_pruning{1}=fullpref_flat;

