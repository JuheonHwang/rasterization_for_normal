function [location_map, tri_map] = fn_rasterization4texture(vertices, faces, texture_idx, image_size)
    location_map = NaN(image_size(1), image_size(2), 3);
    tri_map = zeros(image_size(1), image_size(2));

    for i = 1:length(faces)
        f = faces(i, :);
        v1 = vertices(f(1), :);
        v2 = vertices(f(2), :);
        v3 = vertices(f(3), :);
    
        uv_v1 = texture_idx(f(1), :);
        uv_v2 = texture_idx(f(2), :);
        uv_v3 = texture_idx(f(3), :);
    
        uv_min_x = ceil(min(min(uv_v1(1), uv_v2(1)), uv_v3(1)));
        uv_max_x = floor(max(max(uv_v1(1), uv_v2(1)), uv_v3(1)));
        uv_min_y = ceil(min(min(uv_v1(2), uv_v2(2)), uv_v3(2)));
        uv_max_y = floor(max(max(uv_v1(2), uv_v2(2)), uv_v3(2)));
    
        %if (uv_min_x > image_size(2)) || (uv_min_y > image_size(1)) || (uv_max_x < 1) || (uv_max_y < 1)
        %    continue
        %end
        %
        % Not required for UV Mapping
    
        for x_coord = uv_min_x:uv_max_x
            for y_coord = uv_min_y:uv_max_y
                [c1, c2, c3] = barycentric(uv_v1(1), uv_v2(1), uv_v3(1), uv_v1(2), uv_v2(2), uv_v3(2), x_coord, y_coord);
                if (c1 < 0) || (c2 < 0) || (c3 < 0)
                    continue
                end
                
                location_map(y_coord+1, x_coord+1, :) = c1 * v1 + c2 * v2 + c3 * v3;
                tri_map(y_coord+1, x_coord+1) = i;
                % + 1은 Indexing 시점에 할 것, 그래야지 Code Migration이 편함
                
            end
        end
    end
end