function [y] = spm_int_L(P,M,U)
% integrates a MIMO nonlinear system using a fixed Jacobian: J(x(0)
% FORMAT [y] = spm_int_L(P,M,U)
% P   - model parameters
% M   - model structure
% U   - input structure or matrix
%
% y   - (v x l)  response y = g(x,u,P)
%__________________________________________________________________________
% Integrates the MIMO system described by
%
%    dx/dt = f(x,u,P,M)
%    y     = g(x,u,P,M)
%
% using the update scheme:
%
%    x(t + dt) = x(t) + U*dx(t)/dt
%
%            U = (expm(dt*J) - I)*inv(J)
%            J = df/dx
%
% at input times.  This integration scheme evaluates the update matrix (U)
% at the expansion point
%
%--------------------------------------------------------------------------
%
% SPM solvers or integrators
%
% spm_int_ode:  uses ode45 (or ode113) which are one and multi-step solvers
% respectively.  They can be used for any ODEs, where the Jacobian is
% unknown or difficult to compute; however, they may be slow.
%
% spm_int_J: uses an explicit Jacobian-based update scheme that preserves
% nonlinearities in the ODE: dx = (expm(dt*J) - I)*inv(J)*f.  If the
% equations of motion return J = df/dx, it will be used; otherwise it is
% evaluated numerically, using spm_diff at each time point.  This scheme is
% infallible but potentially slow, if the Jacobian is not available (calls
% spm_dx).
%
% spm_int_E: As for spm_int_J but uses the eigensystem of J(x(0)) to eschew 
% matrix exponentials and inversion during the integration. It is probably
% the best compromise, if the Jacobian is not available explicitly.
%
% spm_int_B: As for spm_int_J but uses a first-order approximation to J
% based on J(x(t)) = J(x(0)) + dJdx*x(t).
%
% spm_int_L: As for spm_int_B but uses J(x(0)).
%
% spm_int_U: like spm_int_J but only evaluates J when the input changes.
% This can be useful if input changes are sparse (e.g., boxcar functions).
% spm_int_U also has the facility to integrate delay differential equations
% if a delay operator is returned [f J D] = f(x,u,P,M). It is used 
% primarily for integrating fMRI models
%
% spm_int:   Fast integrator that uses a bilinear approximation to the
% Jacobian evaluated using spm_bireduce. This routine will also allow for
% sparse sampling of the solution and delays in observing outputs. It is
% used primarily for integrating fMRI models
%___________________________________________________________________________
% Copyright (C) 2005 Wellcome Trust Centre for Neuroimaging
 
% Karl Friston
% $Id: spm_int_L.m 1070 2008-01-07 19:03:15Z guillaume $
 
 
% convert U to U.u if necessary
%--------------------------------------------------------------------------
if ~isstruct(U)
    U.u = U;
end
try
    dt = U.dt;
catch
    dt = 1;
end
try
    ns = M.ns;
catch
    ns = length(U.u);
end
 
 
% state equation; add [0] states if not specified
%--------------------------------------------------------------------------
try
    f   = fcnchk(M.f,'x','u','P','M');
catch
    f   = inline('sparse(0,1)','x','u','P','M');
    M.n = 0;
    M.x = sparse(0,0);
end
 
% and output nonlinearity
%--------------------------------------------------------------------------
try
    g   = fcnchk(M.g,'x','u','P','M');
catch
    g   = [];
end
 
% Initial states and inputs
%--------------------------------------------------------------------------
try
    u = U.u(1,:);
catch
    u = sparse(1,M.m);
end
try
    try
        x   = feval(M.x0,P,M,U);
        M.x = x;
    catch
        x   = M.x;
    end
catch
    x   = sparse(0,1);
    M.x = x;
end
 
 
% dx(t)/dt and Jacobian df/dx
%--------------------------------------------------------------------------
try
    [fx dfdx] = f(x,u,P,M);
catch
    dfdx      = spm_diff(f,x,u,P,M,1);
end
dfdx  = full(dfdx);
p     = max(abs(real(eig(dfdx))));
N     = ceil(max(1,dt*p*2));
n     = length(spm_vec(x));
Q     = (spm_expm(dt*dfdx/N) - speye(n,n))*pinv(dfdx);
 
% integrate
%==========================================================================
for i = 1:ns
 
    % input
    %----------------------------------------------------------------------
    try
        u  = U.u(i,:);
    end
 
    % update dx = (expm(dt*J) - I)*inv(J)*fx
    %----------------------------------------------------------------------
    for j = 1:N
        x = spm_vec(x) + Q*spm_vec(f(x,u,P,M));
        x = spm_unvec(x,M.x);
    end
 
    % output - implement g(x)
    %----------------------------------------------------------------------
    if length(g)
        y(:,i) = spm_vec(g(x,u,P,M));
    else
        y(:,i) = spm_vec(x);
    end
 
end
 
% transpose
%--------------------------------------------------------------------------
y      = real(y');
