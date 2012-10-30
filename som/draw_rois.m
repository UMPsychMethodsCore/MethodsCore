%
% add path to /Users/rcwelsh/matlabScripts/DrawObjects
%             .....SOM_V.../
%
nVoxels = [];
nRad = 0;
clear XYZ
XYZ = {};

radiusVoxels = [];
for iRad = 0:.05:5
    nRad = nRad + 1;
    XYZ{nRad}=SOM_MakeSphereROI(iRad)
    nVoxels=[nVoxels size(XYZ{nRad},2)]
    radiusVoxels = [radiusVoxels iRad];
end

unVoxels = unique(nVoxels);

for iVox = 1:length(unVoxels)
    idxRad = find(nVoxels == unVoxels(iVox));
    idxRad = idxRad(1);
    figure(iVox);
    cubes = {};
    for iCube = 1:size(XYZ{idxRad},2)
        cubes{iCube} = DO_Translate(cube1s,XYZ{idxRad}(1,iCube),XYZ{idxRad}(2,iCube),XYZ{idxRad}(3,iCube));
    end
    hold on;
    for iCube = 1:length(cubes)
        cubes{iCube}.edgecolor = [0 0 0];
        DO_Renderpatch(cubes{iCube});
    end
    axis off
    axis square
    view(35,45);
    title(sprintf('n Voxels : %d, Radius = %f',size(XYZ{idxRad},2),radiusVoxels(idxRad)),'fontweight','bold','fontsize',14);
    print('-dpng',sprintf('roi_n_%03d_%2.2f_radius.png',size(XYZ{idxRad},2),radiusVoxels(idxRad)));
end
