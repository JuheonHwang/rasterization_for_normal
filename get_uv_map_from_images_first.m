function [uv_map] = get_uv_map_from_images(filenames, uv_location_map, uv_tri_map, uv_map_size, vertices, faces)
    uv_map = NaN(uv_map_size(1)*uv_map_size(2), 3, length(filenames));
    uv_tri_map_flat = uv_tri_map(:);
    uv_location_map_flat = reshape(uv_location_map, [], 3);
    
    uv_location_map_flat = [uv_location_map_flat, ones(size(uv_location_map_flat, 1), 1)];

    global_norm = vertexNormal(triangulation(faces, vertices));

    is_uv_valid = uv_tri_map_flat > 0;
    uv_tri_valid = uv_tri_map_flat(is_uv_valid);
    % uv_loc_valid = uv_location_map_flat(is_uv_valid, :);

    cam_params = load("F:\\3_DB\\CamSystem\\20230831_highlight_human\\cams\\cam_mat.mat");

    for i = 1:length(filenames)
        file_name = filenames(i);
        img = imread(sprintf('F:\\3_DB\\CamSystem\\20230831_highlight_human\\normal\\M_Normal_CAM%s.png', file_name));
        
        % mask is optional
        mask = imread(sprintf('F:\\3_DB\\CamSystem\\20230831_highlight_human\\mask\\Position000007_CAM%s.png', file_name));
        mask = mask ./255;
        mask = mask >= 0.5;

        db_img = double(img) .* double(mask);
        % db_img = double(img);
        
        cam_param = cam_params.(sprintf('CAM%s', file_name));
        K = cam_param.K;
        M = cam_param.R;
        T = cam_param.t;

        % [M, T, eX, eY, f, a, b, K1, K2, image_size] = read_camParam(sprintf('camParam/%s.tka', file_name));
        % K = [f/eX 0 a; 0 f/eY b; 0 0 1];

        MT = zeros(3, 4);
        MT(:, 1:3) = M;
        MT(:, 4) = T;
        
        uv_local_loc_flat = uv_location_map_flat * MT';
        uv_img_loc_flat = uv_local_loc_flat * K';
        uv_img_p_flat = uv_img_loc_flat(:, 1:2) ./ uv_img_loc_flat(:, 3);
        % uv_local_loc_flat = (uv_location_map_flat - T) * M';
        % uv_img_loc_flat = uv_local_loc_flat * K';
        % uv_img_p_flat = uv_img_loc_flat(:, 1:2) ./ uv_img_loc_flat(:, 3);

        is_verts_invisible = sum(global_norm .* M(3, :), 2) <= 0;
        is_faces_invisible = any(is_verts_invisible(faces), 2);

        is_uv_valid_here = is_uv_valid;
        is_uv_valid_here(is_uv_valid) = is_faces_invisible(uv_tri_valid);

        uv_img_p_flat_valid = uv_img_p_flat(is_uv_valid_here, :);
        
        uv_map(is_uv_valid_here, 1, i) = interp2(db_img(:, :, 1), uv_img_p_flat_valid(:, 1)+1, uv_img_p_flat_valid(:, 2)+1, 'nearest', NaN);
        uv_map(is_uv_valid_here, 2, i) = interp2(db_img(:, :, 2), uv_img_p_flat_valid(:, 1)+1, uv_img_p_flat_valid(:, 2)+1, 'nearest', NaN);
        uv_map(is_uv_valid_here, 3, i) = interp2(db_img(:, :, 3), uv_img_p_flat_valid(:, 1)+1, uv_img_p_flat_valid(:, 2)+1, 'nearest', NaN);
        % uv_map(is_uv_valid_here, 1, i) = interp2(db_img(:, :, 1), uv_img_p_flat_valid(:, 1)+1, uv_img_p_flat_valid(:, 2)+1, 'linear', NaN);
        % uv_map(is_uv_valid_here, 2, i) = interp2(db_img(:, :, 2), uv_img_p_flat_valid(:, 1)+1, uv_img_p_flat_valid(:, 2)+1, 'linear', NaN);
        % uv_map(is_uv_valid_here, 3, i) = interp2(db_img(:, :, 3), uv_img_p_flat_valid(:, 1)+1, uv_img_p_flat_valid(:, 2)+1, 'linear', NaN);
        % + 1은 Sampling 시점에 할 것, 그래야지 Code Migration이 편함
    end
    uv_map_ = (uv_map ./ 255.0) * 2.0 - 1.0;
    % uv_map(round(sum(uv_map_ .* uv_map_, 2)) ~= 1) = NaN;
    uv_map(round(realsqrt(sum(uv_map_ .* uv_map_, 2)), 2) <= 0.99 | round(realsqrt(sum(uv_map_ .* uv_map_, 2)), 2) >= 1.01) = NaN;
        
    % uv_map = nanmean(uv_map, 3);
    uv_map = nanmedian(uv_map, 3);
    uv_map = reshape(uv_map, uv_map_size(1), uv_map_size(2), 3);
end