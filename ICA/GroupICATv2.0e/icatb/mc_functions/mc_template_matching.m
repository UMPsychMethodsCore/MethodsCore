function mc_template_matching(NWTemplatePath, compPath, outpath)
%% Main function of template matching, put in template path and component
%% path, gives out a template matching score txt file

%  NWTemplatePath: where your network templates are
%       !!!something like this: /net/dysthymia/ICA_test/NWTemplatePath (without the last '/')
%  COMPATH: where your ICA output component maps are
%  OUTPATH: where you would like to save the template matching score file:
%  recommended to be in the output path(as the same directory of all the zip files)


%% do re-referencing for each img in the template network folder

rereference_inpath = NWTemplatePath;    %input path of template

% create another output folder called 'inpath_rerefenced' and save the re-refenced
% image in this output folder
rereference_out.Template = [NWTemplatePath,'_rereferenced'];
rereference_out.mode = 'makedir';
rereference_outpath = mc_genpath(rereference_out);

% pick up a component img for rereferencing
% here the first found component is chosen
searchpath = [compPath '/*component*hdr'];
components = dir(searchpath);
referenceimg = fullfile(compPath,components(1).name);

% do re-referencing
mc_rereferencing_batch(referenceimg, rereference_inpath, rereference_outpath);

%replace NWTemplatePath by rereferenced path
NWTemplatePath = rereference_outpath;

%% get best fit for each component
% 1. loop over components
% 2. loop over network templates for each component: find the best fit
% network

all_comp_best_fit = mc_getbestfitNW(compPath, NWTemplatePath);


%% write out best fit into a txt file
% change to cell
ncomp = length(all_comp_best_fit);
writeout = cell(ncomp+1,3);

writeout{1,1} = 'component name'; writeout{1,2} = 'best match network'; writeout{1,3} = 'matching score';
for icomp = 1: ncomp
    writeout{icomp+1,1} = all_comp_best_fit(icomp).compname;
    writeout{icomp+1,2} = all_comp_best_fit(icomp).NWname;
    writeout{icomp+1,3} = all_comp_best_fit(icomp).score;
end

outtxt = fullfile(outpath, 'network_template_mathing_score.txt');
mc_dlmcell(outtxt, writeout,',');