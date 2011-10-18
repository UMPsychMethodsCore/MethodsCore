% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Validate that the mat and the dim of two headers are identical
%
% function OK = SOM_SpaceVerify(header_1,header_2)
%
%  OK = -1 is bad
% 
%     =  1 all is okay.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

OK = -1;

%
% Did they pass headers?
%

% Do this for convience so we can loop.
headers       = {header_1,header_2};
fieldsToCheck = {'mat','dim'};

% Now check.

for iHDR = 1:2
  for iField = 1:2
    if isfield(headers{iHDR},fieldsToCheck{iField}) == 0
      SOM_LOG('You need to specify valid headers to be checked.');
      return
    end
  end
end

%
% Okay they seem like valid headers, now check them.
%

if any(headers{1}.mat(:) - header{2}.mat(:))
  SOM_LOG(sprintf('FATAL ERROR : ".mat(:)" does not match for files %s and %s ',header{1}.hdr.fname,header{2}.hdr.fname));
  return
end

if any(header{1}.dim(1:3) - header{2}.dim(1:3))
  SOM_LOG(sprintf('FATAL ERROR : ".dim(1:3)" does not match for files %s and %s ',header{1}.hdr.fname,header{2}.hdr.fname));
  return
end  

OK = 1;

return

%
% All done.
%