%%%%%%  initialize variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code to create logfile name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogDirectory = mc_GenPath(struct('Template',LogTemplate,'mode','makedir'));
result = mc_Logger('setup',LogDirectory);
if (~result)
    %error with setting up logging
    mc_Error('There was an error creating your logfiles.\nDo you have permission to write to %s?',LogDirectory);
end
global mcLog;
mcWarnings = 0;

spm_jobman('initcfg');  % hopefully add marsbar to MATLAB path

marsbar('on');

clear CombinedData
clear SPMList;
CombinedData={};
clear Header

UseSPM=1;

iCol=1;
SPMPrevious.SPM.xY.P=   {};

FullFileNameStruct = struct('Template',OutputPathTemplate,...
    'suffix','.csv',...
    'mode','makeparentdir');

FullFileName       = mc_GenPath(FullFileNameStruct);

for ijob = 1 : size(ExtractionJobs,1)


    ConditionPathCheck.Template = ExtractionJobs{ijob,1};
    ConditionPathCheck.mode = 'check';
    ConditionPathCheck.type = 1;
    ConditionPath = mc_GenPath(ConditionPathCheck);




    spm_nameCheck.Template = fullfile(ConditionPath,'SPM.mat');
    spm_nameCheck.mode = 'check';
    spm_name = mc_GenPath(spm_nameCheck);


    TypeOfROI =   ischar(ExtractionJobs{ijob,2});
    switch TypeOfROI

        case 0 %%% sphere

            c=ExtractionJobs{ijob,2}(1:3);
            r=ExtractionJobs{ijob,2}(4);

            roitype='sphere';
            d = [];

            d = sprintf('%0.1fmm radius sphere at [%0.1f %0.1f %0.1f]',r,c);
            l = sprintf('sphere_%0.0f-%0.0f_%0.0f_%0.0f',r,c);
            o = maroi_sphere(struct('centre',c,'radius',r));


            ROIName =  num2str(ExtractionJobs{ijob,2});

        case 1 %%% .img

            ROIPathCheck.Template = ExtractionJobs{ijob,2};
            ROIPathCheck.mode = 'check';
            ROIPath = mc_GenPath(ROIPathCheck);
            roi_file = [ROIPath];
            imgname = ROIPath;



            roitype='image';


            o = [];





            [p f e] = fileparts(imgname);

            binf=1;
            func = '';

            d = f; l = f;
            if ~isempty(func)
                d = [d ' func: ' func];
                l = [l '_f_' func];
            end
            if binf
                d = [d ' - binarized'];
                l = [l '_bin'];
            end
            o = maroi_image(struct('vol', spm_vol(imgname), 'binarize',binf,...
                'func', func));

            % convert to matrix format to avoid delicacies of image format
            o = maroi_matrix(o);


            [pn ROIName]=fileparts(ExtractionJobs{ijob,2});

    end %%% end switch



    display(sprintf('\n\n\n'));
    display('***********************************************')
    display(sprintf('This is job#: %s', num2str(ijob)));
    display(sprintf('I will extract from this SPM.mat: %s', spm_name));
    if TypeOfROI==0
        display(sprintf('I will place a spherical ROI at MNI coordinates: %s, with radius: %s', num2str(c),num2str(r)));
    else
        display(sprintf('I will use this ROI: %s', roi_file));
    end;





    % Make marsbar design object
    D  = mardo(spm_name);

    % Make marsbar ROI object
    %R  = maroi(roi_file);
    R=o;
    % Fetch data into marsbar data object
    Y  = get_marsy(R, D, SummaryFunction);


    % display(sprintf('The output will be stored here: %s', FullFileName));
    display('***********************************************')

    y  = summary_data(Y);  % get summary time course(s)


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

        if (iscell(SPMData.SPM.xY.P))
            SPMAsMat = strvcat(strrep(SPMData.SPM.xY.P,',',''));
        else
            temp = SPMData.SPM.xY.P;
            tempcell = mat2cell(temp,ones(size(temp,1),1), size(temp,2));
            SPMAsMat = strvcat(strrep(tempcell,',',''));
        end
        
        CombinedData{iCol}=SPMAsMat(:,1:end-2);
        Header{iCol}='Subject from SPM';
        iCol=iCol+1;
    end %% end if statement


    if TypeOfROI==0
        Header{iCol}=['SPM=',ExtractionJobs{ijob,1},'#####ROI=sphere:',num2str(c), '_radius:' num2str(r), '### Summary type:' ,SummaryFunction ];

    else

        Header{iCol}=['SPM=',ExtractionJobs{ijob,1},'##### ROI=',ROIName, '### Summary type:' ,SummaryFunction ];
    end

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
    CombinedData{x}(CurrLength+1:MaxLength,:) = ' ';

end


%%%% write the results to a single file

theFID = fopen(FullFileName,'w');

if theFID < 0
    fprintf('Error opening the csv file\n');
    return
end

StringStatement='Row Number';
fprintf(theFID,'%s,',StringStatement);

for i=1:size(CombinedData,2) %%% loop through columns

    fprintf(theFID,'%s,',Header{i});
end % loop through cols

fprintf(theFID,'\n');
for iRow = 1:MaxLength

    chariRow = int2str(iRow);
    fprintf(theFID,'%s,',chariRow);


    for iCol = 1:size(CombinedData,2);


        fprintf(theFID,'%s,',CombinedData{iCol}(iRow,:));
    end   % loop through cols
    fprintf(theFID,'\n');
end   % loop through rows

fclose(theFID);

display('Done!!!');
