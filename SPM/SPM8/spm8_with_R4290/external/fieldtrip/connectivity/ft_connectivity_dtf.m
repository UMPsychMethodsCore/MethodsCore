function [dtf, dtfvar, n] = ft_connectivity_dtf(input, varargin)

hasjack = keyval('hasjack', varargin{:}); if isempty(hasjack), hasjack = 0; end
powindx = keyval('powindx', varargin{:});
% FIXME build in feedback
% FIXME build in proper documentation
% FIXME build in dDTF etc

siz    = size(input);
n      = siz(1);
ncmb   = siz(2);
outsum = zeros(siz(2:end));
outssq = zeros(siz(2:end));

if isempty(powindx)
  % data are represented as chan_chan_therest
  for j = 1:n
    tmph   = reshape(input(j,:,:,:,:), siz(2:end));
    den    = sum(abs(tmph).^2,2);
    tmpdtf = abs(tmph)./sqrt(repmat(den, [1 siz(2) 1 1 1]));
    outsum = outsum + tmpdtf;
    outssq = outssq + tmpdtf.^2;
    %tmp    = outsum; tmp(2,1,:,:) = outsum(1,2,:,:); tmp(1,2,:,:) = outsum(2,1,:,:); outsum = tmp;
    %tmp    = outssq; tmp(2,1,:,:) = outssq(1,2,:,:); tmp(1,2,:,:) = outssq(2,1,:,:); outssq = tmp;
    % FIXME swap the order of the cross-terms to achieve the convention such that
    % labelcmb {'a' 'b'} represents: a->b
  end
else
  % data are linearly indexed
  sortindx = [0 0 0 0];
  for k = 1:ncmb
    iauto1  = find(sum(cfg.powindx==cfg.powindx(k,1),2)==2);
    iauto2  = find(sum(cfg.powindx==cfg.powindx(k,2),2)==2);
    icross1 = k;
    icross2 = find(sum(cfg.powindx==cfg.powindx(ones(ncmb,1)*k,[2 1]),2)==2);
    indx    = [iauto1 icross2 icross1 iauto2];
    
    if isempty(intersect(sortindx, sort(indx), 'rows')),
      sortindx = [sortindx; sort(indx)];
      for j = 1:n
        tmph    = reshape(input(j,indx,:,:), [2 2 siz(3:end)]);
        den     = sum(abs(tmph).^2,2);
        tmpdtf  = reshape(abs(tmph)./sqrt(repmat(den, [1 2 1 1])), [4 siz(3:end)]);
        outsum(indx,:) = outsum(indx,:) + tmpdtf([1 3 2 4],:);
        outssq(indx,:) = outssq(indx,:) + tmpdtf([1 3 2 4],:).^2;
        % FIXME swap the order of the cross-terms to achieve the convention such that
        % labelcmb {'a' 'b'} represents: a->b
      end
    end
  end
end
dtf = outsum./n;

if n>1, %FIXME this is strictly only true for jackknife, otherwise other bias is needed
  if hasjack,
    bias = (n - 1).^2;
  else
    bias = 1;
  end
  dtfvar = bias.*(outssq - (outsum.^2)/n)./(n-1);
else
  dtfvar = [];
end
