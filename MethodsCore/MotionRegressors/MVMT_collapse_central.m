

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General calculations that apply to both Preprocessing and First Level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (alreadydone(1))
	basefile = [stp basefile];
end

Num_run = size(RunDir,1);
Num_run_total = Num_run;

finalfilename = '';

for iSubject = 1: size(SubjDir,1)
	S=SubjDir{iSubject}(1:end); 
	Num_run = size(SubjDir{iSubject,3},2);
	for iRun = 1:Num_run_total
		InputDir = fullfile(Exp,ImageLevel1,S,ImageLevel2,RunDir{iRun},ImageLevel3);
		InputFiles = spm_select('FPList',InputDir,['^rp_' basefile '.*\.txt']);
		if (size(InputFiles,1)>1)
			error('Error -- too many realignment (rp) files found');
			return;
		end
		InputFile = strtrim(InputFiles(1,:));
		
		combinedReg{iSubject,iRun}=[];
		chariRun = int2str (iRun);
		
		if (iRun > Num_run)
			currentReg = NaN .* zeros(NumScan(iRun),6);
		else		
			currentReg = load(InputFile);
		end
		
		combinedReg{iSubject,iRun} = currentReg;
	end; %runs
end; %subjects

OutputDir = fullfile(Exp,RegLevel1);
eval(sprintf('!mkdir -p %s', OutputDir))
OutputFileName = fullfile(OutputDir,RegLevel2); 

theFID = fopen([OutputFileName, '.csv'],'w');

if theFID < 0
	error('Error opening the csv file for output');
	return;
end

fprintf(theFID,'Subject,SubNum,Run,TR,x_mm,y_mm,z_mm,pitch,roll,yaw,\n');

for iSubject =1:size(SubjDir,1)
	S=SubjDir{iSubject}(1:end);
	Num_run = size(SubjDir{iSubject,3},2);
	for iRun=1:Num_run_total
		chariSubject = int2str(iSubject);
		chariRun = int2str (iRun);
		for iRow = 1:size(combinedReg{iSubject,iRun},1);
			chariRow = int2str (iRow);
			fprintf(theFID,'%s,',S);
			fprintf(theFID,'%s,',chariSubject);
			fprintf(theFID,'%s,',chariRun);
			fprintf(theFID,'%s,',chariRow);
			for iColumn=1:size(combinedReg{iSubject,iRun},2);
				fprintf(theFID,'%g,',combinedReg{iSubject,iRun}(iRow,iColumn));
			end
			fprintf(theFID,'\n');
		end %rows
	end %runs
end %subjects
fclose(theFID);
