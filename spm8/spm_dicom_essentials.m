function hdr1 = spm_dicom_essentials(hdr0)
% Remove unused fields from DICOM header
% FORMAT hdr1 = spm_dicom_essentials(hdr0)
% hdr0 - original DICOM header
% hdr1 - Stripped down DICOM header.
%
% With lots of DICOM files, the size of all the headers can become too
% big for all the fields to be saved.  The idea here is to strip down
% the headers to their essentials.
%
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_dicom_essentials.m 2268 2008-09-30 21:15:32Z guillaume $

used_fields = {...
    'AcquisitionDate',...
    'AcquisitionNumber',...
    'AcquisitionTime',...
    'BitsAllocated',...
    'BitsStored',...
    'CSAImageHeaderInfo',...
    'Columns',...
    'EchoNumbers',...
    'EchoTime',...
    'Filename',...
    'FlipAngle',...
    'HighBit',...
    'ImageOrientationPatient',...
    'ImagePositionPatient',...
    'ImageType',...
    'InstanceNumber',...
    'MRAcquisitionType',...
    'MagneticFieldStrength',...
    'Modality',...
    'PatientID',...
    'PatientsName',...
    'PixelRepresentation',...
    'PixelSpacing',...
    'Private_0029_1210',...
    'ProtocolName',...
    'RepetitionTime',...
    'RescaleIntercept',...
    'RescaleSlope',...
    'Rows',...
    'SOPClassUID',...
    'SamplesperPixel',...
    'ScanningSequence',...
    'SequenceName',...
    'SeriesDescription',...
    'SeriesInstanceUID',...
    'SeriesNumber',...
    'SliceNormalVector',...
    'SliceThickness',...
    'SpacingBetweenSlices',...
    'StartOfPixelData',...
    'StudyDate',...
    'StudyTime',...
    'TransferSyntaxUID',...
    'VROfPixelData'};

fnames = fieldnames(hdr0);
for i=1:numel(used_fields),
    if any(strmatch(used_fields{i},fnames,'exact')),
       hdr1.(used_fields{i}) = hdr0.(used_fields{i});
    end
end

if isfield(hdr1,'Private_0029_1210'),
    Private_0029_1210_fields = {...
        'Columns',...
        'Rows',...
        'ImageOrientationPatient',...
        'ImagePositionPatient',...
        'SliceThickness',...
        'PixelSpacing'};
    hdr1.Private_0029_1210 = ...
        getfields(hdr1.Private_0029_1210,...
                       Private_0029_1210_fields);
end
 
if isfield(hdr1,'CSAImageHeaderInfo'), 
    CSAImageHeaderInfo_fields = {...
        'SliceNormalVector',...
        'NumberOfImagesInMosaic',...
        'AcquisitionMatrixText',...
        'ICE_Dims'};
    hdr1.CSAImageHeaderInfo = ...
        getfields(hdr1.CSAImageHeaderInfo,...
                       CSAImageHeaderInfo_fields);
end

if isfield(hdr1,'CSASeriesHeaderInfo'),    
    CSASeriesHeaderInfo_fields = {};
    hdr1.CSASeriesHeaderInfo = ...
        getfields(hdr1.CSASeriesHeaderInfo,...
                       CSASeriesHeaderInfo_fields); 
end


function str1 = getfields(str0,names)
str1 = [];
for i=1:numel(names)
    for j=1:numel(str0),
        if strcmp(str0(j).name,names{i})
            str1 = [str1,str0(j)];
        end
    end
end


