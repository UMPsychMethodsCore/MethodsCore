function status = saveClusterLabelToText(handles,table,clusterNumber,filename,rwType)
% status = saveClusterLabelToText(handles,table,clusterNumber,filename,rwType)
%
% wfu_results internal function
%
% handles is from wfu_results
% table is from clusterStats
% clusterNumber prints in the header for each section (for example when used by whole brain label) 
% filename is the file to write to
% rwType is either 'new' or 'append' to filename
% status is true if operation is good (written data), or false otherwise
  status=false;

	switch lower(rwType)
		case 'new'
			try
				fid = fopen(filename,'w');
			catch
				beep();                                                                
				disp(sprintf('Unable to open %s for writing', filename));              
				return;                                                                
			end
		case 'append'
			try
				fid = fopen(filename,'a');
			catch
				beep();                                                                
				disp(sprintf('Unable to open %s for appending', filename));              
				return;                                                                
			end
		otherwise
			beep();
			disp(sprintf('Unknown operation: %s for writting file',rwType));
			return;
	end

	%title
	if isempty(clusterNumber)
		titleText=sprintf('Cluster Statistics and Labels:  Cluster with peak at (%g %g %g)',table.peak.MNI);
	else
		titleText=sprintf('Cluster %i\nStatistics and Labels:  Cluster with peak at (%g %g %g)',clusterNumber, table.peak.MNI);
	end

	fprintf(fid,['%s' handles.data.lineEnding],titleText);

	%Cluster Stats
	fprintf(fid,['Voxels in cluster: %- 15i Peak T: %- 15.4f Mean T: %- 15.4f Std T: %- 15.4f' handles.data.lineEnding],...
		table.voxels,table.max,table.mean,table.std);

	fprintf(fid,handles.data.lineEnding);

	%Region Stats
	fprintf(fid, ['\t%- 30s %- 30s %- 40s %- 10s %- 10s %- 10s' handles.data.lineEnding],...
		char(table.headers(1)),char(table.headers(2)),char(table.headers(3)),char(table.headers(4)),char(table.headers(5)),char(table.headers(6)));
	
	%column Locations
	stringFormat=['\t%- 30s %- 30s %- 40s%- 10i %- 10.4f %- 10.4f' handles.data.lineEnding]; %removed space between 3rd and 4th element to preserve alignment (weird)
	
	if isfield(table,'data')
		for i=1:size(table.data,1)
%might can use later.
%			if isempty(table.data{i,1})
%				fontWeightDesc='normal';
%			else
%				fontWeightDesc='Bold';
%			end
			fprintf(fid,stringFormat,...
				strtrim(table.data{i,1}),strtrim(table.data{i,2}),strtrim(table.data{i,3}),...
				table.data{i,4},table.data{i,5},table.data{i,6});
		end
		fprintf(fid,handles.data.lineEnding);
		fprintf(fid,handles.data.lineEnding);
	else
		fprintf(fid,['Voxel not found in atlas(es).' handles.data.lineEnding]);
  end

  try
    fclose(fid);
  end

	status=true;


return