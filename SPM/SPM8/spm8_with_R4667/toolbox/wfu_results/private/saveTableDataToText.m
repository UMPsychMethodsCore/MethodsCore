function sts = saveTableDataToText(tableData, xSPM, filename)
% sts = saveTableDataToText(tableData, xSPM, filename)
%
% wfu_results internal function
%
% writes tableData (from an spm_list) to a text file

  sts = false;
  
  if nargin < 3
		warning('saveTableDataToText called without sufficient arguments');
		return;
	end

	try
		fid = fopen(filename,'w');
	catch
		beep();                                                                
		disp(sprintf('Unable to open %s for writing', filename));              
		return;                                                                
  end                                                                      
	
  if ispc
    lineEnding='\r\n';
  elseif isunix
    lineEnding='\n';
  else
    beep();
    disp('Unknown system type, defaulting to line ending of \n (unix)');
    lineEnding='\n';
  end
  
	%
	%	text width should be based on a 145 character width
	%
	
	% FROM spm_list.m
	fprintf(fid, ['Statistics:  %s' lineEnding], tableData.tit);
	if ~isempty(tableData.dat) & tableData.dat{1,2} > 1;
		fprintf(fid,['%- 20s',...				%set-level
			'%- 52s',...									%cluster-level
			'%- 60s',...									%peak-level
			'% 5s% 5s% 5s',...            %location
      lineEnding],...   %lineEnding
			'set-level','cluster-level','voxel-level','mm','mm','mm');
		fprintf(fid,['%- 10s%- 10s',...							%set-level
			'%- 13s%- 13s%- 13s%-13s',...							%cluster-level
			'%- 15s%- 15s%- 10s%- 10s%- 10s',...      %peak-level
      lineEnding],...               %lineEnding
			'p', 'c', 'p(FWE-corr)', 'q(FDR-corr)', 'k(E)', 'p(unc)', 'p(FWE-corr)', 'p(FDR-corr)', xSPM.STAT, 'Z', 'P(unc)');
  else
		fprintf(fid,['%- 20s',...				%set-level
			'%- 52s',...									%cluster-level
			'%- 60s',...									%peak-level
			'% 5s% 5s% 5s',...            %location
      lineEnding],...   %lineEnding
			' ','cluster-level','voxel-level','mm','mm','mm');
		fprintf(fid,['%- 10s%- 10s',...							%set-level
			'%- 13s%- 13s%- 13s%-13s',...										%cluster-level
			'%- 15s%- 15s%- 10s%- 10s%- 10s',...      %peak-level
      lineEnding],...               %lineEnding
			' ', ' ', 'p(FWE-corr)', 'q(FDR-corr)', 'k(E)', 'p(unc)', 'p(FWE-corr)', 'p(FDR-corr)', xSPM.STAT, 'Z', 'P(unc)');
	end
	
	if ~length(xSPM.Z)
		fprintf(fid,['no suprathreshold clusters' lineEnding]);
	end
	
	for i=1:size(tableData.dat,1)
		%-Print cluster and maximum voxel-level p values {Z}
   	%---------------------------------------------------------------
% might can use this later
%   	if isempty(tableData.dat{i,3})
%   		fontWeightDesc='normal';
%   	else
%   		fontWeightDesc='Bold';
%   	end
		if isempty(tableData.dat{i,3})
			formatString = ['%- 10s%- 10s',... 									%set-level
					'%- 13s%- 13s%- 13s%- 13s',...									%cluster-level
					'%-015.3f%-015.3f%-010.2f%-010.2f%-010.3f',...	%peak-level
					'% 5.0f% 5.0f% 5.0f',...												%location
          lineEnding];                        %lineEnding
			fprintf(fid, formatString,...
				' ',' ',...
				' ',' ',' ',' ',...
				tableData.dat{i,7},tableData.dat{i,8},tableData.dat{i,9},tableData.dat{i,10},tableData.dat{i,11},...
				tableData.dat{i,12});
		elseif isempty(tableData.dat{i,1}) || tableData.dat{i,2} <= 1
			formatString = ['%- 10s%- 10s',... 									%set-level
					'%-013.3f%-013.3f%-013.0f%-013.3f',...          %cluster-level
					'%-015.3f%-015.3f%-010.2f%-010.2f%-010.3f',...	%peak-level
					'% 5.0f% 5.0f% 5.0f',...												%location
          lineEnding];                        %lineEnding
			fprintf(fid, formatString,...
				' ',' ',...
				tableData.dat{i,3},tableData.dat{i,4},tableData.dat{i,5},tableData.dat{i,6},...
				tableData.dat{i,7},tableData.dat{i,8},tableData.dat{i,9},tableData.dat{i,10},tableData.dat{i,11},...
				tableData.dat{i,12});
		else
			formatString = ['%-010.3f%-010.3g',... 							%set-level
					'%-013.3f%-013.3f%-013.0f%-013.3f',...					%cluster-level
					'%-015.3f%-015.3f%-010.2f%-010.2f%-010.3f',...	%peak-level
					'% 5.0f% 5.0f% 5.0f',...												%location
          lineEnding];                        %lineEnding
			fprintf(fid, formatString,...
				tableData.dat{i,1},tableData.dat{i,2},...
				tableData.dat{i,3},tableData.dat{i,4},tableData.dat{i,5},tableData.dat{i,6},...
				tableData.dat{i,7},tableData.dat{i,8},tableData.dat{i,9},tableData.dat{i,10},tableData.dat{i,11},...
				tableData.dat{i,12});
		end		
  end %i=1:size(tableData.dat,1)

  %footer
	fprintf(fid,lineEnding);
	formatString=['%- 70s  %- 70s' lineEnding];
	
	fprintf(fid,formatString,tableData.ftr{1},tableData.ftr{6});
	fprintf(fid,formatString,tableData.ftr{2},tableData.ftr{7});
	fprintf(fid,formatString,tableData.ftr{3},tableData.ftr{8});
	fprintf(fid,formatString,tableData.ftr{4},tableData.ftr{9});
	fprintf(fid,formatString,tableData.ftr{5},tableData.ftr{10});
  
  try
    fclose(fid);
  catch
    beep();
    disp('Unable to close text file after writing');
  end
    sts = true;
return
  
return
