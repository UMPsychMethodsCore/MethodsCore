% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
%
% A routine to calculate the ALFF
%
% Input
%
%     theData     = theData(space,time) (this is the 
%                   standard format being used in this SOM
%                   implementation).
%
%     sample      = sample period (TR in fmri language)
%
%
%     band        = [fLow fHi]
%
%
% function results = SOM_ALFF(theData,sampleTR,band)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_ALFF(theData,sampleTR,band)

results = -1;

if band(1) >= band(2)
  SOM_LOG('FATAL ERROR : fLo >= fHi');
  return
end

% Hard code to use gentle rolling and 10 padding and internal FFT as we 
% need the power spectrum;

band_data    = SOM_Filter(theData,sampleTR,band(1),band(2),2,10,1);

band_data_ps = SOM_PowerSpect(band_data,sampleTR);

results      = sum(sqrt(band_data_ps),2);

return
