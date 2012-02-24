
addpath /net/dysthymia/slab/users/sripada/repos/methods_core/matlabScripts %%%% this is for GeneratePath
display ('-----')
pathcallcmd=GeneratePathCommand(OutputPathTemplate);
OutputPathFile = eval(pathcallcmd);
display('I am going to generate motion regressors');
display(sprintf('The output will be stored here: %s', OutputPathFile));
display('These are the subjects:')
display(SubjDir)
display ('-----')




clear CombinedOutput
clear MotionPath

Num_run_total = size(RunDir,1);


for iSubject = 1: size(SubjDir,1)
    Subject=SubjDir{iSubject}(1:end);
    NumRun= size(SubjDir{iSubject,3},2);
    for jRun = 1:NumRun
        Subject = SubjDir{iSubject,1};
        iRun=SubjDir{iSubject,3}(1,jRun);

        Run = RunDir{iRun};


        pathcallcmd=GeneratePathCommand(MotionPathTemplate);
        MotionPath = eval(pathcallcmd);
        CheckPath(MotionPath, 'a realignment file')
        MotionParameters = load (MotionPath);



        CombinedOutput{iSubject,iRun}=[];
        chariRun = int2str (iRun);

        % 		if (iRun > Num_run_total)
        % 			MotionParameters = NaN .* zeros(NumScan(iRun),6);
        % % 		else
        % % 			CombinedOutput = MotionParameters;
        % 		end

        CombinedOutput{iSubject,iRun} = MotionParameters;
    end; %runs
end; %subjects



%%%%%%% Save results to CSV file

OutputPathFull=GeneratePath(OutputPathTemplate,Exp, OutputName);
[OutputPath OutputName] = fileparts(OutputPathFull);

eval(sprintf('!mkdir -p %s',OutputPath));
OutputPathFile=[OutputPath '/' OutputName];
theFID = fopen([OutputPathFile,'.csv'],'w');
if theFID < 0
    fprintf(1,'Error opening the csv file!\n');
    return
end
fprintf(theFID,'Subject,SubNum,Run,TR,x_mm,y_mm,z_mm,pitch,roll,yaw,\n'); %header
for iSubject = 1:size(SubjDir,1)
    Subject=SubjDir{iSubject,1};
 %   chariSubject = int2str(iSubject);
 chariSubject=num2str(SubjDir{iSubject,2});
    NumRun= size(SubjDir{iSubject,3},2);
    for jRun = 1:NumRun
        iRun=SubjDir{iSubject,3}(1,iRun);

   %     RunString=RunDir{iRun}; %%% maybe set RunString as iRun?
         RunString=num2str(iRun);


        for iRow = 1:size(CombinedOutput{iSubject,jRun},1)
            chariRow = int2str(iRow);
        %    fprintf(theFID,'%s,%s,',Subject,RunString);
            fprintf(theFID,'%s,',Subject);
			fprintf(theFID,'%s,',chariSubject);
			fprintf(theFID,'%s,',RunString);
			fprintf(theFID,'%s,',chariRow);
            for iColumn=1:size(CombinedOutput{iSubject,jRun},2)
                fprintf(theFID,'%g,',CombinedOutput{iSubject,iRun}(iRow,iColumn));
            end %iColumn
            fprintf(theFID,'\n');
        end %iRow
    end %iRun
end %iSubject

fclose(theFID);
display('All Done')