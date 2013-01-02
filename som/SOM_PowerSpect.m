% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2010
%
%
% A routine to return power spectrum of data
%
%     theData     = theData(space,time) (this is the 
%                   standard format being used in this SOM
%                   implementation).
%
%     sample      = sample period (TR in fmri language)
%
% This returns a simple modulus of the FFT of teh time-series.
%
% function [results, powerParams] = SOM_PowerSpect(theData,sample)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results, powerParams] = SOM_PowerSpect(theData,sample)

% Save input for posterity.

powerParams.sample      = sample;

%Determine the Nyquist criterion

nyquist = 1/sample/2;

powerParams.nyquist = nyquist;

% How big is our sample.

if size(theData,2) == 1
    if size(theData,1) > 1
        theData = theData';
        fprintf('Transposing data for you, assuming the vector is time data.\n');
    end
end

N = size(theData,2);

% Make a frequency baseline.

deltaF = nyquist/(floor(N/2)-1);

freq   = (-floor(N/2):floor(N/2)-1)*deltaF;

powerParams.deltaF = deltaF;
powerParams.freq   = freq;

% Get the fft of the data.

ffttheData      = fftshift(fft(theData,[],2),2);

powerParams.fft = ffttheData;

results         = ffttheData.*conj(ffttheData)/2/pi;

% If odd length, then we add to "freq" vector.

if length(results) == length(powerParams.freq)+1
  powerParams.freq = [powerParams.freq powerParams.freq(end)+deltaF];
end

% Now find the middle

middleFreqI      = find(powerParams.freq==0);

% Now just get the spectrum and frequency information.

results            = results(:,middleFreqI:end);
powerParams.freq   = powerParams.freq(middleFreqI:end);
powerParams.midIDX = middleFreqI;

%
% Return
%
