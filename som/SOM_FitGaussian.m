%
% A function that will take in a list of parameters
% as well as look at global memory and see if there 
% is a minimization to perform
%
% function chi2 = SOM_Gaussian(parameters)
%
% fit a variable number of gaussians.

function chi2 = SOM_FitGaussian(parameters)

global SOMGaussian

SOMGaussian.Parms = parameters;

% Determine which elements of data to use. Only those with errors >
% 0

iIncl = find(SOMGaussian.Ye>0);

SOMGaussian.nDF = length(iIncl);

% If there are only two parameters then force mu=0;

if length(parameters) > 2
  mus = parameters(1);
  amps = parameters(2);
  sigmas = parameters(3);
else
  mus = 0;
  amps = parameters(1);
  sigmas = parameters(2);
end

gausses = 0;

SOMGaussian.Yth = gaussian(SOMGaussian.X,mus,sigmas,amps);

SOMGaussian.Residuals = SOMGaussian.Yth - SOMGaussian.Y;

chi2 = sum((SOMGaussian.Residuals(iIncl).^2)./(SOMGaussian.Ye(iIncl).^2));

%
% Return
%

%function retGauss = gaussian(xVals,mu,sigma,amplitude)

function retGauss = gaussian(xVals,mu,sigma,amplitude)

retGauss = exp(-.5*((xVals-mu)/sigma).^2);

retGauss = retGauss/max(retGauss)*amplitude;

%
% all done
%
