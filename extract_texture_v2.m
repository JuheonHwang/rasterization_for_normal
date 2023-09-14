clear; close all;

[vertex, faces, textures] = jwutils.readObj('out_upper.obj');

figure; jwutils.dispMesh(vertex, faces, [0.8 0.8 0.8 1.0]);

filenames= ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10",...
            "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",...
            "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% uv_map_size = [512, 512];
% uv_map_size = [1024, 1024];
uv_map_size = [2048, 2048];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
texture_idx = textures .* (uv_map_size-1);

[uv_location_map, uv_tri_map] = fn_rasterization4texture(vertex, faces, texture_idx, uv_map_size);
[uv_map] = get_uv_map_from_images_first(filenames, uv_location_map, uv_tri_map, uv_map_size, vertex, faces);

figure; imshow(uv_map/255.);