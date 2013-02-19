Exp = '/home/slab/users/mangstad/testdata/';
LogTemplate = '[Exp]/Logs';

ImageTemplate = '[Exp]/[Subject]/func/[Run]/';  

basefile = 'run';

imagetype = 'nii';

TR = 2;

RunDir = {
	'run_01/';
    'run_02/';
};

SubjDir = {
      'testsub',1,[1 2];
};

SliceTimePrefix = 'a';
RealignPrefix = 'r';
CoregOverlayPrefix = '';
CoregHiResPrefix = '';
NormalizePrefix = 'w2_';
SmoothPrefix = 's6_';

StepsToDo = [1 1 1 1 1 1];

AlreadyDone = [0 0 0 0 0 0];

OverlayTemplate = '[Exp]/[Subject]/anatomy/ht1overlay.nii';
HiResTemplate =    '[Exp]/[Subject]/anatomy/ht1spgr.nii';

AnatTemplate = '[Exp]/[Subject]/func/coReg/';

NormMethod = 'seg';

WarpTemplate = '[mcRoot]/SPM/SPM8/spm8_with_R4667/templates/EPI.nii';

NumSlices = 30; 

SliceOrder = [1:1:NumSlices];

RefSlice = [];

RefImage = [15];

VoxelSize = [2 2 2];

SmoothingKernel = 6;

UseSandbox = 1;
SandboxDir = '/home/slab/users/mangstad/testdata/sandbox/';

NumScan = [];

spmdefaults = {
};


global mcRoot;
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'Preprocess'));
%addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'))
addpath('/net/dysthymia/MethodsCore/matlabScripts');
addpath('/net/dysthymia/MethodsCore/SPM/SPM8/spm8_with_R4667');

Preprocess_mc_central
