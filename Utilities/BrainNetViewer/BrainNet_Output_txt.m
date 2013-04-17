function output_txt = BrainNet_Output_txt(obj,event_obj)
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

%% Added by Mingrui Xia, 20120806 show value of selected vertex
global FLAG
global surf
if FLAG.Loadfile > 8    
    coordmat = repmat(pos',[1,size(surf.coord,2)]);
    dif = sum(surf.coord - coordmat);
    output_txt{end+1} = ['Val: ',num2str(surf.T(dif==0))];    
end

%%
global OutputText
if ~isempty(OutputText.AAL)
    sub = round(OutputText.AAL.AAL_hdr.mat \ [pos,1]');
    ind = OutputText.AAL.AAL_vol(sub(1),sub(2),sub(3));
    if ind ~= 0
        output_txt{end+1} = OutputText.AAL.AAL_label{ind};
    end
end
if ~isempty(OutputText.Brodmann)
    sub = round(OutputText.Brodmann.Brodmann_hdr.mat \ [pos,1]');
    ind = OutputText.Brodmann.Brodmann_vol(sub(1),sub(2),sub(3));
    if ind ~= 0
        output_txt{end+1} = ['Brodmann Area',num2str(ind)];
    end
end