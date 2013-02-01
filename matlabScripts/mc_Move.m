function result = mc_Move(OldFileTemplate,NewFileTemplate)
% A utility function to move files.  This function will resolve mc_GenPath
% style template variables and create the target folder if necessary. It
% attempts to use java in MATLAB for a faster move command, but if it fails
% it will fall back to the slower movefile function.
% FORMAT mc_Move(FileTemplate,TargetTemplate);
% 
% FileTemplate      A string with the full path for the file to move.  This 
%                   can use mc_GenPath style templates or can be a simple
%                   path.
%
% TargetTemplate    A string with the full path of the target file. This
%                   can use mc_GenPath style templates or can be a simple
%                   path.
%    

    %take input file and target in Template form
    %evaluate in caller's scope and create target directory if necessary
    %then move file to target
    
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