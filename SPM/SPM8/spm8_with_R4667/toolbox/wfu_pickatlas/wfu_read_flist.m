function reply = wfu_read_flist(filename)

if ~exist('filename')
    filename = wfu_pickfile('*.flist','Choose an flist'); 
end
 
reply   = textread(filename,'%s','commentstyle','matlab','delimiter','\n');
reply   = char(reply);

if ~isempty(str2num(reply(1,:)))
	records = str2num(reply(1,:));
	reply   = reply(2:records + 1,:);
end

