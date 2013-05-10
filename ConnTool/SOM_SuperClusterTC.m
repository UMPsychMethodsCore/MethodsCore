% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2010
%
% A function to get the time courses for the
% super clusters. This will be based on a variety
% of methods
%
% function [SCTimeCourse] = SOM_SuperClusterTC(SOMResults,SCMap,whichOption)
%
% SOMResults - the structure that is returned by SOM_CalculateMap
%
% SCMap is a xGrid x yGrid array with super cluster memebership as value
%
% whichOption
%
%  1 = average the exemplars
% 
%  2 = average the data
%
%  3 = weighted average of the data
%
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SCTimeCourse = SOM_SuperClusterTC(SOMResults,SCMap,whichOption)

global SOMMem
    
SCTimeCourse = [];

if isfield(SOMMem{1},'theData') == 0
    fprintf('Missing SOMMem\n');
    return
end

if exist('whichOption') == 0
    whichOption = 1;
end

if ismember(whichOption,[1 2 3]) == 0
    fprintf('Forcing whichOption to 1\n');
    whichOption = 1;
end

if isfield(SOMResults,'SelfOMap') == 0
    fprintf('Missing SelfOMap as part of SOMResults structure\n');
    return
end

if isfield(SOMResults,'IDX') == 0
    fprintf('Missing SelfOMap as part of SOMResults structure\n');
    return
end

% Okay do the work now.

SCUnique = unique(SCMap);

nTime = size(SOMMem{1}.theData,2);

SCTimeCourse = zeros(nTime,length(SCUnique));

NCHKVOXELCOUNT = 0;

for iSC = 1:length(SCUnique)
    iEXP = find(SCMap==SCUnique(iSC));
    IDXData = ismember(SOMResults.IDX,iEXP);
    fprintf('Number in %03d is %03d and %05d\n',iSC,length(iEXP),length(find(IDXData)));
    NCHKVOXELCOUNT = NCHKVOXELCOUNT + length(find(IDXData));    
    switch whichOption
        case 1
            % Average of the exemplars
            SCTimeCourse(:,iSC) = mean(SOMResults.SelfOMap(:,iEXP),2);
            fprintf('using exemplars\n');
        case 2
            % Average of the data in that SC.
            SCTimeCourse(:,iSC) = mean(SOMMem{1}.theData(IDXData,:),1)';
            fprintf('using data\n');            
        case 3
            fprintf('Not implemented yet.\n');
    end
    
end

SCTimeCourse = SOM_UnitNormMatrix(SCTimeCourse,1);

%
% All done.
%





