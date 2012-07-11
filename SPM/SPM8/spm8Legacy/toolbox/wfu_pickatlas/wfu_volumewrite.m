function wfu_volumewrite(fid,volume,precise)

if (fid < 0)
   return;
end

for i = 1:size(volume,4)
   for j = 1: size(volume,3)
   	fwrite(fid, volume(:,:,j,i), precise);
	end
end
