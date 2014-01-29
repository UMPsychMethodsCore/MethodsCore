function SOM_Texturizer(results_initial, results_supercluster)

%not gonna work with a grid
if ~isfield(results_initial,'v2')
  fprintf('Did not run for a sphere!')
  return
end

%texturize the sphere with the given vertices... still needs some cleaning up...
[b,v,t] = texturizer_v4(results_initial.v2);

%vertex colors are determined by which cluster they belong to
y = results_supercluster.IDX';

%draw the overly-graphically-intensive spheres
sphere_hist;
