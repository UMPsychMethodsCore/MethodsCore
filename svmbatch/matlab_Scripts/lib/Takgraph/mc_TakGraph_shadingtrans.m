function [ a ] = mc_TakGraph_shadingtrans( a )
% MC_TAKGRAPH_SHADINGTRANS 
% This function decides whether to use single transparency for all the cell
% shading or scaled transparency for cell based on their log10 p-values
% 
%       INPUTS
%                       a.shading                -      Options for shading set up 
%                          a.shading.transmode   -      Shading mode
%                                                       1  - Scaled transparency
%                                                       0  - Single transparency
%                       a.shading.trans0         -      Single transparency value
%                       a.shading.trans1.mode    -      How do you want to rescale your cell-level effect sizes into transparency. Express this with 1 = opaque, 0 = clear.
%                                                       1 - Provide a range. We will linearly rescale your data to this range
%                                                       2 - Provide a scale factor and a constant. The constant will be added, then the data grown away from the mean by scale factor.
%                                                       3 - Provide a scale factor and a center. Your data will be recentered to this and grown away from the center by scale factor
%                       a.shading.trans1.range   -      A range for use with scaled shading mode 1
%                       a.shading.trans1.scale   -      Scale factor for use with scaled shading modes 2 and 3
%                       a.shading.trans1.constant-      Constant for use with scaled shading mode 2
%                       a.shading.trans1.center  -      Center for use with scaled shading mode 3
%                       a.shading.trans1.startpt -      1x2 vector of X, Y to be top left corner of first square of scaled transparency shade bar 
%                       a.shading.trans1.xsize   -      In scaled shading, how big each transparency square should be in x (left/right)
%                       a.shading.trans1.ysize   -      In scaled shading, how big each transparency square should be in y (down/up)

%                      
%       OUTPUTS
%                       a.shading.transparency  -       Transparency of the shading blocks. 
%                                                       If mode 0 is selected, it will be a single value;
%                                                       If mode 1 is selected, it will be a nNet x Nnet matrix that contains transparency value for each cell

hold on;

effect_size = a.stats.cellsig;

if ~isfield(a.shading,'transmode')
    a.shading.transmode = 0;
end

switch a.shading.transmode
    case 0
        if (~isfield(a.shading,'trans0'))
            a.shading.trans0 = 0.5;
        end
        a.shading.transparency = a.shading.trans0;
    
    case 1
        
        % Default
        if (~isfield(a.shading,'trans1')
            error('Nothing defined about the scaled transparency: You gotta do something to eat the food!')
        end
        if (~isfiled(a.shading.trans1,'mode')
            a.shading.trans1.mode = 1; 
        end
        
        % Variable Initialization
        range    = a.shading.trans1.range;
        scale    = a.shading.trans1.scale;
        constant = a.shading.trans1.constant;
        center   = a.shading.trans1.center;
        startpt  = a.shading.trans1.startpt;
        xsize    = a.shading.trans1.xsize;
        ysize    = a.shading.trans1.ysize;
        
        
        % value_slice: Give this function all of the effect sizes, and it will come up with
        % 11 points that define the range. This can be used downstream
        % for use with shadebar subfunction
        in = effect_size;
        effects = reshape(in,1,numel(in));
        effects(isnan(effects)) = 0;
        effects(effects<0)=0;
        effects = effects(find(effects));
        ef_min = min(effects);
        ef_max = max(effects);
        ef_rg = range(effects);
        ef_step = ef_rg/10;
        ef = ef_min + ef_step * (0:10);
        values = ef;
        sm_values = values;
        
        % Effects2Transp
        % Give it two things. Your effect sizes and the a.Shading.Trans struct. It will translate
        % your effect sizes into transparency based on the options set in the struct
        % You can also give it your testpoints, which it will translate into transparencies to make a shadebar
        orig_size = size(effect_size);
        effect_vec = reshape(effect_size,1,numel(effect_size));
        effect_vec(isnan(effect_vec)) = 0 ; % change any of the NaN's to 0's which should not bias anything
        in.raw  = effect_vec;
        in.test = sm_values;
        switch a.shading.trans1.mode
            case 1
                in.range               = range;
                [effect_vec,sm_transp] = rescale1(in);
            case 2
                in.constant            = constant;
                in.scale               = scale;
                in.lowlimit            = 0;
                in.uplimit             = 1;
                [effect_vec,sm_transp] = rescale2(in);                
            case 3
                in.center              = center;
                in.scale               = scale;
                in.lowlimit            = 0;
                in.uplimit             = 0;
                [effect_vec,sm_transp] = rescale3(in);
        end
        
        transp                 = effect_vec; % do not take complement, since FaceAlpha is already scaled so 1 = opaque
        a.shading.transparency = reshape(transp,orig_size); % make it back into a matrix

        scaleout = add_shadebar(sm_values,sm_transp,startpt,xsize,ysize);
        
        
        
end

hold off;



function [out, test_rescaled] = rescale1(in)
% Linearly rescale in.raw into range specified by in.range
% NOTE - in.raw and in.range MUST BE ROW VECTORS
% in.test are some other points that you want transformed according to the rules of in.raw
% This will break if you give it something with no variance or something stupid

orig = in.raw;
origIDX = in.raw; % store how to index back into orig
in.raw = in.raw(find(in.raw)); % get rid of all nonzero elements
if range(in.raw)~=0 && range(in.range)~=0
    in.raw = in.raw - min(in.raw); % get it scaled into (0, max)

    in.raw = in.raw ./ max(in.raw); % scale it to (0,1)

    in.raw = in.raw .* range(in.range); % scale it so that ranges match

    in.raw = in.raw + min(in.range); % translate so that left edges match

    if isfield(in,'test') % rescale test points according to rules of the rest
        in.test = in.test - min(in.raw);        
        in.test = in.test ./ max(in.test);
        in.test = in.test .* range(in.range);
        in.test = in.test + min(in.range);
        test_rescaled = in.test;
    end
out = zeros(size(orig));
out(origIDX) = in.raw;
end

function [out, test_rescaled] = rescale2(in)
% This will add a constant to a vector, and then grow it by a factor away from the middle of the limits
% It can also trim the result so that it stays in a reasonable range
% Arguments
% in.raw
% in.constant
% in.scale
% in.lowlimit
% in.uplimit
% in.test are some other points that you want transformed according to the rules of in.raw

balance = mean([in.lowlimit in.uplimit]);

in.raw = in.raw + in.constant; % add it in the scaling factor
in.raw = in.raw - balance; % center it about balance before dilation
in.raw = in.raw .* in.scale; % dilate it by scaling factor
in.raw = in.raw + balance; % move it back to the old center | balance
in.raw(in.raw>in.uplimit) = in.uplimit; % trim any of the large values
in.raw(in.raw<in.lowlimit) = in.lowlimit; % trim small values
out = in.raw;

if isfield(in,'test') % rescale test points according to rules of the rest
    in.test = in.test + in.constant;
    in.test = in.test - balance;
    in.test = in.test .* in.scale;
    in.test = in.test + balance;
    in.test(in.test>in.uplimit) = in.uplimit;
    in.test(in.test<in.lowlimit) = in.lowlimit;
    test_rescaled = in.test;
end

function [out test_rescaled] = rescale3(in)
% This will recenter your data about a variable point and grow it by a scale factor away from center
% ARGS
% in.raw - your original vector
% in.center - the new center
% in.scale - the factor to grow by
% in.lowlimit
% in.uplimit
% in.test are some other points that you want transformed according to the rules of in.raw

in.raw = in.raw - mean(in.raw); % center data about 0 b4 dilation
in.raw = in.raw .* in.scale; % dilate it by scaling factor
in.raw = in.raw + in.center; % move the data to the new center
in.raw(in.raw>in.uplimit) = in.uplimit; % trim any of the large values
in.raw(in.raw<in.lowlimit) = in.lowlimit; % trim small values
out = in.raw;

if isfield(in,'test') % rescale test points according to rules of the rest
    in.test = in.test - mean(in.raw);
    in.test = in.test .* in.scale
    in.test = in.test + in.center
    in.test(in.test>in.uplimit) = in.uplimit;
    in.test(in.test<in.lowlimit) = in.lowlimit;
end


function out = add_shadebar(value,transp,startpt,xsize,ysize)
% This function will add a series of labeled transparencies
% to your graph to provide it a key.
% INPUTS
% value - row vector of effect sizes
% transp - row vector of corresponding transparencies
% startpt - 1x2 vector of X, Y to be top left corner of first square
% xsize - how big each transparency square should be in x (left/right)
% ysize - how big each transparency square should be in y (down/up)
% Value labels will get written at the y start pt, mid way in X
% NOTE - top left corner of graph is (1,1)


curx = startpt(1);
cury = startpt(2);

for i = 1:numel(value)
    % Setup the offsets
    rx = curx;
    bx = curx+xsize;
    yx = curx+xsize*2;

    % Draw the boxes
    fill(...
    [rx, rx+xsize, rx+xsize,rx],...
    [cury, cury, cury+ysize, cury+ysize],...
    'r', 'FaceAlpha',transp(i));

    fill(...
    [bx, bx+xsize, bx+xsize,bx],...
    [cury, cury, cury+ysize, cury+ysize],...
    'b', 'FaceAlpha',transp(i));

    fill(...
    [yx, yx+xsize, yx+xsize,yx],...
    [cury, cury, cury+ysize, cury+ysize],...
    'y', 'FaceAlpha',transp(i));

    % Add the textlabel
    curstring = [ '10^{-' num2str(round(value(i))) '}'];

    text(yx+xsize+10,cury+4,curstring);

    cury = cury + ysize; % increment y left to right


end

out = 1;





