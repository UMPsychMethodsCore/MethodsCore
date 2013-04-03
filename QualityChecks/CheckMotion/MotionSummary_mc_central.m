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
            [FD FDjudge] = mc_FD_calculation(MotionParameters, FDcriteria, FDLeverArm, ScansBefore, ScansAfter);
        else
            Output = euclideanDisplacement(fliplr(MotionParameters),LeverArm);
            [FD FDjudge] = mc_FD_calculation(fliplr(MotionParameters), FDcriteria, FDLeverArm, ScansBefore, ScansAfter);
        end
        
        Output.meanFD       = mean(FD);
        Output.censorvector = FDjudge;
        Output.nonzeroFD    = nnz(FDjudge);
        
        if ~isstruct(Output) && Output == -1; return; end;
        CombinedOutput{iSubject,jRun} = Output;
        
        % Write out censor regressor csv
        [pathstr file ext] = fileparts(MotionPath);
        fdCsv = fullfile(pathstr, 'fdOutliers.csv');
        fdFid = fopen(fdCsv, 'w');
        if fdFid == -1
            fprintf(1, 'Cannot write fdOutliers.csv for subject %s\n', Subject);
            fprintf(1, 'Check permissions for path: %s\n', pathstr);
        else
            if ~isempty(FDjudge)
                ind = find(FDjudge(:) > 0);
                [m n] = ind2sub(size(FDjudge), ind);
                for i = 1:(length(m) - 1)
                    fprintf(fdFid, 'scan%d,', m(i));
                end
                fprintf(fdFid, 'scan%d\n', m(end));

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

fprintf(theFID,'Subject,Run,maxSpace,meanSpace,sumSpace,maxAngle,meanAngle,sumAngle,meanFD,SupraThresholdFD\n'); %header
for iSubject = 1:size(SubjDir,1)
    Subject = SubjDir{iSubject,1};
    for jRun = 1:size(SubjDir{iSubject,3},2)
        RunNum = SubjDir{iSubject,3}(jRun);
        
        %%%%% Select appropriate output based on h user has set
        index=strfind(MotionPathTemplate,'Run');
        if size(index)>0
            RunString=RunDir{jRun};
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
        fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.meanFD);
        fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,jRun}.nonzeroFD);
    end
end

fclose(theFID);
display('All Done')
