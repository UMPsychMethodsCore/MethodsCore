function ROI = wfu_txt2roi(fname)
%
% function ROI = wfu_txt2roi(fname)
%
%     convert input text listing of regions into ROI struct
%
% Any input line in fname that begins with a numeric value is accepted as
% an entry into the ROI struct.  The remainder of any valid input line up 
% to an optional TAB character is interpreted as the title for the region.
%
[fid, message] = fopen(fname, 'rt');
if fid ==  -1
    error(message);
end
ROI = struct('ID', 0, 'Nom_C', '', 'Nom_L', '');
i = 1;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    if ~isempty(tline)
        m = str2num(tline(1));
        if ~isempty(m)
            [n, rem] = strread(tline, '%d %s %*s', 'delimiter', '\n');
            str = strread(char(rem), '%s', 'delimiter', '\t');
            title = char(str(1));
%             disp(sprintf('n = *%d*, title = *%s*', n, title));
            ROI(i).ID = n;
            ROI(i).Nom_C = title;
            ROI(i).Nom_L = title;
            i = i + 1;
        end
    end
end
fclose(fid);
