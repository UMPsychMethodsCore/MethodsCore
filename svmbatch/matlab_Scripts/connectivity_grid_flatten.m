function [ output_args ] = connectivity_grid_flatten( conmat , filename, exampletype)
%CONNECTIVITY_GRID_FLATTEN Summary of this function goes here
%   [ output_args ] = connectivity_grid_flatten( conmat , filename, exampletype)

%% Iterate over files
flatmat = flatten_diagonal ();

write_lines();



    function [ fid ] = write_lines ()
        writeme=[1:size(flatmat,2);flatmat];
        writeme=writeme(:,writeme(2,:)~=0);
        fid = fopen(filename,'a');

        fprintf(fid,'%+.0f ',exampletype);
        fprintf(fid,'%.0f:%f ',writeme);
        fprintf(fid,'\n');

        fclose(fid);

    end

    function [flatmat] = flatten_diagonal ()
        conmat_protected = conmat;
        conmat_protected(find(conmat_protected==0)) = Inf;
        flatmat_full = reshape(triu(conmat_protected,1),1,size(conmat_protected(:),1));
        flatmat = flatmat_full(find(flatmat_full));
        flatmat(find(flatmat==Inf)) = 0;
    end

end