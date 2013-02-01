function s = mc_Copy(FileTemplate,TargetTemplate)
% A utility function to copy files.  This function will resolve mc_GenPath
% style template variables and create the target folder if necessary.
% FORMAT mc_Copy(FileTemplate,TargetTemplate);
% 
% FileTemplate      A string with the full path for the file to copy.  This 
%                   can use mc_GenPath style templates or can be a simple
%                   path.
%
% TargetTemplate    A string with the full path of the target file. This
%                   can use mc_GenPath style templates or can be a simple
%                   path.
%

    
    %take input file and target in Template form
    %evaluate in caller's scope and create target directory if necessary
    %then copy file to target
    
    FileName = evalin('caller',sprintf('mc_GenPath(struct(''Template'',''%s'',''mode'',''check''))',FileTemplate));
    TargetPath = evalin('caller',sprintf('mc_GenPath(struct(''Template'',''%s'',''mode'',''makeparentdir''))',TargetTemplate));
    TargetFile = evalin('caller',sprintf('mc_GenPath(''%s'')',TargetTemplate));
    
    [s m] = copyfile(FileName,TargetFile);
    
    if (~s)
        mc_Error(m);
    end
    