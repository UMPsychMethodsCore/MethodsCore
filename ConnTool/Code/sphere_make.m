function v = sphere_make(nPnts,nIter)

v = randn(nPnts,3);
v = SOM_UnitNormMatrix(v,2);

weight = 1/nPnts;

diff_vect = zeros(nPnts,nPnts,3);

for ii=1:nIter
    vdotv = v*v';
    dist = (acos(vdotv)).^2;
    v_rep_x = repmat(reshape(v,[nPnts,1,3]),[1,nPnts,1]);
    v_rep_y = repmat(reshape(v,[1,nPnts,3]),[nPnts,1,1]);
    diff_vect = cross(v_rep_x,cross(v_rep_x,v_rep_y,3),3);
    diff_vect = diff_vect./repmat(dist,[1,1,3]);
    diff_vect = weight*diff_vect;
    diff_vect(find(isnan(diff_vect))) = 0;
    v = SOM_UnitNormMatrix(v + squeeze(sum(diff_vect,2)),2);
end
