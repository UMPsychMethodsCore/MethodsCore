% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
%
% INPUT
%
%   parameters -- see SOM_PreProcesData
%
%      .rois
%      .Output
%               .correlation  - 'maps'    - save a single correlation matrix
%                               'images'  - save a single correlation image
%                                           per ROI
%               .directory    - full directory path to output
%               .name         - name of output file (generic)
%               .description  - comment to add to image files.
%               .power        - write out the power spectrum of ROIs
%                               THIS IS AN OPTIONAL FLAG.
%
%
% OUTPUT
%
%     Output
%
%        .OK = 1 all okay, other wise not.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function Output = SOM_CheckOutput(parameters)

% Default is error

Output.OK = -1;

% check for the "rois" field;

if isfield(parameters,'Output') == 0
    SOM_LOG('FATAL ERROR : You need to specify ".Output" definitions');
    return
end

Output = parameters.Output;

Output.OK = -1;

%
% Make sure they have asked for "maps" or "images".
%

if isfield(Output,'correlation')
    if ischar(Output.correlation)
        Output.correlation = lower(Output.correlation);
        switch lower(Output.correlation(1))
            case 'm'
                Output.type = 0;   % Correlation map/mat file. This require more than 1 ROI!
            case 'i'
                Output.type = 1;   % r-image and z-image.
            otherwise
                SOM_LOG('FATAL ERROR : Output type no specified');
                return
        end
    else
        SOM_LOG('FATAL ERROR : Output type needs to be specified as string');
        return
    end
else
    SOM_LOG('FATAL ERROR : Correlation output type is missing');
    return
end

% 
% Now check for the output directory, it must exist
%

if isfield(Output,'directory') 
    if exist(Output.directory,'dir') == 0
        SOM_LOG('WARNING : Output directory is not there, but will attempt to create');
        [mkS mkM mkID] = mkdir(Output.directory);
        if mkS
            SOM_LOG('WARNING : Success');
        else
            SOM_LOG('FATAL WARNING : Can not create');
            return
        end
    end
else
    SOM_LOG('FATAL WARNING : Can not create');
    return
end

if isfield(Output,'name') == 0
    SOM_LOG('WARNING : Missing output name, will use generic');
    Outputname = 'rmap';
else
    Outputname = Output.name;
end

% Now make sure there are no special characters in name, but allow '_'.

CHAROK = isstrprop(Outputname, 'alphanum');

Output.name = [];

for iCHAR = 1:length(CHAROK)
    if CHAROK(iCHAR) | strcmp(Outputname(iCHAR),'_')
        Output.name = [ Output.name Outputname(iCHAR) ] ;
    else
        SOM_LOG(sprintf('WARNING : Removing special character "%s" from Output.name',Outputname(iCHAR)));
    end
end

if isfield(Output,'description') == 0
    Output.description = 'Correlaton map';
    SOM_LOG('STATUS : Using generic file comment description.');
end

% What about power spectrum

if isfield(Output,'power') == 0
  Output.power = 0;
else
  if Output.power ~= 0 
    Output.power = 1;
    SOM_LOG('WARNING : You have enabled power spectrum saving of ROIs. Be aware that assumptions of a single run are made.');
  end
end

%

Output.OK = 1;

return

%
% All done
%


