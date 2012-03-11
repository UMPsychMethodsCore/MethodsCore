% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2011
% Copyright.
%
% uniqueNII
% 
% A utility function to return a unique list of files
% names, after the frame number has been discarded.
%
% function [uniqueList count] = uniqueNII(inputList)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function [uniqueList count] = uniqueNII(inputList)

uniqueList = [];
count = [];

for iP = 1:size(inputList,1)
  [d1 d2 d3 d4] = spm_fileparts(inputList(iP,:));
  uniqueList = strvcat(uniqueList,fullfile(d1,[d2 d3]));
end

uniqueList = unique(uniqueList,'rows');

count = zeros(size(uniqueList,1),1);

for iP = 1:size(uniqueList,1)
  count(iP) = 0;
  for iO = 1:size(inputList,1)
      [d1 d2 d3 d4] = spm_fileparts(inputList(iO,:));
      if strcmp(uniqueList(iP,:),fullfile(d1,[d2 d3]))
	count(iP) = count(iP) + 1;
      end
  end
end

%
% all done.
% 