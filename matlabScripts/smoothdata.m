function outdata = smoothdata(data,  TR, cutoff, N_coeffs,  verbose)
% function outdata = smoothdata(data,  TR, cutoff, N_coeffs [,verbose])
%
%
% (c) 2005 Luis Hernandez-Garcia 
% University of Michigan
% report bugs to:  hernan@umich.edu
%
%
% This is a low pass FIR filter using the Parks Mclellan design algorithm
% The phase introduced by the filter is linear and is un-done by 
% filtering the data again, backwards.It uses 11 coefficients.
%
% data  - a vector of input data
% TR    - sampling rate of the data in seconds (sampling period, actually)
% cutoff  -  the desired cut-off frequency in Hz.
% N_coeffs - number of coefficients for the filter (sharper cutoffs with more coeffs.)
% verbose -  if you want to see what it does to the data, use verbose=1
%         if just want to filter the data, don't use the argument at all.
%
    

    %data = data-mean(data);
    nyquist = 1/(2*TR);
    
    %%%%%%  These are the important lines of the code   %%%%%%%%%%%%%
    % convert cutoff frequency from Hz to pi*rads
    cutoff = cutoff  / nyquist;
    b = remez(N_coeffs, [0 cutoff-0.005  cutoff+0.005  1], [1 1 0 0]);
    outdata = filtfilt(b,1, data);
    
    %b = remez(10, [0 0.05  0.2  1], [0 0 1 1]);
    %outdata = filtfilt(b,1, outdata);
    
    %outdata = outdata * mean(data)/mean(outdata);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
if (nargin==5)
    close all
    freqz(b)
    figure

    % Read the data from file
%    data = load(data_file);
%    data = data(:,2);
    len = max(size(data));
    time = [1:len] * TR;
    
    xlabel('sec.')
    
    % Fourier Transform the data
    fdata = fftshift(fft(data));   
    scalefactor = max(abs(fdata)); 
    
    %frequency range:
    f = [1:len]';
    f = (f - len/2 ) * 1/(TR * len);

    % Plotting the data before the filter:
   
    subplot(2,1,1) , hold on,plot(time, (data))
    subplot(2,1,2), plot(f, abs(fdata)),...
        axis([0 1/(2*TR)  0  scalefactor]), xlabel('Hz.');
      
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Make  Fourier Domain Filter by hand
    %ffilt = ones(len, 1);
    %co  = len/2  +  cutoff * (TR * len);
    %ffilt(co:end) = exp(-((f(co:end) - cutoff).^2) / 0.001 );
    %co  = len/2  - cutoff * (TR * len);
    %ffilt(1:co)   = exp( -((f(1:co) + cutoff).^2) / 0.001 );
        
    %subplot(2,1,2) , hold on , plot(f, ffilt*scalefactor/2 ,'g');
    %whos
        
    % Apply the filter to the data and IFT it
    %fdata  = fdata .* ffilt;
    %data = ifft(fdata);
    
     % Fourier Transform the data
    outfdata = fftshift(fft(outdata));
    
%     % Let's look at the impulse response of the filter:
%     % the impulse is a spike halfway through the time series
%     impulse= zeros(size(data));
%     impulse(max(size(data))/2) = 1;
%     
%     impulse_response = filtfilt(b,1,impulse);
%     
%     freq_response = fftshift(fft(impulse_response));
%     freq_impulse = fftshift(fft(impulse));
%     
%     freq_gain = 20*log10( abs(freq_response).^2 ./ abs(freq_impulse) ) ;
%   
    
    %Plotting the reponse of the filter
    subplot(2,1,1) , hold on,plot(time, (outdata), 'r'), title ('Time Domain'), legend('Before', 'After')
    subplot(2,1,2), hold on, plot(f, abs(outfdata), 'r'), title ('Frequency Domain');
    legend('Before', 'After');
    %subplot(3,1,3), hold on, plot(f, freq_gain , 'g');

end

return

