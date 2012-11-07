function [ EdgeTable ] = mc_EdgeTable( varargin )
%MC_EDGETABLE Make an "Edge Table"
%
% Usage 1
%   Provide the results of an SVM run as a struct
%
% Usage 2
%   Provide a path to a file that was the result of an SVM run
%
% Usage 3
%   Provide all of the pieces necessary to create a TakGraph (in progress)
%
%   Inputs
% 
%       Feature Weights
%       Path to Network Map
%   

%% Parse arguments

switch nargin
    case 1
        if isstruct(varargin{1})
            SVM=varargin{1};
        end

        if ischar(varargin{1})
            SVM=path_EdgeTable(varargin{1});
        end
        
    otherwise
end

SVM=struct_Parse(SVM);
EdgeTable = struct_EdgeTable(SVM);
writepath = set_edgetable_path(SVM.SVMSetup);
result = write_EdgeTable(EdgeTable,writepath);

function out = set_edgetable_path(in)
%This function expects you to pass it the SVMSetup field. It will
%return an output path where it will write the edge table
unpack_struct(in);
abspath=mc_GenPath(in.OutputTemplate);
out = [abspath '/EdgeTable.csv'];




function out = path_EdgeTable(in)
out = load(in);



function out = struct_Parse(in)
out=in;
if isfield(in,'SVM_ConnectomeResults');
    out=in.SVM_ConnectomeResults;
end


function abspath = build_first_path(template,SubjDir,RunDir,Exp)

Subject=SubjDir{1,1};
Run=RunDir{1};

abspath=mc_GenPath(template);

function out = pathclean(oldpath,pattern,newpattern);
out=regexprep(oldpath,pattern,newpattern);


function out = struct_EdgeTable(in) % Heavy lifting happens here

%% Figure out pruned subset
prune = all(in.LOOCV_pruning{1});

%% Get ROI's in MNI space
parameters=load(build_first_path(in.SVMSetup.ROITemplate,in.SVMSetup.SubjDir,in.SVMSetup.RunDir,in.SVMSetup.Exp));

ROI=parameters.parameters.rois.mni.coordinates;

%% Clean the path to avoid Exp

in.SVMSetup.ConnTemplate=pathclean(in.SVMSetup.ConnTemplate,'\[Exp\]',in.SVMSetup.Exp);

%% Load up, clean, and delta the paired data

[data SubjAvail]=mc_load_connectomes_paired(in.SVMSetup.SubjDir,in.SVMSetup.ConnTemplate,in.SVMSetup.RunDir);

data=mc_connectome_clean(data);

[data_baseline label]=mc_calc_deltas_paired(data,SubjAvail,[1 0]);
data_baseline=mean(data_baseline(label==1,:));
[data_delta label]=mc_calc_deltas_paired(data,SubjAvail,[-1 1]);
data_delta=mean(data_delta(label==1,:));

%% Create the tables

TblBaseLine=mc_connectome_tablewriter(prune,ROI,data_baseline,0,'/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr');
TblDelta=mc_connectome_tablewriter(prune,ROI,data_delta,0,'/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr');

out=[TblBaseLine TblDelta(:,5)];

out{1,5}='Pearson R Baseline';
out{1,end}='Pearson R Con2 - Con1';


function out = write_EdgeTable(edgetable,path) % Write the edge tab
fid = fopen(path,'w');
for iE=1:size(edgetable,1)
    for iL=1:size(edgetable,2)
        thing=edgetable{iE,iL};
        if ischar(thing)
            fprintf(fid,'"%s",',edgetable{iE,iL});
        elseif isnumeric(thing) & size(thing,2)==1
            fprintf(fid,'"%d",',edgetable{iE,iL});
        else
            fprintf(fid,'"[%d, %d, %d]",',thing);
        end
    end
    fprintf(fid,'\n');
end
fclose(fid);
out=1;
