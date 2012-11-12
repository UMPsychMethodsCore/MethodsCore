% Central script for batch PPI extraction
% DO NOT MODIFY THIS SCRIPT
% Originally created by Chandra Sripada
% Modified by Mike Angstadt

if (exist('spmVersion')~=1)
	spmVersion= 'spm5';
end

[ret host] = system('hostname -s');

%paths 0 = sopho 64bit spm5
%      1 = sopho 32bit spm5
%      2 = sopho 64bit spm2
%      3 = sopho 32bit spm2
%      4 = dysthymia/schizo/mania 64bit spm5
%      5 = dysthymia/schizo/mania 32bit spm5
%      6 = dysthymia/schizo/mania 64bit spm2
%      7 = dysthymia/schizo/mania 32bit spm2

paths = 0;
switch (host)
 case 'sopho'
  paths = 0;
 case 'dysthymia'
  paths = 4;
 case 'mania'
  paths = 4;
 case 'schizo'
  paths = 4;
 otherwise
  paths = 0;
end

switch computer
 case 'GLNX86'
  paths = paths + 1;
 case 'GLNXA64'
  paths = paths;
 otherwise
  paths = paths;
end

if (strcmp(spmVersion,'spm2'))
    paths = paths + 2;
end
if (strcmp(spmVersion,'spm8'))
	paths = paths + 10;
end

switch (paths)
 case 0
  addpath /usr/local/spm5
  addpath /data/batch/matlabScripts
  addpath /data/batch/current_version
 case 2
  addpath /usr/local/spm2
  addpath /data/batch/matlabScripts
  addpath /data/batch/current_version
 case 4
  addpath /net/dysthymia/spm5_64b
  addpath /net/dysthymia/matlabScripts/
 case 5
  addpath /net/dysthymia/spm5
  addpath /net/dysthymia/matlabScripts/
 case 6
  addpath /net/dysthymia/spm2_64b
  addpath /net/dysthymia/matlabScripts/
 case 7
  addpath /net/dysthymia/spm2
  addpath /net/dysthymia/matlabScripts/
 case 10
 	addpath /usr/local/spm8
 	addpath /data/batch/matlabScripts
 	addpath /data/batch/current_version
 	addpath /data/batch/umich_batch
 
 otherwise
end

switch PPItype
 case 1
  prefix = 'PPI';
 case 0
  prefix = 'PMP';
 otherwise
  prefix = 'PPI';
end

spm('defaults','fmri');
global defaults

mask = []; %not presently used
type = 2; % 2= PPI, do not change this value

for iJob = 1 : size(PPIJobs,1);
    
    VOIgenname = PPIJobs{iJob,1};
    xyz = [];
    if (isempty(spec))
        spec = PPIJobs{iJob,2};
    else
        xyz = PPIJobs{iJob,2}';
    end
    
    conditions = PPIJobs{iJob,3};
    weights = PPIJobs{iJob,4};  
    
    
    for iSubject = 1: size(subjDir,1);
        S=subjDir{iSubject}(1:end);       
        S=strrep(S,'/','');
        InputDir = [Exp, InputLevel1, S, '/', InputLevel2, InputLevel3];
        %Path to SPM.mat to read from
        VOIname = [S,'_',VOIgenname];  % Name of the VOI output file
        
        for iRun = 1:size(subjDir{iSubject,3},2);
            chariRun = int2str (iRun);    
            VOIretrievename = ['VOI_',VOIname,'_',chariRun,'.mat'];
            PPIname = [S,'_',VOIgenname,'_r',chariRun];
            
            currentDir = pwd;
            cd(InputDir);
            
            if (Mode == 0 | Mode == 1)
                switch (spmVersion)
                 case 'spm2'
                  mask = spec;
                  voi_extract_batch(InputDir,contrastNum, threshold, extent, VOIname, iRun, typeVOI, spec, xyz, mask, adjust);
                  if (PPItype)
                      load([InputDir 'SPM.mat']);
                      mike_peb_ppi(SPM,VOIretrievename, conditions, weights, type, PPIname);
                  else
                      %pmp
                      pmp_process(InputDir,VOIretrievename,PPIname);
                  end
                 case 'spm5'
                  voi_extract_batch_spm5(InputDir,contrastNum, threshold, extent, VOIname, iRun, typeVOI, spec, xyz, mask, adjust);
                  if (PPItype)
                      load([InputDir 'SPM.mat']);
                      mike_peb_ppi_spm5(SPM,VOIretrievename, conditions, weights, type, PPIname);
                  else             
                      %pmp
                      pmp_process(InputDir,VOIretrievename,PPIname);
                  end 
                 case 'spm8'
                  voi_extract_batch_spm5(InputDir,contrastNum, threshold, extent, VOIname, iRun, typeVOI, spec, xyz, mask, adjust);
                  if (PPItype)
                      load([InputDir 'SPM.mat']);
                      mike_peb_ppi_spm5(SPM,VOIretrievename, conditions, weights, type, PPIname);
                  else             
                      %pmp
                      pmp_process(InputDir,VOIretrievename,PPIname);
                  end 
                 otherwise
                end
            end
            
            combinedReg{iSubject,iRun}=[];
            chariRun = int2str(iRun);
            chariRun = int2str(subjDir{iSubject,3}(iRun));
            load([prefix '_' PPIname]);
            if (PPItype)
                combinedReg{iSubject,iRun}=horzcat(PPI.Y,PPI.P,PPI.ppi);
            else
                combinedReg{iSubject,iRun} = PMP.Y;
                NumCond = size(conditions,2);
                for p = 1:NumCond
                    combinedReg{iSubject,iRun} = [combinedReg{iSubject,iRun} PMP.P{p}];
                end
                for p = 1:NumCond
                    combinedReg{iSubject,iRun} = [combinedReg{iSubject,iRun} PMP.pmp{p}];
                end               
            end
            
            cd(currentDir);
            
        end % loop through runs

    	close all;        
    end % loop through Subjects
    
    OutputDir = [Exp OutputLevel1 OutputLevel2 OutputLevel3];
    eval(sprintf('!mkdir -p %s',OutputDir));
    OutputFileName = [OutputDir, VOIgenname, '_' prefix];
    theFID = fopen([OutputFileName,'.csv'],'w');
    if theFID < 0
        fprintf(1,'Error opening the csv file!\n');
        return
    end
    if (PPItype)
        fprintf(theFID,'Subject,Run,Timepoint,Y,P,PPI\n'); %header
        for iSubject = 1:size(subjDir,1)
            S=subjDir{iSubject}(1:end);
            for iRun = 1:size(subjDir{iSubject,3},2)
                chariRun = int2str(iRun);
                chariRun = int2str(subjDir{iSubject,3}(iRun));
                for iRow = 1:size(combinedReg{iSubject,iRun},1)
                    chariRow = int2str(iRow);
                    fprintf(theFID,'%s,%s,%s,',S,chariRun,chariRow);
                    for iColumn=1:size(combinedReg{iSubject,iRun},2)
                        fprintf(theFID,'%g,',combinedReg{iSubject,iRun}(iRow,iColumn));
                    end %iColumn
                    fprintf(theFID,'\n');
                end %iRow
            end %iRun
        end %iSubject
    else
        fprintf(theFID,'Subject,Run,Timepoint,Y,');
        for p = 1:NumCond
            fprintf(theFID,'P_%s,',num2str(p));
        end
        for p = 1:NumCond
            fprintf(theFID,'PMP_%s,',num2str(p));
        end
        fprintf(theFID,'\n');
        for iSubject = 1:size(subjDir,1)
            S=subjDir{iSubject}(1:end-1);
            for iRun = 1:size(subjDir{iSubject,3},2)
                chariRun = int2str(iRun);
                chariRun = int2str(subjDir{iSubject,3}(iRun));
                for iRow = 1:size(combinedReg{iSubject,iRun},1)
                    chariRow = int2str(iRow);
                    fprintf(theFID,'%s,%s,%s,',S,chariRun,chariRow);
                    for iColumn=1:size(combinedReg{iSubject,iRun},2)
                        fprintf(theFID,'%g,',combinedReg{iSubject,iRun}(iRow,iColumn));
                    end %iColumn
                    fprintf(theFID,'\n');
                end %iRow
            end %iRun
        end %iSubject        
    end
    
    fclose(theFID);
    
    close all;
    
    if (ischar(spec))
    	spec = [];
    end
end % loop through PPIjobs


