function [filename] = pickfile(filter,title)


if ~exist('filter','var') filter = '*'; end
if ~exist('title','var') title = 'Choose a file'; end
filename=[];
[fname pathname] = uigetfile(filter, title);
if fname ~= 0 filename=[pathname,fname]; end;
