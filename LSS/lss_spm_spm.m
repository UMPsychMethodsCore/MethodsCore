function [SPM allbetas allQ] = lss_spm_spm(SPM)
%spm_spm code

SVNid     = '$Rev: 3960 $';

allbetas = [];
allQ = [];

%-Say hello
%--------------------------------------------------------------------------
SPMid     = spm('FnBanner',mfilename,SVNid);
Finter    = spm('FigName','Stats: estimation...'); spm('Pointer','Watch');
 
%-Change to SPM.swd if specified
%--------------------------------------------------------------------------
try
    cd(SPM.swd);
catch
    SPM.swd = pwd;
end
 
%-Ensure data are assigned
%--------------------------------------------------------------------------
try
    SPM.xY.VY;
catch
    spm('alert!','Please assign data to this design', mfilename);
    spm('FigName','Stats: done',Finter); spm('Pointer','Arrow')
    return
end

%==========================================================================
% - A N A L Y S I S   P R E L I M I N A R I E S
%==========================================================================
 
%-Initialise
%==========================================================================
fprintf('%-40s: %30s','Initialising parameters','...computing');        %-#
xX            = SPM.xX;
[nScan nBeta] = size(xX.X);

%-If xM is not a structure then assume it's a vector of thresholds
%--------------------------------------------------------------------------
try
    xM = SPM.xM;
catch
    xM = -Inf(nScan,1);
end
if ~isstruct(xM)
    xM = struct('T',    [],...
                'TH',   xM,...
                'I',    0,...
                'VM',   {[]},...
                'xs',   struct('Masking','analysis threshold'));
end
 
%-Check confounds (xX.K) and non-sphericity (xVi)
%--------------------------------------------------------------------------
if ~isfield(xX,'K')
    xX.K  = 1;
end
try
    %-If covariance components are specified use them
    %----------------------------------------------------------------------
    xVi   = SPM.xVi;
catch
 
    %-otherwise assume i.i.d.
    %----------------------------------------------------------------------
    xVi   = struct( 'form',  'i.i.d.',...
                    'V',     speye(nScan,nScan));
end

%-Get non-sphericity V
%==========================================================================
try
    %-If xVi.V is specified proceed directly to parameter estimation
    %----------------------------------------------------------------------
    V     = xVi.V;
    str   = 'parameter estimation';
 
catch
    
    % otherwise invoke ReML selecting voxels under i.i.d assumptions
    %----------------------------------------------------------------------
    V     = speye(nScan,nScan);
    str   = '[hyper]parameter estimation';
end
 
%-Get whitening/Weighting matrix: If xX.W exists we will save WLS estimates
%--------------------------------------------------------------------------
try
    %-If W is specified, use it
    %----------------------------------------------------------------------
    W     = xX.W;
catch
    
    if isfield(xVi,'V')
 
        % otherwise make W a whitening filter W*W' = inv(V)
        %------------------------------------------------------------------
        W     = spm_sqrtm(spm_inv(xVi.V));
        W     = W.*(abs(W) > 1e-6);
        xX.W  = sparse(W);
        
    else
        % unless xVi.V has not been estimated - requiring 2 passes
        %------------------------------------------------------------------
        W     = speye(nScan,nScan);
        str   = 'hyperparameter estimation (1st pass)';
    end
end
 
%-Design space and projector matrix [pseudoinverse] for WLS
%==========================================================================
xX.xKXs   = spm_sp('Set',spm_filter(xX.K,W*xX.X));       % KWX
xX.xKXs.X = full(xX.xKXs.X);
xX.pKX    = spm_sp('x-',xX.xKXs);                        % projector
erdf      = spm_SpUtil('trRV',xX.xKXs);                  % Working error df
 
%-If xVi.V is not defined compute Hsqr and F-threshold under i.i.d.
%--------------------------------------------------------------------------
if ~isfield(xVi,'V')
    
    Fcname = 'effects of interest';
    iX0    = [SPM.xX.iB SPM.xX.iG];
    xCon   = spm_FcUtil('Set',Fcname,'F','iX0',iX0,xX.xKXs);
    X1o    = spm_FcUtil('X1o', xCon(1),xX.xKXs);
    Hsqr   = spm_FcUtil('Hsqr',xCon(1),xX.xKXs);
    trRV   = spm_SpUtil('trRV',xX.xKXs);
    trMV   = spm_SpUtil('trMV',X1o);
 
    % Threshold for voxels entering non-sphericity estimates
    %----------------------------------------------------------------------
    try
        modality = lower(spm_get_defaults('modality'));
        UFp      = spm_get_defaults(['stats.' modality '.ufp']);
    catch
        UFp      = 0.001;
    end
    UF           = spm_invFcdf(1 - UFp,[trMV,trRV]);
end
 
%-Image dimensions and data
%==========================================================================
VY       = SPM.xY.VY;
spm_check_orientations(VY);
 
% check files exists and try pwd
%--------------------------------------------------------------------------
for i = 1:numel(VY)
    if ~spm_existfile(VY(i).fname)
        [p,n,e]     = fileparts(VY(i).fname);
        VY(i).fname = [n,e];
    end
end
 
M        = VY(1).mat;
DIM      = VY(1).dim(1:3)';
xdim     = DIM(1); ydim = DIM(2); zdim = DIM(3);
YNaNrep  = spm_type(VY(1).dt(1),'nanrep');
 
%-Maximum number of residual images for smoothness estimation
%--------------------------------------------------------------------------
MAXRES   = spm_get_defaults('stats.maxres');
nSres    = min(nScan,MAXRES);
 
fprintf('%s%30s\n',repmat(sprintf('\b'),1,30),'...done');               %-#
 
%==========================================================================
% - F I T   M O D E L   &   W R I T E   P A R A M E T E R    I M A G E S
%==========================================================================
 
%-MAXMEM is the maximum amount of data processed at a time (bytes)
%--------------------------------------------------------------------------
MAXMEM = spm_get_defaults('stats.maxmem');
mmv    = MAXMEM/8/nScan;
blksz  = min(xdim*ydim,ceil(mmv));                             %-block size
nbch   = ceil(xdim*ydim/blksz);                                %-# blocks
nbz    = max(1,min(zdim,floor(mmv/(xdim*ydim))));   nbz = 1;   %-# planes
nbz = zdim; %just do whole image at once
blksz  = blksz * nbz;
 
%-Initialise variables used in the loop
%==========================================================================
[xords, yords] = ndgrid(1:xdim, 1:ydim);
xords = xords(:)'; yords = yords(:)';           % plane X,Y coordinates
S     = 0;                                      % Volume (voxels)
s     = 0;                                      % Volume (voxels > UF)
Cy    = 0;                                      % <Y*Y'> spatially whitened
CY    = 0;                                      % <(Y - <Y>) * (Y - <Y>)'>
EY    = 0;                                      % <Y>    for ReML
i_res = round(linspace(1,nScan,nSres))';        % Indices for residual
 
%-Initialise XYZ matrix of in-mask voxel co-ordinates (real space)
%--------------------------------------------------------------------------
XYZ   = zeros(3,xdim*ydim*zdim);
 
%-Cycle over bunches blocks within planes to avoid memory problems
%==========================================================================
spm_progress_bar('Init',100,str,'');


for z = 1:nbz:zdim                       %-loop over planes (2D or 3D data)
 
    % current plane-specific parameters
    %----------------------------------------------------------------------
    CrPl    = z:min(z+nbz-1,zdim);       %-plane list
    zords   = CrPl(:)*ones(1,xdim*ydim); %-plane Z coordinates
    CrBl    = [];                        %-parameter estimates
    CrResI  = [];                        %-residuals
    CrResSS = [];                        %-residual sum of squares
    Q       = [];                        %-in mask indices for this plane
 
    for bch = 1:nbch                     %-loop over blocks
 
        %-Print progress information in command window
        %------------------------------------------------------------------
        if numel(CrPl) == 1
            str = sprintf('Plane %3d/%-3d, block %3d/%-3d',...
                z,zdim,bch,nbch);
        else
            str = sprintf('Planes %3d-%-3d/%-3d',z,CrPl(end),zdim);
        end
        if z == 1 && bch == 1
            str2 = '';
        else
            str2 = repmat(sprintf('\b'),1,72); 
        end
        fprintf('%s%-40s: %30s',str2,str,' ');
 
        %-construct list of voxels in this block
        %------------------------------------------------------------------
        I     = (1:blksz) + (bch - 1)*blksz;       %-voxel indices
        I     = I(I <= numel(CrPl)*xdim*ydim);     %-truncate
        xyz   = [repmat(xords,1,numel(CrPl)); ...
                 repmat(yords,1,numel(CrPl)); ...
                 reshape(zords',1,[])];
        xyz   = xyz(:,I);                          %-voxel coordinates
        nVox  = size(xyz,2);                       %-number of voxels
 
        %-Get data & construct analysis mask
        %=================================================================
        fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...read & mask data')
        Cm    = true(1,nVox);                      %-current mask
 
 
        %-Compute explicit mask
        % (note that these may not have same orientations)
        %------------------------------------------------------------------
        for i = 1:length(xM.VM)
 
            %-Coordinates in mask image
            %--------------------------------------------------------------
            j = xM.VM(i).mat\M*[xyz;ones(1,nVox)];
 
            %-Load mask image within current mask & update mask
            %--------------------------------------------------------------
            Cm(Cm) = spm_get_data(xM.VM(i),j(:,Cm),false) > 0;
        end
 
        %-Get the data in mask, compute threshold & implicit masks
        %------------------------------------------------------------------
        Y     = zeros(nScan,nVox);
        for i = 1:nScan
 
            %-Load data in mask
            %--------------------------------------------------------------
            if ~any(Cm), break, end                %-Break if empty mask
            Y(i,Cm)  = spm_get_data(VY(i),xyz(:,Cm),false);
 
            Cm(Cm)   = Y(i,Cm) > xM.TH(i);         %-Threshold (& NaN) mask
            if xM.I && ~YNaNrep && xM.TH(i) < 0    %-Use implicit mask
                Cm(Cm) = abs(Y(i,Cm)) > eps;
            end
        end
 
        %-Mask out voxels where data is constant
        %------------------------------------------------------------------
        Cm(Cm) = any(diff(Y(:,Cm),1));
        Y      = Y(:,Cm);                          %-Data within mask
        CrS    = sum(Cm);                          %-# current voxels
 
 
        %==================================================================
        %-Proceed with General Linear Model (if there are voxels)
        %==================================================================
        if CrS
 
            %-Whiten/Weight data and remove filter confounds
            %--------------------------------------------------------------
            fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...filtering');%-#
 
            KWY   = spm_filter(xX.K,W*Y);
 
            %-General linear model: Weighted least squares estimation
            %--------------------------------------------------------------
            fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...estimation');%-#
 
            beta  = xX.pKX*KWY;                    %-Parameter estimates
            allbetas = [allbetas, beta];
            res   = spm_sp('r',xX.xKXs,KWY);       %-Residuals
            ResSS = sum(res.^2);                   %-Residual SSQ
            clear KWY                              %-Clear to save memory
 
 
            %-If ReML hyperparameters are needed for xVi.V
            %--------------------------------------------------------------
            if ~isfield(xVi,'V')
 
                %-F-threshold & accumulate spatially whitened Y*Y'
                %----------------------------------------------------------
                j   = sum((Hsqr*beta).^2,1)/trMV > UF*ResSS/trRV;
                j   = find(j);
                if ~isempty(j)
                    q  = size(j,2);
                    s  = s + q;
                    q  = spdiags(sqrt(trRV./ResSS(j)'),0,q,q);
                    Y  = Y(:,j)*q;
                    Cy = Cy + Y*Y';
                end
 
            end % (xVi,'V')
 
 
            %-if we are saving the WLS (ML) parameters
            %--------------------------------------------------------------
            if isfield(xX,'W')
 
                %-sample covariance and mean of Y (all voxels)
                %----------------------------------------------------------
                CY         = CY + Y*Y';
                EY         = EY + sum(Y,2);
 
                %-Save betas etc. for current plane as we go along
                %----------------------------------------------------------
                CrBl       = [CrBl,    beta];
                CrResI     = [CrResI,  res(i_res,:)];
                CrResSS    = [CrResSS, ResSS];
 
            end % (xX,'W')
            clear Y                         %-Clear to save memory
 
        end % (CrS)
 
        %-Append new inmask voxel locations and volumes
        %------------------------------------------------------------------
        XYZ(:,S + (1:CrS)) = xyz(:,Cm);     %-InMask XYZ voxel coords
        Q                  = [Q I(Cm)];     %-InMask XYZ voxel indices
        allQ = [allQ Q];
        S                  = S + CrS;       %-Volume analysed (voxels)
 
    end % (bch)
  
    %-Report progress
    %----------------------------------------------------------------------
    fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...done');             %-#
    spm_progress_bar('Set',100*(bch + nbch*(z - 1))/(nbch*zdim));
 
 
end % (for z = 1:zdim)
fprintf('\n');                                                          %-#
spm_progress_bar('Clear')
 %return;
%==========================================================================
% - P O S T   E S T I M A T I O N   C L E A N U P
%==========================================================================
if S == 0, spm('alert!','No inmask voxels - empty analysis!'); return; end
 
%-average sample covariance and mean of Y (over voxels)
%--------------------------------------------------------------------------
CY   = CY/S;
EY   = EY/S;
CY   = CY - EY*EY';
 
%-If not defined, compute non-sphericity V using ReML Hyperparameters
%==========================================================================
if ~isfield(xVi,'V')
    
    %-check there are signficant voxels
    %----------------------------------------------------------------------
    if s == 0
        spm('FigName','Stats: no significant voxels',Finter); 
        spm('Pointer','Arrow');
        if isfield(SPM.xGX,'rg')&&~isempty(SPM.xGX.rg)
            figure(Finter);
            plot(SPM.xGX.rg);
            spm('alert*',{'Please check your data'; ...
                'There are no significant voxels';...
                'The globals are plotted for diagnosis'});
        else
            spm('alert*',{'Please check your data'; ...
                'There are no significant voxels'});
        end
        warning('Please check your data: There are no significant voxels.');
        return
    end
 
    %-ReML estimate of residual correlations through hyperparameters (h)
    %----------------------------------------------------------------------
    str    = 'Temporal non-sphericity (over voxels)';
    fprintf('%-40s: %30s\n',str,'...ReML estimation');                  %-#
    Cy     = Cy/s;
 
    % ReML for separable designs and covariance components
    %----------------------------------------------------------------------
    if isstruct(xX.K)
        m     = length(xVi.Vi);
        h     = zeros(m,1);
        V     = sparse(nScan,nScan);
        for i = 1:length(xX.K)
 
            % extract blocks from bases
            %--------------------------------------------------------------
            q     = xX.K(i).row;
            p     = [];
            Qp    = {};
            for j = 1:m
                if nnz(xVi.Vi{j}(q,q))
                    Qp{end + 1} = xVi.Vi{j}(q,q);
                    p           = [p j];
                end
            end
 
            % design space for ReML (with confounds in filter)
            %--------------------------------------------------------------
            Xp     = xX.X(q,:);
            try
                Xp = [Xp xX.K(i).X0];
            end
 
            % ReML
            %--------------------------------------------------------------
            fprintf('%-30s\n',sprintf('  ReML Block %i',i));
            [Vp,hp] = spm_reml(Cy(q,q),Xp,Qp);
            V(q,q)  = V(q,q) + Vp;
            h(p)    = hp;
        end
    else
        [V,h] = spm_reml(Cy,xX.X,xVi.Vi);
    end
 
    % normalize non-sphericity and save hyperparameters
    %----------------------------------------------------------------------
    V         = V*nScan/trace(V);
    xVi.h     = h;
    xVi.V     = V;                  % Save non-sphericity xVi.V
    xVi.Cy    = Cy;                 % spatially whitened <Y*Y'>
    SPM.xVi   = xVi;                % non-sphericity structure
 
    
    if ~isfield(xX,'W')
        if spm_matlab_version_chk('7') >=0
            save('SPM','SPM','-V6');
        else
            save('SPM','SPM');
        end
        clear
        load SPM
        [SPM allbetas allQ]= lss_spm_spm(SPM);
        return
    end
    

end
SPM.xVi        = xVi;               % non-sphericity structure
SPM.xVi.CY     = CY;                %-<(Y - <Y>)*(Y - <Y>)'>
 
SPM.xX         = xX;                %-design structure
 