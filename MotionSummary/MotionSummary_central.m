display ('-----')
OutputPathFile = mc_GenPath( struct('Template',OutputPathTemplate,...
                                    'suffix','.csv',...
                                    'mode','makeparentdir') );
                                
display('I am going to compute summary motion summary statistics');
display(sprintf('The size of the lever arm I will use is %d',LeverArm));
display(sprintf('The output will be stored here: %s', OutputPathFile));
display('These are the subjects:')
display(SubjDir)
display ('-----')

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
            Output = euclideanDisplacement(MotionParameters,LeverArm,FDLeverArm,FDcriteria);
        else
            Output = euclideanDisplacement(fliplr(MotionParameters),LeverArm,FDLeverArm,FDcriteria);
        end
        if ~isstruct(Output) && Output == -1; return; end;
        CombinedOutput{iSubject,jRun} = Output;
    end

end

%%%%%%% Save results to CSV file
theFID = fopen(OutputPathFile,'w');
if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return;
end

%%%%%%%%%% Output Values for each Run of each Subject%%%%%%%%%%%%%%%%
% fprintf(theFID,'Subject,Run,maxSpace,meanSpace,maxAngle,meanAngle,meanFD,nonzeroFD\n'); %header
% for iSubject = 1:size(SubjDir,1)
%     Subject = SubjDir{iSubject,1};
%     for jRun = 1:size(SubjDir{iSubject,3},2)
%         RunNum = SubjDir{iSubject,3}(jRun);
%         
%         %%%%% Select appropriate output based on h user has set
%         index=strfind(MotionPathTemplate,'Run');
%         if size(index)>0
%             RunString=RunDir{jRun};
%         else
%             RunString=num2str(jRun);
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         fprintf(theFID,'%s,%s,',Subject,RunString);
%         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.maxSpace);
%         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.meanSpace);
%         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.maxAngle);
%         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.meanAngle);
%         fprintf(theFID,'%.4f,',CombinedOutput{iSubject,jRun}.meanFD);
%         fprintf(theFID,'%.4f\n',CombinedOutput{iSubject,jRun}.nonzeroFD);
%     end
% end

%%%%%%%%%%%%%%%%% Output averaged values along runs for each Subject %%%%%
fprintf(theFID,'Subject,maxSpace,meanSpace,maxAngle,meanAngle,meanFD,nonzeroFD\n'); %header
for iSubject = 1:size(SubjDir,1)
    Subject = SubjDir{iSubject,1};
%     for jRun = 1:size(SubjDir{iSubject,3},2)
%         RunNum = SubjDir{iSubject,3}(jRun);
        
%         %%%%% Select appropriate output based on h user has set
%         index=strfind(MotionPathTemplate,'Run');
%         if size(index)>0
%             RunString=RunDir{jRun};
%         else
%             RunString=num2str(jRun);
%         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        temp = [CombinedOutput{iSubject,:}];
        FinalOutput.maxSpace = mean([temp(:).maxSpace]);
        FinalOutput.meanSpace = mean([temp(:).meanSpace]);
        FinalOutput.maxAngle = mean([temp(:).maxAngle]);
        FinalOutput.meanAngle = mean([temp(:).meanAngle]);
        FinalOutput.meanFD = mean([temp(:).meanFD]);
        FinalOutput.nonzeroFD = sum([temp(:).nonzeroFD]);
        
        fprintf(theFID,'%s,%s,',Subject);
        fprintf(theFID,'%.4f,',FinalOutput.maxSpace);
        fprintf(theFID,'%.4f,',FinalOutput.meanSpace);
        fprintf(theFID,'%.4f,',FinalOutput.maxAngle);
        fprintf(theFID,'%.4f,',FinalOutput.meanAngle);
        fprintf(theFID,'%.4f,',FinalOutput.meanFD);
        fprintf(theFID,'%.4f\n',FinalOutput.nonzeroFD);
%     end
end

fclose(theFID);
display('All Done')
