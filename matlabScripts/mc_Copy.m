function s = mc_Copy(FileTemplate,TargetTemplate)
    

    %take input file and target in Template form
    %evaluate in caller's scope and create target directory if necessary
    %then copy file to target
    
    %actually need to evaluate these in caller
    
    FileName = evalin('caller',sprintf('mc_GenPath(struct(''Template'',''%s'',''mode'',''check''))',FileTemplate));
    TargetPath = evalin('caller',sprintf('mc_GenPath(struct(''Template'',''%s'',''mode'',''makeparentdir''))',TargetTemplate));
    TargetFile = evalin('caller',sprintf('mc_GenPath(''%s'')',TargetTemplate));
    
    [s m] = copyfile(FileName,TargetFile);
    
    if (~s)
        mc_Error(m);
    end
    