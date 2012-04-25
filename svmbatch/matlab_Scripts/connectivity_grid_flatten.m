function [ output_args ] = connectivity_grid_flatten( conmat , filename, exampletype, cleanconMat)
%CONNECTIVITY_GRID_FLATTEN Summary of this function goes here
%   [ output_args ] = connectivity_grid_flatten( conmat , filename, exampletype)


flatmat = flatten_diagonal (conmat);
cleanconMat_flat = flatten_diagonal (cleanconMat);

write_lines();



    function [ fid ] = write_lines ()
        writeme=[1:size(flatmat,2);flatmat];
        writeme=writeme(:,logical(cleanconMat_flat));
        writeme=writeme(:,writeme(2,:)~=0);
        fid = fopen(filename,'a');

        fprintf(fid,'%+.0f ',exampletype);
        fprintf(fid,'%.0f:%f ',writeme);
        fprintf(fid,'\n');

        fclose(fid);

    end

    function [flatmat] = flatten_diagonal (inmat)
        conmat_protected = inmat;
        conmat_protected(conmat_protected==0) = Inf;
        flatmat_full = reshape(triu(conmat_protected,1),1,size(conmat_protected(:),1));
        flatmat = flatmat_full(flatmat_full~=0);
        flatmat(isinf(flatmat)) = 0;
    end

end