function [dynamicrange, fALFF] = icatb_get_spec_stats(s, f)
% Get spectral stats
%
[mv, ind]=max(s);
dynamicrange = max(s)-min(s(ind:end));
LF = find(f<0.1);
HF = find(f>0.15);
fALFF = trapz(f(LF),s(LF))/trapz(f(HF),s(HF));