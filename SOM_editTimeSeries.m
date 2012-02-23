% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Routine to take 2D input (space x time)
% and edit out points
%
% function D1 = SOM_editTimeSeries(D0,censorVector)
%
% data         = space x time data.
%
% censorVector = string of 1's and 0's, one element per time
%                point on what to keep and throw away in
%                time-series data.
%
% Output
% 
% D1           = space x time data, edited.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function D1 = SOM_editTimeSeries(D0,censorVector)

D1 = -1;

if size(D0,2) ~= length(censorVector)
  SOM_LOG(sprintf('FATAL : Size of D0 (%d,%d) not consistent with edit vector (%d))',size(D0,1),size(D0,2),length(censorVector)));
  return
end

idxGood = find(censorVector~=0);
D1 = D0(:,idxGood);

return

%
% all done
% 