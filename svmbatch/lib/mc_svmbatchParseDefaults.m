function out = mc_svmbatchParseDefaults(Opt)

if(~isfield(Opt,'svmlib'))
    Opt.svmlib=1;
end

if(~isfield(Opt,'matrixtype'))
    Opt.matrixtype='upper';
end

if (~isfield(Opt,'ztrans'))
    Opt.ztrans = 0;
end

if (~isfield(Opt,'binarize'))
    Opt.binarize = 0;
end

if (~isfield(Opt,'DataType'))
    Opt.DataType = 'Matrix';
end

%disable visualization if using 3D mode
if (isfield(Opt,'DataType') && strcmp(Opt.DataType,'3D'))
    Opt.Vizi = 0;
end
