% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2006
%
%
% A routine to mix up the phase of the individual data time-series
% for calculation of the false rate.
%
% function SOM_Bootstrap
%
% What goes in is the data, what comes out is the data
% with fourier components having their phases randomly
% assigned to -pi to pi.
%
% global SOMMem
%
% Input
%
%     SOMMem{slot}.theData(nVoxel,nTime)  - the data.
%     SOMMem{slot}.fftData(nVoxe,nTime)   - fft of the above data.
%     SOMMem{slot}.PData(nVoxel,nTime)    - phase of above data.
%     SOMMem{slot}.afftData(nVoxel,nTime) - magniture of the above data.
%
%     SOMMem{slot}.Padding                - Size of padding.
%
% Output
%    
%     SOMMem{slot}.theDataRP  -  data with the phase of the frequency components
%               randomly assigned.
%     SOMMem{slot}.fftDataN   -  new fft of the data (fftDataN = fft(theDataRP,[],2);
%
%     SOMMem{slot}.Dphase     -  the random phase used.
%
% Change to used global memory to help with out of memory issues.
%
%
% According to MRM 51:418-422 (2004) Laird, Rogers and Meyerand
% the phase should be randomly shifted simultaneously by the 
% same amount for each frequency component. This will keep the 
% spatial correlations.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SOM_Bootstrap

global SOMMem

% Force to use slot #1 to grab the time course data
% However, we need to place the randomized data into slot 3.

slot = 1;

% Make sure that there is data present

SOMMem{slot}.Error = 0;

if isfield(SOMMem{slot},'theData') == 0
    fprintf('Error - no data present in the SOMMem global structure.\n');
    SOMMem{slot}.Error = 1;
    return
end

% Check that padding is there.

if isfield(SOMMem{slot},'Padding') == 0
    SOMMem{slot}.Padding = 10;
    fprintf('Forcing SOMMem{slot}.Padding = 10;\n');
end

SOMMem{slot}.Padding = floor(SOMMem{slot}.Padding);

if SOMMem{slot}.Padding < 0
    SOMMem{slot}.Padding = 10;
    fprintf('Forcing SOMMem{slot}.Padding = 10;\n');
end

% Get the fft of the data, save time by only doing once per looping call.
% You must CLEAR THIS IF YOU ARE DOING DIFFERENT DATA SET.

if isfield(SOMMem{slot},'fftData') == 0 | ...
        isfield(SOMMem{slot},'afftData') == 0 | ...
        isfield(SOMMem{slot},'PData') == 0 | ...
        any(size(SOMMem{slot}.fftData) - (size(SOMMem{slot}.theData)+[0 2*SOMMem{slot}.Padding]))
    fprintf('Calculating Original Data Fourier Components.\n');
    % Calculate the padding.
    Padding1 = mean(SOMMem{slot}.theData(:,1:SOMMem{slot}.Padding),[2]);
    Padding2 = mean(SOMMem{slot}.theData(:,end-SOMMem{slot}.Padding+1:end),[2]);
    SOMMem{slot}.fftData = fft([repmat(Padding1,[1 SOMMem{slot}.Padding]) SOMMem{slot}.theData repmat(Padding2,[1 SOMMem{slot}.Padding])],[],2);
    % Get the magnitude of the data.
    SOMMem{slot}.afftData = abs(SOMMem{slot}.fftData);
    % Get the phase of the data.
    SOMMem{slot}.PData = angle(SOMMem{slot}.fftData);
else
    fprintf('Using Pre-existing FFT of ''theData''.\n');
end

% How big is our sample.

N = size(SOMMem{slot}.fftData,2);

Npnts2 = floor((N-1)/2);

% Determine even/oddness of number of time points.
OddEven = 1-mod(N,2);

% randomize the new phase change.
dphase = pi-2*pi*rand(1,Npnts2);

SOMMem{slot}.Dphase = repmat([0 -fliplr(dphase) pi-2*pi*rand(1,OddEven) dphase],[size(SOMMem{slot}.theData,1) 1]);

% Reassemble the data.
SOMMem{slot}.fftDataN = SOMMem{slot}.afftData.*exp((SOMMem{slot}.PData+SOMMem{slot}.Dphase)*i);

% Calculate the new signal. Taking the real part is fine as the original 
% signal is real.

SOMMem{slot}.DataN = real(ifft(SOMMem{slot}.fftDataN,[],2));

% And unit norm it at the same time.

SOMMem{3}.theData = SOM_UnitNormMatrix(SOMMem{slot}.DataN(:,1+SOMMem{slot}.Padding:end-SOMMem{slot}.Padding),2);

%
% All done.
%
