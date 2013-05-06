fprintf(1,'-----\n');
OutputPathFile = mc_GenPath( struct('Template',OutputPathTemplate,...
                                    'suffix','.csv',...
                                    'mode','makeparentdir') );
                  
fprintf(1, 'Computing motion summary statistics\n');
fprintf(1, 'Size of level arm: %f\n', LeverArm);
fprintf(1, 'Output file: %s\n', OutputPathFile);
fprintf(1, 'Subjects:\n');
display(SubjDir);
fprintf(1, '-----\n');

clear CombinedOutput
clear MotionPath
for iSubject = 1:size(SubjDir,1)
    Subject = SubjDir{iSubject,1};     
    for jRun = 1:size(SubjDir{iSubject,3},2)
        RunNum = SubjDir{iSubject,3}(jRun);
        Run    = RunDir{RunNum};

        MotionPathCheck  = struct('Template',MotionPathTemplate,'mode','check');
        MotionPath       = mc_GenPath(MotionPathCheck);
        MotionParameters = load(MotionPath);
        
        [pathstr,name,ext] = fileparts(MotionPath);
        if any(strcmp(ext,{'.par','.dat'}))
            Output = euclideanDisplacement(MotionParameters,LeverArm);
            [FD, FDjudge] = mc_FD_calculation(MotionParameters, FDcriteria, FDLeverArm, FramesBefore, FramesAfter);
        else
            Output = euclideanDisplacement(fliplr(MotionParameters),LeverArm);
            [FD, FDjudge] = mc_FD_calculation(fliplr(MotionParameters), FDcriteria, FDLeverArm, FramesBefore, FramesAfter);
        end
        
        % Pre-Scrubbing Summary of FD
        Output.meanFD       = mean(FD);
        Output.maxFD        = max(FD);
        Output.stdFD        = std(FD);
        Output.censorvector = sum(FDjudge,2);
        Output.nonzeroFD    = nnz(FDjudge);
        
        % Post-Scrubbing Summary of FD
        FD_post = FD;
        FD_post(Output.censorvector==1) = [];
        Output.meanFDpost   = mean(FD_post);
        Output.maxFDpost    = max(FD_post);
        Output.stdFDpost    = std(FD_post);
                
        if ~isstruct(Output) && Output == -1; return; end;
        CombinedOutput{iSubject,jRun} = Output;
        
        if exist('OutputCensorVector','var') && (~isempty(OutputCensorVector))
            OutputCensorVectorFile = mc_GenPath(struct('Template',OutputCensorVector,...
                'suffix','.mat',...
                'mode','makeparentdir'));
            if ~isempty(Output.censorvector)
                cv = Output.censorvector;
            else
                cv = zeros(size(FD));       % No scan excluded scenario
            end
            save(OutputCensorVectorFile,'cv');
        end
        
        % Write out censor regressor csv
        [pathstr, file, ext] = fileparts(MotionPath);
        fdCsv = fullfile(pathstr, 'fdOutliers.csv');
        fdFid = fopen(fdCsv, 'w');
        if fdFid == -1
            fprintf(1, 'Cannot write fdOutliers.csv for subject %s\n', Subject);
            fprintf(1, 'Check permissions for path: %s\n', pathstr);
        else
            if ~isempty(FDjudge)
                for i = 1:size(FDjudge, 1)
                    for k = 1:(size(FDjudge, 2) - 1)
                        fprintf(fdFid, '%d,', FDjudge(i, k));
                    end
                    fprintf(fdFid, '%d\n', FDjudge(i, end));
                end
            end
            fclose(fdFid);
        end
    end
end

%%%%%%% Save results to CSV file
theFID = fopen(OutputPathFile,'w');
if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return;
end

fprintf(theFID,'Subject,Run,maxSpace,meanSpace,sumSpace,maxAngle,meanAngle,sumAngle,maxFDpre,meanFDpre,stdFDpre,maxFDpost,meanFDpost,stdFDpost,SupraThresholdFD\n'); %header
for iSubject = 1:size(SubjDir,1)
    Subject = SubjDir{iSubject,1};
    for jRun = 1:size(SubjDir{iSubject,3},2)
        RunNum = SubjDir{iSubject,3}(jRun);
        
        %%%%% Select appropriate output based on h user has set
        index=strfind(MotionPathTemplate,'Run');
        if size(index)>0
            RunString=RunDir{RunNum};
        else
            RunString=num2str(jRun);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        fprintf(theFID,'%s,%s,',Subject,RunString);
        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.maxSpace);
        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.meanSpace);
        fprintf(theFID,'%.4f,', CombinedOutput{iSubject, jRun}.sumSpace);
        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.maxAngle);
        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.meanAngle);
        fprintf(theFID,'%.4f,', CombinedOutput{iSubject, jRun}.sumAngle);
        fprintf(theFID,'%.4f,', CombinedOutput{iSubject, jRun}.maxFD);
        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.meanFD);
        fprintf(theFID,'%.4f,', CombinedOutput{iSubject, jRun}.stdFD);
        fprintf(theFID,'%.4f,', CombinedOutput{iSubject, jRun}.maxFDpost);
        fprintf(theFID,'%.4f,', CombinedOutput{iSubject, jRun}.meanFDpost);
        fprintf(theFID,'%.4f,', CombinedOutput{iSubject, jRun}.stdFDpost);
        fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,jRun}.nonzeroFD);
    end
end

fclose(theFID);
display('All Done')
