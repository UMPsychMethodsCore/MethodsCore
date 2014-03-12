function NodeSelect = mc_node_select(NodeCoord,NodeList)

L          = size(NodeCoord,1);
l          = size(NodeList,1);
NodeSelect = []; % vector to contain the selected node number

for i = 1:l
    for j = 1:L
        if isequal(NodeList(i,:),NodeCoord(j,:))
            NodeSelect = [NodeSelect,j];
            break;
        end
    end
end
