% Set up your design matrix. You will need to provide a path to a cleansed        %
% Master Data file. It must have a column named 'Subject' for the parsing to      %
% work properly. This will happen in R automatically, then switch back to MATLAB  %
%                                                                                 %
% des.csvpath     -       A full path to your cleansed MasterData File (MDF)      %
% des.IncludeCol  -       String naming col of logicals in MDF for subsetting     %
% des.model       -       A formula expression indicating how to build the design %
%                         matrix. See R or examples for details. Intercept is     %
%                         automatically included in most cases                    %
% des.FxCol       -       Which column of the design matrix will hold the effect  %
%                         of interest? Note that the first column will be an      %
%                         intercept term, so if you have a paired design, set this%
%                         to 1. If you were interested in the first term in       %
%                         des.model, you would set this to 2. If the third term,  %
%                         set it to 3, and so on.                                 %
% des.FlipFx      -       By default, results will be reported in terms of your   %
%                         design matrix. However, sometimes this is the reverse   %
%                         of the way you want to interpret it. R will order its   %
%                         categorical factors alphabetically, so if you have      %
%                         some subjects labeled 'A' for autism and others labeled %
%                         'H' for healthy control, autism will end up being the   %
%                         reference group, and your "effect" will actually be the %
%                         effect of being healthy. If you'd like to flip this, set%
%                         des.FlipFx to 1, and it will multiply the des.FxCol of  %
%                         your design matrix by -1, so that you can interpret     %
%                         results in a more naturaly way.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

des.csvpath = '/net/data4/SomeStudy/MDF.csv';
des.IncludeCol = 'Include.Overall';
des.model = '~ Disease + Motion' ; 
des.FxCol = 2;
des.FxFlip = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Does your data follow a paired structure? If so, set paired to 1, and also        %
% be sure to set RunDir. This will get plugged in for '[Run]' in your templates.    %
% You'll also need to set a contrast that will be used to do the delta calculation. %
% This contrast will be the weights of the runs specified in RunDir.                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

paired = 0;

RunDir= {
    'rest_1'
    'rest_2'
    'rest_3'
} ;

pairedContrast = [1 -1 0]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Provide a path to the .mat files that hold your connectivity or cPPI matrices %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CorrTemplate = '/net/data4/SomeStudy/FirstLevel/MotionScrubbedLinks/[Subject]/censortest_corr.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Is the data that you're loading connectivity or cPPI? In other words, do you %
% care about the upper portion of the connectivity matrix, or the whole thing? %
% If doing connectivity, set matrixtype to 'upper'.                            %
% If doing cPPI, set matrixtype to 'nodiag'.                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrixtype = 'nodiag';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have resting state data, you may want to Z tranform your data using %
% Fisher's transform. If so, set ZTrans to 1.                                %
% If you have cPPI data, BE SURE TO SET THIS TO 0.                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ZTrans = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify a folder to hold your output. If it does not not already exist, %
% it will be created for you.                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outputPath = '/net/data4/MyStudy/SweetNewOutput';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Which column of your MDF has info on how to partition your data into folds? %
% There should be a column which has a defined value for each of subjects     %
% that are marked to be included.                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FoldsCol = 'Fold';



