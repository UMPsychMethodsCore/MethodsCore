function [ data_conditions, SubjAvail ] = mc_load_connectomes_paired( SubjDir, FileTemplate, RunDir )
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
%                           strings which will be swapped in for [Subject]
%                           in your FileTemplate. For paired SVM, next is a
%                           mapping of conditions to runs. Include a
%                           0 if a given condition is not present. E.g. 
%                           [3 1 0] would indicate that
%                           condition one is present in Run 3, condition two
%                           is present in run 1, and condition three is
%                           missing.
%       FileTemplate    -   Path used for finding your connectivity
%                           matrices, suitable for passing to mc_GenPath.
%                           Only thing you can use here is Subject.
%                           Example:
%                           '/net/data4/MAS/FirstLevel/[Subject]/conn.mat'
%       RunDir          -   Do you have multiple runs (or something run-like 
%                           to iterave over?) If so, specify it here.
% 
%   OUTPUT
%       data_conditions -   All of your loaded data! Should be a three
%                           dimensional array. Rows index examples, columns
%                           index features, and depth indexes conditions
%       SubjAvail       -   A mapping of subject availability by condition.
%                           2D matrix. Rows index subjects, columns index
%                           conditions. 1 indicates availability, 0
%                           indicates unavailability

conPathTemplate.Template=FileTemplate;
conPathTemplate.mode='check';
  
nSubs=size(SubjDir,1);

nCond = size(SubjDir{1,2},2);

SubjAvail = zeros(nSubs,nCond);



unsprung=0;


for iSub=nSubs
  Subject = SubjDir{iSub,1};
  for iCond = 1:condNum
    curRunID = SubjDir{iSub,2}(iCond);
    if curRunID ~= 0
      Run = RunDir{curRunID};
      conPath=mc_GenPath(conPathTemplate);
      conmat=load(conPath);
      rmat=conmat.rMatrix;
      if ~exist('unsprung','var') || unsprung==0
        data_conditions=zeros(nSubs,size(mc_flatten_upper_triangle(rmat),2),condNum);
        unsprung=1;
      end
      SubjAvail(iSub,iCond)=1;
      data_conditions(iSub,:,iCond) = mc_flatten_upper_triangle(rmat);
    end
  end
end


end

