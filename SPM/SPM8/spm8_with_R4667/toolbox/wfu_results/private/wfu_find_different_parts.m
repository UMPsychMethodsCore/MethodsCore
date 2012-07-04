function [before after beforePlace afterPlace] = wfu_find_different_parts(baseString,compareString,caseSensative)
% [before after beforePlace afterPlace] = wfu_find_different_parts(baseString,compareString,caseSensative)
%
% caseSensative default = true
%
%
%  results returned so that:
%  compareString = [before baseString(beforePlace:afterPace) after]

  str1=char(baseString);
  str2=char(compareString);
  
  if ~exist('caseSensative','var')
    caseSensative=true;
  end
  
  before = [];
  after = [];
  beforePlace = [];
  afterPlace = [];
  
  if caseSensative
    if strcmp(str1,str2), return; end;
  else
    if strcmpi(str1,str2), return; end;
  end

  pos1 = 1;
  pos2 = 1;
  
  beforeCondMet = false;
  
  %before comparison
  while pos1 <= length(str1) 
    while pos2 <= length(str2)
      if caseSensative
        if strcmp(str1(pos1),str2(pos2))
          try
            if strcmp(str1(pos1+1),str2(pos2+1)), beforeCondMet=true; end
          catch
            beforeCondMet=true;
          end
        end
      else
        if ~strcmpi(str1(pos1),str2(pos2))
          try
            if strcmpi(str1(pos1+1),str2(pos2+1)), beforeCondMet=true; end
          catch
            beforeCondMet=true;
          end
        end
      end
      if beforeCondMet, break; end;
%      fprintf('%s\t%s\tdiffer\n',str1(pos1),str2(pos2));
      pos2=pos2+1;
    end
    if beforeCondMet, break; end;
    pos1=pos1+1;
  end
  
  before=str2(1:pos2-1);
  beforePlace=pos1;
  
  %after comparisons
  while pos1 <= length(str1) & pos2 <= length(str2)
    if caseSensative
      if ~strcmp(str1(pos1),str2(pos2))
%        fprintf('%s\t%s\tdiffer\n',str1(pos1),str2(pos2));
        break;
      end
    else
      if ~strcmpi(str1(pos1),str2(pos2))
%        fprintf('%s\t%s\tdiffer\n',str1(pos1),str2(pos2));
        break;
      end
    end
%    fprintf('%s\t%s\tsame\n',str1(pos1),str2(pos2));
    pos1=pos1+1;
    pos2=pos2+1;
  end
  
  if pos2<=length(str2)
    after = [after str2(pos2:end)];
    afterPlace = pos1-1;
  end

return