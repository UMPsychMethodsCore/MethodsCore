% This is li_test.m, the left-right-helper function of the LI-toolbox:
% Call with li_test to assess handeness AS VALID ON YOUR COMPUTER!
%
% Please see the accompanying Readme.txt for more infos.
% !USE AT YOUR OWN RISK! 
% Yours, Marko Wilke
%
% ==========================================================================================================
%                                          Preludes: settings, inputs, etc.
% ==========================================================================================================


% get a nice and clean environment
  clc
  fg = spm_figure('Findwin','Graphics');
  fi = spm_figure('Findwin','Interactive');
  spm_figure('Clear',fg);
  spm_figure('Clear',fi);


% avoid display of Divide by Zero
  warning off MATLAB:divideByZero


% using variable PP to inform user
  PP = 'Welcome to the LI test script';
  spm('FigName', PP);


% set variables for common cases; change stdpth if your masks reside elsewhere
  stdpth = [spm('Dir') filesep 'toolbox' filesep 'LI' filesep 'data'];


% ==========================================================================================================
%                                    	  Show reference and local images
% ==========================================================================================================


% find our little demo image
  a = [stdpth filesep 'demo.fig'];


% load image, prepare progress reports
  gcf1 = openfig(a);
  set(0,'Units','pixels');
  scnsize = get(0,'ScreenSize');
  pos1 = [round(scnsize(3)/20), round(scnsize(4)/20), round(scnsize(3)/10*4.5), round(scnsize(4)/10*8.5)];
  set(gcf1, 'Position', pos1);  
  axis off;

		
% now right figure
  show = str2mat([stdpth filesep 'LI-left.img'], [stdpth filesep 'LI-right.img']);
  spm_check_registration(show);


% now let user decide on what to do
  msgbox(['The image shown on the LEFT side ("This is what it should look like") should look like the spm_'...
	 'graphics window on the RIGHT side (i.e., this is what it looks like on your computer); if it does,'...
	 ' you SHOULD be fine. If it does NOT, you may run into PROBLEMS with handedness! The toolbox will now TRY'...
	 ' to check the handedness assumptions and potentially switch the left/right images coming with this toolbox,'...
	 ' but there is no guarantee it will work in all cases and all settings.'...
	 ' Please check with a local dataset of known laterality. Thank you!'], 'LI-Toolbox: Handedness test')


% ==========================================================================================================
%                                        	  Clean ups
% ==========================================================================================================


% ===== say goodbye ===== 
  PP = 'Have a nice day  :)';
  spm('FigName', PP);
  clear stdpth a gcf1 scnsize pos1 show


% re-enable warning
  warning on MATLAB:divideByZero


% ===== That's all folks =====