function out = mc_BaseVars2Struct()
WSVARS = evalin('base','who');
for wscon=1:size(WSVARS,1)
    if ~strcmpi(WSVARS{wscon},'WSVARS') && ~strcmpi(WSVARS{wscon},'wscon')
        thisvar=evalin('caller',WSVARS{wscon});
        out.(WSVARS{wscon})=thisvar;
    end
end
