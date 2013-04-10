function auc = mc_AUCcalculation(Data,SubjDir,Thresh,subName)

    
% Total subject number x run number
sub_count = 0;

for iSubject = 1:size(SubjDir,1)
    for jRun = 1:size(SubjDir{iSubject,3},2)
        sub_count = sub_count+1;
    end
end

% arrays that save the sum and average of metric values
sumOutput = zeros(length(Thresh),1);
aveOutput = zeros(length(Thresh),1);

for mThresh = 1:length(Thresh)
    
    for iSubject = 1:size(SubjDir,1)
        for jRun = 1:size(SubjDir{iSubject,3},2)
            sumOutput(mThresh) = sumOutput(mThresh) + Data{iSubject,jRun,mThresh}.(subName);
        end
    end
    
    aveOutput(mThresh) = sumOutput(mThresh)/sub_count;
    
end

% Sort the threshold values, for plot purpose
[ThreshSorted,index]=sort(Thresh);
aveOutputSorted = aveOutput(index);

% Plot the threshold - metric curve
figure;
plot(ThreshSorted,aveOutputSorted);
xlabel('Threshold');
ylabel(subName);

% Calculate AUC
auc = 0;
for i = 1:(length(Thresh)-1)
    auc = auc+(aveOutputSorted(i)+aveOutputSorted(i+1))*(ThreshSorted(i+1)-ThreshSorted(i))*0.5;
end
