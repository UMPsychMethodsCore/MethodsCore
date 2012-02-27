function PhysioMat = mkPhysioMatPhilips(physfile, sampTime, disdaq, Nslices, TR, saveFile)
% function PhysioMat = mkPhysioMat(physfile, sampTime, disdaq, Nslices, TR, saveFile)
% physfile: names of the physio data file (4 column format)
% sampTime: sampling period for physio A/D
% disdaq: number of discarded images. these are not recorded in the Pfile, but the physio file contains data
% acquired during that time
% Nslices: number of slices in each frame
% TR: scanner image acquisition tims


%
% Hacked for philips by Robert Welsh
% Sept 2011
% Ann Arbor
%

phys = load(physfile);
Nimgs = floor(size(phys,1)*sampTime / TR) - disdaq ;
Tslice = TR/Nslices;
AQlength = round((Nimgs+disdaq)*TR/sampTime);

time = phys(1:AQlength,1);
resp = phys(1:AQlength,2);
card = phys(1:AQlength,3);

resp = resp-mean(resp);

filtered_resp = smoothdata(resp, sampTime, 1, 9);
%plot(filtered_resp)

filtered_resp = filtered_resp-mean(filtered_resp);

% and we smooth again by just averaging the 1/2 second around
% the wave form.
% added this for philips as the philips data is NOT smooth and we really 
% need to smooth it alot.
% -Robert

filtered_resp2 = smooth(filtered_resp,round(.5/sampTime));
filtered_resp2 = filtered_resp2-mean(filtered_resp2);

fprintf('\nExtracting respiratory phases ... finding resp peaks');
respPeaks = getPeaks(filtered_resp2);

% Okay, not we need to make a set of delta functions where the 
% found peaks are. Unfortunately some of them are still not 
% really peaks due to the bumpyness of the philips respiratory 
% signal, so we need to now only allow those peaks that are
% also above the mean of the time course of the resp trace.
% - Robert

peakDelta = 0*filtered_resp2;

peakDelta(respPeaks) = 1;

% Now only allow peaks where the peak is above zero?

peakDelta = peakDelta.*(filtered_resp2>0);

% Finally we have our candidate peaks.

respPeaks = find(peakDelta);

fprintf('\nMaking the resp phases vector');
rphases = zeros(size(resp));
rphases(respPeaks) = 1;
respPeakDist = diff(respPeaks);

plot(time,resp/max(resp));
hold on;
plot(time,filtered_resp/max(filtered_resp),'r');
plot(time,filtered_resp2/max(filtered_resp2),'k');
bar(time,peakDelta*1.2,'g');
grid on;

for r=1:length(respPeaks)-1;
    rphases(respPeaks(r):respPeaks(r+1)) = [0:2*pi/respPeakDist(r): 2*pi];
end

fprintf('\nMaking the cardiac phases vector');
cardPeaks = find(card);
cphases = card;
cardPeakDist = diff(cardPeaks);

for r=1:length(cardPeaks)-1;
    cphases(cardPeaks(r):cardPeaks(r+1)) = [0:2*pi/cardPeakDist(r): 2*pi];
end

fprintf('\nMaking polynomial regressons (3rd order) for detrending\n');
t = (0:Nimgs-1)';
polynomial = [ones(size(t)) t/sum(t) t.^2/sum(t.^2)  t.^3/sum(t.^3) ];

fprintf('\nRe-Sampling the phases at each slice\n')
PhysioMat = zeros(Nslices, Nimgs, 12);

% Must start ts at 1 if there are no disdaqs, this was a bug!
% the math (disdaq)*TR/sampTime +  Tslice*sl will equal zero when there 
% are no disdaqs which is typical on a philips machine.

for sl=0:Nslices -1
    fprintf('resampling for slice ...%d\n',sl)
    ts = (disdaq)*TR/sampTime +  Tslice*sl + 1 : ...
        round(TR/sampTime): ...
        AQlength-1;
    % Change the definition of ts to be limited to the length of the
    % polynomial function as some cases of philips data it's too big.
    % not sure what is going to happen if the philips data is accidentially
    % truncated.
    % -Robert
    ts = round(ts(1:length(polynomial(:,1))));
    cph = [sin(cphases(ts)) cos(cphases(ts)) sin(2*cphases(ts)) cos(2*cphases(ts)) ];
    rph = [sin(rphases(ts)) cos(rphases(ts)) sin(2*rphases(ts)) cos(2*rphases(ts)) ];
    PhysioMat(sl+1,:,:) = [polynomial cph rph];
    % No need to image the design matrix.
    %
    % imagesc(squeeze([polynomial cph rph]))
end

save(saveFile,'PhysioMat','resp','filtered_resp','filtered_resp2','peakDelta','card','time');

return
