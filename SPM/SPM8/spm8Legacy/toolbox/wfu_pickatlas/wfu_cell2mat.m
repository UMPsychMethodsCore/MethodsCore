function [m] = wfu_cell2mat(c)
% wfu_cell2mat convert a cell array of matrices into one matrix.

cells = prod(size(c));

if cells == 0
  m = [];
  return
end

if cells == 1
  m = c{1};
  return
end

[rows,cols] = size(c);

if (cols == 1)
  m = cell(1,rows);
  for i=1:rows
    m{i} = [c{i}]';
  end
  m = [m{:}]';
  
else
  m = cell(1,rows);
  for i=1:rows
    m{i} = [c{i,[1:cols]}]';
  end
  m = [m{1,[1:rows]}]';
end
