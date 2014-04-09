% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
%
% function  physdata = convertEXphysio( rootName, samplePeriod, downSample)
%
% Input should be a Philips Physio log file, and the samplePeriod is
% typically .002 seconds;
%
%
% Preferably top portion of file is removed, but we still read in
% one line at a time.
%
% Returned is 
%
%   physData(timepoint,item)
%  
%     item
%       1 = timebase
%       2 = respiratory signal
%       3 = cardiac trigger
%       4 = ones
%
%   physOK
%   
%       a flag on where things are okay or not.
%
%   philipsData
%
%       original data
%
%        column
%
%           1 v1raw
%           2 v2raw 
%           3 v1
%           4 v2
%           5 ppu
%           6 resp
%           7 gx
%           8 gy
%           9 gz
%          10 marker,  markers can be combined.
%               02H = ppu trigger, 
%               10H = start of acqu, 
%               20H = end of acquitision.
%
% Copyright Robert C. Welsh, 2011
% Ann Arbor MI
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function  [physData physOK philipsData] = convertPhilipsPhysio( rootName, samplePeriod, downSample)

fprintf('Reading physio data from scanner (Philips)');

physData    = [];
physOK      = -1;

% reserve some space.

philipsData = zeros(1e6,10);

physFID = fopen(rootName,'r');

if physFID < 1
    physData = [];
    fprintf('Error reading physio data from file : %s\n',rootName);
    return
end

READING = 1;

LINECOUNT  = 0;
PLINECOUNT = 0;

while READING
    inLine = fgetl(physFID);
    if inLine == -1
        READING = 0;
    else
        LINECOUNT = LINECOUNT + 1;
        if inLine(1) ~= '#'
            try
 	        physRecording = sscanf(inLine,'%d');
                PLINECOUNT = PLINECOUNT + 1;
                philipsData(PLINECOUNT,:) = physRecording(:);
            catch
                fprintf('Error in decoding line # %d\n',LINECOUNT);
                fprintf('%s\n',inLine);
                fclose(physFID);
                return
            end
        end
    end
    if mod(LINECOUNT,5000) == 0
        fprintf('.');
    end
end

fprintf('\n');

startIDX = find(floor(philipsData(:,end)/10)==1);

if length(startIDX) < 1
    fprintf('I can not find the start index for the physio data\n');
    fprintf('%s\n',rootName);
    fclose(physFID);
    return
end

% Trim the front off (this is needed because sometimes there are two stops 
% in the data stream.

philipsData = philipsData(startIDX(1):end,:);

% Now find the stop.

endIDX   = find(floor(philipsData(:,end)/10)==2);

if length(endIDX) < 1
    fprintf('I can not find the end index for the physio data\n');
    fprintf('%s\n',rootName);
    fclose(physFID);
    return
end

% We trim the data again, stopping at the first stop after the first start.

philipsData = philipsData(1:endIDX(1),:);

timeBase = samplePeriod*[0:size(philipsData,1)-1];

% Now we need to downsample, and not miss the cardiac gates!

physData = [timeBase' philipsData(:,6) mod(philipsData(:,end),10)==2 ones(length(timeBase),1)];

timeBase = physData(1:downSample:end,1);
respData = physData(1:downSample:end,2);
cardData = 0*respData;

iCard    = find(physData(:,3));
iCard    = round(iCard/downSample+.5);

cardData(iCard) = 1;

physData = [timeBase respData cardData ones(length(timeBase),1)];

physOK = 1;

fclose(physFID);

return


