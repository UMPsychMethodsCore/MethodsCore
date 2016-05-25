%+---------------------------------------
%|
%| Robert C. Welsh
%| 2006.09.26
%|
%| Ann Arbor, MICHIGAN
%|
%| Point to a reference image and drop an
%| ROI. - Sphere or box. You can drop as 
%| many as you want.
%|
%+---------------------------------------

function SimpleROIBuilder

SCCSid  = '1.0';

global BCH; %- used as a flag to know if we are in batch mode or not.


global SimpleROIBuilderBatch


%-GUI setup
%-----------------------------------------------------------------------

SPMid                   = spm('FnBanner',mfilename,SCCSid);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup',mfilename,0);

fprintf('SimpleROIBuilder Toolbox 1.0\n');

spm('FigName','Simply Build Binary Mask (ROI) from Reference Image',Finter,CmdLine);

% How many rois do they want to drop into this mask file.

nROIS = spm_input('Number of rois to make','+1','i','1',1,[0,Inf]);

% Abort if no roi's to build.

if nROIS < 1
    spm('alert','Exiting as you requested.',mfilename,[],0);
    return
end

% Get the name of the reference image.

selectPrompt = 'Pick the reference (space defining) image.';

switch lower(spm('Ver'))
    case 'spm2'
      refImage = spm_get([0,1],'*IMAGE',selectPrompt);
    case {'spm5','spm8'}
      refImage = spm_select([0 1],'image',selectPrompt);
    otherwise
        spm('alert',sprintf('I do not recognize that current version of spm : %s',spm('Ver')),mfilename,[],0);
        return
end

% Can we read the reference image?

try
    P_HDR        = spm_vol(refImage);
catch
    spm('alert',sprintf('Error attempting to reference image : %s',refImage),mfilename,[],0);
    return
end

% If no reference image then abort as well.

if size(refImage,1) < 1
    spm('alert','Exiting as you requested.',mfilename,[],0);
    return
end

maskIMGName     = spm_input('Name of output image','+1','s');

nextPOS         = spm_input('!NextPos');

roiINFO = {};

% Now loop and get the information for the ROI.

for iROI = 1:nROIS
    roiINFO{iROI}.center_mm = spm_input(sprintf('Center for ROI #%02d',iROI),...
        nextPOS,'r',[0.0 0.0 0.0],3);

    tmp                      = inv(P_HDR.mat)*([roiINFO{iROI}.center_mm ;1]);
    roiINFO{iROI}.center_vox = tmp(1:3);
    roiINFO{iROI}.type       = spm_input('ROI Shape','+1','b','Sphere|Box', ...
        [],1);
    switch roiINFO{iROI}.type
        case 'Sphere'
            str = 'Radius (mm)';
            nIn = 1;
        case 'Box'
            str = 'Straddle Size (mm)';
            nIn = 3;
    end
    roiINFO{iROI}.size = spm_input(str,'+1','r',[],nIn);
end

SimpleROIBuilder_Engin(refImage,roiINFO,maskIMGName);


spm_clf(Finter);
spm('FigName','Finished',Finter,CmdLine);
spm('Pointer','Arrow');

%
% All done.
%
