
PAnatomy = spm_get([0 1],'*.img','Pick the anatomy');

if length(PAnatomy) < 0
    return
end

PSOM     = spm_get([0 1],'*.img','Pick the SOM Image');

if length(PSOM) < 0
    return
end

SOMThreshold = spm_input('Threshold','+1','r',[0],1);

spm_figure('Create','Graphics');

Fgraph = spm_figure('FindWin','Graphics');
spm_results_ui('Clear',Fgraph);
spm_orthviews('Reset');

global st
st.Space = spm_matrix([0 0 0  0 0 -pi/2])*st.Space;

spm_orthviews('Image',PAnatomy);

spm_orthviews MaxBB;

%spm_orthviews('register',hReg);

VOL = spm_read_vols(spm_vol(PSOM));

XYZ = SOM_XYZ(PSOM);

VOLIDX = find(VOL>=SOMThreshold);
VOLZ = VOL(VOLIDX);
VOLXYZ = XYZ(:,VOLIDX);
VOLHDR = spm_vol(PSOM);

spm_orthviews('addblobs',1,VOLXYZ,VOLZ,VOLHDR.mat);

spm_orthviews('Redraw');
