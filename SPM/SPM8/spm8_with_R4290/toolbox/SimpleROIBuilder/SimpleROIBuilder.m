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

%-GUI setup
%-----------------------------------------------------------------------

SPMid = spm('FnBanner',mfilename,SCCSid);
[Finter,Fgraph,CmdLine] = spm('FnUIsetup','SimpleROIBuilder',0);
fprintf('SimpleROIBuilder Toolbox 1.0\n');

spm('FigName','Simply Build Binary Mask (ROI) from Reference Image',Finter,CmdLine);

% How many rois do they want to drop into this mask file.

nROIS = spm_input('Number of rois to make','+1','i','1',1,[0,Inf]);

% Abort if no roi's to build.

if nROIS < 1
    spm('alert','Exiting as you requested.','ROIBuilder',[],0);
    return
end

% Get the name of the reference image.

if spm('Ver') == 'SPM2'
  P = spm_get([0,1],'*IMAGE','Pick the reference image.');
else
  P = spm_select([0 1],'image','Pick the reference image.');
end

% If no reference image then abort as well.

if size(P,1) < 1
    spm('alert','Exiting as you reuested.','ROIBuilder',[],0);
    return
end

% Pick up the header.

P_HDR = spm_vol(P);

maskIMG = zeros(P_HDR.dim(1:3));

maskIMGName = spm_input('Name of output image','+1','s');

%maskHDR = P_HDR;

[pn fn en] = fileparts(maskIMGName);

if length(en) < 1
  en = '.img';
end

maskHDR.fname = fullfile(pn,[fn en]);

maskHDR.dim = [P_HDR.dim];     % Make it uint8 since it is
% binary.
maskHDR.pinfo = [1;0;0];
maskHDR.descrip = 'SimpleROIBuilder Binary Image w/ ROIs';
maskHDR.mat = P_HDR.mat;

if strcmp(spm('ver'),'spm2') ~= 1
    maskHDR.dt=[2 0];
end


nextPOS = spm_input('!NextPos');

roiINFO = {};

% Now loop and get the information for the ROI.

for iROI = 1:nROIS
    roiINFO{iROI}.center_mm = spm_input(sprintf('Center for ROI #%02d',iROI),...
        nextPOS,'r',[0.0 0.0 0.0],3);

    tmp = inv(P_HDR.mat)*([roiINFO{iROI}.center_mm ;1]);
    roiINFO{iROI}.center_vox = tmp(1:3);
    roiINFO{iROI}.type = spm_input('ROI Shape','+1','b','Sphere|Box', ...
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

% Build an array of coordinates for each and every voxel in the mask

% PMat = spm_imatrix(P_HDR.mat);
% xSize = PMat(7);
% ySize = PMat(8);
% zSize = PMat(9);

xOrds = (1:P_HDR.dim(1))'*ones(1,P_HDR.dim(2));
yOrds = ones(P_HDR.dim(1),1)*(1:P_HDR.dim(2));
xOrds = xOrds(:)';
yOrds = yOrds(:)';

Coords = zeros(3,prod(P_HDR.dim(1:3)));

for iZ = 1:P_HDR.dim(3)
    zOrds = iZ*ones(1,length(xOrds));
    Coords(:,(iZ-1)*length(xOrds)+1:iZ*length(xOrds)) = [xOrds; yOrds; zOrds];
end

% Now put them into mm's

mmCoords = P_HDR.mat*[Coords;ones(1,size(Coords,2))];
mmCoords = mmCoords(1:3,:);

boxBIT = zeros(4,size(mmCoords,2));

% Now loop on the ROI definitions and drop them
% into the mask image volume matrix.

for iROI = 1:nROIS
    % Found the center of this ROI in voxels
    % and then build it.
    xs = mmCoords(1,:) - roiINFO{iROI}.center_mm(1);
    ys = mmCoords(2,:) - roiINFO{iROI}.center_mm(2);
    zs = mmCoords(3,:) - roiINFO{iROI}.center_mm(3);
    switch roiINFO{iROI}.type
        case 'Sphere'
            radii = sqrt(xs.^2+ys.^2+zs.^2);
            VOXIdx = find(radii<=roiINFO{iROI}.size);
        case 'Box'
            xsIDX = find(abs(xs)<=roiINFO{iROI}.size(1));
            ysIDX = find(abs(ys)<=roiINFO{iROI}.size(2));
            zsIDX = find(abs(zs)<=roiINFO{iROI}.size(3));
            boxBIT  = 0*boxBIT;
            boxBIT(1,xsIDX) = 1;
            boxBIT(2,ysIDX) = 1;
            boxBIT(3,zsIDX) = 1;
            boxBIT(4,:) = boxBIT(1,:).*boxBIT(2,:).*boxBIT(3,:);
            VOXIdx = find(boxBIT(4,:));
    end
    maskIMG(VOXIdx) = 1;
end

% Now write out the image.

spm_write_vol(maskHDR,maskIMG);

spm_clf(Finter);
spm('FigName','Finished',Finter,CmdLine);
spm('Pointer','Arrow');

fprintf('\nFinished Building ROI Image.\n');

%
% All done.
%
