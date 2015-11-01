%original_design - a design matrix to check the type of
%design_type - number coded, 1 means a 1 sample t test
%               2 - 2 sample t test
%               0 - unknown type
function [design_type] = design_matrix_type(original_design)

%load the rows and columns sizes of the original design
[dr, dc]=size(original_design);

design_sum = sum(original_design);
dessum = design_sum;

%precondition - we do not know what type it is
design_type = 0;
%check if 1-sample t-test
%by checking that there is one col and that all rows contain a 1
if (dc==1  && length(original_design(original_design==1))==dr)
  design_type=1;
elseif (dc==2)
    %check that there are 2 cols and that the sum of the number
    %of rows that contain exactly one 1 is the same as the total
    %number of rows (eg each row is some form of ?,1 or 1,?)
    %Then check that the number of 0s in the matrix == number of rows
    %eg for each row there exists a zero
  if ((length(original_design(original_design(:,1)==1,1))+ ...
        length(original_design(original_design(:,2)==1,2))==dr) ...
         && length(original_design(original_design(:,:) ==0)) == dr )
    design_type=2;
  end
  elseif (mod(dr,2)==0 & sum(dessum==0)==1 & sum(dessum==2)==(dc-1))
  zscol=find(dessum==0);
  des = original_design;
  zsdat=des(:,zscol);
  sind_dat=des;
  sind_dat(:,zscol)=[];  %removes zeros sum column, leaving subject
                         %indicator columns
  if (sum(zsdat==1)==dr/2 & sum(zsdat==(-1))==dr/2 & sum(sind_dat==1)==2*ones(1,dc-1) &  sum(sind_dat==0)==(dr-2)*ones(1,dc-1))
    design_type=3;
  end

elseif( sum(sum(original_design) == 2) == dc-2 & rank(original_design) == (dc - 1) & sum(design_sum==sum(design_sum==2))==2)
	%spm style paired T test
	design_type = 4;

end