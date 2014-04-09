%+---------------------------------------
%|
%| Robert C. Welsh
%| 2002.10.20
%| 
%| University of Michigan
%| Department of Radiology
%|
%| A little toolbox to apply a mask to
%| a t-map or beta-map or con-map and 
%| report the mean and variance.
%| 
%+---------------------------------------

function ExtractVals

SCCSid  = '0.5';

global BCH; %- used as a flag to know if we are in batch mode or not.

%-GUI setup

%-----------------------------------------------------------------------

SPMid = spm('FnBanner',mfilename,SCCSid);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','ROI->Mask Toolbox',0);
fprintf('ExtractVals Toolbox 0.5\n');

spm('FigName','Extract Values Using Mask',Finter,CmdLine);
% get the name of the rois file.

% smoothing parameters
nExtractions = spm_input('Number of group extractions to perform','+1','i','1',1,[0,Inf]);

if nExtractions < 1
  spm('alert','Exiting as you reuested.');
  return
end

spmMaskFiles = {};
spmValsFiles = {}; 



allsame = spm_input('Do you want to use the same mask for all extractions', -1,'yes|no',[1,0],2);

if allsame == 0 
    for iExtraction = 1:nExtractions
        spmMaskFiles{iExtraction}  = spm_get([0,1],'*.img',sprintf(['Pick' ...
                ' Mask Image File for group pextraction %d'],iExtraction),'./',0)
        
        if (length(spmMaskFiles{iExtraction})< 1)
            spm('alert','Exiting as you requested.','ExtractVals',[],0);
            return
        end
        
        spmValsFiles{iExtraction}  = spm_get([0,Inf],'*.img',sprintf(['Pick T/Beta/Con' ...
                ' Image files for extraction %d'],iExtraction),'./',0);
        
        if (length(spmValsFiles{iExtraction})< 1)
            spm('alert','Exiting as you requested.','ExtractVals',[],0);
                              return
        end
        
    end   
    
elseif allsame == 1
    for iExtraction = 1:1
    spmMaskFiles{1} =  spm_get([0,1],'*.img',sprintf(['Pick' ...
            ' Mask Image File for group pextraction %d'],iExtraction),'./',0);
end
    
    for iExtraction = 1:nExtractions
        spmMaskFiles{iExtraction} = spmMaskFiles{1}
    end
    
    for iExtraction = 1:nExtractions
        spmValsFiles{iExtraction}  = spm_get([0,Inf],'*.img',sprintf(['Pick T/Beta/Con' ...
                ' Image files for extraction %d'],iExtraction),'./',0);
    end
    
    if (length(spmValsFiles{iExtraction})< 1)
        spm('alert','Exiting as you requested.','ExtractVals',[],0);
%             return
    end
    
end


    

  
  spmValsFiles{iExtraction}  = spm_get([0,Inf],'*.img',sprintf(['Pick T/Beta/Con' ...
		    ' Image files for extraction %d'],iExtraction),'./',0);
    
  if (length(spmValsFiles{iExtraction})< 1)
    spm('alert','Exiting as you requested.','ExtractVals',[],0);
    return
  end


% Now extract the files.


fprintf('Extraction NVoxels Mean Variance\n');
for iExtraction = 1:nExtractions
  spm_progress_bar('Init',size(spmValsFiles{iExtraction},1),'Files to Read','Extracting data');
  maskHdr = spm_vol(spmMaskFiles{iExtraction});
  maskVol = spm_read_vols(maskHdr);
  maskIDX = find(maskVol);
  fprintf('Subject #%d\n',iExtraction);
  for iSubject = 1:size(spmValsFiles{iExtraction},1);
    spm_progress_bar('Set',iSubject);
    valsHdr = spm_vol(spmValsFiles{iExtraction}(iSubject,:));
    valsVol = spm_read_vols(valsHdr);
    meanVal = mean(valsVol(maskIDX));
    variVal = var(valsVol(maskIDX));
    nVoxels = length(maskIDX);
    [d1 fnametoprint d2] = fileparts(valsHdr.fname);
    fprintf('%03d %03d %+6.4f %+6.4f %s %s\n',iSubject,nVoxels,meanVal,variVal,fnametoprint,spmMaskFiles{iExtraction});
  end  
  spm_progress_bar('Clear');
end
spm_clf(Finter);
spm('FigName','Finished',Finter,CmdLine);
spm('Pointer','Arrow');

fprintf('\nFinished extracting values.\n');


%
% All done.
%