function reply = wfu_eval(wfu_params,field)
reply = [];
if isfield(wfu_params,field), reply = getfield(wfu_params,field); end;
return
