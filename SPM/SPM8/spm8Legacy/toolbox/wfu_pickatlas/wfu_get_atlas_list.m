function [Atlas] = wfu_get_atlas_list(LookUpFilePath, LookUpFileName, ImageName)
%This program will construct the atlas list
    atlas_toolbox=which('wfu_pickatlas.m');
	d1 = max([find(atlas_toolbox == filesep) 0]);
	if (d1>0)
		atlas_toolbox = atlas_toolbox(1:(d1-1));
	else
			atlas_toolbox = '.';
	end
    
atlas_fname = [atlas_toolbox '/' LookUpFilePath '/' LookUpFileName];
fid = fopen(atlas_fname, 'rt');
Atlas=[];
if (fid == -1)
    beep;
    h=msgbox('Cannot open master lookup file','Error','error');
    pause(3);
    return
end
    atlas_path=[atlas_toolbox '/' LookUpFilePath '/'];
    while ~feof(fid)
        tline = fgetl(fid);
        if  ~strncmp(tline,'%',1)
            [N,tline]=strtok(tline,','); % region name
            [I,tline]=strtok(tline,','); % image name
            [T,tline]=strtok(tline,','); % subregion text file name
            [J,tline]=strtok(tline,','); % offset
            O=str2num(J);
            [A] = lookup(atlas_path, T, I, O, N);
            if(~isempty(A))
                %Atl.Name={AL};
                %Atl.Region=[{R.RegionName}];
                %AtlasList=[AtlasList Atl];
                Atlas=[Atlas A];
                %Region=[Region R];
            end
        end
    end
    fclose(fid); 
    shapeoffset=(length(Atlas) + 1) *1000;
    [A] =wfu_get_shape(atlas_path, ImageName, shapeoffset);
    Atlas = [Atlas A];
return

% --------------------------------------------------------------------
function [Atlas] = lookup (atlas_path, FileName,ImageName,Offset, AtlasName)
%This program will construct the brain atlas lookup table
%The output is a structure of arrays
atlas_fname = FileName;
%segments=600;
%values =zeros(1, segments);
RegionNo=0;
SubregionNo=0;

if exist([atlas_path ImageName],'file')
    [aheader, atlas] = wfu_read_analyze_header([atlas_path ImageName]);
    Atlas.Name=AtlasName;
    Atlas.Aheader=aheader;
    Atlas.Atlas=atlas;
    Atlas.Offset=Offset;

    %fid = fopen(atlas_fname, 'r');
    if exist([atlas_path FileName],'file')
        fid = fopen([atlas_path FileName], 'r');
        while(~feof(fid))
            clear part;
            num = 1;
            line = fgetl(fid);
            if ~isempty(line) 
       	        anyascii = line(line~=' ');
   	            anyascii = anyascii(anyascii~='	');
   
           	    if(~isempty(anyascii))
               		[line1, line2] = strtok(line, '	');
   	            	part(num) = {line1};
           	    	if isempty(line2) 
              			line = deblank(line1);    
        	    		if line(1) == '['
                           	if RegionNo > 0 & SubregionNo == 0
	   	                  		RegionNo = RegionNo-1  ;
   	   	                     	%groupnames = groupnames(1:end-1);         
            			    end
		                 	RegionName = line(2:end-1);
   	 	            	   	RegionNo = RegionNo+1  ;
             			    SubregionNo = 0;
       	        		end
               		end
            		%-----------------------------------------------
            		%Check if first character is a digit 0-9
   	            	%-----------------------------------------------
               		while (~isempty(line2))
                    	[line1, line2] = strtok(line2, '	');
       	        		if ~(isempty(line1) | isempty(deblank(line1)))
           	    			num = num + 1;
              				part(num) = {line1};
                        end
                	end
            		number = str2double(wfu_cell2mat(part(1)));
           	    	if (~isnan(number))
              			%region = region + 1;
      		        	SubregionNo = SubregionNo +1;
              			Region(RegionNo).RegionName = RegionName;
                        Region(RegionNo).ImageName = ImageName;
                        Region(RegionNo).Offset = Offset;
          		    	Region(RegionNo).SubregionNames(SubregionNo) = part(2);
                        Region(RegionNo).SubregionValues(SubregionNo) = number;
                    end
                end      
            end
        end
        fclose(fid);
        if ~(isempty(Region))
            Atlas.Region=Region;
        else
            Atlas=[];
        end
    else
        Atlas=[];
        return
    end    
else
    Atlas=[];
    return
end

function [Atlas] = wfu_get_shape(atlas_path, ImageName, shapeoffset)
% This program will construct the shap atlas list
Atlas=[];
RegionNo=0;
SubregionNo=0;
Offset=shapeoffset;

if exist([atlas_path ImageName],'file')
    [aheader, atlas] = wfu_read_analyze_header([atlas_path ImageName]);
    Atlas.Name=['Shapes'];
    Atlas.Aheader=aheader;
    %Atlas.Atlas=atlas;
    Atlas.Atlas=zeros(aheader.x_dim.value, aheader.y_dim.value, ...
        aheader.z_dim.value, aheader.t_dim.value);
    Atlas.Offset=Offset;

    RegionName = ['Sphere'];
   	RegionNo = 1  ;
    Region(RegionNo).RegionName = RegionName;
    Region(RegionNo).ImageName = ImageName;
    Region(RegionNo).SubregionNames='';
    Region(RegionNo).SubregionValues=[];
    Region(RegionNo).Offset = Offset;
%    Atlas.Region=Region;
    
    RegionName = ['Box'];
   	RegionNo = 2  ;
    Region(RegionNo).RegionName = RegionName;
    Region(RegionNo).ImageName = ImageName;
    Region(RegionNo).SubregionNames='';
    Region(RegionNo).SubregionValues=[];
    Region(RegionNo).Offset = Offset;
    Atlas.Region=[Region];

end    
return
