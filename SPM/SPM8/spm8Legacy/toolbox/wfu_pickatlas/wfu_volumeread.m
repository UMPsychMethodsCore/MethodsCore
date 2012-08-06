function Vol = wfu_volumeread(fid, precise, x,y,z, t)

%------------------------------------------------
%Matlab can't do math on anything except doubles!
%------------------------------------------------
%expr=[precise '(zeros(x,y,z,t))'];
%Vol=eval(expr);

Vol = zeros(x,y,z,t);
for i = 1:t
	for j = 1:z
   	Vol(:,:,j,i) = fread(fid, [x, y], precise);
	end
end
return;