function wfu_structwrite(fid, structv)
if (fid < 0) 
   return;
end
fieldname = fieldnames(structv);
for i = 1: length(fieldname)
   acmd = sprintf('a = structv.%s.value;',wfu_cell2mat(fieldname(i)));
   eval(acmd);
   if( size(a,1) > 1 & size(a, 2) >1)
      a = a';
   end
   wtcmd = sprintf('fwrite(fid, a , structv.%s.type);',wfu_cell2mat(fieldname(i)));
   eval(wtcmd);
end
