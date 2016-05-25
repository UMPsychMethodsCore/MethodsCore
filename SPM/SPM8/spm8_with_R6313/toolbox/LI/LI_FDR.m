function [Tt] = LI_FDR(Timg,df,q)
% stripped-down function from Tom Nichols; see FDRill.m for details;
% modified by Marko Wilke to work for the LI-toolbox, with kind permission :)
%________________________________________________________________________
% @(#)LI_FDR.m	1.1 T. Nichols 02/07/02

V    = spm_vol(Timg);
T    = spm_read_vols(V); T=T(:); T(isnan(T))=[]; T(T==0)=[];

Tp   = 1-spm_Tcdf(T,df);
Tps  = sort(Tp);
iv   = (1:length(T))/length(T);
Tpt  = myFDR(Tp,q);
if isempty(Tpt)
  Tpt = NaN;
  Tt = NaN;
else
  Tt   = spm_invTcdf(1-Tpt,df);
end

function [pID,pN] = myFDR(p,q)
% !!pID - p-value threshold based on independence or positive dependence!!
% pN  - Nonparametric p-value threshold
%______________________________________________________________________________
% Based on FDR.m     1.4 Tom Nichols 02/07/02

p = sort(p(:));
V = length(p);
I = (1:V)';

cVID = 1;
cVN = sum(1./(1:V));

pID = p(max(find(p<=I/V*q/cVID)));
pN = p(max(find(p<=I/V*q/cVN)));

return