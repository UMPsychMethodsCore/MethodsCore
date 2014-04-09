function [infoStruct varargout] = wfu_read_afni_extra_data(inAfniNii)
% [infoStruct spmHeader] = wfu_read_afni_extra_data(inAfniNii)
%  ~or~
% infoStruct = wfu_read_afni_extra_data(inAfniNii)
%
% if two arguments for output are given, the 2nd output is an spm_vol header
% modified to contain corrected fields from the afniHeader information.
% Additional afni information will be placed in spmHeader.afni.
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.3 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.3 $');

  infoStruct = {};
  
  [voxelOffset offsetSize additionalHeader] = wfu_read_nifti_voxel_offset(inAfniNii);
  
  
  XMLstring = char(additionalHeader)';
  
  %parse the XML in str
  [junk remainingXML] = strtok(XMLstring,'<');
  while ~isempty(remainingXML)
    elementName=[];
    [XMLSegment remainingXML] = strtok(remainingXML,'<');
    [elementNameLine XMLSegmentRemaining] =strtok(XMLSegment, char(10));
    if isempty(elementNameLine)
%      disp('in extra elementNameLine check');
      elementNameLine=strtok(XMLsegment, char(10)); %only try once if element name is not after <
    end
    
    elementName = strtok(elementNameLine,' ');
    
    switch lower(elementName)
      case '?xml'
        %do nothing
        
      case 'afni_attributes'
        [elementLine XMLSegmentRemaining] = strtok(XMLSegmentRemaining,char(10));
        while ~isempty(elementLine)
          [key value] = local_key_value(elementLine);
          switch lower(key)
            %below keys should parse into structure part named
            case {'self_idcode'}
              infoStruct.(key) = value;
            %below keys should parse into a numeric array
            case {'nifti_nums'}
              infoStruct.(key) = str2num(value);
            otherwise
              %do nothing
          end % switch key
          [elementLine XMLSegmentRemaining] = strtok(XMLSegmentRemaining,char(10));
        end % while
        
      case 'afni_atr'
        ni_type = [];
        ni_dimen = [];
        atr_name = [];
        completeValue = [];
        [elementLine XMLSegmentRemaining] = strtok(XMLSegmentRemaining,char(10));
        while ~isempty(elementLine)
          [key value] = local_key_value(elementLine);
          switch lower(key)
            case 'ni_type'
              ni_type = value;
            case 'ni_dimen'
              ni_dimen = str2num(value);
            case 'atr_name'
              atr_name = value;
            otherwise
              switch lower(ni_type)
                case 'string'
                  completeValue = [completeValue,local_clean_string(elementLine)];
                case {'int' 'float'}
                  completeValue = [completeValue str2num(elementLine)];
                otherwise
                  completeValue{end+1} = local_clean_string(elementLine);
              end
          end %switch key
          [elementLine XMLSegmentRemaining] = strtok(XMLSegmentRemaining,char(10));
        end %while
        
        %modifications to completeValue
        switch lower(atr_name)
          case 'history_note'
            newValue=wfu_explode(completeValue,'\n');
            completeValue = [];
            for i=1:length(newValue)
              completeValue=strvcat(completeValue,char(newValue{i}));
            end
          case {'ijk_to_dicom' 'ijk_to_dicom_real'}
            completeValue = [reshape(completeValue,4,3)'; 0 0 0 1];
          case 'brick_stats'
            if length(infoStruct.NIfTI_nums) > 5 
              if infoStruct.NIfTI_nums(4) == 1
                completeValue = reshape(completeValue,2,infoStruct.NIfTI_nums(5))';
              elseif infoStruct.NIfTI_nums(5) == 1
                completeValue = reshape(completeValue,2,infoStruct.NIfTI_nums(4))';
              else
                error('Unable to handle ''brick_stats'' in wfu_read_afni_extra_data.m\n');
              end
            end
          case 'brick_stataux'
            indx=1;
            while indx <= length(completeValue)
              brick=  completeValue(indx) + 1;   %bricks are 0 based, matlab 1 based
              code=   completeValue(indx+1);
              numVal= completeValue(indx+2);
              indx=indx+3;
              newStatAux(brick).statCode=code;
              newStatAux(brick).statValues=[];
              for i=1:numVal
                newStatAux(brick).statValues= [newStatAux(brick).statValues completeValue(indx)];
                indx=indx+1;
              end
            end
            completeValue=newStatAux;
          case 'brick_statsym'
            completeValue=wfu_explode(completeValue,';');
          case 'brick_labs'
            completeValue=wfu_explode(completeValue,'~');
          otherwise
            %do nothing
        end
        infoStruct.(atr_name) = completeValue;
        
      otherwise
        if elementName(1) ~= '/'
          beep();
          if isempty(elementName)
            fprintf('WARNING!! AFNI XML Element has no name. \n');
          else
            fprintf('WARNING!!  Do not know how to handle AFNI XML element %s\n',elementName);
          end
        end
    end %  switch elementName
  end
  
  if nargout >= 2
    spmHeader = spm_vol(inAfniNii);
    if ~isempty(infoStruct)
      if any(any(sign(spmHeader(1).mat)~=sign(infoStruct.IJK_TO_DICOM_REAL)))
        WFU_LOG.warn('MAT from reading and AFNI''s IJK_TO_DICOM_REAL do not match.  DATA MAY BE FLIPPED.');
      end

      %correct for multiple volumes
      for i=1:length(spmHeader)
        spmHeader(i).afni = infoStruct;
        spmHeader(i).afni.BRICK_STATS=infoStruct.BRICK_STATS(i,:);
        spmHeader(i).afni.BRICK_TYPES=infoStruct.BRICK_TYPES(i);
        spmHeader(i).afni.BRICK_FLOAT_FACS=infoStruct.BRICK_FLOAT_FACS(i);
        try, spmHeader(i).afni.BRICK_STATAUX=infoStruct.BRICK_STATAUX(i); end;
        try, spmHeader(i).afni.BRICK_STATSYM=infoStruct.BRICK_STATSYM{i}; end;
        try, spmHeader(i).afni.BRICK_LABS=infoStruct.BRICK_LABS{i}; end;
      end
    end
    
    varargout{1} = spmHeader;
    
  end
  

return

function [key value] = local_key_value(str)
  expr = '\s*(.*)="(.*)".*';
  tok = regexp(str, expr, 'tokens');
  if ~isempty(tok);
    key = char(tok{1}(1));
    value = char(tok{1}(2));
  else
    key = '';
    value = '';
  end
return

function cleanString = local_clean_string(dirtyString)
  %remove "crap" around value
  expr = '.*=?"(.*)".*';
  tok = regexp(dirtyString, expr, 'tokens');
  if ~isempty(tok);
    cleanString = char(tok{1}(1));
  else
    cleanString = '';
  end
  cleanString = strtrim(cleanString);
return

%% Revision Log at end

%{
$Log: wfu_read_afni_extra_data.m,v $
Revision 1.3  2010/07/19 20:02:52  bwagner
WFU_LOG implemented.  Function no longer fails for normal nifti.

revision 1.2  2009/12/21 15:07:23  bwagner
moved explode from local to wfu_ function, removing SPM override scripts

revision 1.1  2009/10/09 17:11:38	 bwagner
PickAtlas Release Pre-Alpha 1
%}