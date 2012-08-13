function [L] = spm_lx_sep(P,M)
% observer matrix for a neural mass model of erps: y = G*x
% FORMAT [G] = spm_lx_sep(P,M)
% x      - state vector
%   x(:,1) - voltage (spiny stellate cells)
%   x(:,2) - voltage (pyramidal cells) +ve
%   x(:,3) - voltage (pyramidal cells) -ve
%   x(:,4) - current (spiny stellate cells)    depolarizing
%   x(:,5) - current (pyramidal cells)         depolarizing
%   x(:,6) - current (pyramidal cells)         hyerpolarizing
%   x(:,7) - voltage (inhibitory interneurons)
%   x(:,8) - current (inhibitory interneurons) depolarizing
%   x(:,9) - voltage (pyramidal cells)
%
% G        - y = G*x
%
% where spiny stellate cells and pyramidal cells contribute
%__________________________________________________________________________
%
% David O, Friston KJ (2003) A neural mass model for MEG/EEG: coupling and
% neuronal dynamics. NeuroImage 20: 1743-1755
%__________________________________________________________________________
% %W% Karl Friston %E%

% get stellate and pyramidal cell indices
%--------------------------------------------------------------------------
n      = length(M.pE.A{1});
is     = [1:n] + 1;
ip     = [1:n] + M.n - n;
i      = [is ip];

% parameterised lead field ECD
%--------------------------------------------------------------------------
L      = sparse(M.l,M.n);
L(:,i) = spm_sep_L(P,M);