% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% UMBatchDetectSpike
%
% A function that performs a batch detect spike upon several subjects.
%
%  Call as :
%
%  function results = UMBatchDetectSpike(Images,OutputFile,Subject,Run)
%
%  To Make this work you need to provide the following input:
%
%  Images     = char array of images to test
%  OutputFile = file to write detected spikes
%  ImagePath  = full directory path to Images
%
%  Output
%  
%     results        = -1 if failure
%                       1 if success
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
function results = UMBatchDetectSpike(Images,OutputFile,ImagePath)
    detOpt  = 1;
    Thres   = 10;
    results = -1;

    fid = fopen(OutputFile,'w');
    if fid == -1
        fprintf('Cannot open file: %s\n',Outputfile);
        fprintf('   * * * A B O R T I N G * * *\n');
        return;
    end

    %
    % Build 4D array
    %
    if size(Images,1) > 1
        firstImage = nifti( strtrim(Images(1,:)) );
        data       = zeros( [firstImage.dat.dim(1:3) size(Images,1)] );
        clear firstImage
        
        for i=1:size(Images,1)
            dumImage      = nifti( strtrim(Images(i,:)) );
            data(:,:,:,i) = dumImage.dat(:,:,:,1);
            clear dumImage
        end
    else
        dumImage = nifti( strtrim(Images) );
        data     = dumImage.dat(:,:,:,:);
        clear dumImage
    end
	
    %
    % Detect spikes here
    %
    [success results] = dSpike(data,detOpt);
    if success == -1
        return;
    end
    
    %
    % Write output to text file
    %
    [nSlice nTime] = size(results);
    
    % Common header first
    fprintf(fid,'%s\n\n',ImagePath);
    fprintf(fid,'Slices:%d\n',nSlice);
    fprintf(fid,'nTime :%d\n',nTime);
    fprintf(fid,'Thres :%d\n',Thres);
    fprintf(fid,'detOpt:%d\n\n',detOpt);
    
    % Write detected spikes now
    [Slice Timepoint] = find(results > Thres);
    if isempty(Slice)
        fprintf(fid,'Status : No spikes found\n');
    else
        fprintf(fid,'Status : %d spikes found\n',size(Slice,1));
        
        for i=1:size(Slice,1)
            fprintf(fid,'Slice:%d,Timepoint:%d,AJKZ:%f\n',Slice(i),Timepoint(i),results( Slice(i), Timepoint(i) ) );
        end
    end
    fprintf(fid,'\n');
    fclose(fid);
    
    % Log detectSpike was performed
    DetectSpikeDir = fileparts( strtrim( Images(1,:) ) );
    
    UMBatchLogProcess(DetectSpikeDir,sprintf('UMBatchDetectSpike : Scanned images (%04d) : %s',size(Images,1),Images(1,:)));
    
    if size(Images,1) > 1
        UMBatchLogProcess(DetectSpikeDir,sprintf('UMBatchDetectSpike : through image          : %s',Images(end,:)));
    end
    
    results = 1;
end

