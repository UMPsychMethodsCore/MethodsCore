function fitTextInField(text,handle)
% fitTextInField(text,handle)
%
% Fit the most text possible (from the right) into a handle (usually pushbutton)
	oldUnits=get(handle,'Units');
	set(handle,'Units','Char');
	pos = get(handle,'Position');
	handleLength = pos(3);
	if ispc
		availableLength = round(.50 * handleLength);
	else
		availableLength = round(.65 * handleLength);
	end
	if availableLength < length(text)
		text = ['...' text(end-availableLength:end)];
	end
	set(handle,'String',text);
	set(handle,'Units',oldUnits);
return