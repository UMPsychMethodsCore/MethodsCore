




 addpath /net/dysthymia/spm8/
 addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts %%%% this is for generate_path_CSS
 addpath('/net/data4/MAS/marsbar-0.42/')
% addpath('/net/dysthymia/matlabScripts/marsbar-0.42/')

 %%%%%%  initialize variables
 


clear CombinedData
clear SPMList;
CombinedData={};
clear Header

UseSPM=1;

iCol=1;  
SPMPrevious.SPM.xY.P=   {}; 

FullFileName=eval(generate_PathCommand(OuputPathTemplate));
       
 for ijob = 1 : size(ExtractionJobs,1)
% %      
% %      if ijob==1
% % for iSubject = 1: MaxNumSubj
% %  alldata(iSubject,1)=iSubject;
% % end   
%      end
     pathcallcmd=generate_PathCommand(ExtractionJobs{ijob,1});
     ConditionPath=eval(pathcallcmd);
     pathcallcmd=generate_PathCommand(ExtractionJobs{ijob,2});
     ROIPath = eval(pathcallcmd);
    % ROIName = ExtractionJobs{ijob,3};
     
 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%if UseSPM==1


    spm_name = [ConditionPath '/SPM.mat'] ;
 %   SPMList{iJob}=spm_name;
%end

roi_file = [ROIPath];


display(sprintf('\n\n\n'));
display('***********************************************')
display(sprintf('This is job#: %s', num2str(ijob)));
display(sprintf('I will extract from here: %s', spm_name));
display(sprintf('I will use this ROI: %s', roi_file));
display(sprintf('The output will be stored here: %s', FullFileName));
display('***********************************************')




% Make marsbar design object
D  = mardo(spm_name);

% Make marsbar ROI object
R  = maroi(roi_file);

% Fetch data into marsbar data object
Y  = get_marsy(R, D, 'mean');




% des_path = spm_name;
% rois = maroi('load_cell', roi_file); % make maroi ROI objects
% des = mardo(des_path);  % make mardo design object
% mY = get_marsy(rois{:}, des, 'mean'); % extract data into marsy data object
y  = summary_data(Y);  % get summary time course(s)



%  Gap=MaxNumSubj-size(y,1);
%  y=vertcat(y,zeros(1,Gap)'); %%%% This fills alldata with zeros


SPMData=load(spm_name);
mismatch=0;
%%%% check if the two lists are different
if length(SPMData.SPM.xY.P)==length(SPMPrevious.SPM.xY.P)
for iRow = 1:length(SPMData.SPM.xY.P)
    [file1 fn]=fileparts(SPMData.SPM.xY.P{iRow});
    [file2 fn]=fileparts(SPMPrevious.SPM.xY.P{iRow});
  if  strcmp(file1,file2)
  else
      mismatch=1;
  end
end
else
    mismatch=1;
end

if mismatch==1

     %for iRow = 1:length(SPMData.SPM.xY.P)
%         if UseSPM==1
%         if iRow<=length(SPMData.SPM.xY.P)
       %  S=vertcat(S,SPMData.SPM.xY.P{iRow}(1:end-6));
       SPMAsMat=cell2mat(SPMData.SPM.xY.P);
CombinedData{iCol}=SPMAsMat(:,1:end-2);
Header{iCol}='Subject from SPM';
     iCol=iCol+1;
end %% end if statement    
[pn ROIName]=fileparts(ExtractionJobs{ijob,2});
Header{iCol}=[ExtractionJobs{ijob,1},'_',ROIName(1:end-4)];
CombinedData{iCol} = num2str(y);
iCol=iCol+1;
SPMPrevious.SPM.xY.P=SPMData.SPM.xY.P;
end % loop through extraction jobs


%%%%%% get the cell arrays to be the same length (which greatly eases printing them in a text file %%%%%
MaxLength=0;
for x =1:size(CombinedData,2)
    CurrLength=size(CombinedData{x},1);
    if CurrLength>MaxLength
        MaxLength=CurrLength;
    end
end

for x=1:size(CombinedData,2)
    CurrLength=size(CombinedData{x},1);
    for k=CurrLength+1:MaxLength
        CombinedData{x}(k)='';
    end
end




%%%% write the results to a single file



     
  
  [pn fn en] = fileparts(FullFileName);
  eval(sprintf('!mkdir -p %s', pn))


  theFID = fopen([FullFileName, '.csv'],'w');

if theFID < 0
    fprintf('Error opening the csv file\n');
    return
end

% StringStatement='Subject from SPM';
% fprintf(theFID,'%s,',StringStatement);
 StringStatement='Row Number';
 fprintf(theFID,'%s,',StringStatement);
% 
 for i=1:size(CombinedData,2) %%% loop through columns
%     [pn ROIName]=fileparts(ExtractionJobs{i,2});
%      ColName = [ExtractionJobs{i,1},'_',ROIName(1:end-4)];
      fprintf(theFID,'%s,',Header{i});
 end % loop through cols
% 
% 
% %SPMData=load(spm_name);
% 
% 
  fprintf(theFID,'\n');
     for iRow = 1:MaxLength
%         if UseSPM==1
%         if iRow<=length(SPMData.SPM.xY.P)
%          S=SPMData.SPM.xY.P{iRow}(1:end-6);
%         else
%             S='Empty';
%         end
%         else
%             S='Empty';
%         end 
%         
%          fprintf(theFID,'%s,',S);  
         chariRow = int2str(iRow);
          fprintf(theFID,'%s,',chariRow);
   
 
         
%      SPMDataBefore.SPM.xY.P=   {}; 
  for iCol = 1:size(CombinedData,2);
%       
%     SPMData=load(SPMList{iCol}); 
%     if SPMData.SPM.xY.P ~= SPMDataBefore.SPM.xY.P
%         fprintf(theFID,'\n');
%     for iRow = 1:MaxLength
%         if UseSPM==1
%         if iRow<=length(SPMData.SPM.xY.P)
%          S=SPMData.SPM.xY.P{iRow}(1:end-6);
%         else
%             S='Empty';
%         end
%         else
%             S='Empty';
%         end 
%         
%          fprintf(theFID,'%s,',S);  
%          chariRow = int2str(iRow);
%          fprintf(theFID,'%s,',chariRow);
%     end %% loop through rows
%     end %%% end if
    
        fprintf(theFID,'%s,',CombinedData{iCol}(iRow,:));
    end   % loop through cols
         fprintf(theFID,'\n');
    end   % loop through rows

fclose(theFID);
  
 display('Done!!!');
