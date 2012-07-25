%% do re-referencing for each img in the template network folder
% create another output folder called 'inpath_rerefenced' and save the re-refenced
% image in this output folder



% referenceimg: one img from ICA output components
% inpath: the directory contains the Network templates

% outpath: the directory saves the re-referenced imgs, it's better to just
% append '_rereferenced' to the inpath

function mc_rereferencing_batch(referenceimg, inpath, outpath)

inimg1 = referenceimg;

files = dir(inpath);

for ifile = 1: length(files)
    filename = files(ifile).name;
    [pathstr, name, ext, versn] = fileparts(filename);
    if isequal(ext, '.nii') || isequal(ext, '.img')
        inimg2 = fullfile(inpath, files(ifile).name);
        
        outimg = fullfile(outpath, files(ifile).name);
        
        mc_rereferencing(inimg1, inimg2, outimg);
    end
end