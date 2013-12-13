% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
%
% A routine to calculate the fALFF
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
%     band1       = [fLow fHi]  (narrow band)
%     band2       = [fLow fHi]  (broad band)
%
% NOTE band1 must be contained in band2
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_fALFF(theData,sampleTR,band1,band2)

results = -1;

if (band1(1)<band2(1))
  SOM_LOG('FATAL ERROR : The low frequency of band1 is outside of band2');
  return
end

if (band1(2)>band2(2))
  SOM_LOG('FATAL ERROR : The high frequency of band1 is outside of band2');
  return
end

if band1(1) >= band1(2)
  SOM_LOG('FATAL ERROR : The low frequency of band1 is not consistent');
  return
end

if band2(1) >= band2(2)
  SOM_LOG('FATAL ERROR : The low frequency of band2 is not consistent');
  return
end

if band1(1) == band2(1) & band1(2) == band2(2)
  SOM_LOG('FATAL ERROR : band1 is identical to band2');
  return
end

band1_data_ALFF = SOM_ALFF(theData,sampleTR,band1);
band2_data_ALFF = SOM_ALFF(theData,sampleTR,band2);

results = band1_data_ALFF./band2_data_ALFF;

return
