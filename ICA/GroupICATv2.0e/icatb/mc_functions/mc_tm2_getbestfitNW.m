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



function all_comp_best_fit = mc_tm2_getbestfitNW(compPath, subjPath, networkPath)

nSubj = size(subjPath,1);
nSess = size(subjPath,2);

%% find all network templates in NWTemplatePath, load templates:
% networks: the struc of all the networks, each struct contains name, data,
% time, etc
% network: the read-in image (the volumn) of all the network templates
hdrpath = [networkPath '/*hdr*'];
niipath = [networkPath '/*nii*'];
networks = [dir(hdrpath); dir(niipath)];

nNW = length(networks);

network = cell(nNW);
for iNW = 1:nNW
    networkName = fullfile (networkPath, networks(iNW).name);   
    network{iNW} = spm_read_vols(spm_vol(networkName));
end

%% find all the timecourse imgs for each session in the compPath
% comp_timecourse: nSubjxnSess cell; comp_timecourse{iSubj}{iSess}: # timepoints x # components in the ith session
comp_timecourse = cell(nSubj,nSess);
for iSess = 1:nSess
    for iSubj = 1:nSubj
        singleSess_compPath = compPath{iSess}{iSubj};  %specific session's component path
        
        searchpath = [singleSess_compPath '/*timecourse*hdr'];
        search_timecourse = dir(searchpath);
        timecourse_path = [singleSess_compPath, '/', search_timecourse.name];
        
        clear search_timecourse
        comp_timecourse{iSubj}{iSess} = spm_read_vols(spm_vol(timecourse_path));
        
    end
end


%% load all subj's time course for each session
% subj_timecourse = cell(size(subjPath,1),size(subjPath,2));
for iSubj = 1:size(subjPath,1)
    for iSess = 1:size(subjPath,2)
%         subj_timecourse{iSubj, iSess} = spm_read_vols(spm_vol(subjPath{iSubj, iSess}));
        subj_timecourse = spm_read_vols(spm_vol(subjPath{iSubj, iSess}));
        
        fprintf('------Calculating Pearsons r of subject %d, session %d:------\n', iSubj, iSess);
        % loop over component within one subj
        for iComp = 1:size(comp_timecourse{iSubj}{iSess},2)
            
            fprintf('       Calculating component %d\n', iComp);
%             siz = size(subj_timecourse{iSubj,iSess});
            siz = size(subj_timecourse);
%             timecourse = reshape(subj_timecourse{iSubj,iSess}, [prod(siz(1:3)),siz(4)]);
            timecourse = reshape(subj_timecourse, [prod(siz(1:3)),siz(4)]);

            % x: current subj's time course, nPixels x nt(ime)p(oints)
            % y: current component time course, 
            x = timecourse;
            y = comp_timecourse{iSubj}{iSess}(:,iComp)';

            ntp = min(size(x,2),size(y,2)); %cut time points to avoid time series diff between subj and componts
            nPixel = size(x,1);
            
            x = x(:,1:ntp); y = repmat(y(:,1:ntp),[nPixel,1]);

            %Pearson r
            term1 = x-repmat(mean(x,2),[1,ntp]);
            term2 = y-repmat(mean(y,2),[1,ntp]);
            upper = sum(term1.*term2,2);
            lower = sqrt(sum(term1.^2,2).*sum(term2.^2,2));
            r = upper./lower;

            rmap{iSubj,iSess}{iComp} = reshape(r, siz(1:3));
            %%%!! rmap may contain lots of NaNs which is due to the lower
            %%%term of 0, comes from subj's time course of all 0s.
            
            zmap{iSubj,iSess}{iComp} = .5*(log(1+rmap{iSubj,iSess}{iComp}) - log(1-rmap{iSubj,iSess}{iComp}));
            zmap{iSubj,iSess}{iComp}(isnan(zmap{iSubj,iSess}{iComp}))=0;
            
            vols1 = zmap{iSubj,iSess}{iComp};
            for iNW = 1: length(network)
                vols2 = network{iNW};
                matching_vol = vols1.*vols2;
                unmatching_vol = (1-vols1).*vols2;
                score{iSubj,iSess}(iComp,iNW) = (mean(mean(mean(matching_vol))))-(mean(mean(mean(unmatching_vol))));
            end
            
            matching_score = score{iSubj,iSess}(iComp,:);
            bestfit_ind = find(matching_score == max(matching_score));

            all_comp_best_fit{iSubj, iSess}(iComp).compname = ['component ', num2str(iComp)];
            all_comp_best_fit{iSubj, iSess}(iComp).NWname = networks(bestfit_ind).name;
            all_comp_best_fit{iSubj, iSess}(iComp).score = matching_score(bestfit_ind);
        end
    end
end



%%  for each subj, calculate whole brain r map for each comp
% pearson's r formula: 2 given 1d vector x and y. 
% x and y are both 1xn or nx1 vectors
% The output is a single value r
%
%             sum((x-mean x) * (y-mean y))
%r = ---------------------------------------------------
%       sqrt[ sum(x- mean x).^2 *  sum(y- mean y).^2]
%
%---------------------------------------------------------------------
% SESSION 1:
%       subj 1 -- comp 1    - rmap 11 
%              -- comp 2    - rmap 21
%                   ...                     
%              -- comp n    - rmap n1
%
%       subj 2 -- comp 1    - rmap 12 
%              -- comp 2    - rmap 22
%                   ...                     
%              -- comp n    - rmap n2
%
%                   ... ...
% 
%       subj m -- comp 1    - rmap 1m 
%              -- comp 2    - rmap 2m
%                   ...                     
%              -- comp n    - rmap nm
%


% %loop over session and subject
% rmap = cell(size(subj_timecourse,1),size(subj_timecourse,2));
% for iSess = 1:size(subj_timecourse,2)
%     for iSubj = 1:size(subj_timecourse,1)
%         fprintf('------Calculating Pearsons r of subject %d, session %d:------\n', iSubj, iSess);
%         % loop over component within one subj
%         for iComp = 1:size(comp_timecourse{iSess},2)
%             fprintf('       Calculating component %d\n', iComp);
%             siz = size(subj_timecourse{iSubj,iSess});
%             timecourse = reshape(subj_timecourse{iSubj,iSess}, [prod(siz(1:3)),siz(4)]);
% 
%             % x: current subj's time course, nPixels x nt(ime)p(oints)
%             % y: current component time course, 
%             x = timecourse;
%             y = comp_timecourse{iSess}(:,iComp)';
% 
%             ntp = min(size(x,2),size(y,2)); %cut time points to avoid time series diff between subj and componts
%             nPixel = size(x,1);
%             
%             x = x(:,1:ntp); y = repmat(y(:,1:ntp),[nPixel,1]);
% 
%             %Pearson r
%             term1 = x-repmat(mean(x,2),[1,ntp]);
%             term2 = y-repmat(mean(y,2),[1,ntp]);
%             upper = sum(term1.*term2,2);
%             lower = sqrt(sum(term1.^2,2).*sum(term2.^2,2));
%             r = upper./lower;
% 
%             rmap{iSubj,iSess}{iComp} = reshape(r, siz(1:3));
%             %%%!! rmap may contain lots of NaNs which is due to the lower
%             %%%term of 0, comes from subj's time course of all 0s.
%         end
%     end
% end
% 
% %% converting pearson's r to fisher's z
% % formula: z = 0.5 x [ln(1+r) - ln(1-r)]
% zmap = cell(size(rmap,1),size(rmap,2));
% for iSess = 1:size(rmap,2)
%     for iSubj = 1:size(rmap,1)
%         for iComp = 1: length(rmap{iSubj,iSess})
%             zmap{iSubj,iSess}{iComp} = .5*(log(1+rmap{iSubj,iSess}{iComp}) - log(1-rmap{iSubj,iSess}{iComp}));
%             zmap{iSubj,iSess}{iComp}(isnan(zmap{iSubj,iSess}{iComp}))=0;
%         end
%     end
% end
% 
% 
% 
% 
% %% get matching score for each component and template
% % SESSION i
% %   subj i  -- comp 1(rmap)  -- nw 1
% %                            -- nw 2
% %                              ...      --- best fit nw i
% %                            -- nw n
% % 
% %           -- comp 2(rmap)  -- nw 1
% %                            -- nw 2
% %                              ...      --- best fit nw i
% %                            -- nw n
% %                 ... ...
% % 
% %           -- comp m(rmap)  -- nw 1
% %                            -- nw 2
% %                              ...      --- best fit nw i
% %                            -- nw n     
% score = cell(size(rmap,1),size(rmap,2));
% 
% for iSess = 1:size(rmap,2)
%     for iSubj = 1:size(rmap,1)
%         for iComp = 1: length(rmap{iSubj,iSess})
%             vols1 = zmap{iSubj,iSess}{iComp};
%             for iNW = 1: length(network)
%                 vols2 = network{iNW};
%                 matching_vol = vols1.*vols2;
%                 unmatching_vol = (1-vols1).*vols2;
%                 score{iSubj,iSess}(iComp,iNW) = (mean(mean(mean(matching_vol))))-(mean(mean(mean(unmatching_vol))));
%             end
%         end
%     end
% end
% 
% 
% %% pick out best score for each component
% all_comp_best_fit = cell(size(score,1),size(score,2));
% for iSess = 1:size(score,2)
%     for iSubj = 1:size(score,1)
%         for iComp = 1: size(score{iSubj,iSess},1)
%             matching_score = score{iSubj,iSess}(iComp,:);
%             bestfit_ind = find(matching_score == max(matching_score));
% 
%             all_comp_best_fit{iSubj, iSess}(iComp).compname = ['component ', num2str(iComp)];
%             all_comp_best_fit{iSubj, iSess}(iComp).NWname = networks(bestfit_ind).name;
%             all_comp_best_fit{iSubj, iSess}(iComp).score = matching_score(bestfit_ind);
%         end
%     end
% end
% 
% 
% %% single_comp_best is the struct to store the best-fit network and the corresponding score for each component
% %  all_comp_best_fit is the ncomp*1 struct to store the best fit for each
% %  of the component
% %loop over all components
% % % % for icomp = 1: ncomp
% % % %     bestscore = 0;
% % % %     single_comp_best.NWname = networks(1).name;
% % % %     
% % % % 
% % % %     fprintf('calculating component %d...\n', icomp);
% % % %     single_comp_best.compname = components(icomp).name;
% % % %     % loop over all networks
% % % %     for iNW = 1:nNW
% % % %         
% % % %         comp = fullfile(compPath, components(icomp).name);
% % % %         NW = fullfile(networkPath, networks(iNW).name);     
% % % %         
% % % %         score = mc_getfitindex (comp, NW);
% % % %         
% % % %         % get the best score
% % % %         if score > bestscore
% % % %             bestscore = score;
% % % %             
% % % %             single_comp_best.NWname = networks(iNW).name;
% % % %             single_comp_best.score = bestscore;
% % % %             
% % % %         end
% % % %     end
% % % %     
% % % %     all_comp_best_fit(icomp,1) = single_comp_best;
% % % % end