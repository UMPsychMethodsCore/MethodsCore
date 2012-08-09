function [ data, labels ] = mc_load_connectomes( SubjDir, FileTemplate, RunDir, svmtype )
%MC_LOAD_SVM_DATASET Load connectomic data
%   Prior to performing SVM, you will need to load your connectomic data.
%   These can be produced by the som toolbox including in the advanced
%   feature set of the Methods Core Toolbox. For each subject, this should
%   produce two files, one which holds the connectivity matrix, and the
%   other which holds parameters which indicate ROIs, etc.

conPathTemplate.Template=FileTemplate;
conPathTemplate.mode='check';


switch svmtype
    
    case 'unpaired'
        
        nSubs=size(SubjDir,1);
        
        for iSub=1:size(SubjDir,1)
            Subject = SubjDir{iSub,1};
            Example=SubjDir{iSub,2};
            conPath=mc_GenPath(conPathTemplate);
            conmat=load(conPath);
            rmat=conmat.rMatrix;
            if iSub==1
                superflatmat=zeros(nSubs,size(mc_flatten_upper_triangle(rmat),2));
            end
            superflatmat(iSub,:)=mc_flatten_upper_triangle(rmat);
            label(iSub,1)=Example;
            
        end
        
    case paired

        nSubs=size(SubjDir,1);
        
        
        
        condNum = size(SubjDir{1,2},2);
        
        condAvail = zeros(nSubs,condNum);
        
        
        
        unsprung=0;
        
        % ID Number of Groups
        condNum = size(SubjDir{1,2},2);
        
        
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
                        superflatmat_grouped=zeros(nSubs,size(mc_flatten_upper_triangle(rmat),2),condNum);
                        unsprung=1;
                    end
                    condAvail(iSub,iCond)=1;
                    superflatmat_grouped(iSub,:,iCond) = mc_flatten_upper_triangle(rmat);
                end
                
            end
        end
        
        
        
        
end

