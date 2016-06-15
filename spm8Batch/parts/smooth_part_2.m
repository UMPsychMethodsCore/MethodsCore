
% --------------- BEGINNING OF PART II ----------------------
%
% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

%
% Loop over the subjects and smooth each one.
%

curDIR = pwd;

warning off

for iSub = 1:length(UMBatchSubjs)
  WorkingSubject = [deblank(UMBatchMaster) '/' UMBatchSubjs{iSub}];
  for iRun = 1:length(UMImgDIRS{iSub})
    cd(UMImgDIRS{iSub}{iRun});
    %
    % Find out if they are using a sandbox for the smoothing.
    %
    [CS SandBoxPID Images2Write Images2Write_orig] = moveToSandBox(UMImgDIRS{iSub}{iRun},UMVolumeWild,SandBoxPID,UMVolumeExt);
    %P = spm_select('ExtFPList',UMImgDIRS{iSub}{iRun},['^' UMVolumeWild '.*.nii'],inf);
    fprintf('Smoothing %d "%s" images in %s with %2.1f %2.1f %2.1f\n',size(Images2Write,1),UMVolumeWild,UMImgDIRS{iSub}{iRun},UMKernel(1),UMKernel(2),UMKernel(3));
    results = UMBatchSmooth(Images2Write,UMKernel,OutputName,UMTestFlag);
    if UMCheckFailure(results)
      exit(abs(results))
    end
    %
    % Now move back out of sandbox if so specified
    %
    CSBACK = moveOutOfSandBox(UMImgDIRS{iSub}{iRun},UMVolumeWild,SandBoxPID,OutputName,CS);
    
    %
    %build json file and submit to bash_curl
    %
    [~,Run,~] = fileparts(UMImgDIRS{iSub}{iRun});
    JSONFile = [FULLSCRIPTNAME '_' UMBatchSubjs{iSub} '_' Run '.json'];
    fid = fopen(JSONFile,'w');
    fprintf(fid,'{"OpType":"smoothfMRI",\n"VerHash":"%s",\n',MC_SHA);
    %paramdict
    %hold for now, may no longer be logging command line paramters
    %infiles
    InFiles = unique(strtrim(regexprep(mat2cell(Images2Write_orig,ones(size(Images2Write_orig,1),1),size(Images2Write_orig,2)),',[0-9]*','')));
    fprintf(fid,'"InFile":[\n');
    for iFile = 1:size(InFiles,1)
        [sss ooo] = system(['sha256sum ' InFiles{iFile}]);
        oooo = strsplit(ooo);
        hash = oooo{1};
        fprintf(fid,'{"Hash":"%s",\n"Path":"%s",\n"PortKey":"%d"}',hash,InFiles{iFile},iFile);
        if (iFile < size(InFiles,1))
            fprintf(fid,',');
        end
        fprintf(fid,'\n');
    end
    fprintf(fid,'],\n');
    %outfiles
    fprintf(fid,'"OutFile":[\n');
    for iFile = 1:size(InFiles,1)
        [p f e] = fileparts(InFiles{iFile});
        OutputImage = fullfile(p,[OutputName f e]);
        [sss ooo] = system(['sha256sum ' OutputImage]);
        oooo = strsplit(ooo);
        hash = oooo{1};
        fprintf(fid,'{"Hash":"%s",\n"Path":"%s",\n"PortKey":"%d"}',hash,OutputImage,iFile);
        if (iFile < size(InFiles,1))
            fprintf(fid,',');
        end
        fprintf(fid,'\n');        
    end
    fprintf(fid,']\n}\n');
    fclose(fid);
    %submit json file to database
    [status output] = system(sprintf('%s/bash_curl/curl_json.sh %s %s',mcRoot,JSONFile,DBTarget));
    output
    if (status ~= 0)
        %error with logging to database
        UMCheckFailure(-1);
    end
    
  end
end

fprintf('\nAll done with smoothing images.\n');

cd(curDIR);

%
% all done.
%
