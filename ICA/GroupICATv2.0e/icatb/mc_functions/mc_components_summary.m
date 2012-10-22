%% 
function mc_components_summary(NWTemplatePath, OutPath, nSess, nSubj, nComp )

%% get name list of templates
rereference_outpath = [NWTemplatePath,'_rereferenced'];
templates_hdr = dir([rereference_outpath, '/*.hdr']);
templates_nii = dir([rereference_outpath, '/*.nii']);
templates_list = [templates_hdr;templates_nii];
nTemplates = size(templates_list,1);
templates_namelist = cell(nTemplates,1);
for i = 1:nTemplates
    templates_namelist{i} = templates_list(i,1).name;
end
    
%% read in subj specific components text files
olddir = pwd;
cd(OutPath)

for iSess = 1:nSess
data = cell(nSubj*nComp,5);

%read in text files for each subj
for i = 1:nSubj
    filename = ['network_template_mathing_score_subj',num2str(i),'.txt'];
    fid = fopen(filename);
    a =  textscan(fid,'%s','delimiter',',');
    a2 = a{1,1};
    a = (reshape(a2,[5 nComp*nSess]))';
    % get data from this specific session
    a2 = a((iSess-1)*nComp+1:iSess*nComp,:);
    
    data((i-1)*nComp+1:i*nComp,1:5) = a2;
end


% replace text(template names) with numbers
for i = 1: size(data,1)
    for j = 1:nTemplates
        if isequal(data{i,4},templates_namelist{j})
            data{i,4} = j;
        end
    end
end

% calculate 
componentmat = zeros(nComp,nTemplates);
componenttitle = cell(nComp,1); componenttitle{1} = '';

for i = 1:length(data)
    for j = 1:nComp
        componentname = ['component ', num2str(j)];
        componenttitle{j+1} = componentname;
        if isequal(data{i,3},componentname)
            componentmat(j,data{i,4}) = componentmat(j,data{i,4}) + 1;
        end
    end
end

componentcell = num2cell(componentmat,[nComp,nTemplates]);
templatetitle = templates_namelist';
componentcell = [componenttitle,[templatetitle;componentcell]];
% componentcell = [componenttitle,componentcell]  ;        

if nSess ==1
    mc_dlmcell('component_summary.txt', componentcell,',');
else
    mc_dlmcell(['component_summary_sess',num2str(iSess),'.txt'], componentcell,',');
end

end
cd(olddir)

end