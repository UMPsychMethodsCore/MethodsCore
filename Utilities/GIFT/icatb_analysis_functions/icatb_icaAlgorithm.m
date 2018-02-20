function varargout = icatb_icaAlgorithm(ica_algorithm, data, ICA_Options)
%% Function to get the number of available ICA algorithms or run a particular ICA algorithm
%
% Inputs:
%
% No inputs gives all the algorithms available
% 1. ica_algorithm - Number or specify the algorithm name directly
% 2. data - 2D matrix components by volume
% 3. icaOptions - cell array containing necessary parameters
%
% Outputs:
% 1. icaAlgo - all algorithms available
% 2. W - Weights matrix (components by components)
% 3. A - inverse of Weights (components by components)
% 4. icasig_tmp - Sources (components by volume)
%

% Get modality type
[modalityType, dataTitle] = icatb_get_modality;

if (strcmpi(modalityType, 'fmri'))
    % all the available algorithms for fmri data
    icaAlgo = str2mat('Infomax','Fast ICA', 'Erica', 'Simbec', 'Evd', 'Jade Opac', 'Amuse', ...
        'SDD ICA', 'Semi-blind Infomax', 'Constrained ICA (Spatial)', 'Radical ICA', 'Combi', 'ICA-EBM', 'ERBM', 'IVA-GL', 'MOO-ICAR');
else
    % all the available algorithms for EEG data
    icaAlgo = str2mat('Infomax', 'Fast ICA', 'Erica', 'Simbec', 'Evd', 'Jade Opac', 'Amuse', ...
        'SDD ICA', 'Radical ICA', 'Combi', 'ICA-EBM', 'ERBM', 'IVA-GL');
end


if (nargout < 2)
    varargout{1} = icaAlgo;
    return;
end

if (nargin > 3)
    error('Max number of args allowed is 3.');
end


W = 0; icasig_tmp = 0;

% if there are more than one arguments
if (nargin > 0 && nargin <= 3)
    
    % get the ica algorithm
    if isnumeric(ica_algorithm)
        if ica_algorithm > size(icaAlgo, 1)
            disp(['Selected algorithm number is : ', num2str(size(icaAlgo, 1)), '. Presently there are ', ...
                num2str(size(icaAlgo, 1)), ' algorithms. By default selecting the first algorithm.']);
            ica_algorithm = 1;
        end
        selected_ica_algorithm = lower(deblank(icaAlgo(ica_algorithm, :))); % selected ICA algorithm
    elseif ischar(ica_algorithm)
        selected_ica_algorithm = lower(deblank(ica_algorithm));
        if (strcmpi(selected_ica_algorithm, 'fbss'))
            disp('FBSS algorithm name is changed to ERBM');
            % fbss name is changed to erbm
            selected_ica_algorithm = 'erbm';
        end
        matchIndex = strmatch(selected_ica_algorithm, lower(icaAlgo), 'exact');
        if isempty(matchIndex)
            disp('Algorithm specified is not in the available ICA algorithms. By default selecting the first algorithm.');
            selected_ica_algorithm = lower(deblank(icaAlgo(1, :)));
        end
    end
    
end
% end for checking the number of arguments


% Add your ICA algorithm below
if (nargin > 0 && nargin <= 3)
    
    if ~exist('ICA_Options', 'var')
        ICA_Options = {};
    else
        if isempty(ICA_Options)
            ICA_Options = {};
        end
    end
    % end for checking
    
    switch(lower(selected_ica_algorithm))
        
        case 'infomax'
            %% Infomax
            
            [W, sphere, icasig_tmp] = icatb_runica(data, ICA_Options{1:length(ICA_Options)});
            W = W*sphere;
            icasig_tmp = W*data;
            A = pinv(W);
            
        case 'fast ica'
            %% Fast ICA
            
            [icasig_tmp, A, W] = icatb_fastICA(data, ICA_Options{1:length(ICA_Options)});
            
        case 'erica'
            %% ERICA
            
            [BW, B, W, A, icasig_tmp] = icatb_erica(data);
            W = BW;
            
        case 'simbec'
            %% SIMBEC
            
            [c_index, W] = icatb_simbec(data, size(data, 1));
            A = pinv(W);
            icasig_tmp = W*data;
            
        case 'evd'
            %% EVD
            
            [icasig_tmp, W] = icatb_evd(data, size(data, 1));
            A = pinv(W);
            
        case 'jade opac'
            %% Jade Opac
            
            [icasig_tmp, W] = icatb_jade_opac(data);
            A = pinv(W);
            
        case 'amuse'
            %% AMUSE
            
            [icasig_tmp, W] = icatb_amuse(data);
            A = pinv(W);
            
        case 'sdd ica'
            %% SDD ICA (Requires stats toolbox)
            
            [W, sphere, icasig_tmp] = icatb_runica_opt(data, ICA_Options{1:length(ICA_Options)});
            W = W*sphere;
            icasig_tmp = W*data;
            A = pinv(W);
            
        case 'semi-blind infomax'
            %% Semi blind Infomax
            
            % use the data reduction steps information and the ica options
            % information
            %[sesInfo, ICA_Options, whitesig] = icatb_sbica_example(sesInfo, ICA_Options);
            [W, sphere, icasig_tmp, bias, signs, lrates, y] = icatb_runica_sbica(data, ICA_Options{1:length(ICA_Options)});
            W = W*sphere;
            icasig_tmp = W*data;
            A = pinv(W);
            
        case 'constrained ica (spatial)'
            %% Spatial constrained ICA
            
            % ICA algorithm with spatial constraints
            [out, W] = icatb_multi_fixed_ICA_R_Cor(data, ICA_Options{2:2:length(ICA_Options)});
            icasig_tmp = W*data;
            A = pinv(W);
            
        case 'radical ica'
            %% Radical ICA
            
            % ICA algorithm with spatial constraints
            [icasig_tmp, W] = icatb_fast_RADICAL(data);
            A = pinv(W);
            
        case 'combi'
            %% Combi algorithm
            
            W = icatb_combi(data);
            icasig_tmp = W*data;
            A = pinv(W);
            
        case 'ica-ebm'
            %% Real-valued ICA by entropy bound minimization
            
            W = icatb_ica_ebm(data);
            icasig_tmp = W*data;
            A = pinv(W);
            
        case {'fbss', 'erbm'}
            %% Real-valued full blind source separation
            
            W = icatb_fbss(data, ICA_Options{:});
            icasig_tmp = W*data;
            A = pinv(W);
            
        case 'iva-gl'
            
            %% IVA
            disp('Computing second order IVA ...');
            W = icatb_iva_second_order(data, 'whiten', false);
            if (isempty(ICA_Options))
                ICA_Options = {'maxIter', 1024, 'termThreshold', 1e-6, 'alpha0', 0.1, 'verbose', true};
            end
            ICA_Options(end+1:end+4) = {'whiten', false, 'initW', W};
            disp('Weights from second order IVA are used as initial weights in laplacian IVA. Computing laplacian IVA ...');
            W = icatb_iva_laplace(data, ICA_Options{:}); % run iva-l, initialized with iva-g result
            [W, A, icasig_tmp] = correct_sign(W, data);
            
            
        case 'moo-icar'
            
            %% MOO-ICAR
            % Inputs will be raw fmri data and reference data
            ref_data = ICA_Options{end};
            [icasig_tmp, A] = icatb_gigicar(data, ref_data);
            W = pinv(W);
            
            % Add your own ICA algorithm code below
            
            
    end
    % end for checking the ICA algorithms
    
end



varargout{1} = icaAlgo;
varargout{2} = W;

if (nargout >= 3)
    varargout{3} = A;
    if (nargout == 4)
        varargout{4} = icasig_tmp;
    end
end



function [W, A, SR]  = correct_sign(W, X)

A = zeros(size(W));
SR = zeros(size(X));

for n = 1:size(W, 3)
    S = squeeze(W(:, :, n)*X(:, :, n))';
    sk = sign(icatb_skewness(S) + eps);
    W(:, :, n) = diag(sk)*W(:, :, n);
    SR(:, :, n) = squeeze(W(:, :, n)*X(:, :, n));
    A(:, :, n) = pinv(squeeze(W(:, :, n)));
end