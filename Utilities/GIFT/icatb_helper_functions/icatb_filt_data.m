function data = icatb_filt_data(data, TR, HFcutoff)
%% Filter data

if (~exist('HFcutoff', 'var'))
    HFcutoff = 0.15;
end

NyqF = (1/TR) / 2;
Wn = HFcutoff / NyqF;

try
    [bfilter, afilter] = butter(5, Wn);
catch
    [bfilter, afilter] = icatb_butter(5, Wn);
end

try
    data = filtfilt(bfilter, afilter, data);
catch
    data = icatb_filtfilt(bfilter, afilter, data);
end