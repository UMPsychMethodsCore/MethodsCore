% --------------------------------------------------------------------
function list = findindex(handles, value, d, Offset, MaskSide)
% find out the right atlas and return the mask point list
% --------------------------------------------------------------------
    iheader=handles.data.iheader;
    
    flagShape=0;
    for i=1 : length(handles.Atlas)
        if (handles.Atlas(i).Offset == Offset )
            map=handles.Atlas(i).Atlas;
            if (i==handles.Shape)
                flagShape=1;
            end
            break;
        end
    end
    if handles.atlasVolFlip
      if MaskSide==1
        MaskSide=2;
      elseif MaskSide==2
        MaskSide=1;
      end
    end
    
    switch MaskSide
      case 1 % right side
          map(1:round(iheader.dim(1)/2), :) = 0; 
      case 2 % left side
          map(round(iheader.dim(1)/2) :end, :) = 0;
    end
    if d > 0
        %dilatemask = ones(floor(d)+1);
        if (flagShape)
            mask= (bitand(map,2^value));
        else
            mask = (map==value);
        end  
        %for i = 1 : size(mask, 3)
        %    mask(:,:,i) = dilate(mask(:,:,i), dilatemask);
        %end
        if handles.Dilate2D
            mask = dilate_cube(mask,d);
        else
            mask = dilate_cube(mask,d,1);
        end    
        list = find (mask);
    else
        if (flagShape)
            list = find(bitand(map,2^value));
        else
            list = find(map == value);
        end
    end

    
