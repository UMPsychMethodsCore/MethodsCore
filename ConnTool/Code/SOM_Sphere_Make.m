% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh, Ben Kempke
% Copyright 2005-09
%
% function [v diff_vect_h] = sphere_make(nPnts,nIter,plotOpt)
%
% Input : 
% 
%     nPnts - number of charges on the surface
%     nIter - number of iterations to minimize the energy
%     plotOpt - option to plot the iterations - plotOpt = figure#
% 
% Output : 
%
%     v    - locations of the points on the sphere
%     diff_vect_h = total summed distance that the points move.
%
% Calculate the locations of som examplar on the sphere surface.
% Do this by minimizing the mutual Coulomb iteraction on the surface.
%
%  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [vn v thetav phiv diff_vect_h p3h] = SOM_Sphere_Make(nPnts,nIter,plotOpt)

if exist('plotOpt') == 0
    plotOpt = 0;
end

if isnumeric(plotOpt) == 0
    plotOpt = 0;
end

if round(plotOpt) ~= plotOpt
    plotOpt = 0;
end

v = randn(nPnts,3);
v = SOM_UnitNormMatrix(v,2);

% Put one on the pole and stick it there!

v(1,:) = [0 0 1];

vn = v;

thetav = [];
phiv   = [];
diff_vect_h = [];
p3h    = [];

if nPnts < 2
    return
end

weight = 1/nPnts;

diff_vect = zeros(nPnts,nPnts,3);

diff_vect_h = [];

% This code fails if two charges are randomly assigned to the same space!

if plotOpt > 0
    figure(plotOpt)
    hold off;
    subplot(211);
    hold off;
    sphere(40);
    hold on;
    p3h = plot3(v(:,1),v(:,2),v(:,3),'bo');
    set(p3h,'markerfacecolor','b');
    drawnow
end

for ii=1:nIter
    vdotv = v*v';
    % Potential energy is 1/r;
    dist = (acos(vdotv));
    v_rep_x = repmat(reshape(v,[nPnts,1,3]),[1,nPnts,1]);
    v_rep_y = repmat(reshape(v,[1,nPnts,3]),[nPnts,1,1]);
    diff_vect = cross(v_rep_x,cross(v_rep_x,v_rep_y,3),3);
    diff_vect = diff_vect./repmat(dist,[1,1,3]);
    diff_vect = weight*diff_vect;
    diff_vect(find(isnan(diff_vect))) = 0;
    v_pert = squeeze(sum(diff_vect,2));
    diff_vect_h = [diff_vect_h sum(sum(sqrt(v_pert.*v_pert),2))];
    % the charge on the pole stays!   
    v(2:end,:) = SOM_UnitNormMatrix(v(2:end,:) + v_pert(2:end,:),2);
    if plotOpt > 0
        figure(plotOpt)
        subplot(211)
        set(p3h,'xdata',v(:,1),'ydata',v(:,2),'zdata',v(:,3));
        %p3h = plot3(v(:,1),v(:,2),v(:,3),'b.');
        drawnow
        subplot(223);
        semilogy(diff_vect_h);
        drawnow;
        subplot(224);
        bar(sum(sqrt(v_pert.*v_pert),2));
        drawnow;
    end
end

% Now we can sort them and number as they spiral away from the top of there sphere
% to the bottom of the sphere.

thetav = acos(v(:,3));
phiv   = atan2(v(:,2),v(:,1));
ip = find(phiv)< 0;
phiv(ip) = phiv(ip) + 2*pi;

vn = sortrows([v thetav phiv],[ 4 5]);

%
% All done
%
