function outStruct = voxelImageConversion(xyz,mat,dim,space, flip)
% outStruct = voxelImageConversion(xyz,mat,dim,space)
% or
% outStruct = voxelImageConversion(xyz,handles,space)
%
% wfu_results internal function
%
% convers xyz from specified image, voxel, or MNI space to a structure
% containing all three of the same name.
%
% flip is [a b] where a is true if flipped l/r and b is true if flipped u/d 
%
%
% The second (from struct) version will populate the mat, dim, space, and
% flip as follows:
%
% mat     handles.data.template.header.mat
% dim     handles.data.template.header.dim
% flip    handles.data.preferences.flip
%__________________________________________________________________________
% Created: Oct 9, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.3 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.3 $');
  
  if nargin < 5
    flip=[0 0];
  end
  
  if numel(flip) < 2
    flip=[flip 0];
  end
  
  if isstruct(mat)
    %shift and assign variables
    handles=mat;
    space=dim;
    %assign rest from handles
    mat=  handles.data.template.header.mat;
    dim=  handles.data.template.header.dim;
    flip= handles.data.preferences.flip;
    
  end
  
  
  outStruct=struct('image',[],'voxel',[],'MNI',[]);
  
  if isempty(xyz), return; end;
  if size(xyz,1) ~=  3, xyz=xyz'; end
  if size(xyz,1) == 1, xyz = shiftdim(xyz,1); end
  xyz=xyz(1:3,:);

  numOfXYZs=size(xyz,2);
%  numOfXYZs=1:1
  
  for i=1:numOfXYZs
    WFU_LOG.minutia('INPUT  in %5s space: %d %d %d',space,xyz(:,i));
  end

  repmatSize=[1 size(xyz,2)];
  
  %for debuging
  mni=[0 0 0];
  voxel=[0 0 0];
  image=[0 0 0];
  
  % DO EVERYTHING ON A SPACE CASE BASIS  UGH!!!!
  switch lower(space)
    case 'voxel'
      voxel=  xyz(1:3,:);
      if flip(1) && flip(2)
        mniVox= abs(voxel(1:3,:) - repmat([dim(1) 0 0]',repmatSize));
        mni=    mat * [mniVox(1:3,:); ones(repmatSize)];
        image=  voxel;
      elseif flip(1)
        mniVox= abs(voxel(1:3,:) - repmat([dim(1) 0 0]',repmatSize));
        mni=    mat * [mniVox(1:3,:); ones(repmatSize)];
        image=  abs(voxel(1:3,:) - repmat([0 dim(2) 0]',repmatSize));
      elseif flip(2)
        mni=    mat * [voxel(1:3,:); ones(repmatSize)];
        image=  voxel;
      else
        mni=    mat * [voxel(1:3,:); ones(repmatSize)];
        image=  abs(voxel(1:3,:) - repmat([0 dim(2) 0]',repmatSize));
      end
    case 'mni'
      mni=    xyz(1:3,:);
      if flip(1) && flip(2)
        voxel=  round(inv(mat) * [mni;ones(repmatSize)]);
        voxel=  abs(voxel(1:3,:) - repmat([dim(1) 0 0]',repmatSize));
        image=  voxel;
      elseif flip(1)
        voxel=  round(inv(mat) * [mni;ones(repmatSize)]);
        voxel=  abs(voxel(1:3,:) - repmat([dim(1) 0 0]',repmatSize));
        image=  voxel;
        image=  abs(image(1:3,:) - repmat([0 dim(2) 0]',repmatSize));
      elseif flip(2)
        voxel=  round(inv(mat) * [mni;ones(repmatSize)]);
        image=  voxel;
      else
        voxel=  round(inv(mat) * [mni;ones(repmatSize)]);
        image=  abs(voxel(1:3,:) - repmat([0 dim(2) 0]',repmatSize));
      end
    case 'image'
      image=  xyz(1:3,:);
      if flip(1) && flip(2)
        voxel=    image;
        mnivox=   abs(image(1:3,:) - repmat([dim(1) 0 0]',repmatSize));
        mni=      mat * [mnivox(1:3,:); ones(repmatSize)];
      elseif flip(1)
        voxel=    abs(image - repmat([0 dim(2) 0]',repmatSize));
        mnivox=   abs(image - repmat([dim(1) dim(2) 0]',repmatSize));
        mni=      mat * [mnivox(1:3,:); ones(repmatSize)];
      elseif flip(2)
        voxel=    image;
        mni=      mat * [voxel(1:3,:); ones(repmatSize)];
      else
        voxel=    image;
        voxel=    abs(image - repmat([0 dim(2) 0]',repmatSize));
        mni=      mat * [voxel(1:3,:); ones(repmatSize)];
      end
    otherwise
      WFU_LOG.error('Unknown space `%s`\n',space);
  end
  
  outStruct.MNI=    mni;
  outStruct.voxel=  voxel;
  outStruct.image=  image;
  
  
  %cleanup
  fldnames=fieldnames(outStruct);
  for i=1:length(fldnames)
    fldname=char(fldnames(i));
    if size(outStruct.(fldname),1) > size(outStruct.(fldname),2)
      outStruct.(fldname) = outStruct.(fldname)';
    end;
    tmp=outStruct.(fldname);
    if size(tmp,1)==1, tmp=shiftdim(tmp,1); end
    if size(tmp,1) <3, tmp=tmp'; end;
    outStruct.(fldname)=tmp(1:3,:);
    for j=1:numOfXYZs
      WFU_LOG.minutia('OUTPUT in %5s space: %d %d %d',fldname,outStruct.(fldname)(:,j));
    end
  end

  
return

%{
$Log: voxelImageConversion.m,v $
Revision 1.3  2010/07/22 14:37:04  bwagner
Allowed Up/Down flip.  Flip is now 2 element var with 1st being L/R and 2nd being U/D.  Allow secondary way of calling private/voxelImageConversion.

revision 1.2  2010/07/09 13:37:13  bwagner
Checkin before aHeader to iHeader Pickatlas code update

revision 1.1  2009/10/09 17:11:37  bwagner
PickAtlas Release Pre-Alpha 1
%}