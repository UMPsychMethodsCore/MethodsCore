function  [dataname,bitdepth] = wfu_datatype2name(datatype)
dataname=wfu_spm_type(datatype);
bitdepth=wfu_spm_type(datatype,'bits');


