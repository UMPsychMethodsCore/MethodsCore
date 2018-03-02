function [ data_conditions, SubjAvail ] = mc_load_connectomes_paired( SubjDir, FileTemplate, RunDir, matrixtype )
%MC_LOAD_SVM_DATASET Load connectomic data
%   Prior to performing SVM, you will need to load your connectomic data.
%   These can be produced by the som toolbox including in the advanced
%   feature set of the Methods Core Toolbox. For each subject, this should
%   produce two files, one which holds the connectivity matrix, and the
%   other which holds parameters which indicate ROIs, etc.
%
%   UPDATE-     SOM now frequently writes out roiTC files (.mat files) which
%               contain the time courses for each node. These are significantly
%               smaller in size than the files that contain full connectivity matrices
%               and the p values corresponding to each rho. Moreover, it is often
%               faster to simply load the roiTC file and calculate the connectome
%               on the fly than it is to read the whole connectome from disk.
%               Many *_corr.mat files on disk were recently deleted to save space.
%               For this reason, this function will now seek out roiTC files whenever
%               possible and load from those. If you point it to a file ending in _corr.mat
%               it will try replacing it with _roiTC.mat instead and trying to load that file.
%               If it fails for any reason, it will fall back on the _corr.mat file you specified.
%               You can also directly point it to *_roiTC.mat files and it will calculate connectomes
%               on the fly. Note, if your roiTC files have an ending other than _roiTC.mat it will
%               confuse the loader and it will attempt to load them as _corr.mat files.
% 
%   INPUT
%       SubjDir         -   Cell array holding your subject folders and also
%                           your labels. First column of cell array should be
%                           strings which will be swapped in for [Subject]
%                           in your FileTemplate. For paired SVM, next is a
%                           mapping of conditions to runs. Include a
%                           0 if a given condition is not present. E.g. 
%                           [3 1 0] would indicate that
%                           condition one is present in Run 3, condition two
%                           is present in run 1, and condition three is
%                           missing.
%       FileTemplate    -   Path used for finding your connectivity
%                           matrices, suitable for passing to mc_GenPath.
%                           Only thing you can use here is Subject.
%                           Example:
%                           '/net/data4/MAS/FirstLevel/[Subject]/conn.mat'
%       RunDir          -   Do you have multiple runs (or something run-like 
%                           to iterave over?) If so, specify it here.
%       matrixtype      -   Used to specify matrix mode. If
%                           doing a cPPI, you may be using
%                           a flattened form of the entire
%                           connectivity matrix. In this
%                           case, flattening and
%                           unflattening will work a little
%                           bit differently. 
% 
%   OUTPUT
%       data_conditions -   All of your loaded data! Should be a three
%                           dimensional array. Rows index examples, columns
%                           index features, and depth indexes conditions
%       SubjAvail       -   A mapping of subject availability by condition.
%                           2D matrix. Rows index subjects, columns index
%                           conditions. 1 indicates availability, 0
%                           indicates unavailability
    
conPathTemplate.Template=FileTemplate;
conPathTemplate.mode='check';

nchar = size(FileTemplate,2);

if ~exist('matrixtype','var')
    matrixtype='upper';
end

nSubs=size(SubjDir,1);


nCond = size(SubjDir{1,2},2);

SubjAvail = zeros(nSubs,nCond);



unsprung=0;


for iSub=1:nSubs
    Subject = SubjDir{iSub,1};
    for iCond = 1:nCond
        curRunID = SubjDir{iSub,2}(iCond);
        if curRunID ~= 0
            Run = RunDir{curRunID};
            [roiTCavail, conPath] = find_file();
            if roiTCavail
                conn = load_roiTC();
            else
                conn = load_corr();
            end
            if ~exist('unsprung','var') || unsprung==0
                data_conditions = zeros(nSubs,size(conn,2),nCond);
                unsprung = 1;
            end
            SubjAvail(iSub,iCond)=1;
            data_conditions(iSub,:,iCond) = conn;
        end
    end
end


function  [roiTCavail, conPath] =  find_file
clear TestTemplate;
roiTCavail = false;
nchar = length(FileTemplate);
if strcmpi(FileTemplate((nchar-8):end),'_corr.mat') % if it's a _corr.mat, try to find roiTC, but don't squawk
    TestTemplate.Template = [FileTemplate(1:(nchar-9)) '_roiTC.mat'];
    TestPath = mc_GenPath(TestTemplate);
    if(exist(TestPath,'file'))
        roiTCavail = true;
        conPath = TestPath;
    else
        TestTemplate.Template = FileTemplate;
        TestTemplate.mode = 'check';
        conPath = mc_GenPath(TestTemplate);
    end
elseif strcmpi(FileTemplate((nchar-9):end),'_roiTC.mat'); % if it's already roiTC, try to load that, squawk on fail
    TestTemplate.Template = FileTemplate;
    TestTemplate.mode = 'check'; % squawk if fail
    TestPath = mc_GenPath(TestTemplate);
    roiTCavail = true;
    conPath = TestPath;
else %try just loading it like a regular _corr.mat file anyway
    TestTemplate.Template = FileTemplate;
    TestTemplate.mode = 'check'; % squawk if fail
    TestPath = mc_GenPath(TestTemplate);
    conPath = TestPath;
end
end

function conn =  load_corr
conmat=load(conPath);
rmat=conmat.rMatrix;
switch matrixtype
  case 'upper'
    conn = mc_flatten_upper_triangle(rmat);
  case 'nodiag'
    conn = reshape(rmat,numel(rmat),1);
end
end

function conn = load_roiTC
    roiTC = load(conPath);
    rmat = corr(roiTC.roiTC);
    switch matrixtype
      case 'upper'
        conn = mc_flatten_upper_triangle(rmat);
      case 'nodiag'
        conn = reshape(rmat,numel(rmat),1);
    end
end

end
