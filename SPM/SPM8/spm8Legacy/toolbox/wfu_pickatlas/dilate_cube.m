function dcubes=dilate_cube(cube,dilation,threed,kernel)
% --------------------------------------------------------------------
% Function: dilate_cube()
%
% Purpose:  Will perform 2D or 3D dilation.
%
% Notes:    If function 'imdilate()' exists (i.e., if the user has 
%           the Image Processing Toolbox installed), then the original
%           dilate_cube() code is used. If the toolbox is not installed, then
%           the 'substitute' TRC code is used.
% --------------------------------------------------------------------
if (exist('imdilate'))
    %------------------------------------------------------------
    %This is the original code extracted from wfu_pPickatlas.m:
    %------------------------------------------------------------
    if ~exist('dilation') 
        dilation=1; % default dilation
    end
    
    looplimit=1;
    s = ones(floor(dilation)+1);
    
    if exist('threed') % 3D dilation
        s = ones(3,3,3); 
        looplimit=dilation;
    end

    if exist('kernel') 
        s = kernel; 
    end

    dcubes = cube > 0; % create a binary matrix

    for i = 1:looplimit  
        dcubes = imdilate( (dcubes > 0),s) > 0;  
    end
    
else
%--------------------------------------------------------------------
%    TRC substitute - no Image Analysis Toolbox here, so no "imdilate".
%--------------------------------------------------------------------
	s = max(dilation, 0);
	if ~exist('threed'), threed = 0; end;

	[xd yd zd ] = size(cube);
	dcubes = zeros( xd, yd, zd );

	[ x_sl y_sl z_sl ] = ind2sub( [xd yd zd], find( cube ) );

	for     ip   = 1:length( x_sl )
		ix   = x_sl( ip );	iy  = y_sl( ip );	iz = z_sl( ip );

	    	mnx  = max( 1, ix-s);	mxx = min( ix+s, xd);
	    	mny  = max( 1, iy-s);	mxy = min( iy+s, yd);
		if threed==1
		 mnz = max( 1, iz-s);	mxz = min( iz+s, zd);
	    	else
		 mnz = iz;		mxz = iz;
	        end

		dcubes(mnx:mxx, mny:mxy, mnz:mxz) = 1;
	end

end
