function [ output_args ] = connectivity_grid_flatten( conmat , filename, exampletype, cleanconMat, mode)
%CONNECTIVITY_GRID_FLATTEN Summary of this function goes here
%   [ output_args ] = connectivity_grid_flatten( conmat , filename,
%   exampletype)
%       mode    -   1: write out a file, with bad elements censored
%                   2: return a matrix with bad elements zeroed


flatmat = flatten_diagonal (conmat);
cleanconMat_flat = flatten_diagonal (cleanconMat);
switch mode
    case 1
        write_lines();
    case 2
        flatmat(~logical(cleanconMat_flat))=0;
        output_args=flatmat;
end



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