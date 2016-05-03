function tempfile_name = create_unzipped_tempfile_in_directory(filename,directory)
	[path name ext] = fileparts(filename);
	
	tempfile_name = tempname(directory);
	
	if(strcmp('.gz',ext))
		[path real_name real_ext] = fileparts(name);
		tempfile_name = [tempfile_name real_ext ext];
		copyfile(filename, tempfile_name);
		gzipped_tempfile_name = tempfile_name;
		tempfile_name = gunzip(tempfile_name);
        tempfile_name = tempfile_name{1};
		delete(gzipped_tempfile_name);
	else
		tempfile_name = [tempfile_name ext];
		copyfile(filename, tempfile_name);
	end