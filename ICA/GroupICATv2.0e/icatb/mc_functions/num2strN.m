% Written by Omar Nadeem, UCSD
% omar.nadeem@hotmail.com

% Floors a real number and converts it to an N-digit string, e.g.
% for N=3 1 becomes 001, 34 becomes 034 and 876 remains the same.
% Has various uses, e.g. displaying the time in MM:SS format:
% [num2strN(round(timeElapsed/60),3) ':' num2strN(mod(timeElapsed,60),2)]

function numstr = num2strN(num,N)
    strZeros = ''; 
    numZeros = N - length(num2str(floor(num)));
    for i=1:numZeros
        strZeros = strcat(strZeros,'0');
    end
    numstr = strcat(strZeros,num2str(floor(num)));
end