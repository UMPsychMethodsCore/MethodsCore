function [ data, label ] = mc_load_connectomes_unpaired( SubjDir, FileTemplate )
%MC_LOAD_SVM_DATASET Load connectomic data
%   Prior to performing SVM, you will need to load your connectomic data.
%   These can be produced by the som toolbox including in the advanced
%   feature set of the Methods Core Toolbox. For each subject, this should
%   produce two files, one which holds the connectivity matrix, and the
%   other which holds parameters which indicate ROIs, etc.
%   
%   INPUT
%       SubjDir         -   Cell array holding your subject folders and also
%                           your labels. First column of cell array should be
%                           strings which will be swapped in for [Subject] in
%                           your FileTemplate. Second column is example label.
%                           For two class SVM it should be +1 or -1, though
%                           in the future multiclass or regression labels
%                           should also be supported.
%       FileTemplate    -   Path used for finding your connectivity
%                           matrices, suitable for passing to mc_GenPath.
%                           Only thing you can use here is Subject.
%                           Example:
%                           '/net/data4/MAS/FirstLevel/[Subject]/conn.mat'
% 
%   NOTE - Use this function if loading unpaired datasets where you have two or more classes.

conPathTemplate.Template=FileTemplate;
conPathTemplate.mode='check';



nSubs=size(SubjDir,1);

for iSub=1:size(SubjDir,1)
  Subject = SubjDir{iSub,1};
  Example=SubjDir{iSub,2};
  conPath=mc_GenPath(conPathTemplate);
  conmat=load(conPath);
  rmat=conmat.rMatrix;
  if iSub==1
    data=zeros(nSubs,size(mc_flatten_upper_triangle(rmat),2));
  end
  superflatmat(iSub,:)=mc_flatten_upper_triangle(rmat);
  label(iSub,1)=Example;
end

        
        
        
end

