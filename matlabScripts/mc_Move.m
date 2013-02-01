function result = mc_Move(OldFileTemplate,NewFileTemplate)
    

    %take input file and target in Template form
    %evaluate in caller's scope and create target directory if necessary
    %then move file to target
    
    %actually need to evaluate these in caller
    
    FileName = evalin('caller',sprintf('mc_GenPath(struct(''Template'',''%s'',''mode'',''check''))',OldFileTemplate));
    TargetPath = evalin('caller',sprintf('mc_GenPath(struct(''Template'',''%s'',''mode'',''makeparentdir''))',NewFileTemplate));
    TargetFile = evalin('caller',sprintf('mc_GenPath(''%s'')',NewFileTemplate));
    
    try 
        result = java.io.File(FileName).renameTo(java.io.File(TargetFile));
        if (~result)
            throw(MException('mc_Move:Error','The file could not be moved'));
        end
    catch e
        try
            movefile(FileName,TargetFile);
        catch ee
            mc_Error(ee.message);
        end
    end