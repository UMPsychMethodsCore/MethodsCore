function structv = wfu_structread(fid, structv)

if (fid < 0) 
   return;
end

fieldn = fieldnames(structv);

for i = 1: length(fieldn)
   rdcmd = sprintf('a = fread(fid, structv.%s.size, structv.%s.type);',  wfu_cell2mat(fieldn(i)), wfu_cell2mat(fieldn(i)));
   eval(rdcmd);
   if(size(a,1) >1 & size(a,2) > 1)
      transcmd = sprintf('structv.%s.value = a'';', wfu_cell2mat(fieldn(i)));%
      eval(transcmd);
   else
      transcmd = sprintf('structv.%s.value = a;', wfu_cell2mat(fieldn(i)));%
      eval(transcmd);      
   end   
end

return