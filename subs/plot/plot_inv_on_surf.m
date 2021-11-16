%%
function p_surf_brain = plot_inv_on_surf(model,para,data,thro,source_grid_t,mri,alpha,plot_surf,plot_dist,plot_slice,plot_dipole,azel)

[axis_handle,df_fl] = check_and_assign_struc(para,'axis_handle','matlab.graphics.axis.Axes','df');
if(df_fl)
    axis_handle = CreateAxis([]);
end

aux_para = [];
aux_para.N_faces_max = check_and_assign_struc(para,'N_faces_max','i,>0',30000);
surf_type = 'brain';

[surf, ~] = GetSurface(model,surf_type,aux_para);

surf.vertices = (para.tt*surf.vertices')';

fpos     = surf.faces;
vpos     = surf.vertices;
spos     = source_grid_t;
if length(source_grid_t) == round(length(data)/3)
    activ    = sqrt(sum(reshape(data,3,size(source_grid_t,1))'.^2,2));
elseif size(data,2)>1
    activ   = sqrt(sum(data.^2,2));
else
    activ   = data;
end

%find vertices that correspond to the source space
Idx = knnsearch(spos,vpos);

vactiv   = activ(Idx,:);
thr      = vactiv>thro*max(vactiv);

vcmap2    = 0.8*[zeros(length(vactiv),1) zeros(length(vactiv),1) ones(length(vactiv),1)];
if any(all(activ))
    vcmap2   = vals2colormap(vactiv,'redblue', [min(vactiv) max(vactiv)]);
    vcmap2(~thr,:) = 0.8;
end

hold on
if plot_surf == 1
    
    colormap(redblue);
    p_surf_brain = patch('Faces',fpos,'Vertices',vpos,...
        'LineStyle','none','FaceColor','interp','FaceVertexCData',vcmap2,...
        'FaceLighting','gouraud','FaceAlpha',alpha);
    colorbar
    caxis([min(activ) max(activ)])
else
    p_surf_brain = patch('Faces',fpos,'Vertices',vpos,...
        'LineStyle','none','FaceColor','interp','FaceColor',[0.8 0.8 0.8],...
        'FaceLighting','gouraud','FaceAlpha',alpha);

    if plot_dist == 1
        thr      = activ>thro*max(activ);

        cmap = vals2colormap(activ, 'hot', [min(activ) max(activ)]);
        colormap(cmap)
        colormap(redblue);
        if thro > 0.5
            scatter3(spos(thr,1),spos(thr,2),spos(thr,3),[],cmap(thr,:),'filled')
        else
            scatter3(spos(thr,1),spos(thr,2),spos(thr,3),200*activ(thr),cmap(thr,:),'filled')
        end
    end
end

title(para.title)

if plot_slice == 1
    [~,idm] = max(sqrt(sum(activ,2).^2));
    
    pos = round(spos);
    
    xx = linspace(1,mri.dim(1),mri.dim(1));
    yy = linspace(1,mri.dim(2),mri.dim(2));
    zz = linspace(1,mri.dim(3),mri.dim(3));
    [sX,sY,sZ] = meshgrid(xx,yy,zz);
    an = permute(mri.anatomy,[2 1 3]);
    for i = 1:size(an,1)
        img = squeeze(an(i,:,:));
        img = img/max(max(img)); % image normalization 
        
        an(i,:,:) = adapthisteq(img);
    end
    slice(axis_handle,sX,sY,sZ,an,pos(idm,1),pos(idm,2),pos(idm,3));
    shading flat;
    colormap gray;
    
end

if plot_dipole == 1
    %plot dipole for maximum activity
    cd_matrix = GetSPcdmatrix(model);
    
    [~,midx]=max(data);
    
    s_est = zeros(length(data),1);
    
    s_est(midx:midx+2)=data(midx:midx+2);
    
    all_vec = cd_matrix(:,4:6);
    all_vec = bsxfun(@times,all_vec,s_est);
    pos = cd_matrix(1:3:end,1:3);
    vec = all_vec(1:3:end,:)+all_vec(2:3:end,:)+all_vec(3:3:end,:);
    s_amp = sqrt(sum(vec.^2,2));
    vec = vec/max(s_amp);
    
    est_para = para;
    est_para.color = check_and_assign_struc(para,'est_cone_color','double',[1 0 0]);
    est_para.cone_res = check_and_assign_struc(para,'cone_res','i,>0',20);
    est_para.scaling = check_and_assign_struc(para,'est_scaling','>0',10);
    est_para.axis_handle = axis_handle;
    pos=(para.tt*pos')';
    vec=(para.tt*vec')';
    my_cone_plot(pos,vec,est_para);
end
axis off;

p_surf_brain.FaceLighting = 'gouraud';
%p_surf_brain.AmbientStrength = 0.6;
%p_surf_brain.DiffuseStrength = 0.5;
p_surf_brain.BackFaceLighting = 'unlit';
%p_surf_brain.SpecularExponent = 25;
camlight(azel(1),360-azel(2)); lighting phong
%lightangle(270,270);
%shading interp

view(azel(3),azel(4))

% axis tight
% daspect([1,1,.4])

