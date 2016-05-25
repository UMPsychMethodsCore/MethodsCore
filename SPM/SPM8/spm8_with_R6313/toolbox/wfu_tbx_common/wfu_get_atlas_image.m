function [atlasImageFile rois]= wfu_get_atlas_image(paAtlasName,atlasGroup)
% atlasImageFile = wfu_get_atlas_image(paAtlasName,atlasGroup)
%
% Searches trough the pickatlas and returns the name of the atlas file 
% based on the paAtlasName
%
% AtlasGroup will default to the first Atlas found in atlas_type.txt if not
% given
%
% atlasImageFile is the name of the ROI defining atlas file.
% rois is a cell array of names, where the index correspons to a value in
% the atlas file.

  debug=false;

  if nargin < 1
    error('No atlas specified');
  end
  
  if nargin < 2
    atlasGroup=[];
  end

  if ~any(strcmpi(spm('ver'),{'spm5','spm8'}))
    gospm(5);
  end

  paDir=fileparts(which('wfu_pickatlas'));
  if isempty(paDir), error('Cannot find PickAtlas'); end
  
  [groupName groupDir groupLookup groupImg] = readAtlasType(fullfile(paDir,'atlas_type.txt'),atlasGroup);
  
  masterLookupFile=fullfile(paDir,groupDir,groupLookup);
  [atlasName atlasImg atlasTxt atlasOffset] = readMasterLookup(masterLookupFile,paAtlasName);

  atlasFullName=fullfile(paDir,groupDir,atlasImg);
  regionLookupFile=fullfile(paDir,groupDir,atlasTxt);  

  rois = readRegionLookupAll(regionLookupFile);
  atlasImageFile=atlasFullName;
  
  
return

function [groupName groupDir groupLookup groupImg] = readAtlasType(atlasTypeLookupFile,atlasGroup)
% returns lookup information for atlasGroup.  If atlasGroup is empty, it
% returns lookup information for the first atlasGroup in file.
  debug=false;
  groupName = [];
  groupDir = [];
  groupLookup = [];
  groupImg = [];

  if debug, disp('reading/parse/select atlas_type.txt ...'); end
  fid=fopen(atlasTypeLookupFile,'r');
  if fid < 0, error('Cannot read %s\n',atlasTypeLookupFile); end
  
  while ~feof(fid)
    oneLine=fgetl(fid);
    if oneLine(1)=='%', continue; end
    [t_groupName, rem] = strtok(oneLine,',');
    [t_groupDir,  rem] = strtok(rem,',');
    [t_groupLookup,rem] = strtok(rem,',');
    [t_groupImg,  rem] = strtok(rem,',');
    
    if isempty(atlasGroup), atlasGroup=strtrim(t_groupName); end
    
    if local_search(strtrim(t_groupName),atlasGroup)
      groupName=strtrim(t_groupName);
      groupDir=strtrim(t_groupDir);
      groupLookup=strtrim(t_groupLookup);
      groupImg=strtrim(t_groupImg);
      break;
    end
  end
  fclose(fid);
return

function index = local_search(needle,haystack,casesensitive)
  % searches for needle in haystack
  % if not found, replaces spaces with underscores in needle and tries again
  % if still not found, replaces underscores with spaces in needle and tries again
  %
  % using strfind below to leave the searh mechanism somewhat loose
  
  if nargin < 3, casesensitive = false; end
  local_debug=false;
  if local_debug, disp('==Entering local_search==');end
  
  if ischar(haystack), haystack=cellstr(haystack); end
  if ~iscell(haystack), error('internal function `local_search` is for cell and char style haystacks\n'); end
  
  if ~casesensitive
    needle=upper(needle);
    haystack=upper(haystack);
  end
  
  if ~ischar(needle), needle=char(needle); end
  
  index=~cellfun('isempty',strfind(haystack,needle));
  if local_debug, needle, haystack, index, end

  if ~any(index)
    if local_debug, fprintf('Cannot find needle `%s` normally, replacing spaces with underscores.\n',needle); end
    tmpName=upper(needle);
    tmpName(strfind(tmpName,' '))='_';
    index=~cellfun('isempty',strfind(upper(haystack),tmpName));
    if local_debug, tmpName, haystack, index, end
  end

  if ~any(index)
    if local_debug, fprintf('Cannot find needle `%s` normally, replacing underscores with spaces.\n',needle); end
    tmpName=upper(needle);
    tmpName(strfind(tmpName,'_'))=' ';
    index=~cellfun('isempty',strfind(upper(haystack),tmpName));
    if local_debug, tmpName, haystack, index, end
  end
  if local_debug, disp('==Leaving local_search==');end
return

function [atlasName atlasImg atlasTxt atlasOffset] = readMasterLookup(masterLookupFile,RegionName)
  debug=false;
  atlasName =[];
  atlasImg = [];
  atlasTxt = [];
  atlasOffset = [];
  
  if debug, fprintf('reading/parse/select master_lookup.txt (%s)...\n',masterLookupFile); end
  fid=fopen(masterLookupFile,'r');
  if fid < 0, error('Cannot read %s\n',masterLookupFile); end
  while ~feof(fid)
    oneLine=fgetl(fid);
    [t_atlasName, rem] = strtok(oneLine,',');
    [t_atlasImg, rem]  = strtok(rem,',');
    [t_atlasTxt, rem]  = strtok(rem,',');
    [t_atlasOffset, rem]     = strtok(rem,',');
    if local_search(strtrim(t_atlasName),RegionName)
      atlasName=strtrim(t_atlasName);
      atlasImg=strtrim(t_atlasImg);
      atlasTxt=strtrim(t_atlasTxt);
      atlasOffset=strtrim(t_atlasOffset);
      break;
    end
  end
  fclose(fid);
return

function rois = readRegionLookupAll(regionLookupFile)
  debug=false;
  RoiIndex = [];
  RoiName = [];
  rois=[];
  
  if debug, fprintf('reading/parse/select region_lookup.txt (%s)...\n',regionLookupFile); end
  fid=fopen(regionLookupFile,'r');
  if fid < 0, error('Cannot read %s\n',regionLookupfile); end
  while ~feof(fid)
    oneLine=fgetl(fid);
    oneLine=strtrim(oneLine);
    if isempty(oneLine), continue; end
    if oneLine(1)=='[', continue; end
    [regionIndexString rem]   = strtok(oneLine);
    regionIndex=str2double(regionIndexString);
    if isnan(regionIndex), continue; end
    regionName=[];
    while ~isempty(rem)
      [temp, rem]  = strtok(rem);
      if ~isnan(str2double(temp)), break; end  %word is a "number", break
      regionName=[regionName ' ' temp];
    end
    if isempty(regionName),continue; end

    regionName=strtrim(regionName);

    if debug, fprintf('Index: % 4d      Region: %s\n',regionIndex, regionName); end
    rois{regionIndex}=regionName;
  end
  fclose(fid);
return