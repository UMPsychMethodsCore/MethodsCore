function c = cooler(m)

if nargin < 1, m = size(get(gcf,'colormap'),1); end
r = (0:m-1)'/max(m-1,1);

% c = [r zeros(m,1) 1-r]; %for cooler colormap


c = [1-r r ones(m,1)]; %for cool colormap
