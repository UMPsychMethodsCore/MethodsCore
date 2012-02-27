

%
% fit three lines.
%

function chiSqu = fitLines(params)

global fitVoxelCurveMem

if isfield(fitVoxelCurveMem,'params') == 0
    fitVoxelCurveMem.params = [];
end

fitVoxelCurveMem.params = [fitVoxelCurveMem.params ; params];

iBeg = [];
iMid = [];
iEnd = [];

iBeg = find(fitVoxelCurveMem.xVals <= params(1));
iMid = find(fitVoxelCurveMem.xVals >= params(1) & fitVoxelCurveMem.xVals <= params(2));
iEnd = find(fitVoxelCurveMem.xVals >= params(2));

yTheoryBeg = [];
yTheoryMid = [];
yTheoryEnd = [];

chiSqu = 0;

if length(iBeg) > 1
    fitBeg = fitData2Line(fitVoxelCurveMem.xVals(iBeg),fitVoxelCurveMem.yVals(iBeg));
    yTheoryBeg = fitBeg.p2+fitBeg.p1*fitVoxelCurveMem.xVals(iBeg);
else
    yTheoryBeg = mean(fitVoxelCurveMem.yVals(iBeg));
end

chiSqu = [chiSqu + sum((yTheoryBeg - fitVoxelCurveMem.yVals(iBeg)).^2)];

if length(iMid) > 1
    fitMid = fitData2Line(fitVoxelCurveMem.xVals(iMid),fitVoxelCurveMem.yVals(iMid));
    yTheoryMid = fitMid.p2+fitMid.p1*fitVoxelCurveMem.xVals(iMid);
else
    yTheoryMid = mean(fitVoxelCurveMem.yVals(iMid));
end

chiSqu = [chiSqu + sum((yTheoryMid - fitVoxelCurveMem.yVals(iMid)).^2)];

if length(iEnd) > 1
    fitEnd = fitData2Line(fitVoxelCurveMem.xVals(iEnd),fitVoxelCurveMem.yVals(iEnd));
    yTheoryEnd = fitEnd.p2+fitEnd.p1*fitVoxelCurveMem.xVals(iEnd);
else
    yTheoryEnd = mean(fitVoxelCurveMem.yVals(iEnd));
end

chiSqu = [chiSqu + sum((yTheoryEnd - fitVoxelCurveMem.yVals(iEnd)).^2)];

chiSqu = sum(chiSqu);

fitVoxelCurveMem.chiSqu = chiSqu;

if isfield(fitVoxelCurveMem,'figure')
    figure(fitVoxelCurveMem.figure)
    if isfield(fitVoxelCurveMem,'lineBegHdl')
        if fitVoxelCurveMem.lineBegHdl > 0
            delete(fitVoxelCurveMem.lineBegHdl);
        end
    end
    if isfield(fitVoxelCurveMem,'lineMidHdl')
        if fitVoxelCurveMem.lineMidHdl > 0
            delete(fitVoxelCurveMem.lineMidHdl);
        end
    end
    if isfield(fitVoxelCurveMem,'lineEndHdl')
        if fitVoxelCurveMem.lineEndHdl > 0
            delete(fitVoxelCurveMem.lineEndHdl);
        end
    end
    hold on;
    fitVoxelCurveMem.lineBegHdl = 0;
    fitVoxelCurveMem.lineMidHdl = 0;
    fitVoxelCurveMem.lineEndHdl = 0;
    fitVoxelCurveMem.lineBegHdl = plot(fitVoxelCurveMem.xVals(iBeg),yTheoryBeg*fitVoxelCurveMem.yScale,'g');
    fitVoxelCurveMem.lineMidHdl = plot(fitVoxelCurveMem.xVals(iMid),yTheoryMid*fitVoxelCurveMem.yScale,'g');
    fitVoxelCurveMem.lineEndHdl = plot(fitVoxelCurveMem.xVals(iEnd),yTheoryEnd*fitVoxelCurveMem.yScale,'g');
    set(fitVoxelCurveMem.lineBegHdl,'LineWidth',2);
    set(fitVoxelCurveMem.lineMidHdl,'LineWidth',2);
    set(fitVoxelCurveMem.lineEndHdl,'LineWidth',2);
    drawnow;
end

fitVoxelCurveMem.iBeg = iBeg;
fitVoxelCurveMem.iMid = iMid;
fitVoxelCurveMem.iEnd = iEnd;

return

