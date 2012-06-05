function [connectome, ROIcoordinates] = conjunction()
%% find common ROIs
[commonROI, coA, coB] = intersect(ROIA, ROIB, 'rows');