function mc_template_matching(TempMatchAlg, NWTemplatePath, compPath, subjPath, outpath)
%% Main function of template matching, put in template path and component
%% path, gives out a template matching score txt file

%  NWTemplatePath: where your network templates are
%       !!!something like this: /net/dysthymia/ICA_test/NWTemplatePath (without the last '/')
%  COMPATH: where your ICA output component maps are
%  OUTPATH: where you would like to save the template matching score file:
%  SUBJPATH: tm1 will not use subjPath, only tm2 or tm 3 will use it
%  recommended to be in the output path(as the same directory of all the zip files)


%% do re-referencing for each img in the template network folder

rereference_inpath = NWTemplatePath;    %input path of template

% create another output folder called 'inpath_rerefenced' and save the re-refenced
% image in this output folder
rereference_out.Template = [NWTemplatePath,'_rereferenced'];
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
NWTemplatePath = rereference_outpath;

%% get best fit for each component
% 1. loop over components
% 2. loop over network templates for each component: find the best fit
% network
if TempMatchAlg == 1
    %%%%%%%%%%%%%%%%%%%%%%%!!!!!!!!!!!!!!!!!! needs to be fixed 
    all_comp_best_fit = mc_tm1_getbestfitNW(compPath{end}, NWTemplatePath);
elseif TempMatchAlg == 2
    all_comp_best_fit = mc_tm2_getbestfitNW(compPath(1:end-1), subjPath, NWTemplatePath);
elseif TempMatchAlg == 3
    mc_tm3_getbestfitNW(outpath, NWTemplatePath);
end

%% write out best fit into a txt file
% change to cell
if TempMatchAlg == 1
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
    
elseif TempMatchAlg == 2
    writeout{1,1} = 'subject'; writeout{1,2} = 'session'; 
    writeout{1,3} = 'component name'; writeout{1,4} = 'best match network'; writeout{1,5} = 'matching score';
    for iSubj = 1: size(all_comp_best_fit,1)

        cnt = 0;
        for iSess = 1:size(all_comp_best_fit,2)
            for iComp = 1:length(all_comp_best_fit{iSubj, iSess})
                cnt = cnt+1;
                writeout{cnt,1} = num2str(iSubj);
                writeout{cnt,2} = num2str(iSess);
                writeout{cnt,3} = all_comp_best_fit{iSubj, iSess}(iComp).compname;
                writeout{cnt,4} = all_comp_best_fit{iSubj, iSess}(iComp).NWname;
                writeout{cnt,5} = all_comp_best_fit{iSubj, iSess}(iComp).score;
            end
        end
        
        filename = ['network_template_mathing_score_subj',num2str(iSubj),'.txt'];
        outtxt = fullfile(outpath, filename);

        mc_dlmcell(outtxt, writeout,',');
    end

end