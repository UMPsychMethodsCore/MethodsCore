function vargout=check_design(des_old, des_new, cont_new)
%This function is for displaying the old original design matrix as well
%as the new design matrix and contrast to make sure it has been set up
%properly and the contrast is referring to the correct columns of the
%design matrix.



f = figure('Visible','off','Position',[260,100,300,450],...
	   'MenuBar', 'none','color', [.7, .7, .7], ...
	   'name', 'Check Design', ...
	   'NumberTitle', 'off');



uicontrol(f, 'Style', 'frame', 'Position', [5, 415, 290 30]);



text_dir=uicontrol(f, 'Style', 'text', 'String', ['Check new design and' ...
		    ' contrast'], 'Position', [10,420, 280, 20], ...
		   'backgroundcolor', [.7, .7, .7], ...
		   'FontSize', 16,'Tooltipstring', ['Matrix columns ', ...
		   'must have same meanings']);

text_original=uicontrol(f, 'Style', 'text', 'String', ...
			'Original Design','Position',...
			[10, 385, 135,15],'backgroundcolor', [.7, .7, .7]);
axis_old=axes('Units', 'pixels','Position', [10, 90, 135, 290],'YTickLabel','', 'XTickLabel','');

text_new=uicontrol(f, 'Style', 'text', 'String', 'New Design',...
		   'Position', [155, 385, 135,15],...
		   'backgroundcolor', [.7, .7, .7]);
axis_new=axes('Units', 'pixels','Position', [155, 90, 135, 290],...
	      'YTickLabel','', 'XTickLabel','');

text_cont=uicontrol(f, 'Style', 'text', 'String', 'Contrast',...
		    'Position',[155,75, 135,15],'backgroundcolor', [.7, .7, .7] );
axis_cont=axes('Units', 'pixels','Position', [155, 60, 135, 15],'YTickLabel','', 'XTickLabel','');

close_button=uicontrol(f, 'Style', 'pushbutton', 'String', 'Close', 'Position', [25, 10, 250, 30], 'Callback', 'close(gcf)','backgroundcolor', [0.6, 0.6, 0.6]);



dim_des_old=size(des_old);
set(f, 'CurrentAxes',axis_old)
imagesc(.5,[1:dim_des_old(1)]-.5, des_old, [-1,1])
colormap(gray(300))
set(gca, 'XTickLabel', '', 'XTick', 1:dim_des_old(2),'YTick', 1:dim_des_old(1), 'YTickLabel', '', 'YGrid', 'on', 'XGrid', 'on')

dim_des_new=size(des_new);
set(f, 'CurrentAxes',axis_new)
imagesc(.5,[1:dim_des_new(1)]-.5, des_new, [-1,1])
colormap(gray(300))
set(gca, 'XTickLabel', '', 'XTick', 1:dim_des_new(2),'YTick', 1:dim_des_new(1),'YTickLabel', '', 'YGrid', 'on', 'XGrid', 'on')


set(f, 'CurrentAxes',axis_cont)
imagesc(.5, [1:length(cont_new)]-.5,cont_new, [-1,1])
colormap(gray(100))
set(gca, 'XTickLabel', '', 'XTick', 1:length(cont_new), 'YTickLabel', '', 'XGrid', 'on')

set(f, 'Visible', 'on');



end