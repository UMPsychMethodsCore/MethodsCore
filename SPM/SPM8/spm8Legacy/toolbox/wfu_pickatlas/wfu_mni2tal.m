function outpoints = wfu_mni2tal(inpoints)
% Converts coordinates from MNI brain to best guess
% for equivalent Talairach coordinates
% FORMAT outpoints = mni2tal(inpoints)
% Where inpoints is N by 3 or 3 by N matrix of coordinates
%  (N being the number of points)
% outpoints is the coordinate matrix with Talairach points
% Matthew Brett 10/8/99

dimdim = find(size(inpoints) == 3);
if isempty(dimdim)
  error('input must be a N by 3 or 3 by N matrix')
end
if dimdim == 2
  inpoints = inpoints';
end

% Transformation matrices, different zooms above/below AC
upT = wfu_spm_matrix([0 0 0 0.05 0 0 0.99 0.97 0.92]);
downT = wfu_spm_matrix([0 0 0 0.05 0 0 0.99 0.97 0.84]);

tmp = inpoints(3,:)<0;  % 1 if below AC
inpoints = [inpoints; ones(1, size(inpoints, 2))];
inpoints(:, tmp) = downT * inpoints(:, tmp);
inpoints(:, ~tmp) = upT * inpoints(:, ~tmp);
outpoints = inpoints(1:3, :);
if dimdim == 2
  outpoints = outpoints';
end


%Incidentally, if you use the above transform, and you want to cite it, 
%I suggest that you cite this web address. The transform is also mentioned briefly in the following paper: 
%Duncan, J., Seitz, R.J., Kolodny, J., Bor, D., Herzog, H., Ahmed, A., Newell, F.N., Emslie, H. 
%"A neural basis for General Intelligence", Science (21 July 2000), 289 (5478), 457-460. 
%http://www.mrc-cbu.cam.ac.uk/Imaging/mnispace.html
%
%This algorithm gave me the following transformations: 
%Above the AC (Z >= 0): 
%
%X'= 0.9900X 
%
%Y'= 0.9688Y +0.0460Z 
%
%Z'= -0.0485Y +0.9189Z 
%
%Below the AC (Z < 0): 
%
%X'= 0.9900X 
%
%Y'= 0.9688Y +0.0420Z 
%
%Z'= -0.0485Y +0.8390Z 



