

display ('-----')
OutputPathFile = generate_path_CSS(OutputPathTemplate,Exp);
display('I am going to compute physio summary statistics');
display(sprintf('The size of the lever arm I will use is %d',LeverArm));
display(sprintf('The output will be stored here: %s', OutputPathFile));
display('These are the subjects:')
display(SubjDir)
display ('-----')



addpath /net/dysthymia/matlabScripts/  %%%% this is for generate_path_CSS

clear CombinedOutput
clear MotionPath
for iSubject = 1:size(SubjDir,1)

    NumRun= size(SubjDir{iSubject,3},2);
    for jRun = 1:NumRun
        Subject = SubjDir{iSubject,1};
        iRun=SubjDir{iSubject,3}(1,jRun);
        %       CharjRun = sprintf('%02d',jRun);
        Run = RunDir{iRun};

        pathcallcmd=generate_PathCommand(PhysioPathTemplate);
        PhysioPath = eval(pathcallcmd);
        

        
        PhysioParameters = load (PhysioPath);
        %Output=euclideanDisplacement(MotionParameters,LeverArm);
        CardRate=(sum(card)/(range(time))*60;
        RespRate=(sum(peakDelta)/(range(time))*60;
        
        CombinedOutput{iSubject,iRun}=horzcat(CardRate,RespRate);

    end %% loop over runs

end %%% loop over subjects

%%%%%%% Save results to CSV file

OutputPathFull=generate_path_CSS(OutputPathTemplate,Exp, OutputName);
[OutputPath OutputName] = fileparts(OutputPathFull);

eval(sprintf('!mkdir -p %s',OutputPath));
OutputPathFile=[OutputPath '/' OutputName];
theFID = fopen([OutputPathFile,'.csv'],'w');
if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return
end
fprintf(theFID,'Subject,Run,CardRate,RespRate\n'); %header
for iSubject = 1:size(SubjDir,1)
    Subject=SubjDir{iSubject,1};
    NumRun= size(SubjDir{iSubject,3},2);
    for jRun = 1:NumRun
        iRun=SubjDir{iSubject,3}(1,iRun);
        
        
 
 %%%%% Select appropriate output based on h user has set
 
 index=strfind(PhysioPathTemplate,'Run');
 if size(index)>0
 RunString=RunDir{iRun};
 else
     RunString=num2str(iRun);
%    RunString = sprintf('%02d',jRun);
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
        for iRow = 1:size(CombinedOutput{iSubject,jRun},1)
            chariRow = int2str(iRow);
            fprintf(theFID,'%s,%s,',Subject,RunString);
            for iColumn=1:size(CombinedOutput{iSubject,jRun},2)
                fprintf(theFID,'%g,',CombinedOutput{iSubject,iRun}(iRow,iColumn));
            end %iColumn
            fprintf(theFID,'\n');
        end %iRow
    end %iRun
end %iSubject

fclose(theFID);
display('All Done')
