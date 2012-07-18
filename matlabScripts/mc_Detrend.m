function result = mc_Detrend(Images,Threshold,Order)
% A utility function to apply a detrending to an input image (or series of
% images)
%
% FORMAT result = mc_Detrend(Images,[Order])
%
% Images                 A string containing the fully qualified filename
%                        of the image to detrend OR a cell array of strings
%                        containing the fully qualified filenames of each
%                        timepoint.
%
% Threshold              A value to threshold the initial image at.  Any 
%                        voxel whose timeseries mean is below this value 
%                        will be zeroed out. This is useful to avoid 
%                        detrending non-brain space. Defaults to 0.
%
% Order                  An optional argument to specify the order of the
%                        polynomial to remove. Defaults to 1.
%
% result                 1 if successful, 0 if there was an error.
%

result = 1;

if (~exist('Threshold','var') | isempty(Threshold))
    Threshold = 0;
end

if (~exist('Order','var') | isempty(Order))
    Order = 1;
end

if (~iscell(Images))
    % check if Images is a string
    if (~ischar(Images))
        %error, Images is not a string
        mc_Error('Input ''Images'' is not a string or cell array.');
    end
    % check if Images exists
    if (~exist(Images,'file'))
        %error, Images file does not exist
        mc_Error('File %s does not exist.',Images);
    end
    % load Images into data matrix
    V = spm_vol(Images);
    mtx = spm_read_vols(V);
else
    % check if Images elements exist
    nImgs = size(Images,1);
    for nI = 1:nImgs
        if (~exist(Images{nI},'file'))
            %error Image nI doesn't exist
            mc_Error('File %s does not exist.',Images{nI});
        end
    end
    % load Images into data matrix
    V = spm_vol(Images);
    mtx = spm_read_vols(V);
end

rmtx = reshape(mtx,size(mtx,1)*size(mtx,2)*size(mtx,3),size(mtx,4));
mrmtx = mean(rmtx,2);
tidx = find(mrmtx<=Threshold);
rmtx(tidx,:) = 0;

drmtx = spm_detrend(rmtx',Order)';
dmtx = reshape(drmtx,size(mtx));

V2 = V;
for iV = 1:size(V2,1)
    [p f e] = fileparts(V2(iV).fname);
    df = ['d' f];
    V2(iV).fname = fullfile(p,[df e]);
    spm_write_vol(V2(iV),dmtx(:,:,:,iV));
end


return;

