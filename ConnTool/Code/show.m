function [out, newim] = show(a,windfact)
% usage .. show(a,f);
% displays matrix "a" as a greyscale image in the matlab window
% and "f" is the optional window factors [min,max]

if exist('windfact') == 0, 
  amin = min(min(a));
  amax = max(max(a));
  minmax = [amin,amax];
  a = (a  - amin);
  disp(['min/max= ',num2str(minmax(1)),' / ',num2str(minmax(2))]);
else
  amin = windfact(1);
  amax = windfact(2);
  a = (a  - amin);
  a = a .* (a > 0);
end

colormap(gray);
out=image((a)./(amax-amin).*64);
newim=(a)./(amax-amin).*64;
sfact=1/64*(amax-amin);
axis('image');
axis('on');
% grid on;

