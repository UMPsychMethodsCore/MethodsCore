%
% A function to merge SOM's
%
% function results = SOM_MergeSOMS(P,newName);
%
%  P = array of file names to merge.
%
%         P can also be the output of the matlab "dir" command.
%

function results = SOM_MergeSOMS(P,newName)

if exist('newName') == 0
  newName = 'combined_som';
end

if isstruct(P)
  P1 = P(1).name;
  nFiles = length(P);
else
  P1 = P(1,:);
  nFiles = size(P,1);
end

[fPath fName fExt] = fileparts(P1);

if strcmp(lower(fExt),'img') == 1
  analyzeFMT = 1;
else
  analyzeFMT = 0;
end

if analyzeFMT == 1
  printf('not working\n');
  return
end

load(P1);

s1 = zeros(size(somMap));
for ifl = 1:nFiles
  if isstruct(P)
    load(P(ifl).name);
  else
    load(P(ifl,:));
  end
  okidx = find(isfinite(somMap));
  tmpvol = 0*s1;
  tmpvol(okidx) = somMap(okidx);
  s1 = s1+tmpvol;
end

somMap = s1;
save(newName,'somMap');
results = somMap;

%
% all done.
%