function [] = spm_dcm_create (syn_model, source_model, SNR)
%
% Specify a DCM model without having to use an SPM.mat file
% FORMAT [] = spm_dcm_create (syn_model, source_model, SNR)
%
% syn_model     name of the synthetic DCM to be created 
% source_model  - define new model ('GUI') or 
%               - import values from existing model ('import')
%               - specify it directly by directory & name
%               default: 'GUI'
% SNR           signal-to-noise ratio (default: 1)
%
% This function allows to create DCM networks with known connectivity
% parameters from which synthetic data are then generated by calling spm_dcm_generate.
%
% This function is very much like spm_dcm_ui('specify') 
% but inputs etc. are specified either via the user interface or from an
% existing model.
%
%
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Will Penny & Klaas Enno Stephan
% $Id: spm_dcm_create.m 907 2007-09-05 14:11:58Z klaas $


Finter = spm_figure('GetWin','Interactive');
header = get(Finter,'Name');
set(Finter,'Name','Dynamic Causal Modelling')
WS     = spm('WinScale');

% check parameters and insert default values, if necessary
%===================================================================
if nargin == 0
    syn_model       = spm_input('Name for target DCM_???.mat','+1','s');
    SNR             = spm_input('Signal-to-noise ratio (SNR)? ','+1','r',[],1);
    source_model    = 'GUI';
else
    if nargin == 1
        source_model    = 'GUI'
        SNR             = 1;
    else
        if nargin == 2
            SNR = 1;
        end
    end
end


% outputs
%===================================================================

switch upper(source_model)
    
    case 'GUI'
        % Define model by GUI
        %====================

        % get cell array of region structures
        %------------------------------------------------------------------
        n = spm_input('Enter number of regions','+1','r',[],1);
        for i=1:n,
            str=sprintf('Region %d',i);
            xY(i).name = spm_input(['Name for ',str],'+1','s');
            % Make up spurious VOI info
            % for compatibility with spm_dcm_display
            xY(i).xyz = [i i i]'*10;
            xY(i).XYZmm = [i i i]'*10;
            xY(i).s=1;
            xY(i).spec=1;
        end

        % inputs
        %===================================================================

        % global parameters
        global defaults
        try
            fMRI_T  = defaults.stats.fmri.t;
            fMRI_T0 = defaults.stats.fmri.t0;
        catch
            fMRI_T  = 16;
            fMRI_T0 = 1;
        end;
        SPM.xBF.T  = fMRI_T;
        SPM.xBF.T0 = fMRI_T0;

        spm_input('Basic parameters...',1,'d',mfilename)
        SPM.xY.RT = spm_input('Interscan interval {secs}','+1','r',[],1);
        SPM.nscan = spm_input(['scans per session e.g. 256'],'+1');
        v=SPM.nscan;
        SPM.xBF.dt = SPM.xY.RT/SPM.xBF.T;
        str           = 'specify design in';
        SPM.xBF.UNITS = spm_input(str,'+1','scans|secs');

        Ui=spm_get_ons(SPM,1);

        % Change input format to DCM input format and correct 32 bin offset that is inserted by spm_get_ons
        % (NB: for "normal" DCMs this is corrected for in spm_dcm_ui)
        U.name = {};
        U.u    = [];
        ii     = 0;
        for  i = 1:length(Ui)
            U.u             = [U.u Ui(i).u(33:end,1)];  % correct 32 bin offset that is inserted (as hard coded value!) by spm_get_ons
            U.name{end + 1} = Ui(i).name{1};
            % any parametric modulators?
            if size(Ui(i).u,2) > 1
                for j = 2:size(Ui(i).u,2)
                    U.u             = [U.u Ui(i).u(33:end,j)];
                    U.name{end + 1} = Ui(i).P(j-1).name;
                end
            end
        end
        U.dt = Ui(1).dt;

        % graph connections
        %===================================================================
        m     = size(U.u,2);
        a     = zeros(n,n);
        c     = zeros(n,m);
        b     = zeros(n,n,m);
        d     = uicontrol(Finter,'String','done',...
                          'Position',[200 050 060 020].*WS);
        dx    = 35;
        wx=30;
        wy=20;

        %-intrinsic connections
        %-------------------------------------------------------------------
        spm_input('Specify intrinsic connections from',1,'d')
        spm_input('to',3,'d')

        for i = 1:n
            str    = sprintf('%s %i',xY(i).name,i);
            h1(i)  = uicontrol(Finter,'String',str,...
                'Style','text',...
                'HorizontalAlignment','right',...
                'Position',[020 336-dx*i 080 020].*WS);
            h2(i)  = uicontrol(Finter,'String',sprintf('%i',i),...
                'Style','text',...
                'Position',[100+dx*i 336 020 020].*WS);
        end
        for i = 1:n
            for j = 1:n
                cc=ceil([100+dx*j 340-dx*i wx wy].*WS);
                h3(i,j) = uicontrol(Finter,...
                    'Position',cc,...
                    'Style','edit');
                if i == j
                    set(h3(i,j),'String','-1');
                else
                    set(h3(i,j),'String','0');
                end
            
            end
        end
        drawnow

        % wait for 'done'
        %-----------------------------------------------------------
        while(1)
            pause(0.01)
            if strcmp(get(gco,'Type'),'uicontrol')
                if strcmp(get(gco,'String'),'done')
                    for i = 1:n
                        for j = 1:n
                            a(i,j) = str2num(get(h3(i,j),'string'));
                        end
                    end
                    delete([h1(:); h2(:); h3(:)])
                    break
                end
            end
        end


        %-effects of causes
        %-------------------------------------------------------------------
        for k = 1:m
    
            % buttons and labels
            %-----------------------------------------------------------
            str   = sprintf(...
                'Effects of %-12s on regions... and connections',...
                U.name{k});
            spm_input(str,1,'d')
        
    
            for i = 1:n
                h1(i)  = uicontrol(Finter,'String',xY(i).name,...
                    'Style','text',...
                    'Position',[005 336-dx*i 080 020].*WS);
                h2(i)  = uicontrol(Finter,...
                    'Position',[080 340-dx*i wx wy].*WS,...
                    'Style','edit');
                set(h2(i),'String','0');
            end
            for i = 1:n
                for j = 1:n
                    cc=ceil([130+dx*j 340-dx*i wx wy].*WS);            
                    h3(i,j) = uicontrol(Finter,...
                        'Position',cc,...
                        'Style','edit');
                    set(h3(i,j),'String','0');
                end
            end
            drawnow
    
            % wait for 'done'
            %-----------------------------------------------------------
            set(gcf,'CurrentObject',h2(1))
            while(1)
                pause(0.01)
                if strcmp(get(gco,'Type'),'uicontrol')
                    if strcmp(get(gco,'String'),'done')
                
                        % get c
                        %--------------------------------------------------
                        for i = 1:n
                            c(i,k)   = str2num(get(h2(i),'string'));
                        end
                    
                        % get b ensuring 2nd order effects are allowed
                        %--------------------------------------------------
                        for i = 1:n
                            for j = 1:n
                                b(i,j,k) = str2num(get(h3(i,j),'string'));
                                if i == j & ~c(i,k)
                                    b(i,j,k) = 0;
                                end
                            end
                        end
                        delete([h1(:); h2(:); h3(:)])
                        spm_input('Thank you',1,'d')
                        break
                
                    end
                end
            end
        end
        delete(d)
        
        % Copy to data structure
        DCM.a   = ~(a==0);
        DCM.b   = ~(b==0);
        DCM.c   = ~(c==0);
        DCM.A   = a;
        DCM.B   = b;
        DCM.C   = c;
        DCM.U   = U;
        DCM.xY  = xY;
        DCM.v   = v;
        DCM.n   = length(DCM.xY);
        DCM.TE  = 0.04; % default value for TE

        
    case 'IMPORT'
        % Import existing model - prompt user to choose it
        %=================================================
    	P     = spm_select(1,'^DCM.*\.mat$','Select source DCM_???.mat');
    	load(P{:})

        
    otherwise
        % Import existing model (directly specified by directory & name)
        %==============================================================
    	try
            load(source_model)
        catch
            disp('Source model does not exist - wrong directory or file name?');
            return;
        end
        
        
end % end of switch statement


% ASSUME, for now, default hemodynamics
%------------------------------------------------------------------
[pE,pC,qE]  = spm_dcm_priors(DCM.a,DCM.b,DCM.c);
DCM.H       = qE;

% Now set up output structure 
%-------------------------------------------------------------------
X0    = ones(DCM.v,1);
switch upper(source_model)
    case 'GUI'
        Y.dt  = SPM.xY.RT;
    otherwise
        Y.dt  = DCM.Y.dt;
end
Y.X0  = X0;
for i = 1:DCM.n,
    Y.name{i} = DCM.xY(i).name;
end
Y.Q   = spm_Ce(ones(1,DCM.n)*DCM.v);
DCM.Y = Y;


%-Save and reset title
%-------------------------------------------------------------------
if spm_matlab_version_chk('7') >= 0
    save(['DCM_',syn_model],'-V6','DCM');
else
    save(['DCM_',syn_model],'DCM');
end;

% Now generate synthetic output data
spm_dcm_generate(['DCM_' syn_model],source_model,SNR);

spm('FigName',header);
spm('Pointer','Arrow')

   
return
