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

function OK = SOM_SpaceVerify(header_1,header_2)

OK = -1;

%
% Did they pass headers?
%

% Do this for convience so we can loop.
try
  headers       = {header_1(1),header_2(1)};
catch
  return
end

fieldsToCheck = {'mat','dim'};

% Now check.

for iHDR = 1:2
  for iField = 1:2
    if isfield(headers{iHDR},fieldsToCheck{iField}) == 0
      SOM_LOG('FATAL ERROR : You need to specify valid headers to be checked.');
      return
    end
  end
end

%
% Okay they seem like valid headers, now check them.
%

% We require the difference to be greater than "eps", built-in
% matlab variable.

if any(abs((headers{1}.mat(:) - headers{2}.mat(:)))>eps)
  SOM_LOG(sprintf('FATAL ERROR : ".mat(:)" does not match for files %s and %s ',headers{1}.fname,headers{2}.fname));
  return
end

if any(headers{1}.dim(1:3) - headers{2}.dim(1:3))
  SOM_LOG(sprintf('FATAL ERROR : ".dim(1:3)" does not match for files %s and %s ',headers{1}.fname,headers{2}.fname));
  return
end  

OK = 1;

return

%
% All done.
%