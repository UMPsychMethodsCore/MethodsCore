function spmversion = wfu_get_ver
%  spmversion = wfu_get_ver
%
%  Outputs in standardized form the SPM version as:
%  [] (empty), SPM99, SPM2, SPM5, SPM8

  %standardize output to all upper
  availableVersions = {'SPM99' 'SPM2' 'SPM5' 'SPM8'};

  try
    spmversion = spm('Ver', [], 1);
  catch
    spmversion = [];
  end
  
  spmversion = availableVersions(find(strcmpi(spmversion,availableVersions)));
  spmversion = char(spmversion); %type conversion (cell=>char)
  
  if ~isempty(spmversion) && ~any(strcmpi(spmversion, availableVersions))
      imStr = wfu_implode(availableVersions,', ');
      error('Returned SPM version ** %s ** is not one of { %s }', spmversion, imStr);
  end
return

