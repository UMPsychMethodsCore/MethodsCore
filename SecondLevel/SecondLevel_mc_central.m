%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Second Level random effects script for SPM5 and SPM8
%%% Coded by Mike Angstadt
%%% 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% You shouldn't need to edit this script
%%% Instead refer to the directions and create a jobfile and scanfile
%%% to match your data setup.
%%% If you find bugs with this script, please contact
%%% mangstad@med.umich.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [jobs jobs2] = SecondLevel_mc_central(file)

    spm('defaults','fmri');
    global defaults;
    global options;
    
    options = [];
    options = parse_options(file,options);
    factorial_design = common(options);
    [options.models options.columns] = parse_scans(options.other);
    options.spmver = spm('Ver');
    if (strcmp(options.spmver,'SPM8')==1)
	    spm_jobman('initcfg');
	    spm_get_defaults('cmdline',true);
    end
    
    n = 1;
    n2 = 1;
    jobs = [];
    jobs2 = [];
    for N = 1:length(options.models)
        des = [];
        con.consess = [];
        models = options.models;
        columns = options.columns;
        
        if (options.models(N).include)
            if (isempty(options.models(N).outputpath) | strcmp(options.models(N).outputpath(end),'/'))
                %output path is empty or a folder, construct it from column headers
                options.models(N).outputpath = make_path(options.models(N),options.columns);
            end
        	desmtxcols = 0;
        switch (options.models(N).type)
		 case 1
          if options.other.ImColFlag == 1 % Assume only 1 description
              ImDes  = options.models(N).NumDes.ImDes;
          else
              ImDes  = options.columns(models(N).imagecolumn).description;
          end             
          des = t1(options.models(N),options.columns);
          con.consess{1}.tcon.name = [ImDes ' positive'];
          con.consess{1}.tcon.convec = [1];
          con.consess{1}.tcon.sessrep = 'none';
          con.consess{2}.tcon.name = [ImDes ' negative'];
          con.consess{2}.tcon.convec = [-1];
          con.consess{2}.tcon.sessrep = 'none';
          desmtxcols = 1;
		 case 2
		  [des m c] = t2(options.models(N),options.columns);
		  models(N) = m;
		  columns = c;
		  if (~strcmp(columns(models(N).factor(1).column).description,'') & ~isempty(strfind(columns(models(N).factor(1).column).description,' ')))
		      temp = textscan(columns(models(N).factor(1).column).description,'%s %s');
		      con.consess{1}.tcon.name = [temp{1}{1} ' > ' temp{2}{1}];
		      con.consess{2}.tcon.name = [temp{2}{1} ' > ' temp{1}{1}];
		  else
		      con.consess{1}.tcon.name = ['group 1 > group 2'];
		      con.consess{2}.tcon.name = ['group 2 > group 1'];
		  end
		  con.consess{1}.tcon.convec = [1 -1];
		  con.consess{1}.tcon.sessrep = 'none';
		  con.consess{2}.tcon.convec = [-1 1];
		  con.consess{2}.tcon.sessrep = 'none';
		  desmtxcols = 2;
		 case 3
          des = pt(options.models(N),options.columns);   
          if (options.other.ImColFlag ~= 1 && length(models(N).imagecolumn) > 1)
              con.consess{1}.tcon.name = [columns(models(N).imagecolumn(1)).description ' > ' columns(models(N).imagecolumn(2)).description];
              con.consess{2}.tcon.name = [columns(models(N).imagecolumn(2)).description ' > ' columns(models(N).imagecolumn(1)).description];
          elseif options.other.ImColFlag == 1 && length(options.models(N).NumDes) > 1
              con.consess{1}.tcon.name = [options.models(N).NumDes(1).ImDes ' > ' options.models(N).NumDes(2).ImDes];
              con.consess{2}.tcon.name = [options.models(N).NumDes(2).ImDes ' > ' options.models(N).NumDes(1).ImDes];
          elseif (length(models(N).pathcolumn) > 1)
              con.consess{1}.tcon.name = [columns(models(N).pathcolumn(1)).description ' > ' columns(models(N).pathcolumn(2)).description];
              con.consess{2}.tcon.name = [columns(models(N).pathcolumn(2)).description ' > ' columns(models(N).pathcolumn(1)).description];            
          else
              con.consess{1}.tcon.name = ['image 1 > image 2'];
              con.consess{2}.tcon.name = ['image 2 > image 1'];                 
          end
          % 9/14/2012 - fixed column order in contrasts for paired T-tests
          % due to change in SPM
          if (isfield(models(N),'reg'))
              %con.consess{1}.tcon.convec = [zeros(1,length(des.pt.pair)) zeros(1,size(models(N).reg,2)) 1 -1];
              con.consess{1}.tcon.convect = [1 -1 zeros(1,length(des.pt.pair)) zeros(1,size(models(N).reg,2))];
              con.consess{1}.tcon.sessrep = 'none';
              %con.consess{2}.tcon.convec = [zeros(1,length(des.pt.pair)) zeros(1,size(models(N).reg,2)) -1 1];
              con.consess{2}.tcon.convec = [-1 1 zeros(1,length(des.pt.pair)) zeros(1,size(models(N).reg,2))];
              con.consess{2}.tcon.sessrep = 'none';
          else
              %con.consess{1}.tcon.convec = [zeros(1,length(des.pt.pair)) 1 -1];
              con.consess{1}.tcon.convec = [1 -1 zeros(1,length(des.pt.pair))];
              con.consess{1}.tcon.sessrep = 'none';
              %con.consess{2}.tcon.convec = [zeros(1,length(des.pt.pair)) -1 1];
              con.consess{2}.tcon.convec = [-1 1 zeros(1,length(des.pt.pair))];
              con.consess{2}.tcon.sessrep = 'none';
          end
              desmtxcols = length(des.pt.pair);
		 case 4
		  des = mreg(options.models(N),options.columns);
		  cn = 1;
		  for r = 1:length(options.models(N).reg)
		      con.consess{cn}.tcon.name = [options.models(N).reg(r).name ' pos'];
		      con.consess{cn}.tcon.convec = [zeros(1,(r-1)) 1];
		      con.consess{cn}.tcon.sessrep = 'none';
		      cn = cn + 1;
		      con.consess{cn}.tcon.name = [options.models(N).reg(r).name ' neg'];
		      con.consess{cn}.tcon.convec = [zeros(1,(r-1)) -1];
		      con.consess{cn}.tcon.sessrep = 'none';
		      cn = cn + 1;
		  end
		  desmtxcols = length(options.models(N).reg);
		 case 5
		  des = fd(options.models(N),options.columns);
		  desmtxcols = size(des.fd.icell,2);
		 case 6
		  [des con des2] = fblock(options.models(N),options.columns);
		  desmtxcols = 1;
		end
		cov = covariates(options.models(N),options.columns,options.models(N).type);
		nc = size(cov,2);
		for c = 1:nc
			con.consess{end+1}.tcon.name = [cov(c).cname ' pos'];
			con.consess{end}.tcon.convec = [zeros(1,[desmtxcols + (c-1)]) 1 zeros(1,nc-c)];
			con.consess{end}.tcon.sessrep = 'none';
			con.consess{end+1}.tcon.name = [cov(c).cname ' neg'];
			con.consess{end}.tcon.convec = [zeros(1,[desmtxcols + (c-1)]) -1 zeros(1,nc-c)];
			con.consess{end}.tcon.sessrep = 'none';
        end
        FactorialDesignName = fullfile(options.other.OutputDir,options.models(N).outputpath);
        FactorialDesignCheck = struct('Template',FactorialDesignName,'mode','makedir');
        factorial_design.dir = {mc_GenPath(FactorialDesignCheck)};

		if (options.models(N).type == 6)
            mc_GenPath( struct('Template', fullfile(factorial_design.dir{1},'ME_Group'),...
                               'mode','makedir') );
			jobs2{n2}.stats{1}.factorial_design = factorial_design;
			jobs2{n2}.stats{1}.factorial_design.des = des2;
			jobs2{n2}.stats{1}.factorial_design.cov = [];
			jobs2{n2}.stats{1}.factorial_design.dir = {fullfile(factorial_design.dir{1},'ME_Group/')};
			jobs2{n2}.stats{2}.fmri_est.spmmat = {fullfile(factorial_design.dir{1},'ME_Group/SPM.mat')};
			jobs2{n2}.stats{2}.fmri_est.method.Classical = 1;
			job{1} = jobs2{n2};
			save(fullfile(job{1}.stats{1}.factorial_design.dir{1},'me_group.mat'),'job');
			n2 = n2 + 1;
		end
		con.spmmat = {fullfile(factorial_design.dir{1},'SPM.mat')};
		jobs{n}.stats{1}.factorial_design = factorial_design;
		jobs{n}.stats{1}.factorial_design.des = des;
		jobs{n}.stats{1}.factorial_design.cov = cov;
		jobs{n}.stats{2}.fmri_est.spmmat = {fullfile(factorial_design.dir{1},'SPM.mat')};
		jobs{n}.stats{2}.fmri_est.method.Classical = 1;
		jobs{n}.stats{3}.con = con;
		job{1} = jobs{n};
		save(fullfile(job{1}.stats{1}.factorial_design.dir{1},'second_level.mat'),'job');
		n = n + 1;
	end
    end
    if (strcmp(options.spmver,'SPM8')==1)
    	temp{1} = jobs;
    	temp{2} = jobs2;
        matlabbatch = spm_jobman('spm5tospm8',temp)
        spm_jobman('run',matlabbatch);
    else
    	spm_jobman('run',jobs);
    	spm_jobman('run',jobs2);
    end

function path = make_path(model,columns)
    global options;
	path = model.outputpath;
	switch (model.type)
		case 1
            if options.other.ImColFlag == 1
                ImDes = model.NumDes.ImDes;
            else
                ImDes = columns(model.imagecolumn).description;
            end
			path = strcat(path,columns(model.pathcolumn).description, '_', columns(model.factor(1).column).description, '_', ImDes);
		case 2	  
			if (~strcmp(columns(model.factor(1).column).description,'') & ~isempty(strfind(columns(model.factor(1).column).description,' ')))
				temp = textscan(columns(model.factor(1).column).description,'%s %s');
				grp1 = temp{1}{1};
				grp2 = temp{2}{1};
			else
				grp1 = 'Group1';
				grp2 = 'Group2';
            end
            if options.other.ImColFlag == 1
                ImDes = model.NumDes.ImDes;
            else
                ImDes = columns(model.imagecolumn).description;
            end
			path = strcat(path, columns(model.pathcolumn).description, '_', grp1, 'v', grp2, '_', ImDes);
		case 3            
			if (options.other.ImColFlag ~= 1 && length(model.imagecolumn) > 1)
				path = strcat(path, columns(model.pathcolumn).description, '_', columns(model.factor(1).column).description, '_', columns(model.imagecolumn(1)).description, 'v', columns(model.imagecolumn(2)).description);
            elseif option.other.ImColFlag == 1 && length(model.NumDes) > 1
                path = strcat(path, columns(model.pathcolumn).description, '_', columns(model.factor(1).column).description, '_', model.NumDes(1).ImDes, 'v', model.NumDes(2).ImDes);
			elseif (length(model.pathcolumn) > 1)        
				path = [path columns(model.pathcolumn(1)).description 'v' columns(model.pathcolumn(2)).description '_' columns(model.factor(1).column).description '_' columns(model.imagecolumn).description];
			else
				path = [path columns(model.pathcolumn).description '_' columns(model.factor(1).column).description '_' columns(model.imagecolumn).description];             
			end		
		case 4
            if options.other.ImColFlag == 1
                path = strcat(path, columns(model.pathcolumn).description, '_', columns(model.factor(1).column).description, '_', model.NumDes.ImDes);
            else
                path = [path columns(model.pathcolumn).description '_' columns(model.factor(1).column).description '_' columns(model.imagecolumn).description];
            end
		case 5
			path = [path 'Full_' columns(model.pathcolumn).description '_' model.factor(1).name ];
			for n = 2:size(model.factor,2)
				path = [path 'x' model.factor(n).name];
            end
            if options.other.ImColflag == 1
                path = strcat(path, '_', model.NumDes.ImDes);
            else
                path = [path '_' columns(model.imagecolumn).description];
            end
		case 6
			path = [path 'Flex_'];
			ng = max(columns(model.factor(1).column).data);
			if (ng > 1)
				path = [path model.factor(1).name 'x'];
			end
			path = [path model.withinnames{1}];
			for n = 2:size(model.withinnames,2)
				path = [path 'x' model.withinnames{n}];
			end
	end
	if (isfield(model,'reg'))
		for n = 1:size(model.reg,2)
			path = [path '_' model.reg(n).name];
		end
	end

function cov = covariates(model,columns,type)
    %global options;
    cov = struct('cname',{},'c',{},'iCC',{},'iCFI',{});
    if (model.type ~= 4)
        if (isfield(model,'reg'))
            for n = 1:length(model.reg)
                cov(n).cname = model.reg(n).name;
                cov(n).iCC = model.reg(n).iCC;
                cov(n).iCFI = model.reg(n).iCFI;
                switch (type)
                 case 1
                  cov(n).c = columns(model.reg(n).column).data(find(columns(model.factor(1).column).data));
                 case 2
                  cov(n).c = columns(model.reg(n).column).data(find(columns(model.factor(1).column).data==1));
                  cov(n).c = [cov(n).c; columns(model.reg(n).column).data(find(columns(model.factor(1).column).data==2))];
                 case 3
                  temp1 = columns(model.reg(n).column(1)).data(find(columns(model.factor(1).column).data));
                  temp2 = columns(model.reg(n).column(2)).data(find(columns(model.factor(1).column).data));
                  temp1 = temp1';
                  temp2 = temp2';
                  cov(n).c = reshape([temp1;temp2],1,[])';
                 case 4
                  cov(n).c = columns(model.reg(n).column).data(find(columns(model.factor(1).column).data));
                 case 5
                 	factmtx = [];
                 	for f = 1:size(model.factor,2)
                 		factmtx = [factmtx columns(model.factor(f).column).data];
                 	end
                 	[sortmtx idx] = sortrows(factmtx);
                 	cov(n).c = [];
                 	for s = 1:size(factmtx,1)
                 		if (sortmtx(s,1)>0)
                 			cov(n).c = [cov(n).c;columns(model.reg(n).column).data(idx(s))];
                 		end
                 	end
                 case 6
                  %not currently supported
                  
                end
            end
        end
    end
    
function [models columns] = parse_scans(options)
    %read in model job file
    fid = fopen(options.jobfile);
    n = 1;
    while 1
        line = fgetl(fid);
        if (~ischar(line))
            break;
        end
        line(end+1) = ',';
        temp = textscan(line,'%s','delimiter',',');
        joblist{n} = temp{1};
        n = n + 1;
    end
    fclose(fid);
    for n = 2:length(joblist)
        model(n-1).include = str2num(joblist{n}{1});
        model(n-1).type = str2num(joblist{n}{2});
        model(n-1).outputpath = joblist{n}{3};
        model(n-1).pathcolumn = str2num(joblist{n}{4});
        
        if options.ImColFlag == 1
            model(n-1).NumDes = ImColTokenizer(joblist{n}{5},model(n-1).type);
            model(n-1).imagecolumn = [];
        else
            model(n-1).imagecolumn = str2num(joblist{n}{5});
            model(n-1).NumDes = [];
        end
        
        %model(n-1).subjectrepl = str2num(joblist{n}{6});
        %model(n-1).withinnames = joblist{n}{6};
        model(n-1).withinnames = {};
        if (isempty(joblist{n}{6}))
        	model(n-1).withinnames{1} = joblist{n}{6};
        else
        	[model(n-1).withinnames{1} r] = strtok(joblist{n}{6});
        	while (~isempty(r))
        		[model(n-1).withinnames{end+1} r] = strtok(r);
        	end
        end
        col = 7;
        for x = 1:3
            offset = 6;
            if (size(joblist{n},1) >= col)
                if (~strcmp(joblist{n}{col},''))
                    model(n-1).factor(x).name = joblist{n}{col};
                    model(n-1).factor(x).column = str2num(joblist{n}{col+1});
                    if (model(n-1).type > 1)
                        if any(strcmp(joblist{1}{col+2},{'Indep','Dep'}))
                            model(n-1).factor(x).independent = str2num(joblist{n}{col+2});
                        else
                            model(n-1).factor(x).independent = 0;
                            offset = offset - 1;
                        end
                        if strcmp(joblist{1}{col+3},'Var')
                            model(n-1).factor(x).variance = str2num(joblist{n}{col+3});
                        else
                            model(n-1).factor(x).variance = 1;
                            offset = offset - 1;
                        end
                        if (strcmp(joblist{1}{col+4},'GMSCA'))
                        	model(n-1).factor(x).gmsca = str2num(joblist{n}{col+4});
                        else
                        	model(n-1).factor(x).gmsca = 0;
                        	offset = offset - 1;
                        end
                        if (strcmp(joblist{1}{col+5},'ANCOVA'))
                        	model(n-1).factor(x).ancova = str2num(joblist{n}{col+ 5});
                        else
                        	model(n-1).factor(x).ancova = 0;
                        	offset = offset - 1;
                        end
                    else
                        if ~any(strcmp(joblist{1}{col+2},{'Indep','Dep'}))
                            offset = offset - 1;
                        end
                        if ~strcmp(joblist{1}{col+3},'Var')
                            offset = offset - 1;
                        end
                        if (~strcmp(joblist{1}{col+4},'GMSCA'))
                            offset = offset - 1;
                        end
                        if (~strcmp(joblist{1}{col+5},'ANCOVA'))
                            offset = offset - 1;
                        end
                     end
                else
                    if ~any( strcmp(joblist{1}{col+2},{'Indep','Dep'}) )
                        offset = offset - 1;
                    end
                    if ~strcmp(joblist{1}{col+3},'Var')
                        offset = offset - 1;
                    end
                    if (~strcmp(joblist{1}{col+4},'GMSCA'))
                    	offset = offset - 1;
                    end
                    if (~strcmp(joblist{1}{col+5},'ANCOVA'))
                    	offset = offset - 1;
                    end
                end
            end
            col = col+offset;
        end
        
        x = 1;
        while size(joblist{n},1) >= col
            offset = 4;
            if (isempty(joblist{n}{col}))
                break;
            end
            model(n-1).reg(x).name = joblist{n}{col};
            model(n-1).reg(x).column = str2num(joblist{n}{col+1});
            
            if strcmp(joblist{1}{col+2},'iCFI')
                model(n-1).reg(x).iCFI = str2num(joblist{n}{col+2});
            else
                model(n-1).reg(x).iCFI = 1;
                offset = offset - 1;
            end
            
            if strcmp(joblist{1}{col+3},'iCC')
                model(n-1).reg(x).iCC = str2num(joblist{n}{col+3});
            else
                model(n-1).reg(x).iCC = 1;
                offset = offset - 1;
            end
            
            col = col + offset;
            x = x + 1;
        end
    end
    scanFileCheck = struct('Template',options.scanfile,'mode','check');
    mc_GenPath(scanFileCheck);
    fid = fopen(options.scanfile);
    n = 1;
    while 1
        line = fgetl(fid);
        if (~ischar(line))
            break;
        end
        line(end+1) = ',';
        temp = textscan(line,'%s','delimiter',',');
        scanlist{n} = temp{1};
        n = n + 1;
    end
    fclose(fid);
    for n = 1:length(scanlist{1})
        column(n).columntype = scanlist{1}{n};
        if (strcmp(column(n).columntype,'subject'))
            column(n).columntype = 'path';
        end
        column(n).description = scanlist{2}{n};
        column(n).data = [];
        for s = 3:length(scanlist)
            switch (column(n).columntype)
             case {'subject','path','wpath'}
              column(n).data = strvcat(column(n).data,scanlist{s}{n});
             case {'image','factor','subjectnum','cov','wfactors','wimage'}
              temp = str2num(scanlist{s}{n});
              column(n).data = vertcat(column(n).data,temp);
            end
        end
    end
    models = model;
    columns = column;
    
function des = t1(model,columns)
    global options;
    if options.other.ImColFlag == 1
        ImData = model.NumDes.ImNum;
    else
        ImData = columns(model.imagecolumn).data;
    end

    if (~strcmp(columns(model.factor(1).column).columntype,'factor'))
        error(['The type of column ' num2str(model.factor(1).column) 'does not match type factor']);        
    end
    if (~strcmp(columns(model.pathcolumn).columntype,'path'))
        error(['The type of column ' num2str(model.pathcolumn) 'does not match type path']);
    end
    if (options.other.ImColFlag ~= 1 && ~strcmp(columns(model.imagecolumn).columntype,'image'))
        error(['The type of column ' num2str(model.imagecolumn) 'does not match type image']);
    end
    images = get_images(columns(model.pathcolumn).data, ImData);
    scans{1} = [];
    for n = 1:length(columns(model.factor(1).column).data)
        if (columns(model.factor(1).column).data(n) == 1)
            if (isempty(scans{1}))
                scans{1} = images{n};
            else 
                scans{end+1} = images{n};
            end
        end
    end
    des.t1.scans = scans';
    
function [des model columns] = t2(model,columns)
    global options;
    if options.other.ImColFlag == 1
        ImData = model.NumDes.ImNum;
    else
        ImData = columns(model.imagecolumn).data;
    end

    if (size(model.factor(1).column,2)>1)
    	newcol = size(columns,2) + 1;
    	columns(newcol).columntype = 'factor';
    	columns(newcol).description = [columns(model.factor(1).column(1)).description ' ' columns(model.factor(1).column(2)).description];
    	columns(newcol).data = [columns(model.factor(1).column(1)).data + 2*columns(model.factor(1).column(2)).data];
    	model.factor(1).column = newcol;
    end
    if (~strcmp(columns(model.factor(1).column).columntype,'factor'))
        error(['The type of column ' num2str(model.factor(1).column) 'does not match type factor']);        
    end
    if (~strcmp(columns(model.pathcolumn).columntype,'path'))
        error(['The type of column ' num2str(model.pathcolumn) 'does not match type path']);
    end
    if (options.other.ImColFlag ~= 1 && ~strcmp(columns(model.imagecolumn).columntype,'image'))
        error(['The type of column ' num2str(model.imagecolumn) 'does not match type image']);
    end
    images = get_images(columns(model.pathcolumn).data, ImData);
    scan1{1} = [];
    scan2{1} = [];
    for n = 1:length(columns(model.factor(1).column).data)
        if (columns(model.factor(1).column).data(n) == 1)
            if (isempty(scan1{1}))
                scan1{1} = images{n};
            else 
                scan1{end+1} = images{n};
            end
        elseif (columns(model.factor(1).column).data(n) == 2)
            if (isempty(scan2{1}))
                scan2{1} = images{n};
            else 
                scan2{end+1} = images{n};
            end
        end
    end
    des.t2.scans1 = scan1';
    des.t2.scans2 = scan2';
    des.t2.dept = model.factor(1).independent;
    des.t2.variance = model.factor(1).variance;
    des.t2.gmsca = model.factor(1).gmsca;
    des.t2.ancova = model.factor(1).ancova;
    
function des = pt(model,columns)
    global options;
    if (~strcmp(columns(model.factor(1).column).columntype,'factor'))
        error(['The type of column ' num2str(model.factor(1).column) 'does not match type factor']);        
    end
    if (length(model.pathcolumn) > 1) 
        if (~strcmp(columns(model.pathcolumn(1)).columntype,'path'))
            error(['The type of column ' num2str(model.pathcolumn(1)) 'does not match type path']);
        end
        if (~strcmp(columns(model.pathcolumn(2)).columntype,'path'))
            error(['The type of column ' num2str(model.pathcolumn(2)) 'does not match type path']);
        end
        if (options.other.ImColFlag ~= 1 && ~strcmp(columns(model.imagecolumn).columntype,'image'))
            error(['The type of column ' num2str(model.imagecolumn) 'does not match type image']);
        end 
        type = 'path';
    elseif (options.other.ImColFlag ~= 1 && length(model.imagecolumn) > 1)
        if (~strcmp(columns(model.pathcolumn).columntype,'path'))
            error(['The type of column ' num2str(model.pathcolumn) 'does not match type path']);
        end
        if (~strcmp(columns(model.imagecolumn(1)).columntype,'image'))
            error(['The type of column ' num2str(model.imagecolumn(1)) 'does not match type image']);
        end         
        if (~strcmp(columns(model.imagecolumn(2)).columntype,'image'))
            error(['The type of column ' num2str(model.imagecolumn(2)) 'does not match type image']);
        end   
        type = 'image';
    elseif options.other.ImColFlag == 1
        if (~strcmp(columns(model.pathcolumn).columntype,'path'))
            error(['The type of column ' num2str(model.pathcolumn) 'does not match type path']);
        end
        type = 'image';
    else
        error(['Your paired samples T-test is not set up correctly. You need either 2 entries in the Path column or 2 entries in the Image column']);
    end
    switch (type)
     case 'path'
      if options.other.ImColFlag == 1
          images1 = get_images(columns(model.pathcolumn(1)).data,model.NumDes.ImNum);
          images2 = get_images(columns(model.pathcolumn(2)).data,model.NumDes.ImNum);
      else
          images1 = get_images(columns(model.pathcolumn(1)).data,columns(model.imagecolumn).data);
          images2 = get_images(columns(model.pathcolumn(2)).data,columns(model.imagecolumn).data);
      end
     case 'image'
      if options.other.ImColFlag == 1
          images1 = get_images(columns(model.pathcolumn).data,model.NumDes(1).ImNum);
          images2 = get_images(columns(model.pathcolumn).data,model.NumDes(2).ImNum);
      else
          images1 = get_images(columns(model.pathcolumn).data,columns(model.imagecolumn(1)).data);
          images2 = get_images(columns(model.pathcolumn).data,columns(model.imagecolumn(2)).data);
      end
    end
    pair = [];
    for n = 1:length(columns(model.factor(1).column).data)
        scans{1} = [];
        scans{2} = [];
        if (columns(model.factor(1).column).data(n) == 1)
            scans{1} = images1{n};
            scans{2} = images2{n};
            if (isempty(pair))
                pair(1).scans = scans';
            else
                pair(end+1).scans = scans';
            end
        end
    end
    des.pt.pair = pair;
    des.pt.dept = model.factor(1).independent;
    des.pt.variance = model.factor(1).variance;
    des.pt.gmsca = model.factor(1).gmsca;
    des.pt.ancova = model.factor(1).ancova;
    
function des = mreg(model,columns)
    global options;
    if (~strcmp(columns(model.factor(1).column).columntype,'factor'))
        error(['The type of column ' num2str(model.factor(1).column) 'does not match type factor']);        
    end
    if (~strcmp(columns(model.pathcolumn).columntype,'path'))
        error(['The type of column ' num2str(model.pathcolumn) 'does not match type path']);
    end
    if (options.other.ImColFlag ~= 1 && ~strcmp(columns(model.imagecolumn).columntype,'image'))
        error(['The type of column ' num2str(model.imagecolumn) 'does not match type image']);
    end
    
    if options.other.ImColFlag == 1
        images = get_images(columns(model.pathcolumn).data, model.NumDes.ImNum); % Assume only one image number
    else
        images = get_images(columns(model.pathcolumn).data, columns(model.imagecolumn).data);
    end
    
    scans{1} = [];
    for n = 1:length(columns(model.factor(1).column).data)
        if (columns(model.factor(1).column).data(n) == 1)
            if (isempty(scans{1}))
                scans{1} = images{n};
            else 
                scans{end+1} = images{n};
            end
        end
    end
    mcov = [];
    for n = 1:length(model.reg)
        mcov(n).cname = model.reg(n).name;
        mcov(n).iCC = model.reg(n).iCC;
        mcov(n).c = columns(model.reg(n).column).data(find(columns(model.factor(1).column).data));
    end
    des.mreg.scans = scans';
    des.mreg.mcov = mcov;
    
function des = fd(model,columns)
    global options;
    num_factors = length(model.factor);
    for n = 1:num_factors
        if (~strcmp(columns(model.factor(n).column).columntype,'factor'))
            error(['The type of column ' num2str(model.factor(n).column) 'does not match type factor']);        
        end
    end
    if (~strcmp(columns(model.pathcolumn).columntype,'path'))
        error(['The type of column ' num2str(model.pathcolumn) 'does not match type path']);
    end
    if (options.other.ImColFlag ~= 1 && ~strcmp(columns(model.imagecolumn).columntype,'image'))
        error(['The type of column ' num2str(model.imagecolumn) 'does not match type image']);
    end
    
    if options.other.ImColFlag == 1
        images = get_images(columns(model.pathcolumn).data, model.NumDes.ImNum);
    else
        images = get_images(columns(model.pathcolumn).data, columns(model.imagecolumn).data);
    end
    
    fact = [];
    for n = 1:num_factors
        fact(n).levels = max(columns(model.factor(n).column).data);
        fact(n).name = model.factor(n).name;
        fact(n).dept = model.factor(n).independent;
        fact(n).variance = model.factor(n).variance;
        fact(n).gmsca = model.factor(n).gmsca;
        fact(n).ancova = model.factor(n).ancova;
    end
    switch (num_factors)
     case 1
      cellnum = 1;
      for x = 1:fact(1).levels
          icell(cellnum).levels = [x];
          scan_num = find(columns(model.factor(1).column).data == x);
          for n = 1:length(scan_num)
              icell(cellnum).scans{n} = images{scan_num(n)};
          end
          icell(cellnum).scans = icell(cellnum).scans';
          cellnum = cellnum + 1;
      end
      
     case 2
      cellnum = 1;
      for x = 1:fact(1).levels
          for y = 1:fact(2).levels
              icell(cellnum).levels = [x;y];
              scan_num = intersect(find(columns(model.factor(1).column).data == x), find(columns(model.factor(2).column).data == y));
              for n = 1:length(scan_num)
                  icell(cellnum).scans{n} = images{scan_num(n)};
              end
              icell(cellnum).scans = icell(cellnum).scans';
              cellnum = cellnum + 1;
          end
      end
      
     case 3
      cellnum = 1;
      for x = 1:fact(1).levels
          for y = 1:fact(2).levels
              for z = 1:fact(3).levels
                  icell(cellnum).levels = [x;y;z];
                  scan_num = intersect(intersect(find(columns(model.factor(1).column).data == x), find(columns(model.factor(2).column).data == y)),find(columns(model.factor(3).column).data == z));
                  for n = 1:length(scan_num)
                      icell(cellnum).scans{n} = images{scan_num(n)};
                  end
                  icell(cellnum).scans = icell(cellnum).scans';
                  cellnum = cellnum + 1;
              end
          end
      end
      
    end
    des.fd.fact = fact;
    des.fd.icell = icell;

function [specall con icell] = get_within_images3(model,columns)
	global options;
	
	%always 1 between (grouping) and 1 within factor for SPM
	%since SPM can only deal with 3 factors, and the first is subject
	
	between = columns(model.factor(1).column).data;
	[y idx] = sort(between);
	include = [];
	for i = 1:size(idx,1)
		if (between(idx(i)) ~= 0)
			include = [include;idx(i)];
		end
	end
	scans = {};
    
    if options.other.ImColFlag == 1
        for s=1:size(include,1) %loop over included subject rows
            for p1=1:size(model.pathcolumn,1) % loop over paths
                for p2=1:size(model.pathcolumn,2)
                    for i1=1:size(model.NumDes.ImNum,1)
                        for i2=1:size(model.NumDes.ImNum,2)
                            VecImNum = repmat(model.NumDes.ImNum(i1,i2),length(between),1);
                            p = columns(model.pathcolumn(p1,p2)).data(include(s),:);
                            i = VecImNum(include(s));
                            ImName = fullfile(options.other.MainDir,deblank(p),options.other.ModelDir,[options.other.ContrastPrefix '_' sprintf('%04d',i) options.other.InputImgExt]);
                            ImNameCheck = struct('Template',ImName,'mode','check');
                            ImName = mc_GenPath(ImNameCheck);
                            scans{end+1} = strcat(ImName,',1');
                        end
                    end
                end
            end
        end
    else                
        for s = 1:size(include,1) %loop over included subject rows
            for p1 = 1:size(model.pathcolumn,1) %loop over paths
                for p2 = 1:size(model.pathcolumn,2)
                    for i1 = 1:size(model.imagecolumn,1) %loop over images
                        for i2 = 1:size(model.imagecolumn,2)
                            p = columns(model.pathcolumn(p1,p2)).data(include(s),:);
                            i = columns(model.imagecolumn(i1,i2)).data(include(s));
                            ImName = fullfile(options.other.MainDir,deblank(p),options.other.ModelDir,[options.other.ContrastPrefix '_' sprintf('%04d',i) options.other.InputImgExt]);
                            ImNameCheck = struct('Template',ImName,'mode','check');
                            ImName = mc_GenPath(ImNameCheck);
                            scans{end+1} = strcat(ImName,',1');
                        end
                    end
                end
            end
        end
    end
    
	n = size(include,1);
	ng = size(unique(between(include)),1);
	for i = 1:ng
		npg(i) = sum(between(include)==i);
    end
	m = p1 * p2 * i1 * i2;
	repl = [1:(n*m)]';
    repl = ones(1,n*m)';
	group = [];
	for g = 1:ng
		group = [group;g*ones(1,m*npg(g))'];
	end
	subj = [];
	within = [];
	for s = 1:n
		for w = 1:m
			subj = [subj;s];
			within = [within;w];
		end
	end
	mtx = [repl subj group within];
	specall.scans = scans;
	specall.imatrix = mtx;
	
	%auto calculate average image per subject for use in full factorial anova
	icell = [];
	if (ng > 1)
        meg_outputdir = fullfile(options.other.OutputDir,model.outputpath,'ME_Group');
        MegOutputDirCheck = struct('Template',meg_outputdir,'mode','makedir');
        meg_outputdir = {mc_GenPath(MegOutputDirCheck)};
		
		numlevels = max(columns(model.factor(1).column).data);
		for l = 1:numlevels
			icell(l).levels = l;
			icell(l).scans = {};
		end
		for s = 1:n
			offset = (s-1)*m;
			[a b c d] = fileparts(scans{offset+1});
			%jobs{s}.util{1}.imcalc.output = ['me_group_' cell2mat(model.withinnames) '.img'];
			%jobs{s}.util{1}.imcalc.outdir = {a};
			jobs{s}.util{1}.imcalc.output = ['me_group' strrep(strrep(strrep(a,options.other.MainDir,''),options.other.ModelDir,''),'/','_') '.img'];
			jobs{s}.util{1}.imcalc.outdir = meg_outputdir;
			jobs{s}.util{1}.imcalc.expression = 'mean(X)';
			jobs{s}.util{1}.imcalc.options.dmtx = 1;
			jobs{s}.util{1}.imcalc.options.mask = 0;
			jobs{s}.util{1}.imcalc.options.interp = 1;
			jobs{s}.util{1}.imcalc.options.dtype = 4;
			for c = 1:m
				jobs{s}.util{1}.imcalc.input{c} = scans{offset+c};
			end
			%icell(mtx(offset+s,3)).scans{end+1} = fullfile(a,['me_group_' cell2mat(model.withinnames) '.img']);
			icell(mtx(offset+1,3)).scans{end+1} = fullfile(meg_outputdir{1},jobs{s}.util{1}.imcalc.output);
		end
		for l = 1:numlevels
			icell(l).scans = icell(l).scans';
		end
		if (strcmp(options.spmver,'SPM8')==1)
		    	temp{1} = jobs;
		        matlabbatch = spm_jobman('spm5tospm8',temp)
		        spm_jobman('run',matlabbatch);
		else
		    	spm_jobman('run',jobs);
		end
	end
	
	%main effect of group (for interaction calculation only, not used for testing)
	if (ng > 1)
		nc = ng*m;
		meg = [];
		for g = 1:ng-1
			meg{g} = [zeros(1,(m*(g-1))) ones(1,m) -1*ones(1,m) zeros(1,(nc-(2*m)-(m*(g-1)))) zeros(1,n)];
		end
	end
	
	wf = 0;
	withinfactors = {};
	m = [];
	if (size(model.pathcolumn,1)>1)
		wf = wf + 1;
		withinfactors{end+1}.name = model.withinnames{wf};
		withinfactors{end}.levels = size(model.pathcolumn,1);
		m = [m size(model.pathcolumn,1)];
	end
	if (size(model.pathcolumn,2)>1)
		wf = wf + 1;
		withinfactors{end+1}.name = model.withinnames{wf};
		withinfactors{end}.levels = size(model.pathcolumn,2);
		m = [m size(model.pathcolumn,2)];
	end
	if options.other.ImColFlag ~= 1 && (size(model.imagecolumn,1)>1)
		wf = wf + 1;	
		withinfactors{end+1}.name = model.withinnames{wf};
		withinfactors{end}.levels = size(model.imagecolumn,1);
		m = [m size(model.imagecolumn,1)];
    elseif options.other.ImColFlag == 1 && (size(model.NumDes.ImNum,1)>1)
        wf = wf + 1;
        withinfactors{end+1}.name = model.withinnames{wf};
        withinfactors{end}.levels = size(model.NumDes.ImNum,1);
        m = [m size(model.NumDes.ImNum,1)];
	end
	if options.other.ImColFlag ~= 1 && (size(model.imagecolumn,2)>1)
		wf = wf + 1;
		withinfactors{end+1}.name = model.withinnames{wf};
		withinfactors{end}.levels = size(model.imagecolumn,2);	
		m = [m size(model.imagecolumn,2)];
    elseif options.other.ImColFlag == 1 && (size(model.NumDes.ImNum,2)>1)
        wf = wf + 1;
        withinfactors{end+1}.name = model.withinnames{wf};
        withinfactors{end}.levels = size(model.NumDes.ImNum,2);
        m = [m size(model.NumDes.ImNum,2)];
    end
	connum = 1;

	%main effect of within
	mtx = recurse_loop([],m,zeros(1,size(m,2)),[]);
	for y = 1:size(mtx,2)
		consess{connum}.fcon.name = ['Main Effect of ' withinfactors{y}.name];
		consess{connum}.fcon.sessrep = 'none';
		consess{connum}.fcon.convec = {};
		for z = 1:size(mtx{y},1)
			mtx{y}{z} = [repmat(mtx{y}{z},1,ng) zeros(1,n)];
			consess{connum}.fcon.convec{z} = mtx{y}{z};
		end
		connum = connum + 1;
	end

	nf = size(m,2);
	if (ng > 1)
		nf = nf + 1;
	end
	
	%2-way interactions
	if (nf > 1)
		%with group
		if (ng > 1)
			for y = 1:size(mtx,2)
				consess{connum}.fcon.name = ['Interaction of ' model.factor(1).name ' x ' withinfactors{y}.name];
				consess{connum}.fcon.sessrep = 'none';
				consess{connum}.fcon.convec = {};
				for r1 = 1:size(meg,2)
					for r2 = 1:size(mtx{y},1)
						consess{connum}.fcon.convec{end+1} = meg{r1} .* mtx{y}{r2};
					end
				end
				connum = connum + 1;
			end
		end
		%with other within factors
		for y1 = 1:size(mtx,2)
			for y2 = y1:size(mtx,2)
				if (y1 ~= y2)
					consess{connum}.fcon.name = ['Interaction of ' withinfactors{y1}.name ' x ' withinfactors{y2}.name];
					consess{connum}.fcon.sessrep = 'none';
					consess{connum}.fcon.convec = {};
					for r1 = 1:size(mtx{y1},1)
						for r2 = 1:size(mtx{y2},1)
							consess{connum}.fcon.convec{end+1} = mtx{y1}{r1} .* mtx{y2}{r2};
						end
					end
					connum = connum + 1;
				end
			end
		end
	end
	
	%3-way interactions
	if (nf > 2)
		%with group
		if (ng > 1)
			for y1 = 1:size(mtx,2)
				for y2 = y1:size(mtx,2)
					if (y1 ~= y2)
						consess{connum}.fcon.name = ['Interaction of ' model.factor(1).name ' x ' withinfactors{y1}.name ' x ' withinfactors{y2}.name];
						consess{connum}.fcon.sessrep = 'none';
						consess{connum}.fcon.convec = {};
						for r1 = 1:size(meg,2)
							for r2 = 1:size(mtx{y1},1)
								for r3 = 1:size(mtx{y2},1)
									consess{connum}.fcon.convec{end+1} = meg{r1} .* mtx{y1}{r2} .* mtx{y2}{r3};
								end
							end
						end
						connum = connum + 1;
					end
				end
			end
		end
		%with other within factors
		for y1 = 1:size(mtx,2)
			for y2 = y1:size(mtx,2)
				for y3 = y2:size(mtx,2)
					if (y1 ~= y2 & y1 ~= y3 & y2 ~= y3)
						consess{connum}.fcon.name = ['Interaction of ' withinfactors{y1}.name ' x ' withinfactors{y2}.name ' x ' withinfactors{y3}.name];
						consess{connum}.fcon.sessrep = 'none';
						consess{connum}.fcon.convec = {};
						for r1 = 1:size(mtx{y1},1)
							for r2 = 1:size(mtx{y2},1)
								for r3 = 1:size(mtx{y3},1)
									consess{connum}.fcon.convec{end+1} = mtx{y1}{r1} .* mtx{y2}{r2} .* mtx{y3}{r3};
								end
							end
						end
						connum = connum + 1;
					end
				end
			end
		end
	end
	
	%4-way interactions
	if (nf > 3)
		%with group
		if (ng > 1)
			for y1 = 1:size(mtx,2)
				for y2 = y1:size(mtx,2)
					for y3 = y2:size(mtx,2)
						if (y1 ~= y2 & y1 ~= y3 & y2 ~= y3)
							consess{connum}.fcon.name = ['Interaction of ' model.factor(1).name ' x ' withinfactors{y1}.name ' x ' withinfactors{y2}.name ' x ' withinfactors{y3}.name];
							consess{connum}.fcon.sessrep = 'none';
							consess{connum}.fcon.convec = {};
							for r1 = 1:size(meg,2)
								for r2 = 1:size(mtx{y1},1)
									for r3 = 1:size(mtx{y2},1)
										for r4 = 1:size(mtx{y3},1)
											consess{connum}.fcon.convec{end+1} = meg{r1} .* mtx{y1}{r2} .* mtx{y2}{r3} .* mtx{y3}{r4};
										end
									end
								end
							end
							connum = connum + 1;
						end
					end
				end
			end
		end
		%with other within factors
		for y1 = 1:size(mtx,2)
			for y2 = y1:size(mtx,2)
				for y3 = y2:size(mtx,2)
					for y4 = y3:size(mtx,2)
						if (y1 ~= y2 & y1 ~= y3 & y1 ~= y4 & y2 ~= y3 & y2 ~= y4 & y3 ~= y4)
							consess{connum}.fcon.name = ['Interaction of ' withinfactors{y1}.name ' x ' withinfactors{y2}.name ' x ' withinfactors{y3}.name ' x ' withinfactors{y4}.name];
							consess{connum}.fcon.sessrep = 'none';
							consess{connum}.fcon.convec = {};
							for r1 = 1:size(mtx{y1},1)
								for r2 = 1:size(mtx{y2},1)
									for r3 = 1:size(mtx{y3},1)
										for r4 = 1:size(mtx{y4},1)
											consess{connum}.fcon.convec{end+1} = mtx{y1}{r1} .* mtx{y2}{r2} .* mtx{y3}{r3} .* mtx{y4}{r4};
										end
									end
								end
							end
							connum = connum + 1;
						end
					end
				end
			end
		end
	end
	
	%stopping there for now until I make a better solution
	con.consess = consess;
	con.delete = 0;

function [des con des2] = fblock(model,columns)
	num_between = length(model.factor);
	[specall con icell] = get_within_images3(model,columns);
	fac(1).name = 'subject';
	fac(1).dept = 0;
	fac(1).variance = 0;
	fac(1).gmsca = 0;
	fac(1).ancova = 0;
	maininters{1}.fmain.fnum = 1;
	fac(2).name = model.factor(1).name;
	fac(2).dept = model.factor(1).independent;
	fac(2).variance = model.factor(1).variance;
	fac(2).gmsca = 0;
	fac(2).ancova = 0;
	fsuball.specall = specall;
	fac(3).name = 'within';
	fac(3).dept = 1;
	fac(3).variance = 0;
	fac(3).gmsca = 0;
	fac(3).ancova = 0;
	maininters{2}.inter.fnums = [2 3]';
	
	des.fblock.fac = fac;
	des.fblock.fsuball = fsuball;
    des.fblock.maininters = maininters;

%currently hardcoded, need to improve
	num_factors = 1;
	fact = [];
	for n = 1:num_factors
		fact(n).levels = max(columns(model.factor(n).column).data);
		fact(n).name = model.factor(n).name;
		fact(n).dept = model.factor(n).independent;
		fact(n).variance = model.factor(n).variance;
		fact(n).gmsca = model.factor(n).gmsca;
		fact(n).ancova = model.factor(n).ancova;
	end

	des2.fd.fact = fact;
	des2.fd.icell = icell;	
    
function images = get_images(p,i)
    global options;
    for n=1:size(p,1)
        subject = strtrim( p(n,:) );
        imageName = strcat(options.other.ContrastPrefix,'_',sprintf('%04d',i(1)),options.other.InputImgExt);
        imageCheck.Template = fullfile(options.other.MainDir,subject,options.other.ModelDir,imageName);
        imageCheck.mode = 'check';
        image = mc_GenPath(imageCheck);
        images{n} = strcat(image,',1');
    end
    images = images';
    
function factorial_design = common(options)
    %factorial_design.cov = options.cov;
    factorial_design.masking = options.masking;
    factorial_design.globalc = options.globalc;
    factorial_design.globalm = options.globalm;
    %factorial_design.dir = options.dir;
    
function options = parse_options(file,opt)
    if (isstr(file))
	    eval(strrep(file,'.m',''));
	    if (exist('cov'))

	    end
	    if (exist('masking'))
		if (isfield(masking,'tm'))
		    if (isfield(masking.tm,'tm_none'))
			opt.masking.tm.tm_none = [];
		    end
		    if (isfield(masking.tm,'tma'))
			opt.masking.tm.tma.athresh = masking.tm.tma.athresh;
		    end
		    if (isfield(masking.tm,'tmr'))
			opt.masking.tm.tmr.rthresh = masking.tm.tmr.rthresh;
		    end
		end
		if (isfield(masking,'im'))
		    opt.masking.im = masking.im;
		end
		if (isfield(masking,'em'))
		    opt.masking.em = {masking.em};
		end
	    end
	    if (exist('globalc'))
		if (isfield(globalc,'g_omit'))
		    opt.globalc.g_omit = [];
		end
		if (isfield(globalc,'g_user'))
		    opt.globalc.g_user.global_uval = globalc.g_user.global_uval;
		end
		if (isfield(globalc,'g_mean'))
		    opt.globalc.g_mean = [];
		end
	    end
	    if (exist('globalm'))
		if (isfield(globalm,'gmsca'))
		   if (isfield(globalm.gmsca,'gmsca_no'))
		       opt.globalm.gmsca.gmsca_no = [];
		   end
		   if (isfield(globalm.gmsca,'gmsca_yes'))
		       opt.globalm.gmsca.gmsca_yes.gmscv = globalm.gmsca.gmsca_yes.gmscv;
		   end
		end
		if (isfield(globalm,'glonorm'))
		    opt.globalm.glonorm = globalm.glonorm;
		end
	    end
	    %if (exist('dir'))
		%opt.dir = {dir};
	    %end
	    if (exist('other'))
		opt.other = other;
	    end
	    options = opt;
    else
        if ~isfield(file.other,'ImColFlag')
            file.other.ImColFlag = 0;
        end
        
        if isfield(file.other,'InputImgExt')
            if ~any( strcmp(file.other.InputImgExt,{'.nii','.img'}) )

                mc_Error(['Warning: Invalid opt.other.InputImgExt\n',...
                          'Expected ''.nii'' or ''.img'', but found %s\n',...
                          ' * * * A B O R T I N G * * *\n'],file.other.InputImgExt);
                      
            end
        else
            file.other.InputImgExt = '.img';
        end
	    options = file;
    end
     
function mtx = recurse_loop(mtx, n, m, d)
	if (isempty(mtx))
		for x = 1:size(n,2)
			mtx{x} = cell(n(x)-1,1);
		end
	end
	if (isempty(d))
		d = 1;
	end
	for x = 1:n(d)
		m(d) = x;
		if (d < size(m,2))
			mtx = recurse_loop(mtx,n,m, d+1);
		end
		if (d == size(m,2))
			for y = 1:size(mtx,2)
				for r = 1:n(y)-1
					if (m(y) == r)
						mtx{y}{r} = [mtx{y}{r} 1];
					elseif (m(y) == r+1)
						mtx{y}{r} = [mtx{y}{r} -1];
					else
						mtx{y}{r} = [mtx{y}{r} 0];
					end
				end
			end
		end
    end
    
function TheTokens = ImColTokenizer(input,type)
%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% ImColTokenizer
%
% A routine that parses the 'ImCol' column in the job file when ImColFlag =
% 1.
%
% Call as :
%
%   function TheTokens = ImColtokenizer(input)
%
% To Make this work you need to provide the following input:
%
%   input = a string that adheres to the following syntax:
%            1. Descriptions are optional
%            2. Descriptions are always followed by a ':' -- whitespace is
%               ignored
%            3. Image numbers are mandotory
%            4. If type == 3, either both image numbers are missing their
%               descriptions or both have their descriptions
%            5. No descriptions should be present for type == 6
%            Examples: 'asdf:1'
%                      '1 2'
%                      'asdf:1 qwerty:2'
%   type = the model type
%
% Output
%
%   TheTokens = an array of Token structures
%
% Return structures
%
%   struct NumDes {
%                   array double ImNum;
%                   string ImDes;
%                  };
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
NumDes = struct('ImNum',[],'ImDes','');
input  = strtrim(input);

if isempty(type)
    TheTokens = NumDes;
    return;
end

switch type
    case {1, 2, 4, 5}
        ColonLoc = regexp(input,':');
        if length(ColonLoc) == 0
            NumDes.ImNum = str2num(input);
        elseif length(ColonLoc) == 1
            NumDes.ImDes = strtrim( input(1:ColonLoc-1) );
            NumDes.ImNum = str2num( input(ColonLoc+1:end) );
        else
            error(['\nWarning: Invalid ImCol syntax: %s\n'...
                   '   * * * A B O R T I N G * * * \n'],input);
        end
    case {3} % PairedSamplesT
        ColonLoc = regexp(input,':');
        if length(ColonLoc) == 0
            Spaces = regexp(input,' ');
            if isempty(Spaces) % Only one image number
                NumDes.ImNum = str2num(input);
            else               % Two image numbers
                NumDes2 = NumDes;
                NumDes.ImNum = str2num( input(1:Spaces(1)-1) );
                NumDes2.ImNum = str2num( input(Spaces(end)+1:end) );
                NumDes = [NumDes NumDes2];
            end
        elseif length(ColonLoc) == 1 % Only supports when 1 image number is present, otherwise things will break
            NumDes.ImDes = strtrim( input(1:ColonLoc-1) );
            NumDes.ImNum = str2num( input(ColonLoc+1:end) );
        elseif length(ColonLoc) == 2
            Spaces  = regexp(input,' ');
            NumDes2 = NumDes;
            NumDes.ImDes = strtrim( input(1:ColonLoc(1)-1) );
            NumDes.ImNum = str2num( input(ColonLoc(1)+1:Spaces(1)-1) );
            NumDes2.ImDes = strtrim( input(Spaces(end)+1:ColonLoc(2)-1) );
            NumDes2.ImNum = str2num( input(ColonLoc(2)+1:end) );
            NumDes = [NumDes NumDes2];
        else
            error(['\nWarnig: Invalid ImCol syntax: %s\n'...
                   'Too many '':'' in argument\n'...
                   '   * * * A B O R T I N G * * *\n'],input);
        end
    case {6} % Flexible factorial, header is not used
        NumDes.ImNum = str2num(input);
    otherwise
        error(['\nUnknown model type\n'...
               '   * * * A B O R T I N G * * *\n'],[]);
end
TheTokens = NumDes;
    

    
    
    
    
    
    
    
    
    
    
