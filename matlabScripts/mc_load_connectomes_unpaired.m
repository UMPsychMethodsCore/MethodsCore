function [ data, label ] = mc_load_connectomes_unpaired( SubjDir, FileTemplate, matrixtype, nolabels )
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
%   
%   INPUT
%       SubjDir         -   Cell array holding your subject folders and also
%                           your labels. First column of cell array should be
%                           strings which will be swapped in for [Subject] in
%                           your FileTemplate. Second column is example label.
%                           For two class SVM it should be +1 or -1, though
%                           in the future multiclass or regression labels
%                           should also be supported.
%       FileTemplate    -   Path used for finding your connectivity
%                           matrices, suitable for passing to mc_GenPath.
%                           Only thing you can use here is Subject.
%                           Example:
%                           '/net/data4/MAS/FirstLevel/[Subject]/conn.mat'
%       matrixtype      -   Used to specify matrix mode. If
%                           doing a cPPI, you may be using
%                           a flattened form of the entire
%                           connectivity matrix. In this
%                           case, flattening and
%                           unflattening will work a little
%                           bit differently.  
%       nolabels        -   Set to true if you are not passing in any labels, and don't want any back
%   NOTE - Use this function if loading unpaired datasets where you have two or more classes.
%                           indicates unavailability
conPathTemplate.Template=FileTemplate;
conPathTemplate.mode='check';

nchar = size(FileTemplate,2);

if ~exist('matrixtype','var')
    matrixtype='upper';
end

nSubs=size(SubjDir,1);

for iSub=1:size(SubjDir,1)
    fprintf(1,'Loading Connectome for Subject %d of %d\n', iSub, nSubs)
    Subject = SubjDir{iSub,1};
    [roiTCavail, conPath] = find_file();
    if roiTCavail
        conn = load_roiTC();
    else
        conn = load_corr();
    end
    if iSub==1
        data=zeros(nSubs,size(conn,2));
    end
    data(iSub,:) = conn;
    if exist('nolabels','var') && ~nolabels
    else
        Example=SubjDir{iSub,2};
        label(iSub,1)=Example;
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
