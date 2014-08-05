nSpace = 40000;
%[b,v,t] = sphere_iter(3,1);
%i = [];
%for ii=1:40000:nSpace
  %D1 = rand(400000,3)-.5;
  %D1 = randn(40000,3);
  %D1 = SOM_UnitNormMatrix(D1,2);
  %udotv = D1*v';
  %y = sum(udotv>.992,1);
  %[y,i_tmp] = sum(udotv,[],2);
  %i = [i;i_tmp];
%end
%y = hist(i,1:length(v));
%closest = v*v2';
%[y,i] = max(closest,[],2);
%y = colors(i)';
%whos y
%y = zeros(length(v),1);
%y(1:length(v2)) = randn(length(v2),1);
%y = y';
tri_v = zeros(length(t),4,3);
size([v(t(:,1),1),v(t(:,2),1),v(t(:,3),1),v(t(:,4),1)])
tri_v(:,:,1) = [v(t(:,1),1),v(t(:,2),1),v(t(:,3),1),v(t(:,4),1)];
tri_v(:,:,2) = [v(t(:,1),2),v(t(:,2),2),v(t(:,3),2),v(t(:,4),2)];
tri_v(:,:,3) = [v(t(:,1),3),v(t(:,2),3),v(t(:,3),3),v(t(:,4),3)];
col_v = zeros(length(t),4);
col_v(:,:) = [y(t(:,1))',y(t(:,1))',y(t(:,1))',y(t(:,1))'];
%axes('Box','on');
subplot(2,2,1);
fill3(tri_v(:,:,1)',tri_v(:,:,2)',tri_v(:,:,3)',col_v(:,:,1)','FaceAlpha',1,'FaceLighting','phong','SpecularStrength',1);
axis off
axis equal
subplot(2,2,4);
fill3(tri_v(:,:,1)',tri_v(:,:,2)',tri_v(:,:,3)',col_v(:,:,1)','FaceAlpha',1,'FaceLighting','phong','SpecularStrength',1);
%axes('Visible','off');
axis off
axis equal
subplot(2,2,2);
fill3(tri_v(:,:,1)',tri_v(:,:,2)',tri_v(:,:,3)',col_v(:,:,1)','FaceAlpha',1,'FaceLighting','phong','SpecularStrength',1);
%axes('Visible','off');
axis off
axis equal
subplot(2,2,1);
v_ext = results_initial.v2*1.05;
camva(50);
for ii=1:size(results_initial.v2,1)
    text(v_ext(ii,1),v_ext(ii,2),v_ext(ii,3),num2str(ii),'HorizontalAlignment','center','ButtonDownFcn',['subplot(2,2,1);campos([',num2str(v_ext(ii,1)*2),',',num2str(v_ext(ii,2)*2),',',num2str(v_ext(ii,3)*2),']);subplot(2,2,4);campos([',num2str(v_ext(ii,1)*2),',',num2str(v_ext(ii,2)*2),',',num2str(v_ext(ii,3)*2),']);subplot(2,2,3);plot(SelfOMap(:,',num2str(ii),'));subplot(2,2,2);campos([',num2str(-v_ext(ii,1)*2),',',num2str(-v_ext(ii,2)*2),',',num2str(-v_ext(ii,3)*2),']);'],'BackgroundColor',[1 1 1])
end
campos([2 0 0]);
subplot(2,2,4);
camva(50);
text(v_ext(:,1),v_ext(:,2),v_ext(:,3),num2str([1:size(results_initial.v2,1)]'),'HorizontalAlignment','center')
campos([2 0 0]);
subplot(2,2,2);
camva(50);
campos([-2 0 0]);
text(v_ext(:,1),v_ext(:,2),v_ext(:,3),num2str([1:size(results_initial.v2,1)]'),'HorizontalAlignment','center')
drawnow
