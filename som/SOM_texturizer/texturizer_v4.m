function [b,v,t] = texturizer(v)

v_x = reshape(v,[size(v,1),1,3]);
v_y = reshape(v,[1,size(v,1),3]);
v_x_rep = repmat(v_x,[1,size(v,1),1]);
v_y_rep = repmat(v_y,[size(v,1),1,1]);
dist = v_x_rep-v_y_rep;
dist = dist.^2;
dist = sqrt(squeeze(sum(dist,3)));
t = zeros(0,3);
b = zeros(size(v,1));
new_triangles = [];
old_triangles = [];
tri_combs = nchoosek(1:3,2);
for ii=1:size(v,1)
    ii
    [y,i2] = sort(dist(ii,:));
    i2 = i2(2:end);
    num_vertices = 3;
    flag = false;
    g = [];
    %sphere_hist
    %text(v(:,1),v(:,2),v(:,3),num2str([1:100]'))
    %if ii==10
    %    pause;
    %end
    new_triangles = [];
    for num_vertices = 3:8
        tri_length = [];
        vertices = find(b(ii,:)>0);
        count = 1;
        while length(vertices) < num_vertices
            if any(vertices==i2(count))
                count = count + 1;
            else
                vertices = [vertices,i2(count)];
                count = count + 1;
            end
        end
        combs = nchoosek(vertices,2);
        for jj=1:size(combs,1)
            tri_length(jj) = dist(combs(jj,1),combs(jj,2));%dist(ii,combs(jj,1))+dist(ii,combs(jj,2))+dist(combs(jj,1),combs(jj,2));
        end
        [y,i] = sort(tri_length);
        for num_triangles = 1:length(vertices)
            y = hist([combs(i(1:num_triangles),1);combs(i(1:num_triangles),2)],[1:size(v,1)]);
            if any(find(y>2))
                i = [i(1:num_triangles-1),i(num_triangles+1:end)];
            end
        end
        for jj=1:size(combs,1)
            tri_length(jj) = dist(ii,combs(jj,1))+dist(ii,combs(jj,2))+dist(combs(jj,1),combs(jj,2));
        end
        g = [g mean(tri_length(i(1:length(vertices))))];
        new_triangles{num_vertices} = sort([combs(i(1:length(vertices)),:),repmat(ii,[length(vertices),1])],2);
    end
    [y,i] = sort(g);
    new_triangles = new_triangles{i(1)+2};
    for jj=1:size(new_triangles,1)
        temp_compare = sum(t==repmat(new_triangles(jj,:),[size(t,1),1]),2);
        cur_b = [b(new_triangles(jj,1),new_triangles(jj,2));
                 b(new_triangles(jj,1),new_triangles(jj,3));
                 b(new_triangles(jj,2),new_triangles(jj,3))];
        if all(temp_compare~=3) & ~any(cur_b>=2)
            t = [t;new_triangles(jj,:)];
            b(new_triangles(jj,1),new_triangles(jj,2)) = b(new_triangles(jj,1),new_triangles(jj,2))+1;
            b(new_triangles(jj,1),new_triangles(jj,3)) = b(new_triangles(jj,1),new_triangles(jj,3))+1;
            b(new_triangles(jj,2),new_triangles(jj,3)) = b(new_triangles(jj,2),new_triangles(jj,3))+1;
            b(new_triangles(jj,2),new_triangles(jj,1)) = b(new_triangles(jj,2),new_triangles(jj,1))+1;
            b(new_triangles(jj,3),new_triangles(jj,1)) = b(new_triangles(jj,3),new_triangles(jj,1))+1;
            b(new_triangles(jj,3),new_triangles(jj,2)) = b(new_triangles(jj,3),new_triangles(jj,2))+1;
        end
    end
end
f_t = [];
p = [];
[x,y] = ind2sub(size(b),find(b));
for ii=1:length(x)
    v = [v;(v(x(ii),:)+v(y(ii),:))/2];
    b(x(ii),y(ii)) = length(v);
    b(y(ii),x(ii)) = length(v);
end
min_t = Inf;
for ii=1:length(t)
    new_point = (v(t(ii,1),:)+v(t(ii,2),:)+v(t(ii,3),:))/3;
    v = [v;new_point];
    for jj=1:3
        %b(t(ii,jj),t(ii,mod(jj+3,3)+1))% < min_t
        %    min_t = t(ii,jj);
        %end
        f_t = [f_t;t(ii,jj),b(t(ii,jj),t(ii,mod(jj+1,3)+1)),length(v),b(t(ii,jj),t(ii,mod(jj+3,3)+1))];
    end
end
min_t
t = f_t;
b(find(b)) = 1;