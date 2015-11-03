% handle logging
LogDirectory = mc_GenPath(struct('Template',LogTemplate,'mode','makedir'));
result = mc_Logger('setup', LogDirectory);
if (~result)
    mc_Error('There was an error creating your logfiles.\nDo you have permission to write to %s?',LogDirectory);
end
global mcLog



display ('-----')
OutputPathFile = mc_GenPath(OutputPathTemplate);
display('I am going to compute physio summary statistics');
display(sprintf('The output will be stored here: %s', OutputPathFile));
display('These are the subjects:')
display(SubjDir)
display ('-----')


clear CombinedOutput
clear MotionPath
for iSubject = 1:size(SubjDir,1)

    Subject = SubjDir{iSubject,1};
    NumRun  = numel(SubjDir{iSubject,3});
    
    for jRun = 1:NumRun
        
        iRun = SubjDir{iSubject,3}(1,jRun);
        %       CharjRun = sprintf('%02d',jRun);
        Run  = RunDir{iRun};

        PhysioPathCheck = struct('Template',PhysioPathTemplate,...
                                 'mode','check');
        PhysioPath = mc_GenPath(PhysioPathCheck);
        
        PhysioParameters = load (PhysioPath);
        %Output=euclideanDisplacement(MotionParameters,LeverArm);
        
        CardRate=(sum(PhysioParameters.card)/(range(PhysioParameters.time))*60);
        RespRate=(sum(PhysioParameters.peakDelta)/(range(PhysioParameters.time))*60);
        
        CombinedOutput{iSubject,iRun}=horzcat(CardRate,RespRate);

    end %% loop over runs

end %%% loop over subjects

%%%%%%% Save results to CSV file

OutputPathFullStruct = struct('Template',OuputPathTemplate,...
                              'suffix','.csv',...
                              'mode','makeparentdir');
                          
OuputPathFile        = mc_GenPath(OutputPathFullStruct);

theFID = fopen(OutputPathFile,'w');
if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return
end

fprintf(theFID,'Subject,Run,CardRate,RespRate\n'); %header

for iSubject = 1:size(SubjDir,1)
    
    Subject = SubjDir{iSubject,1};
    NumRun  = size(SubjDir{iSubject,3},2);
    
    for jRun = 1:NumRun
        
        iRun = SubjDir{iSubject,3}(1,iRun);

%  %%%%% Select appropriate output based on h user has set
%  
%  index=strfind(PhysioPathTemplate,'Run');
%  if size(index)>0
%  RunString=RunDir{iRun};
%  else
%    RunString = sprintf('%02d',jRun);
 %end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%
 
        RunString=num2str(iRun);
 
        for iRow = 1:size(CombinedOutput{iSubject,jRun},1)
            chariRow = int2str(iRow);
            fprintf(theFID,'%s,%s,',Subject,RunString);
            for iColumn=1:size(CombinedOutput{iSubject,jRun},2)
                fprintf(theFID,'%g,',CombinedOutput{iSubject,iRun}(iRow,iColumn));
            end %iColumn
            fprintf(theFID,'\n');
        end %iRow
    end %iRun

    % Log usage
    str = sprintf('Subject:%s Runs:%d PhysioSummary complete.\n', Subject, NumRun);
    UsageResult = mc_Usage(str, 'PhysioSummary');
    if ~UsageResult
        mc_Logger('log', 'Unable to log usage information.', 2);
    end
    
end %iSubject

fclose(theFID);
display('All Done')
