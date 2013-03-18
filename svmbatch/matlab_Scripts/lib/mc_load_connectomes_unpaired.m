function [ data, label ] = mc_load_connectomes_unpaired( SubjDir, FileTemplate, matrixtype )
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
%       matrixtype      -   Used to specify matrix mode. If
%                           doing a cPPI, you may be using
%                           a flattened form of the entire
%                           connectivity matrix. In this
%                           case, flattening and
%                           unflattening will work a little
%                           bit differently. % 
%   NOTE - Use this function if loading unpaired datasets where you have two or more classes.

conPathTemplate.Template=FileTemplate;
conPathTemplate.mode='check';

if ~exist('matrixtype','var')
    matrixtype='upper';
end


nSubs=size(SubjDir,1);

for iSub=1:size(SubjDir,1)
  Subject = SubjDir{iSub,1};
  Example=SubjDir{iSub,2};
  conPath=mc_GenPath(conPathTemplate);
  conmat=load(conPath);
  rmat=conmat.rMatrix;
  if iSub==1
      switch matrixtype
        case 'upper'
          data=zeros(nSubs,size(mc_flatten_upper_triangle(rmat),2));
        case 'nodiag'
          data=zeros(nSubs,numel(rmat));
      end
      switch matrixtype
        case 'upper'
          data(iSub,:)=mc_flatten_upper_triangle(rmat);
        case 'nodiag'
          data(iSub,:)=reshape(rmat,numel(rmat),1);
      end
      label(iSub,1)=Example;
      
  end
end
