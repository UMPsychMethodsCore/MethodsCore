function wfu_pointers(fig,type)
% type is:
% * hand
% * closedhand or handdown
% * hand1
% * hand2
% * standard builtin "icons" from matlab
%The hand icons are from: http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=9855&objectType=File
  if nargin<2, type='Arrow'; end

  switch lower(type)
		case 'hand'
			cdata = [...
				 NaN NaN NaN NaN NaN NaN NaN   1   1 NaN NaN NaN NaN NaN NaN NaN
				 NaN NaN NaN   1   1 NaN   1   2   2   1   1   1 NaN NaN NaN NaN
				 NaN NaN   1   2   2   1   1   2   2   1   2   2   1 NaN NaN NaN
				 NaN NaN   1   2   2   1   1   2   2   1   2   2   1 NaN   1 NaN
				 NaN NaN NaN   1   2   2   1   2   2   1   2   2   1   1   2   1
				 NaN NaN NaN   1   2   2   1   2   2   1   2   2   1   2   2   1
				 NaN   1   1 NaN   1   2   2   2   2   2   2   2   1   2   2   1
				   1   2   2   1   1   2   2   2   2   2   2   2   2   2   2   1
				   1   2   2   2   1   2   2   2   2   2   2   2   2   2   1 NaN
				 NaN   1   2   2   2   2   2   2   2   2   2   2   2   2   1 NaN
				 NaN NaN   1   2   2   2   2   2   2   2   2   2   2   2   1 NaN
				 NaN NaN   1   2   2   2   2   2   2   2   2   2   2   1 NaN NaN
				 NaN NaN NaN   1   2   2   2   2   2   2   2   2   2   1 NaN NaN
				 NaN NaN NaN NaN   1   2   2   2   2   2   2   2   1 NaN NaN NaN
				 NaN NaN NaN NaN NaN   1   2   2   2   2   2   2   1 NaN NaN NaN
				 NaN NaN NaN NaN NaN   1   2   2   2   2   2   2   1 NaN NaN NaN
				 ];
	    hotspot = [10 9];
	
		case {'closedhand','handdown'}
			cdata = [...
				 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
				 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
				 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
				 NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
				 NaN NaN NaN NaN   1   1 NaN   1   1 NaN   1   1 NaN NaN NaN NaN
				 NaN NaN NaN   1   2   2   1   2   2   1   2   2   1   1 NaN NaN
				 NaN NaN NaN   1   2   2   2   2   2   2   2   2   1   2   1 NaN
				 NaN NaN NaN NaN   1   2   2   2   2   2   2   2   2   2   1 NaN
				 NaN NaN NaN   1   1   2   2   2   2   2   2   2   2   2   1 NaN
				 NaN NaN   1   2   2   2   2   2   2   2   2   2   2   2   1 NaN
				 NaN NaN   1   2   2   2   2   2   2   2   2   2   2   2   1 NaN
				 NaN NaN   1   2   2   2   2   2   2   2   2   2   2   1 NaN NaN
				 NaN NaN NaN   1   2   2   2   2   2   2   2   2   2   1 NaN NaN
				 NaN NaN NaN NaN   1   2   2   2   2   2   2   2   1 NaN NaN NaN
				 NaN NaN NaN NaN NaN   1   2   2   2   2   2   2   1 NaN NaN NaN
				 NaN NaN NaN NaN NaN   1   2   2   2   2   2   2   1 NaN NaN NaN
				 ];
	    hotspot = [10 9];    
	
		case 'hand1'
			cdata = [...
				 NaN NaN NaN NaN NaN NaN NaN   1   1 NaN NaN NaN NaN NaN NaN NaN
				 NaN NaN NaN   1   1 NaN   1   2   2   1   1   1 NaN NaN NaN NaN
				 NaN NaN   1   2   2   1   1   2   2   1   2   2   1 NaN NaN NaN
				 NaN NaN   1   2   2   1   1   2   2   1   2   2   1 NaN   1 NaN
				 NaN NaN NaN   1   2   2   1   2   2   1   2   2   1   1   2   1
				 NaN NaN NaN   1   2   2   1   2   2   1   2   2   1   2   2   1
				 NaN   1   1 NaN   1   2   2   2   2   2   2   2   1   2   2   1
				   1   2   2   1   1   2   2   2   1   2   2   2   2   2   2   1
				   1   2   2   2   1   2   2   1   1   2   2   2   2   2   1 NaN
				 NaN   1   2   2   2   2   2   2   1   2   2   2   2   2   1 NaN
				 NaN NaN   1   2   2   2   2   2   1   2   2   2   2   2   1 NaN
				 NaN NaN   1   2   2   2   2   2   1   2   2   2   2   1 NaN NaN
				 NaN NaN NaN   1   2   2   2   2   1   2   2   2   2   1 NaN NaN
				 NaN NaN NaN NaN   1   2   2   1   1   1   2   2   1 NaN NaN NaN
				 NaN NaN NaN NaN NaN   1   2   2   2   2   2   2   1 NaN NaN NaN
				 NaN NaN NaN NaN NaN   1   2   2   2   2   2   2   1 NaN NaN NaN
				 ];
			hotspot = [10 9];              
	              
		case 'hand2'
			cdata = [...
				NaN NaN NaN NaN NaN NaN NaN   1   1 NaN NaN NaN NaN NaN NaN NaN
				NaN NaN NaN   1   1 NaN   1   2   2   1   1   1 NaN NaN NaN NaN
				NaN NaN   1   2   2   1   1   2   2   1   2   2   1 NaN NaN NaN
				NaN NaN   1   2   2   1   1   2   2   1   2   2   1 NaN   1 NaN
				NaN NaN NaN   1   2   2   1   2   2   1   2   2   1   1   2   1
				NaN NaN NaN   1   2   2   1   2   2   1   2   2   1   2   2   1
				NaN   1   1 NaN   1   2   2   2   2   2   2   2   1   2   2   1
	 			  1   2   2   1   1   2   2   2   1   1   2   2   2   2   2   1
				  1   2   2   2   1   2   2   1   2   2   1   2   2   2   1 NaN
				NaN   1   2   2   2   2   2   2   2   2   1   2   2   2   1 NaN
				NaN NaN   1   2   2   2   2   2   2   1   2   2   2   2   1 NaN
				NaN NaN   1   2   2   2   2   2   1   2   2   2   2   1 NaN NaN
				NaN NaN NaN   1   2   2   2   1   2   2   2   2   2   1 NaN NaN
				NaN NaN NaN NaN   1   2   2   1   1   1   1   2   1 NaN NaN NaN
				NaN NaN NaN NaN NaN   1   2   2   2   2   2   2   1 NaN NaN NaN
				NaN NaN NaN NaN NaN   1   2   2   2   2   2   2   1 NaN NaN NaN
				];
			hotspot = [10 9];              
	end
	
	if exist('cdata','var')
    set(fig,'Pointer','custom','PointerShapeCData',cdata,'PointerShapeHotSpot',hotspot);
  else
    try
      set(fig,'Pointer',type)
    catch ME
    end
  end
return
