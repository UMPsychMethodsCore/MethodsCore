function [ output_args ] = connectivity_grid_flatten( conmat , filename, exampletype)
%CONNECTIVITY_GRID_FLATTEN Summary of this function goes here
%   Detailed explanation goes here

%% Iterate over files
flatmat = flatten_diagonal ();

write_lines();



    function [ fid ] = write_lines ()
        writeme=[1:size(flatmat,2);flatmat];

        fid = fopen(filename,'a');

        fprintf(fid,'%+.0f ',exampletype);
        fprintf(fid,'%.0f:%f ',writeme);
        fprintf(fid,'\n');

        fclose(fid);

    end

    function [flatmat] = flatten_diagonal ()
        flatmat_full = reshape(triu(conmat,1),1,size(conmat(:),1));
        flatmat = flatmat_full(find(flatmat_full));
    end

end