function c = spm_config_srender
% Configuration file for surface visualisation
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_config_srender.m 2736 2009-02-12 12:23:21Z john $

entry = inline(['struct(''type'',''entry'',''name'',name,'...
        '''tag'',tag,''strtype'',strtype,''num'',num,''help'',{{}})'],...
        'name','tag','strtype','num');

files = inline(['struct(''type'',''files'',''name'',name,'...
        '''tag'',tag,''filter'',fltr,''num'',num,''help'',{{}})'],...
        'name','tag','fltr','num');

mnu = inline(['struct(''type'',''menu'',''name'',name,'...
        '''tag'',tag,''labels'',{labels},''values'',{values},''help'',{{}})'],...
        'name','tag','labels','values');

branch = inline(['struct(''type'',''branch'',''name'',name,'...
        '''tag'',tag,''val'',{val},''help'',{{}})'],...
        'name','tag','val');
repeat = inline(['struct(''type'',''repeat'',''name'',name,''tag'',tag,'...
         '''values'',{values})'],'name','tag','values');

Red = mnu('Red','Red',...
    {'0.0','0.2','0.4','0.6','0.8','1.0'},...
    {0,0.2,0.4,0.6,0.8,1});
Red.val = {1};
Red.help = {['The intensity of the red colouring (0 to 1).']};

Green = mnu('Green','Green',...
    {'0.0','0.2','0.4','0.6','0.8','1.0'},...
    {0,0.2,0.4,0.6,0.8,1});
Green.val = {1};
Green.help = {['The intensity of the green colouring (0 to 1).']};

Blue = mnu('Blue','Blue',...
    {'0.0','0.2','0.4','0.6','0.8','1.0'},...
    {0,0.2,0.4,0.6,0.8,1});
Blue.val = {1};
Blue.help = {['The intensity of the blue colouring (0 to 1).']};

Color = branch('Color','Color',{Red,Green,Blue});
Color.help = {[...
'Specify the colour using a mixture of red, green and blue. '...
'For example, white is specified by 1,1,1, black is by 0,0,0 and '...
'purple by 1,0,1.']};

AmbientStrength = mnu('Ambient Strength','AmbientStrength',...
    {'0.0','0.2','0.4','0.6','0.8','1.0'},...
    {0,0.2,0.4,0.6,0.8,1});
AmbientStrength.val = {0.2};
AmbientStrength.help = {[...
'The strength with which the object reflects ambient '...
'(non-directional) lighting.']};

DiffuseStrength = mnu('Diffuse Strength','DiffuseStrength',...
    {'0.0','0.2','0.4','0.6','0.8','1.0'},...
    {0,0.2,0.4,0.6,0.8,1});
DiffuseStrength.val = {0.8};
DiffuseStrength.help = {[...
'The strength with which the object diffusely reflects '...
'light. Mat surfaces reflect light diffusely, whereas '...
'shiny surfaces reflect speculatively.']};

SpecularStrength = mnu('Specular Strength','SpecularStrength',...
    {'0.0','0.2','0.4','0.6','0.8','1.0'},...
    {0,0.2,0.4,0.6,0.8,1});
SpecularStrength.val = {0.2};
SpecularStrength.help = {[...
'The strength with which the object specularly reflects '...
'light (i.e. how shiny it is). '...
'Mat surfaces reflect light diffusely, whereas '...
'shiny surfaces reflect speculatively.']};

SpecularExponent = mnu('Specular Exponent','SpecularExponent',...
    {'0.01','0.1','10','100'},{0.01,0.1,10,100});
SpecularExponent.val = {10};
SpecularExponent.help = {[...
'A parameter describing the specular reflectance behaviour. '...
'It relates to the size of the high-lights.']};

SpecularColorReflectance = mnu('Specular Color Reflectance',...
    'SpecularColorReflectance',...
    {'0.0','0.2','0.4','0.6','0.8','1.0'},...
    {0,0.2,0.4,0.6,0.8,1});
SpecularColorReflectance.val = {0.8};
SpecularColorReflectance.help = {[...
'Another parameter describing the specular reflectance behaviour.']};

FaceAlpha = mnu('Face Alpha','FaceAlpha',...
    {'0.0','0.2','0.4','0.6','0.8','1.0'},...
    {0,0.2,0.4,0.6,0.8,1});
FaceAlpha.val = {1};
FaceAlpha.help = {[...
'The opaqueness of the surface.  A value of 1 means it is '...
'opaque, whereas a value of 0 means it is transparent.']};

fname = files('Surface File','SurfaceFile','mat',[1 1]);
fname.ufilter = '.*\.gii$';
fname.help = {[...
'Filename of the surf_*.mat file containing the rendering information. '...
'This can be generated via the surface extraction routine in SPM. '...
'Normally, a surface is extracted from grey and white matter tissue class '...
'images, but it is also possible to threshold e.g. an spmT image so that '...
'activations can be displayed.']};

Object = branch('Object','Object',...
{fname,Color,DiffuseStrength,AmbientStrength,SpecularStrength,SpecularExponent,SpecularColorReflectance,FaceAlpha});
Object.help = {[...
'Each object is a surface (from a surf_*.mat file), which may have a '...
'number of light-reflecting qualities, such as colour and shinyness.']};

Objects = repeat('Objects','Objects',{Object});
Objects.help = {[...
'Several surface objects can be displayed together in different colours '...
'and with different reflective properties.']};



Position = entry('Position','Position','e',[1 3]);
Position.val = {[100 100 100]};
Position.help = {'The position of the light in 3D.'};

Light  = branch('Light','Light',{Position,Color});
Light.help = {'Specification of a light source in terms of position and colour.'};

Lights = repeat('Lights','Lights',{Light});
Lights.help = {[...
'There should be at least one light specified so that the objects '...
'can be clearly seen.']};

sren = branch('Surface Rendering','SRender',{Objects,Lights});
sren.prog = @spm_srender;
sren.help = {[...
'This utility is for visualising surfaces.  Surfaces first need to be '...
'extracted and saved in surf_*.mat files using the surface extraction '...
'routine.']};

expr.type = 'entry';
expr.name = 'Expression';
expr.tag  = 'expression';
expr.strtype = 's';
expr.num  = [2 Inf];
expr.val = {'i1'};
expr.help = {...
'Example expressions (f):',...
'    * Mean of six images (select six images)',...
'       f = ''(i1+i2+i3+i4+i5+i6)/6''',...
'    * Make a binary mask image at threshold of 100',...
'       f = ''i1>100''',...
'    * Make a mask from one image and apply to another',...
'       f = ''i2.*(i1>100)''',[...
'             - here the first image is used to make the mask, which is applied to the second image'],...
'    * Sum of n images',...
'       f = ''i1 + i2 + i3 + i4 + i5 + ...'''};

thresh.type    = 'entry';
thresh.name    = 'Surface isovalue(s)';
thresh.tag     = 'thresh';
thresh.num     = [1 1];
thresh.val     = {.5};
thresh.strtype = 'e';
thresh.help    = {['Enter the value at which isosurfaces through ' ...
                  'the resulting image is to be computed.']};

surf = branch('Surface','surface',{expr,thresh});
surf.help = {[...
'An expression and threshold for each of the surfaces to be generated.']};

surfaces = repeat('Surfaces','Surfaces',{surf});
surfaces.help = {'Multiple surfaces can be created from the same image data.'};

inpt.type = 'files';
inpt.name = 'Input Images';
inpt.tag  = 'images';
inpt.filter = 'image';
inpt.num  = [1 Inf];
inpt.help = {[...
'These are the images that are used by the calculator.  They ',...
'are referred to as i1, i2, i3, etc in the order that they are ',...
'specified.']};

opts.type = 'branch';
opts.name = 'Surface Extraction';
opts.tag  = 'SExtract';
opts.val  = {inpt,surfaces};
opts.prog = @spm_sextract;
opts.vfiles = @filessurf;
opts.help = {[...
'User-specified ',...
'algebraic manipulations are performed on a set of images, with the result being ',...
'used to generate a surface file. The user is prompted to supply images to ',...
'work on and a number of expressions to ',...
'evaluate, along with some thresholds. The expression should be a standard matlab expression, ',...
'within which the images should be referred to as i1, i2, i3,... etc. '...
'An isosurface file is created from the results at the user-specified threshold.']};

c = repeat('Rendering','render',{opts,sren});
c.help = {[...
'This is a toolbox that provides a limited range '...
'of surface rendering options. The idea is to first extract surfaces from '...
'image data, which are saved in rend_*.mat files. '...
'These can then be loaded and displayed as surfaces. '...
'Note that OpenGL rendering is used, which can be problematic '...
'on some computers. The tools are limited - and they do what they do.']};
return;


function vfiles=filessurf(job)
vfiles={};
[pth,nam,ext] = fileparts(job.images{1});
for k=1:numel(job.surface),
    vfiles{k} = fullfile(pth,sprintf('surf_%s_%.3d.mat',nam,k));
end;
return;

