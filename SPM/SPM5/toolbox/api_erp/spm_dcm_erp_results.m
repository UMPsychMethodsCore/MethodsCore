function [DCM] = spm_dcm_erp_results(DCM,Action)
% Results for ERP Dynamic Causal Modeling (DCM)
% FORMAT spm_dcm_erp_results(DCM,'ERPs (mode)');
% FORMAT spm_dcm_erp_results(DCM,'ERPs (sources)');
% FORMAT spm_dcm_erp_results(DCM,'Coupling (A)');
% FORMAT spm_dcm_erp_results(DCM,'Coupling (B)');
% FORMAT spm_dcm_erp_results(DCM,'Coupling (C)');
% FORMAT spm_dcm_erp_results(DCM,'trial-specific effects');
% FORMAT spm_dcm_erp_results(DCM,'Input');
% FORMAT spm_dcm_erp_results(DCM,'Response');
% FORMAT spm_dcm_erp_results(DCM,'Data');
%                
%___________________________________________________________________________
%
% DCM is a causal modelling procedure for dynamical systems in which
% causality is inherent in the differential equations that specify the model.
% The basic idea is to treat the system of interest, in this case the brain,
% as an input-state-output system.  By perturbing the system with known
% inputs, measured responses are used to estimate various parameters that
% govern the evolution of brain states.  Although there are no restrictions
% on the parameterisation of the model, a bilinear approximation affords a
% simple re-parameterisation in terms of effective connectivity.  This
% effective connectivity can be latent or intrinsic or, through bilinear
% terms, model input-dependent changes in effective connectivity.  Parameter
% estimation proceeds using fairly standard approaches to system
% identification that rest upon Bayesian inference.
%__________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_dcm_erp_results.m 1079 2008-01-11 11:05:48Z guillaume $


% get figure handle
%--------------------------------------------------------------------------
Fgraph = spm_figure('GetWin','Graphics');
colormap(gray)
if ~strcmp(lower(Action), 'dipoles')
    figure(Fgraph)
    clf
end

% trial data
%--------------------------------------------------------------------------
xY  = DCM.xY;                   % data
nt  = length(xY.xy);            % Nr trial types
ne  = size(xY.xy{1},2);         % Nr electrodes
nb  = size(xY.xy{1},1);         % Nr time bing
t   = xY.Time;                  % PST

% plot data 
%--------------------------------------------------------------------------
switch(lower(Action))
case{lower('Data')}
    try
        for i = 1:nt
            
            % confounds if specified 
            %--------------------------------------------------------------
            try
                X0 = spm_orth(xY.X0(1:nb,:),'norm');
                R  = speye(nb,nb) - X0*X0';
            catch
                R  = speye(nb,nb);
            end
            
            % plot data 
            %--------------------------------------------------------------
            subplot(nt,2,(i - 1)*2 + 1)
            plot(t,R*xY.xy{i})
            xlabel('time (ms)')
            try
                title(sprintf('Observed response (code:%i)',xY.code(i)))
            catch
                title(sprintf('Observed response %i',i))
            end
            axis square
            try
              axis(A);
            catch
              A = axis;
            end
            
            % image data 
            %--------------------------------------------------------------
            subplot(nt,2,(i - 1)*2 + 2)
            imagesc([1:ne],t,R*xY.xy{i})
            xlabel('time (ms)')
            try
                title(sprintf('Observed response (code:%i)',xY.code(i)))
            catch
                title(sprintf('Observed response %i',i))
            end
            
        end
    end
    return
end

% post inversion parameters
%--------------------------------------------------------------------------
nu  = length(DCM.B);          % Nr inputs
nc  = size(DCM.H{1},2);       % Nr modes
ns  = size(DCM.A{1},2);       % Nr of sources
np  = size(DCM.K{1},2);       % Nr of population per source
np  = np/ns;


% switch
%--------------------------------------------------------------------------
switch(lower(Action))
    
case{lower('ERPs (mode)')}

    % spm_dcm_erp_results(DCM,'ERPs (mode)');
    %----------------------------------------------------------------------
    co = {'b', 'r', 'g', 'm', 'y', 'k'};
    lo = {'-', '--'};
    
    for i = 1:nc
        subplot(ceil(nc/2),2,i), hold on
        str   = {};
        for j = 1:nt
            plot(t,DCM.H{j}(:,i), lo{1},...
                'Color', co{j},...
                'LineWidth',2);
            str{end + 1} = sprintf('trial %i (predicted)',j);
            plot(t,DCM.H{j}(:,i) + DCM.R{j}(:,i), lo{2},...
                'Color',co{j});
            str{end + 1} = sprintf('trial %i (observed)',j);
                        set(gca, 'XLim', [t(1) t(end)]);

        end
        hold off
        title(sprintf('mode %i',i))
        grid on
        axis square
        try
            axis(A);
        catch
            A = axis;
        end
    end
    xlabel('time (ms)')
    legend(str)
    
    
case{lower('ERPs (sources)')}
    
    % spm_dcm_erp_results(DCM,'ERPs (sources)');
    %----------------------------------------------------------------------
    mx = max(max(cat(2, DCM.K{:})));
    mi = min(min(cat(2, DCM.K{:})));
    col = {'b','r','g','m','y','c'};
    
    for i = 1:ns
        str   = {};
        for j = 1:np
            subplot(ceil(ns/2),2,i), hold on
            for k = 1:nt
                if j == np
                    plot(t, DCM.K{k}(:,i + ns*(j - 1)), ...
                        'Color',col{k}, ...
                        'LineWidth',2);
                else
                    plot(t, DCM.K{k}(:,i + ns*(j - 1)), ':', ...
                        'Color',col{k}, ...
                        'LineWidth',2);
                end
                str{end + 1} = sprintf('trial %i (pop. %i)',k,j);
            end
        end
        set(gca, 'YLim', [mi mx], 'XLim', [t(1) t(end)]);
        hold off
        title(DCM.Sname{i})
        grid on
        axis square
    end
    xlabel('time (ms)')
    legend(str)
    
    
case{lower('Coupling (A)')}
    
    % spm_dcm_erp_results(DCM,'coupling (A)');
    %----------------------------------------------------------------------
    str = {'Forward','Backward','Lateral'};
    for  i =1:3
        
        % images
        %------------------------------------------------------------------
        subplot(4,3,i)
        imagesc(exp(DCM.Ep.A{i}))
        title(str{i},'FontSize',10)
        set(gca,'YTick',[1:ns],'YTickLabel',DCM.Sname,'FontSize',8)
        set(gca,'XTick',[])
        xlabel('from','FontSize',8)
        ylabel('to','FontSize',8)
        axis square
    
        % table
        %------------------------------------------------------------------
        subplot(4,3,i + 3)
        text(0,1/2,num2str(full(exp(DCM.Ep.A{i})),' %.2f'),'FontSize',8)
        axis off,axis square

    
        % PPM
        %------------------------------------------------------------------
        subplot(4,3,i + 6)
        image(64*DCM.Pp.A{i})
        set(gca,'YTick',[1:ns],'YTickLabel',DCM.Sname,'FontSize',8)
        set(gca,'XTick',[])
        title('PPM')
        axis square
    
        % table
        %------------------------------------------------------------------
        subplot(4,3,i + 9)
        text(0,1/2,num2str(DCM.Pp.A{i},' %.2f'),'FontSize',8)
        axis off, axis square
        
    end
    
case{lower('Coupling (C)')}
    
    % spm_dcm_erp_results(DCM,'coupling (C)');
    %----------------------------------------------------------------------
    
    % images
    %----------------------------------------------------------------------
    subplot(2,4,1)
    imagesc(exp(DCM.Ep.C))
    title('Factors','FontSize',10)
    set(gca,'XTick',[1:nu],'XTickLabel','Input','FontSize',8)
    set(gca,'YTick',[1:ns],'YTickLabel',DCM.Sname, 'FontSize',8)
    axis square
    
    % PPM
    %----------------------------------------------------------------------
    subplot(2,4,3)
    image(64*DCM.Pp.C)
    title('Factors','FontSize',10)
    set(gca,'XTick',[1:nu],'XTickLabel','Input','FontSize',8)
    set(gca,'YTick',[1:ns],'YTickLabel',DCM.Sname, 'FontSize',8)
    axis square
    title('PPM')
    
    % table
    %----------------------------------------------------------------------
    subplot(2,4,2)
    text(0,1/2,num2str(full(exp(DCM.Ep.C)),' %.2f'),'FontSize',8)
    axis off

    % table
    %----------------------------------------------------------------------
    subplot(2,4,4)
    text(0,1/2,num2str(DCM.Pp.C,' %.2f'),'FontSize',8)
    axis off

 
case{lower('Coupling (B)')}
    
    % spm_dcm_erp_results(DCM,'coupling (B)');
    %----------------------------------------------------------------------
    for i = 1:nu
        
        % images
        %------------------------------------------------------------------
        subplot(4,nu,i)
        imagesc(exp(DCM.Ep.B{i}))
        title(DCM.xU.name{i},'FontSize',10)
        set(gca,'YTick',[1:ns],'YTickLabel',DCM.Sname,'FontSize',8)
        set(gca,'XTick',[])
        xlabel('from','FontSize',8)
        ylabel('to','FontSize',8)
        axis square

        % tables
        %------------------------------------------------------------------
        subplot(4,nu,i + nu)
        text(0,1/2,num2str(full(exp(DCM.Ep.B{i})),' %.2f'),'FontSize',8)
        axis off
        axis square
        
        % PPM
        %------------------------------------------------------------------
        subplot(4,nu,i + 2*nu)
        image(64*DCM.Pp.B{i})
        set(gca,'YTick',[1:ns],'YTickLabel',DCM.Sname,'FontSize',8)
        set(gca,'XTick',[])
        title('PPM')
        axis square

        % tables
        %------------------------------------------------------------------
        subplot(4,nu,i + 3*nu)
        text(0,1/2,num2str(DCM.Pp.B{i},' %.2f'),'FontSize',8)
        axis off
        axis square
        
    end
    
case{lower('trial-specific effects')}
    
    % spm_dcm_erp_results(DCM,'trial-specific effects');
    %----------------------------------------------------------------------
    for i = 1:ns
        for j = 1:ns

            % ensure connection is enabled
            %--------------------------------------------------------------
            q     = 0;
            for k = 1:nu
                q = q | DCM.B{k}(i,j);
            end

            % plot trial-specific effects
            %--------------------------------------------------------------
            if q
                B     = zeros(nt,1);
                for k = 1:nu
                    B = B + DCM.xU.X(:,k)*DCM.Ep.B{k}(i,j);
                end
                
                subplot(ns,ns,(i - 1)*ns + j)
                bar(exp(B)*100,'c')
                title([DCM.Sname{j}, ' to ' DCM.Sname{i}],'FontSize',10)
                xlabel('trial',  'FontSize',8)
                ylabel('strength (%)','FontSize',8)
                set(gca,'XLim',[0 nt + 1])
                axis square

            end
        end
    end
    
case{lower('Input')}
    
    % plot data
    % ---------------------------------------------------------------------
    xU    = DCM.xU;
    tU    = 0:xU.dt:xU.dur;
    [U N] = spm_erp_u(tU,DCM.Ep,DCM.M);

    subplot(2,1,1)
    plot(t,U,t,N,':')
    xlabel('time (ms)')
    title('input')
    axis square, grid on
    for i = 1:length(DCM.M.ons)
        str{i} = sprintf('input (%i)',i);
    end
    str{end + 1} = 'nonspecific';
    legend(str)
    
case{lower('Response')}
    
    % plot data
    % ---------------------------------------------------------------------
    try
        A     = [];
        for i = 1:nt
            subplot(nt,2,2*i - 1)
            plot(t,DCM.Hc{i} + DCM.Rc{i})
            xlabel('time (ms)')
            try
                title(sprintf('Observed (adjusted-code:%i)',xY.code(i)))
            catch
                title(sprintf('Observed (adjusted) %i',i))
            end
            A(end + 1,:) = axis;

            subplot(nt,2,2*i - 0)
            plot(t,DCM.Hc{i})
            xlabel('time (ms)')
            title('Predicted')
            A(end + 1,:) = axis;
        end
        a(1)  = min(A(:,1));
        a(2)  = max(A(:,2));
        a(3)  = min(A(:,3));
        a(4)  = max(A(:,4));
        for i = 1:nt
            subplot(nt,2,2*i - 1)
            axis(a); axis square, grid on
            subplot(nt,2,2*i - 0)
            axis(a); axis square, grid on
        end
        
    end
    
    
case{lower('Response (image)')}
    
    % plot data
    % ---------------------------------------------------------------------
    try
        for i = 1:nt
            subplot(nt,2,2*i - 1)
            imagesc([1:ne],t,DCM.Hc{i} + DCM.Rc{i})
            xlabel('time (ms)')
            try
                title(sprintf('Observed (adjusted-code:%i)',xY.code(i)))
            catch
                title(sprintf('Observed (adjusted) %i',i))
            end
            axis square, grid on, A = axis;

            subplot(nt,2,2*i - 0)
            imagesc([1:ne],t,DCM.Hc{i})
            xlabel('time (ms)')
            title('Predicted')
            axis(A); axis square, grid on
        end
    end

case{lower('Dipoles')}
    
    % plot dipoles
    % ---------------------------------------------------------------------
    try
        P            = DCM.Eg;   
        np           = size(P.Lmom,2)/size(P.Lpos,2);
        sdip.n_seeds = 1;
        sdip.n_dip   = np*ns;
        sdip.Mtb     = 1;
        sdip.j{1}    = full(P.Lmom);
        sdip.j{1}    = sdip.j{1}(:);
        sdip.loc{1}  = kron(ones(1,np),full(P.Lpos));
        spm_eeg_inv_ecd_DrawDip('Init', sdip)
    catch
        warndlg('use the render API button to view results')
        return
    end
    
case{lower('Spatial overview')}
        spm_dcm_erp_viewspatial(DCM)
end
