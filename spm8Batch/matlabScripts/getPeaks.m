function inds = getPeaks(data)
% function inds = getPeaks(data)
%
% identify peaks by identifying the points where the derivative crosses
% from positive to negative
%
% I recommend that the input data be really smooth

ddata = diff(data);
crossings = zeros(size(ddata));

for c=1:length(ddata)-1
    if ddata(c) > 0 & ddata(c+1)<0
        crossings(c) =1;
    end
end
inds = find(crossings);
return
    