function [ output_args ] = mc_draw_box( x1, y1, x2, y2 )
%MC_DRAW_BOX Summary of this function goes here
%   Detailed explanation goes here

line([x1 x1],[y1 y2])
line([x1 x2],[y1 y1])
line([x2 x2],[y1 y2])
line([x1 x2],[y2 y2])

end

