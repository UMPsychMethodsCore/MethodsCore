% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Validate the data parameters
% pass for SOM_PreProcessData
%
%
% function data = SOM_CheckDataStructure(parameters)
%
% data. 
%
%   run{i}.
%
%        P                 = full directory path to time-series data.
%
%        MotionParameters  = array of motion parameters
%
%        MaskFLAG          = 0 don't do any masking and grab all of the data
%                          = 1 mask using either what is in parameters.epi
%                            or by building a subject specific mask with
%                            SOM_CreateMask
%        nTIME             = number of time points to 
%                            analyze.
%
%        censorVector      = vector of 0's and 1's on which
%                            specific TR's to include in the analysis, this is after
%                            the nTIME has trimmed the data. NOT REQUIRED.
%
%   OK                = -1 returned if bad
%                        1 if things are okay.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Modified Nov 8, 2011 to have nTIME be part of data.run
% structure, previously it was part of the TIME.run structure.

% 2012.01.17 - put in check for censor vector - RCWelsh

function data = SOM_CheckDataStructure(parameters)

data.OK = -1;

if isfield(parameters,'data') == 0
    SOM_LOG('FATAL ERROR : Missing data structure from parameters');
    return
end

data    = parameters.data;
data.OK = -1;

if isfield(data,'run') == 0
  SOM_LOG('FATAL ERROR : Missing run variable from parameters.data');
  return
end

% Now loop on each run.

for iRUN = 1:length(data.run)
  if isfield(data.run(iRUN),'P') == 0
    SOM_LOG('FATAL ERROR : Missing P variable in parameters.data');
    return
  end

  if ischar(data.run(iRUN).P) == 0
    SOM_LOG('FATAL ERROR : You need to specify a character array of files');
    return
  end

  % Now check to see if the input files actually exist.
  
  if exist(data.run(iRUN).P(1,:),'file') == 0
    SOM_LOG(sprintf('FATAL ERROR : File %s does not exist',data.run(iRUN).P(1,:)));
    return
  end
  
  % Read in a single header for this run from the first file.
  
  data.run(iRUN).hdr = spm_vol(data.run(iRUN).P(1,:));
  
  % How many points in this run? If the hdr is multi-dimensional
  % than most likely a nifti file, and if P has more than one line
  % than it is img/hdr.
  
  nTIME = max( [ length(data.run(iRUN).hdr) size(data.run(iRUN).P,1) ] );

  if isfield(data.run(iRUN),'nTIME') == 0
    data.run(iRUN).nTIME = nTIME;
    SOM_LOG(sprintf('STATUS : Determined that for run %d, there are %d time-points.',iRUN,nTIME));
  end
  
  if isfield(data.run(iRUN),'censorVector')
    if length(data.run(iRUN).censorVector) ~= data.run(iRUN).nTIME
      SOM_LOG(sprintf('FATAL : Specified censorVector of length %d for run %d does not match %d'),iRUN,data.run(iRUN).nTIME)
      return
    end
  end  
      
  % Check to see if the motion parameters are there
      
  if isfield(data.run(iRUN),'MotionParameters') == 1
    if size(data.run(iRUN).MotionParameters,1) ~= data.run(iRUN).nTIME
      SOM_LOG('WARNING : Motion parameters length does not match expected number of time points');
      if length(data.run(iRUN).MotionParameters) > 0 & size(data.run(iRUN).MotionParameters,1) < data.run(iRUN).nTIME
	SOM_LOG(sprintf('FATAL ERROR : Motion parameter array is too short for run %d',iRUN));
        return
      end	
    end
  else
    data.run(iRUN).MotionParameters = [];
    SOM_LOG(sprintf('STATUS : No motion parameters for run %d',iRUN));
  end

  % And now make sure all files for this run are consistent.
  
  for iFILE = 2:size(data.run(iRUN).P,1)
    if exist(data.run(iRUN).P(iFILE,:),'file') == 0
      SOM_LOG(sprintf('FATAL ERROR : File %s does not exist'),data.run(iRUN).P(iFILE,:));
      return
    else
      thisHDR = spm_vol(data.run(iRUN).P(iFILE,:));     % fixed on 5/2/2012
      if SOM_SpaceVerify(data.run(iRUN).hdr,thisHDR) ~= 1
	SOM_LOG('FATAL ERROR : Error with consistent in-run image space definition.');
	return
      end
    end
  end
  
end

% Now check that the headers of each run specifies the same space:

for iRUN = 2:length(data.run)
  if SOM_SpaceVerify(data.run(1).hdr,data.run(iRUN).hdr) ~= 1
    SOM_LOG('FATAL ERROR : Error with consistent cross-run image space definition.');
    return
  end
end

% Check to see what type of masking
% The masking flag will apply to all of the runs, else
% we'd end up with a different number of space points per run
% which does NOT make sense.

if isfield(data,'MaskFLAG') == 0
  SOM_LOG('WARNING : Defaulting to using a mask on the data');
  data.MaskFLAG = 1;
end

if isnumeric(data.MaskFLAG) == 0
  SOM_LOG('WARNING : data.MaskFLAG is not numeric, forcing it to 1');
  data.MaskFLAG = 1;
end

if data.MaskFLAG ~= 0
  data.MaskFLAG = 1;
end

% Everything is ok.

data.OK = 1;

return

        
        
        