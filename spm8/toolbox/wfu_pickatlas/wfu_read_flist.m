function reply = wfu_read_flist(filename)

if ~exist('filename')
    [file,path] = uigetfile('*.flist','Choose an flist');
    filename    = fullfile(path,file); 
end
 
reply   = textread(filename,'%s','commentstyle','matlab');
reply   = char(reply);

if ~isempty(str2num(reply(1,:)))
	records = str2num(reply(1,:));
	reply   = reply(2:records + 1,:);
end

