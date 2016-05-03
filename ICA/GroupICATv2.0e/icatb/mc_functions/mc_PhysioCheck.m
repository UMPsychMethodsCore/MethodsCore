%% get best fit for each component
% compPath: path that contains components from ICA
% networkPath: path that contains the network templates

% all_comp_best_fit is a ncomp*1 struct, each one has three fields:
    % all_comp_best_fit(ncomp).compname: component name
    % all_comp_best_fit(ncomp).NWname: best fit network name
    % all_comp_best_fit(ncomp).score: best fit network's score

% 1. loop over components
% 2. loop over network templates for each component: find the best fit
% network

function mc_PhysioCheck(PhysioTemplate, compPath, subjPath)

%% if do PhsioChecks, do re-referencing for each img in the grey/white/csf template network folder
rereference_inpath = PhysioTemplate;    %input path of template

% create another output folder called 'inpath_rerefenced' and save the re-refenced
% image in this output folder
rereference_out.Template = [PhysioTemplate,'_rereferenced'];
rereference_out.mode = 'makedir';
rereference_outpath = mc_GenPath(rereference_out);

% pick up a component img for rereferencing
% here the first found component in the 'all session' folder is chosen
searchpath = [compPath{end} '/*component*hdr'];
components = dir(searchpath);
referenceimg = fullfile(compPath{end},components(1).name);

% do re-referencing
mc_rereferencing_batch(referenceimg, rereference_inpath, rereference_outpath);

%replace NWTemplatePath by rereferenced path
PhysioTemplatePath = rereference_outpath;

%% do Physio Checks
mc_getPhysioCheckR2mat(compPath{end}, PhysioTemplatePath);

end

function mc_getPhysioCheckR2mat(compPath, networkPath)

% find all the component imgs in the compPath
searchpath = [compPath '/*component*hdr'];
components = dir(searchpath);

ncomp = length(components);

%find all network templates in NWTemplatePath
hdrpath = [networkPath '/*hdr*'];
niipath = [networkPath '/*nii*'];
networks = [dir(hdrpath); dir(niipath)];

nNW = length(networks);

% all combination of corr
comp_nw_corr = NaN(ncomp,nNW);

%% sigle_comp_best is the struct to store the best-fit network and the corresponding score for each component
%  all_comp_best_fit is the ncomp*1 struct to store the best fit for each
%  of the component
%loop over all components
for icomp = 1: ncomp
    
    single_comp_best.NWname = networks(1).name;
    
    fprintf('calculating component %d...\n', icomp);
    single_comp_best.compname = components(icomp).name;
    % loop over all networks
    for iNW = 1:nNW
        
        comp = fullfile(compPath, components(icomp).name);
        NW = fullfile(networkPath, networks(iNW).name);

        comp_nw_corr(icomp,iNW) = mc_tm1_getcorr(comp,NW);

    end
end
% get r.^2
comp_nw_corr = comp_nw_corr.^2;
save([compPath,'/../comp_nw_corr.mat'],'comp_nw_corr');

end