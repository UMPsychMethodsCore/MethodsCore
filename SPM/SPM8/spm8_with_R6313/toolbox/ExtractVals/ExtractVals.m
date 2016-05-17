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
%| 2006.10.03 - Modified to include maximum value.
%|
%+---------------------------------------

function ExtractVals

SCCSid  = '0.75';

global BCH; %- used as a flag to know if we are in batch mode or not.

%-GUI setup
%-----------------------------------------------------------------------

SPMid = spm('FnBanner',mfilename,SCCSid);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','ROI->Mask Toolbox',0);
fprintf('ExtractVals Toolbox 0.5\n');

spm('FigName','Extract Values Using Mask',Finter,CmdLine);
% get the name of the rois file.

% smoothing parameters
nExtractions = spm_input('Number of group/ROI extractions to perform','+1','i','1',1,[0,Inf]);

if nExtractions < 1
  spm('alert','Exiting as you requested.','ExtractVals',[],0);
  return
end

spmMaskFiles = {};
spmValsFiles = {};

for iExtraction = 1:nExtractions
  if spm('Ver') == 'SPM2'
    spmMaskFiles{iExtraction}  = spm_get([0,1],'*.img',sprintf('Pick Mask Image File for group/ROI pextraction %d',iExtraction),'./',0);
  else 
    spmMaskFiles{iExtraction}  = spm_select([0,1],'image',sprintf('Pick Mask Image File for group/ROI pextraction %d',iExtraction));
  end
  
  if (length(spmMaskFiles{iExtraction})< 1)
    spm('alert','Exiting as you requested.','ExtractVals',[],0);
    return
  end
  if spm('Ver') == 'SPM2'
    spmValsFiles{iExtraction}  = spm_get([0,Inf],'*.img',sprintf(['Pick T/Beta/Con' ...
		    ' Image files for extraction %d'],iExtraction),'./',0);
  else
    spmValsFiles{iExtraction}  = spm_select([0,Inf],'image',sprintf('Pick T/Beta/Con.. Image files for extraction %d',iExtraction));
  end
  if (length(spmValsFiles{iExtraction})< 1)
    spm('alert','Exiting as you requested.','ExtractVals',[],0);
    return
  end
end

% Now extract the files.

fid = fopen('extracted_vals.txt','w');
if (fid>0)
  fprintf('Writing extractions to "extracted_vals.txt"\n');
end

fprintf('Subject NVoxels Mean StandDev MaxValue\n');
for iExtraction = 1:nExtractions
  spm_progress_bar('Init',size(spmValsFiles{iExtraction},1),'Files to Read','Extracting data');
  maskHdr = spm_vol(spmMaskFiles{iExtraction});
  maskVol = spm_read_vols(maskHdr);
  maskIDX = find(maskVol);
  fprintf('Extraction #%d\n',iExtraction);
  for iSubject = 1:size(spmValsFiles{iExtraction},1);
    spm_progress_bar('Set',iSubject);
    valsHdr = spm_vol(spmValsFiles{iExtraction}(iSubject,:));
    valsVol = spm_read_vols(valsHdr);
    % 
    % Is this a 4D volume?
    %
    nVoxels = length(maskIDX);
    for iTime = 1:size(valsVol,4)
      [d1 fnametoprint d2] = fileparts(valsHdr(iTime).fname);
      thisVol = valsVol(:,:,:,iTime);
      meanVal = mean(thisVol(maskIDX));
      variVal = var(thisVol(maskIDX));
      maxVal  = max(thisVol(maskIDX));
      %meanVal = mean(valsVol(maskIDX));
      %variVal = var(valsVol(maskIDX));
      %maxVal  = max(valsVol(maskIDX));
      %nVoxels = length(maskIDX);
      fprintf('%03d %03d %+9.7f %+9.7f %+9.7f %02d %s\n',iSubject,nVoxels,meanVal,sqrt(variVal),maxVal,iTime,fnametoprint);
      if (fid>0) 
	     fprintf(fid,'%03d,%03d,%+9.7f,%+9.7f,%+9.7f,%02d,%s\n',iSubject,nVoxels,meanVal,sqrt(variVal),maxVal,iTime,fnametoprint);
      end
    end
  end  
  spm_progress_bar('Clear');
end
fclose(fid);
spm_clf(Finter);
spm('FigName','Finished',Finter,CmdLine);
spm('Pointer','Arrow');

fprintf('\nFinished extracting values.\n');

%
% All done.
%
