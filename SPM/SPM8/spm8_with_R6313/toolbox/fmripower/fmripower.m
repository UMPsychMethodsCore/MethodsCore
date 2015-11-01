function fmripower()

%grab the screen size so we can center the windows
scrsz = get(0,'ScreenSize');

prompt_width = 400;
prompt_height = 230;

%this constructs the main gui in the center of the scene
prompt = figure('Visible','on','Position',[scrsz(3)/2-prompt_width/2, ...
    scrsz(4)/2-prompt_height/2,prompt_width,prompt_height], ...
	   'MenuBar', 'none', 'Name', 'Program Selection', ...
	   'NumberTitle', 'off', 'color', [.7, .7, .7]);

uicontrol(prompt,'Style','pushbutton','String',...
          'FSL', 'Callback',{@fsl_pushbutton_callback},...
          'Position',[60,60,100,100], 'backgroundcolor', [0.6, 0.6, 0.6]); 

uicontrol(prompt,'Style','pushbutton','String',...
          'SPM', 'Callback',{@spm_pushbutton_callback},...
          'Position',[240,60,100,100], 'backgroundcolor', [0.6, 0.6, 0.6]); 
          
uicontrol(prompt,'Style', 'text','Position',[30,175,350,40],...
			'String', 'Please select the program you used to generate your analysis',...
			'FontSize', 13);

uiwait(prompt);
close(prompt);

function spm_pushbutton_callback(source,eventdata)
	fmripower_spm;
	uiresume(gcbf);

function fsl_pushbutton_callback(source,eventdata)
	fmripower_fsl;
	uiresume(gcbf);