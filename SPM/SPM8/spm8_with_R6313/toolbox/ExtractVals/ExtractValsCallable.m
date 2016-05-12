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

function ExtractValsCallable(roiFile,FilesToExtract)

nExtractions = 1;

if nExtractions < 1
  fprintf('Exiting as you requested.\n');
  return
end

spmMaskFiles{1} = roiFile;

spmValsFiles{1} = FilesToExtract;

% Now extract the files.

fid = fopen('extracted_vals.txt','w');

if (fid>0)
  fprintf('Writing extractions to "extracted_vals.txt"\n');
end

fprintf('Subject NVoxels Mean StandDev MaxValue\n');
for iExtraction = 1:nExtractions
  maskHdr = spm_vol(spmMaskFiles{iExtraction});
  maskVol = spm_read_vols(maskHdr);
  maskIDX = find(maskVol);
  fprintf('Extraction #%d\n',iExtraction);
  for iSubject = 1:size(spmValsFiles{iExtraction},1);
    valsHdr = spm_vol(strtrim(spmValsFiles{iExtraction}(iSubject,:)));
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
end
fclose(fid);

fprintf('\nFinished extracting values.\n');

%
% All done.
%
