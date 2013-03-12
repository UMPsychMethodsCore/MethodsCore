function [ a ] = mc_TakGraph_enlarge( a )
% MC_TAKGRAPH_ENLARGE 
% If the enlarge option is "on" (when a.DotDilateMat exists), this function is needed to update a.mediator.square
% to make it as a matrix represents enlarged edge dots.
% Need to run mc_Network_mediator.m first
%
% UNFORTUNATELY, this will overwrite its neighbors in probably a column-major way
%
%
%       INPUTS
%               a.DotDilateMat                  -       Your dilation matrix. Your original square matrix mat will be a nOffset*2 matrix of offsets that you wish to expand
%                                                       For example, to enlarge the dots by adding dots above, below, and to either side, use:
%                                                       a.DotDilateMat = [1 0; -1 0; 0 1; 0 -1];
%               a.mediator                      -       See mc_Network_FeatRestruct for details
%                       a.mediator.square       -       
%                       a.mediator.NetSubset    -       OPTIONAL - Contiguous vector of network labels to plot. We will only dilate edges in these networks                                                       
%       OUTPUT
%               a.mediator
%                       a.mediator.square       -       Updated matrix representing enlarged dots.
%
%


enlarge = a.mediator.square;

if isfield(a.mediator,'NetSubset')
    NetLogic = ismember(a.mediator.sorted,a.mediator.NetSubset);
else
    NetLogic = logical(ones(size(a.mediator.sorted)));
end

NetLogicSquare = zeros(size(a.mediator.square));
NetLogicSquare(NetLogic,NetLogic) = 1;
NetLogicIdx = find(NetLogicSquare);
enlarge = enlarge(NetLogic,NetLogic);

enlarge = triu(enlarge,1); % zero out the lower triangle and diagonal

mat     = a.DotDilateMat;

out = enlarge;
[hotx, hoty] = find(enlarge~=1); % ID all non 1 (non sigifnicant) points
[maxx, maxy] = size(enlarge);

for ihot = 1:size(hotx,1) % Loop over values to enlarge
    curVal = enlarge(hotx(ihot),hoty(ihot)); % Grab the value of the current thing to expand
    
    for ioff = 1:size(mat,1) % Loop over enlargements
        newx = hotx(ihot) + mat(ioff,1); %new x coordinate
        newy = hoty(ihot) + mat(ioff,2); %new y coordinate
        logicx = newx <= maxx & newx >=1; % check if new x coordinate is in bounds
        logicy = newy <= maxy & newy >=1; % check if new y coordinate is in bounds
        logicall = logicx & logicy ;  % check that both x and y coordinate are in bounds
        
        if logicall % if it's good, let's enlarge
            out(newx,newy) = curVal;
        end
    end
end

a.mediator.square(NetLogicIdx) = out;

a.mediator.square = triu(a.mediator.square,1); % zero out any dilations below diag

end

