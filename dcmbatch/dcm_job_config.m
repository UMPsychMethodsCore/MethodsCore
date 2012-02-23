% %%
% %define variables for function
% %name of output structure of DCM
% DCM_name='DCM.mat';
% %path of SPM matrix and VOI matrices
% data_path='datapath';
% 
% %a: driving, b: modulatory, c: connectivity
% load allDCM.mat;
% a = allDCM{1,1};
% b = allDCM{3,1};
% c = allDCM{2,1};
% 
% %voi names
% VOI_name={'voi1.mat';'voi2.mat';'voi3.mat';'voi4.mat';'voi5.mat'};


%--------------------------------------------------------------------------
%---------                  function begins here            ---------------
%This function generates a structure called DCM which contains the
%information of the whole DCM matrix including all of the nodes and driving inputs. Inforamtion
%includes RT, X0, node name, onsets of each driving input, etc.
%The inputs are: 1.data_path: where your SPM.mat, VOI.mat are, also where the output .mat is going to be saved
%2.a, b, c: driving, modulatory and connectivity matrices
%3.VOI_name: a cell array contains the names of each VOI(node) .mat
%The output matrix DCM is saved into a .mat file. The output matrix can be
%reached either through directly run the function and get DCM or by loading
%the .mat file
%--------------------------------------------------------------------------
function DCM=dcm_job_config(data_path, a, b, c, VOI_name)

[nnodes, ndriv]=size(a);

%specify SPM
load(fullfile(data_path,'SPM.mat'),'SPM');

%specify VOIs
for i=1:nnodes
load(fullfile(data_path,VOI_name{i}),'xY');
DCM.xY(i) = xY;
end

DCM.n = length(DCM.xY);      % number of regions
DCM.v = length(DCM.xY(1).u); % number of time points

DCM.Y.dt  = SPM.xY.RT;          %RT
DCM.Y.X0  = DCM.xY(1).X0;       %X0
%specify each node's info
for i = 1:DCM.n
    DCM.Y.y(:,i)  = DCM.xY(i).u;
    DCM.Y.name{i} = DCM.xY(i).name;
end

%covariance constraint error
DCM.Y.Q    = spm_Ce(ones(1,DCM.n)*DCM.v);

%dt and name
DCM.U.dt   =  SPM.Sess.U(1).dt;
DCM.U.name = [SPM.Sess.U.name];

%u: onsets
DCM.U.u = [];
for i=1:ndriv
DCM.U.u    = [DCM.U.u, SPM.Sess.U(i).u(33:end,1)];
end

%delays and TE
DCM.delays = repmat(SPM.xY.RT,DCM.n,1);
DCM.TE     = 0.04;

%options
DCM.options.nonlinear  = 0;
DCM.options.two_state  = 0;
DCM.options.stochastic = 0;
DCM.options.nograph    = 1;

%DCM a: drving, b: modulatory, c: connectivity
DCM.a = a;
DCM.b = b;
DCM.c = c;
DCM.d = zeros(DCM.n,DCM.n,0);

save(fullfile(data_path,DCM_name), 'DCM');
end


