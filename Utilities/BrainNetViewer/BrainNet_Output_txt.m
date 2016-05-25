function output_txt = myfunction(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
output_txt = {['X: ',num2str(pos(1),4)],...
    ['Y: ',num2str(pos(2),4)]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end
global AAL
if ~isempty(AAL)
    sub = round(AAL.AAL_hdr.mat \ [pos,1]');
    ind = AAL.AAL_vol(sub(1),sub(2),sub(3));
    if ind ~= 0
        output_txt{end+1} = AAL.AAL_label{ind};
    end
end