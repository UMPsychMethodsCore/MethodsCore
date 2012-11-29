function [PMP,R] = pmp_process(inputdir,voifile,pmpfile)
%***This script is currently EXPERIMENTAL and should not*** 
%***yet be used to generate results for publication***
%FORMAT [PMP,R] = pmp_process(inputdir,voifile,pmpfile)
%   PMP        - output PMP structure
%      .Y      - Original Seed data
%      .P{n}   - 1xN cell array of Psychological regressors 
%                (1 for each condition)
%      .pmp{n} - 1xN cell array of psychophysio interaction regressors 
%                (1 for each condition)
%   R          - output matrix to use in SPM5/8 Multiple Regressors option
%                dimensions will be MxN where M is the number of timepoints 
%                in your task and N is (# Conditions)*2+1 (condition 
%                regressors first, then an interaction regressor for each 
%                condition, and finally the seed timeseries
%   inputdir   - Directory containing subject's SPM and VOI files
%   voifile    - Name of VOI file to get Seed data from
%   pmpfile    - Output name for PMP file to save
%
%Created 8/3/2010 by Mike Angstadt

spmfile = ['SPM.mat'];

p = load([inputdir '/' voifile]);

load([inputdir '/SPM.mat']);

RT = SPM.xY.RT;
dt = SPM.xBF.dt;
NT = RT/dt;
%%%Added to correct for slice time reference slice per SPM8
fMRI_T0 = SPM.xBF.T0;

xY(1) = p.xY;
Sess = SPM.Sess(xY(1).Sess);

%condition names, and includes, and weights (not needed since we'll include all at weight 1)
U.name = {};
U.u = [];
U.w = [];

u = length(Sess.U);
for i = 1:u
	for j = 1:length(Sess.U(i).name)
		U.w = [U.w 1];
		U.u = [U.u Sess.U(i).u(33:end,j)];
		U.name{end+1} = Sess.U(i).name{j};
	end
end

N = length(xY(1).u);
k = 1:NT:N*NT; % microtime to scan time indices

hrf = spm_hrf(dt);

%create convolved explanatory {Hxb} variables in scan time -- what?
xb = spm_dctmtx(N*NT + 128,N);
Hxb = zeros(N,N);
for i = 1:N
	Hx = conv(xb(:,i),hrf);
	Hxb(:,i) = Hx(k+128);
end
xb = xb(129:end,:);

%get confounds (in scan time) and constant term
X0 = xY(1).X0;
M = size(X0,2);

%get response variable
for i = 1:size(xY,2)
	Y(:,i) = xY(i).u;
end

%remove confounds and save Y in output structure
Yc = Y-X0*inv(X0'*X0)*X0'*Y;
PMP.Y = Yc(:,1);
if size(Y,2) == 2
	PMP.P = Yc(:,2);
end

%specify covariance components; assume neuronal response is white
%treating confounds as fixed effects
Q = speye(N,N)*N/trace(Hxb'*Hxb);
Q = blkdiag(Q,speye(M,M)*1e6);

%get whitening matrix (NB: confounds have already been whitened)
W = SPM.xX.W(Sess.row,Sess.row);

%create structure for spm_PEB
P{1}.X = [W*Hxb X0];
P{1}.C = speye(N,N)/4;
P{2}.X = sparse(N+M,1);
P{2}.C = Q;

% COMPUTE PSYCHOPHYSIOLOGIC INTERACTIONS
% use basis set in microtime
%---------------------------------------------------------------------
% get parameter estimates and neural signal; beta (C) is in scan time
% This clever trick allows us to compute the betas in scan time which is
% much quicker than with the large microtime vectors. Then the betas
% are applied to a microtime basis set generating the correct neural
% activity to convolve with the psychological variable in mircrotime
%---------------------------------------------------------------------
C  = spm_PEB(Y,P);
xn = xb*C{2}.E(1:N);
xn = spm_detrend(xn);

% setup psychological variable from inputs and contast weights (DON'T need weights, all 1)
%multiply psychological variables by neural signal
%convolve and resample at each scan for bold signal
%---------------------------------------------------------------------
%PSY = zeros(N*NT,1);
j = size(U.u,2) + 1;
for i = 1:size(U.u,2)
	PSY{i} = full(U.u(:,i));
	PSYxn{i} = PSY{i}.*xn;
	PSYHRF{i} = conv(PSY{i},hrf);
	%%%fixed to correct for slice time reference slice per SPM8
	PSYHRF{i} = PSYHRF{i}((k-1)+fMRI_T0);
	pmp{i} = conv(PSYxn{i},hrf);
	%%%fixed to correct for slice time reference slice per SPM8
	pmp{i} = pmp{i}((k-1)+fMRI_T0);
	pmp{i} = spm_detrend(pmp{i});
	R(:,i) = PSYHRF{i};
	R(:,j) = pmp{i};
	j = j + 1;
end

R(:,j) = PMP.Y;

% save psychological variables
%---------------------------------------------------------------------
PMP.psy = U;
PMP.P   = PSYHRF;
PMP.xn  = xn;
PMP.pmp = pmp;

PMP.xY = xY;
PMP.dt = dt;

save(fullfile(inputdir,['PMP_' pmpfile]),'PMP','R');

%save in a format that can be read by Multiple Regressors in SPM5