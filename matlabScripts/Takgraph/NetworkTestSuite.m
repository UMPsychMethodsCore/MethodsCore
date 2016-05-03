% This script should let you test your scripts to make sure they're working appropriately

nROI = 1080;
feat = mc_flatten_upper_triangle(random('binom',2, .01,nROI)+1);
nets = round(rand(1,1080)* 14);

a1.NetworkLabels = nets;
a1.values = feat;

%% Restructure Your Features
a2 = mc_Network_FeatRestruct(a1);

%% Count your cells
a3 = mc_Network_CellCount(a2);

%% Generate a fake permutation results

perms = round(rand(15,15,1e4)*7e3);
a3.perms = perms;

a3.stats.FDR.Enable = 1;
a3.stats.FDR.NetIn = [3 4 7 1];

%% Calculate CellLevel Statistics

a4 = mc_Network_CellLevelStats(a3);


%% Enlarge dots

a4.DotDilateMat = [1 0; % cross
                   -1 0;
                   0 1;
                   0 -1; ];
                   
a5 = mc_TakGraph_enlarge(a4);

%% Plot Edges and Cell Boundaries


a6 = mc_TakGraph_plot(a5);

%% Calculate Shading Color

a7 = mc_TakGraph_CalcShadeColor(a6);



%% Let's assume we have it. We'll need to know what color to make each cell
a7.shading.shademask = zeros(15);
a7.shading.shademask(2,2) = 1;
a7.shading.shademask(3,7) = 1;

% Add the shading
a8 = mc_TakGraph_AddShading(a7);
