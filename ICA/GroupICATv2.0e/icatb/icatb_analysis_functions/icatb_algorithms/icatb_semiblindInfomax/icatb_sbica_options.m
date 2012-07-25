function ICA_Options = icatb_sbica_options(ICA_Options, dewhiteM)
% Add some more options to use semi-blind ICA

% Time dimension
tdim = size(dewhiteM, 1);

whiteM = pinv(dewhiteM);

% Number of Independent Comp.
numOfIC = size(dewhiteM, 2);

%tar and nov are SPM time courses
RA = randn(tdim, numOfIC)/.05;

ind = strmatch('TC', ICA_Options(1:2:end), 'exact');

if isempty(ind)
    error('Time course constraints are not selected.');
end

TC = ICA_Options{2*ind(1)};

% Make the timecourses to match the tdim (number of time points) by ICdim
% (number of components)
if size(TC, 1) ~= tdim
    TC = TC';
end

% Average of the time course constraints
RA(:, 1) = sum(TC, 2) / size(TC, 2);

% get the number of ICA options
numOptions = length(ICA_Options);

ICA_Options{numOptions + 1} = 'weights';
ICA_Options{numOptions + 2} = inv(whiteM*RA)/10000000;

numOptions = numOptions + 2;

% Pass dewhiteM, prefs
prefs = [.5 zeros(1, numOfIC - 1)];

% Appending the ICA options
ICA_Options{numOptions + 1} = 'prefs';
ICA_Options{numOptions + 2} = prefs;

numOptions = numOptions + 2;

ICA_Options{numOptions + 1} = 'dewhiteM';
ICA_Options{numOptions + 2} = dewhiteM;

numOptions = numOptions + 2;

ICA_Options{numOptions + 1} = 'whiteM';
ICA_Options{numOptions + 2} = whiteM;
