function qc_FrameReport(out,Rname,thresh)
%
% Input:
%   out
%       out{1} - mean of masked frames
%       out{2} - z score of mean frames
%       out{3} - z score of difference between mean frames
%       out{4} - mse between frames
%   Rname - file name for printing; include extension

scrsz = get(0,'ScreenSize');
                 
h = figure('Position',[1 scrsz(4)/2 1280 900],'visible','off');
plot(out{1});
title('Frame Mean Values','FontSize',16);
xlabel('Frame','FontSize',16); ylabel('Mean Intensity','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose',Rname,h);
close(h);

h = figure('Position',[1 scrsz(4)/2 1280 720],'visible','off');
plot(out{2});
title('Z Scored Frame Means','FontSize',16);
xlabel('Frame','FontSize',16); ylabel('Z Score','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose','-append',Rname,h);
close(h);

tp = 1:length(out{3});
thresh = thresh*ones(length(out{3}),1);
h = figure('position',[1 scrsz(4)/2 1280 720],'visible','off');
plot(tp,out{3},'b',tp,thresh,'k--',tp,-thresh,'k--');
ylim([-10 10]);
title('Standardized diff between frame means','FontSize',16);
xlabel('Frame','FontSize',16);ylabel('Z Score','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose','-append',Rname,h);
close(h);

h = figure('position',[1 scrsz(4)/2 1280 720],'visible','off');
plot(out{4});
title('MSE between frames','FontSize',16);
xlabel('Frame','FontSize',16);ylabel('MSE','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose','-append',Rname,h);
close(h);

if isunix || ismac
    [pathstr file ext] = fileparts(Rname);
    pdfName = fullfile(pathstr,[file '.pdf']);
    cmd = sprintf('ps2pdf %s %s',Rname,pdfName);
    system(cmd);
    delete(Rname);
else
    fprintf(1,'No PDF for you!\n');
end
