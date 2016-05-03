%%

cd /net/data4/MAS_ICA_data/Out_TemplateMatchingAlg2_PBO_ramdperm4_10comp
nsubj = 32;
ncomp = 10;
data = cell(nsubj*ncomp,5);

for i = 1:nsubj
    filename = ['network_template_mathing_score_subj',num2str(i),'.txt'];
    fid = fopen(filename);
    a =  textscan(fid,'%s','delimiter',',');
    a2 = a{1,1};
    a2 = (reshape(a2,[5 ncomp]))';
    

    data((i-1)*ncomp+1:i*ncomp,1:5) = a2;
end



for i = 1: size(data,1)
    switch data{i,4}
        case 'anterior_cingulate_precun.hdr'
            data{i,4} = 1;
        case 'auditory.hdr'
            data{i,4} = 2;
        case 'default.hdr'
            data{i,4} = 3;
        case 'IFG_middle_temporal.hdr'
            data{i,4} = 4;
        case 'left_executive.hdr'
            data{i,4} = 5;
        case 'left_right_exec_combined_network.hdr'
            data{i,4} = 6;
        case 'motor.hdr'
            data{i,4} = 7;
        case 'parietal_association_cortex.hdr'
            data{i,4} = 8;
        case 'posterior_default.hdr'
            data{i,4} = 9;
        case 'right_executive.hdr'
            data{i,4} = 10;
        case 'salience.hdr'
            data{i,4} = 11;
        case 'single_subj_T1.nii'
            data{i,4} = 12;
        case 'supplementary_motor.hdr'
            data{i,4} = 13;
        case 'visual.hdr'
            data{i,4} = 14;
    end
end

componentmat = zeros(10,14);

for i = 1:length(data)
    switch data{i,3}
        case 'component 1'
            componentmat(1,data{i,4}) = componentmat(1,data{i,4}) + 1;
        case 'component 2'
            componentmat(2,data{i,4}) = componentmat(2,data{i,4}) + 1;
        case 'component 3'
            componentmat(3,data{i,4}) = componentmat(3,data{i,4}) + 1;
        case 'component 4'
            componentmat(4,data{i,4}) = componentmat(4,data{i,4}) + 1;
        case 'component 5'
            componentmat(5,data{i,4}) = componentmat(5,data{i,4}) + 1;
        case 'component 6'
            componentmat(6,data{i,4}) = componentmat(6,data{i,4}) + 1;
        case 'component 7'
            componentmat(7,data{i,4}) = componentmat(7,data{i,4}) + 1;
        case 'component 8'
            componentmat(8,data{i,4}) = componentmat(8,data{i,4}) + 1;
        case 'component 9'
            componentmat(9,data{i,4}) = componentmat(9,data{i,4}) + 1;
        case 'component 10'
            componentmat(10,data{i,4}) = componentmat(10,data{i,4}) + 1;

    end
end
componentcell = num2cell(componentmat,[ncomp,14]);
templatetitle = {'anterior_cingulate_precun.hdr','auditory.hdr','default.hdr','IFG_middle_temporal.hdr',...
    'left_executive.hdr', 'left_right_exec_combined_network.hdr','motor.hdr','parietal_association_cortex.hdr',...
    'posterior_default.hdr','right_executive.hdr', 'salience.hdr','single_subj_T1.nii',...
    'supplementary_motor.hdr','visual.hdr'};
componentcell = [templatetitle;componentcell];
componenttitle = {'';'component 1';'component 2';'component 3';'component 4';'component 5';...
                    'component 6';'component 7';'component 8';'component 9';'component 10'};
      componentcell = [componenttitle,componentcell]  ;        


%      xlswrite('matchingcomponent_statistics.xls',componentcell);  