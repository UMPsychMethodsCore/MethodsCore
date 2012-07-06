function [regressors betanames] = cppi_CreateRegressors(roiTC,parameters)

betanames = [];
load(parameters.cppi.SPM);
roiTC = SPM.xX.W*roiTC; %applying whitening matrix from SPM model
roiTC = spm_filter(SPM.xX.K,roiTC); %filter here with SPM filter, or use Robert's filter in preprocessing?

RT = SPM.xY.RT;
dt = SPM.xBF.dt;
NT = RT/dt;
fMRI_T0 = SPM.xBF.T0;

regressors = [];
offset = 0;
for iRun = 1:size(SPM.Sess,2)
    roiTCtemp = roiTC(1+offset:parameters.data.run(iRun).nTimeAnalyzed+offset,:);
    offset = offset + parameters.data.run(iRun).nTimeAnalyzed;
    %calculate confounds
    xY.X0 = SPM.xX.xKXs.X(:,[SPM.xX.iB SPM.xX.iG]);
    xY.X0 = xY.X0(SPM.Sess(iRun).row,:);
    xY.X0 = [xY.X0 SPM.xX.K(iRun).X0];
    xY.X0 = xY.X0(:,any(xY.X0));

    [m n] = size(roiTCtemp);
    if m>n
        [v s v] = svd(roiTCtemp'*roiTCtemp);
        s = diag(s);
        v = v(:,1);
        u = roiTCtemp*v/sqrt(s(1));
    else
        [u s u] = svd(roiTCtemp*roiTCtemp');
        s = diag(s);
        u = u(:,1);
        v = roiTCtemp'*u/sqrt(s(1));
    end
    d = sign(sum(v));
    u = u*d;
    v = v*d;
    Y = u*sqrt(s(1)/n);
    roiTCtemp = Y;
    
    Sess = SPM.Sess(iRun);

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

    N = length(roiTCtemp);
    k = 1:NT:N*NT; % microtime to scan time indices

    hrf = spm_hrf(dt);

    %create convolved explanatory {Hxb} variables in scan time
    xb = spm_dctmtx(N*NT + 128,N);
    Hxb = zeros(N,N);
    for i = 1:N
        Hx = conv(xb(:,i),hrf);
        Hxb(:,i) = Hx(k+128);
    end
    xb = xb(129:end,:);

    %get confounds (in scan time) and constant term
    X0 = xY.X0;
    M = size(X0,2);

    Y = roiTCtemp;

    %remove confounds and save Y in output structure
    Yc = Y-X0*inv(X0'*X0)*X0'*Y;
    PMP.Y = Yc(:,1);

    %specify covariance components; assume neuronal response is white
    %treating confounds as fixed effects
    Q = speye(N,N)*N/trace(Hxb'*Hxb);
    Q = blkdiag(Q,speye(M,M)*1e6);

    %get whitening matrix (NB: confounds have already been whitened)
    W = SPM.xX.W(Sess.row,Sess.row);

    %create structure for spm_PEB
    clear P
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
        PSYHRF{i} = PSYHRF{i}((k-1)+fMRI_T0);
        pmp{i} = conv(PSYxn{i},hrf);
        pmp{i} = pmp{i}((k-1)+fMRI_T0);
        pmp{i} = spm_detrend(pmp{i});
        R(:,i) = PSYHRF{i};
        R(:,j) = pmp{i};
        betanames2{i} = ['Run ' num2str(iRun) ' ' U.name{i}];
        betanames2{j} = ['Run ' num2str(iRun) ' ' U.name{i} ' x Seed interaction'];
        j = j + 1;
    end

    R(:,j) = PMP.Y;
    betanames2{j} = ['Run ' num2str(iRun) ' Seed'];
    %if (parameters.RegressFLAGS.Motion)
    %    R = [R parameters.data.run(iRun).MotionParameters];
    %end
    betanames = [betanames betanames2];
    regressors = [regressors; R];
end

return;

