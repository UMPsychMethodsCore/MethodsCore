
display ('-----')
OutputPathFile = generate_path_CSS(OutputPathTemplate,Exp);
display('I am going to generate motion regressors');
display(sprintf('The output will be stored here: %s', OutputPathFile));
display('These are the subjects:')
display(SubjDir)
display ('-----')



addpath /net/dysthymia/matlabScripts/  %%%% this is for generate_path_CSS

clear CombinedOutput
clear MotionPath

Num_run_total = size(RunDir,1);

finalfilename = '';

for iSubject = 1: size(SubjDir,1)
	Subject=SubjDir{iSubject}(1:end); 
	   NumRun= size(SubjDir{iSubject,3},2);
    for jRun = 1:NumRun
        Subject = SubjDir{iSubject,1};
        iRun=SubjDir{iSubject,3}(1,jRun);
        
         Run = RunDir{iRun};
        
        
        pathcallcmd=generate_PathCommand(MotionPathTemplate);
        MotionPath = eval(pathcallcmd);
        MotionParameters = load (MotionPath);
        
% 		InputDir = fullfile(Exp,ImageLevel1,Subject,ImageLevel2,RunDir{iRun},ImageLevel3);
% 		InputFiles = spm_select('FPList',InputDir,['^rp_' basefile '.*\.txt']);
% 		if (size(InputFiles,1)>1)
% 			error('Error -- too many realignment (rp) files found');
% 			return;
% 		end
		%InputFile = strtrim(InputFiles(1,:));
		
		CombinedOutput{iSubject,iRun}=[];
		chariRun = int2str (iRun);
		
		if (iRun > Num_run_total)
			MotionParameters = NaN .* zeros(NumScan(iRun),6);
% 		else		
% 			CombinedOutput = MotionParameters;
		end
		
		CombinedOutput{iSubject,iRun} = MotionParameters;
	end; %runs
end; %subjects

% OutputDir = fullfile(Exp,RegLevel1);
% eval(sprintf('!mkdir -p %s', OutputDir))
% OutputFileName = fullfile(OutputDir,RegLevel2); 
% 
% theFID = fopen([OutputFileName, '.csv'],'w');
% 
% if theFID < 0
% 	error('Error opening the csv file for output');
% 	return;
% end
% 
% fprintf(theFID,'Subject,SubNum,Run,TR,x_mm,y_mm,z_mm,pitch,roll,yaw,\n');
% 
% for iSubject =1:size(SubjDir,1)
% 	Subject=SubjDir{iSubject}(1:end);
% 	Num_run = size(SubjDir{iSubject,3},2);
% 	for iRun=1:Num_run_total
% 		chariSubject = int2str(iSubject);
% 		chariRun = int2str (iRun);
% 		for iRow = 1:size(combinedReg{iSubject,iRun},1);
% 			chariRow = int2str (iRow);
% 			fprintf(theFID,'%s,',Subject);
% 			fprintf(theFID,'%s,',chariSubject);
% 			fprintf(theFID,'%s,',chariRun);
% 			fprintf(theFID,'%s,',chariRow);
% 			for iColumn=1:size(combinedReg{iSubject,iRun},2);
% 				fprintf(theFID,'%g,',combinedReg{iSubject,iRun}(iRow,iColumn));
% 			end
% 			fprintf(theFID,'\n');
% 		end %rows
% 	end %runs
% end %subjects
% fclose(theFID);


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
fprintf(theFID,'Subject,SubNum,Run,TR,x_mm,y_mm,z_mm,pitch,roll,yaw,\n'); %header
for iSubject = 1:size(SubjDir,1)
    Subject=SubjDir{iSubject,1};
    NumRun= size(SubjDir{iSubject,3},2);
    for jRun = 1:NumRun
        iRun=SubjDir{iSubject,3}(1,iRun);
        
      RunString=num2str(iRun);   
 
%  %%%%% Select appropriate output based on h user has set
%  
%  index=strfind(MotionPathTemplate,'Run');
%  if size(index)>0
%  RunString=RunDir{iRun};
%  else
%      RunString=num2str(iRun);
% %    RunString = sprintf('%02d',jRun);
%  end
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 
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