%atlas for P857

 load('/data2/neugebauer/Matlab/P0857/SimBio/P0857_free/P0857_source_space_idxs_for_DTK_atlas.mat');
load('/data2/neugebauer/Matlab/P0857/SimBio/P0857_free/P0857_mesh_mat_with_DTK_labels.mat');



%%
figure;
hold on;

for i=1:108
    
    if ~isempty(sp_idx_atlas{i})
        myscatter3(source_grid(sp_idx_atlas{i},:), '*')
    end
end
    


%%

atlas_grid=cell(34559,1);


for i=1:108
     if ~isempty(sp_idx_atlas{i})
         v=sp_idx_atlas{i};
          for k=1:length(v)
            atlas_grid{v(k)}=anatomical_labels{i, 4};
          end
    end
end

