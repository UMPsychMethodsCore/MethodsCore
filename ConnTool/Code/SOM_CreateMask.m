% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
%
% Routine to create analysis mask.
%
% function [hdr, results, analyzeFMT] = SOM_CreateMask(P)
%
% P          - a list of files to create the mask from.
% 
% hdr        -  Analyze hdr for the mask.
% results    -  a binary image of the mask
% analyzeFMT - a flag, 1 if analyze used, 0 if plain mat files.
%
% If you are using plain files, then make sure that the only
% item contained in the file is a single volume time point.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [hdr, results, analyzeFMT] = SOM_CreateMask(P)

global SOM

if ~isfield(SOM,'maskThresh')
    SOM.maskThresh = .125;
else
    if SOM.maskThresh > 1;
        SOM.maskThresh = 1/SOM.maskThresh;
        fprintf('Making SOM.maskThresh < 1 : %f\n',SOM.maskThresh);
    end
end

fprintf('Create mask...\n');

% Determine whether to use spm or read in mat files?

[fPath fName fExt] = fileparts(P(1,:));

if strcmp(strtrim(lower(fExt)),'.img')
    analyzeFMT=1
else
    if (strcmp(strtrim(lower(fExt)),'.nii'))
        analyzeFMT=2;
    else
        analyzeFMT=0;
    end
end

if analyzeFMT == 1
    som_mask = spm_read_vols(spm_vol(P(1,:)));
else
    if analyzeFMT == 2
        mtx = spm_read_vols(spm_vol(P(1,:)));
        som_mask = ones(size(mtx,1),size(mtx,2),size(mtx,3));
    else
        tmpVol = load(P(1,:));
        fldNm = fieldnames(tmpVol);
        if length(fldNm) ~= 1
            fprintf('\nError - the mat file has more than one variable.\n');
            fprintf('File : %s\n',P(1,:));
            hdr = [];
            results = [];
            analyzeFMT = [];
            return
        end
        som_mask = getfield(tmpVol,fldNm{1});
    end
end
volSIZE = size(som_mask);

som_mask = ones(size(som_mask));

spm('defaults','fmri');
global defaults;

if analyzeFMT == 2
    V = spm_vol(P(1,:));
    for iV = 1:size(V,1)
        vol = spm_read_vols(V(iV));
        t(iV) = spm_global(V(iV));
        som_mask  = som_mask.*(vol>(defaults.mask.thresh * t(iV)));   
        %
        % Check to see if the volumes being read are all the same size.
        %
        if any(volSIZE - size(vol))
            fprintf('\nVolumes are of different size!.\n');
            fprintf('%s\n',P(iP,:));
            hdr = [];
            results = [];
            analyzeFMT= [];
            return
        end
        clear vol; 
    end
   
else
    for iP = 1:size(P,1)
        fprintf('\b\b\b%03d',iP)
        if analyzeFMT == 1
            vol   = spm_read_vols(spm_vol(P(iP,:)));
            t(iP) = spm_global(spm_vol(P(iP,:)));
        else
            tmpVol = load(P(iP,:));
            fldNm = fieldnames(tmpVol);
            if length(fldNm) ~= 1
                fprintf('\nError - the mat file has more than one variable.\n');
                fprintf('File : %s\n',P(iP,:));
                hdr = [];
                results = [];
                analyzeFMT = [];
                return
            end
            vol   = getfield(tmpVol,fldNm{1});
            mvol  = mean(mean(mean(vol)))*SOM.maskThresh;  % Just like SPM.
            t(iP) = mean(vol(find(vol>mvol)));

        end
        som_mask  = som_mask.*(vol>(defaults.mask.thresh * t(iP)));
        %
        % Check to see if the volumes being read are all the same size.
        %
        if any(volSIZE - size(vol))
            fprintf('\nVolumes are of different size!.\n');
            fprintf('%s\n',P(iP,:));
            hdr = [];
            results = [];
            analyzeFMT= [];
            return
        end
        clear vol;
    end
end


fprintf('\b\b\bdone\n');

iMask = find(som_mask);

if analyzeFMT == 1
    hdr = spm_vol(P(1,:));
    [pn fn] = fileparts(hdr.fname);
    nhdr.fname    = fullfile(pn,'som_mask.img');
    nhdr.dim(1:3) = hdr.dim(1:3);
    nhdr.mat      = hdr.mat;
    nhdr.descrip  = ['SOM Created Masked based on SPM:',spm('ver')];
    if strcmp(spm('ver'),'SPM5') | strcmp(spm('ver'),'SPM8')
        nhdr.dt = [4 0];
    else
        nhdr.dim(4) = 4;
    end
    spm_write_vol(nhdr,som_mask);
    hdr = nhdr;
else
    if analyzeFMT == 2
        hdr = spm_vol(P(1,:));
        hdr = hdr(1);
        [pn fn] = fileparts(hdr.fname);
        nhdr.fname = fullfile(pn,'som_mask.img');
        nhdr.dim(1:3) = hdr.dim(1:3);
        nhdr.mat = hdr.mat;
        nhdr.descrip = ['SOM Created Masked based on SPM:',spm('ver')];
        if (strcmp(spm('ver'),'SPM5') | strcmp(spm('ver'),'SPM8'))
            nhdr.dt = [4 0];
        else
            nhdr.dim(4) = 4;
        end
        spm_write_vol(nhdr,som_mask);
        hdr = nhdr;
    else

        hdr = [];
        save(fullfile(fPath,'som_mask'),'som_mask');
    end
end

results = som_mask;

clear som_mask;

%
% All done.
%
