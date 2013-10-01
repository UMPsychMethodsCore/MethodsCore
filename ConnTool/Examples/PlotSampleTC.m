
if exist('parameters','var') == 0
    fprintf('You need to load a parameters file\n');
    return
end

try
    sampleTC = parameters.data.run(1).sampleTC;
catch
    fprintf('You parameters does not have the sampleTC stored\n');
    return
end

try
    fmriTR = parameters.TIME.run(1).TR;
catch
    fprintf('You parameters does not have the fmriTR stored\n');
    return
end


% % fig1 = figure;
% % plt1 = plot(fmriTR*(1:length(sampleTC(1,:))),sampleTC(1,:));
% % 
% % fig1Pos = get(fig1,'position');
% % set(fig1,'position',[fig1Pos(1:2) 500 200]);
% % set(get(plt1,'parent'),'linewidth',2,'fontweight','bold','fontsize',14);
% % xlb1 = xlabel('Time (Seconds)');
% % ylb1 = ylabel('Raw MR signal');

theKey = ['R' parameters.RegressFLAGS.order];

for iPlot = 1:size(sampleTC,1)-1
    newFig = figure;
    pl11 = plot(fmriTR*(1:length(sampleTC(iPlot,:))),sampleTC(iPlot,:),'k','linewidth',2);
    hold on;
    pl12 = plot(fmriTR*(1:length(sampleTC(iPlot+1,:))),sampleTC(iPlot+1,:),'r','linewidth',2);
    axvals = axis;
    axis([130 210 axvals(3:4)]);
    set(newFig,'position',[fig1Pos(1:2) 500 200]);
    set(get(pl11,'parent'),'linewidth',2,'fontweight','bold','fontsize',14);
    xlb1 = xlabel('Time (Seconds)');
    %ylb1 = ylabel('Raw MR signal');
    legend(theKey(iPlot),theKey(iPlot+1));
    title(sprintf('Processing step %d\\rightarrow%d',iPlot,iPlot+1),'fontweight','bold','fontsize',14);
    set(newFig,'paperpositionmode','auto');
    drawnow;
    print('-dpng',sprintf('processingStep_%d_%d.png',iPlot,iPlot+1));
end
