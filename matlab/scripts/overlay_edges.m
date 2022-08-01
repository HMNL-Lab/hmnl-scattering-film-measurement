function [diff] = overlay_edges(data)
    arguments
        data (1,1) struct
    end

    r_path = data.parameters.args.reflection_image_path;
    t_path = data.parameters.args.transmission_image_path;
    x1 = data.cropRegion.x1;
    x2 = data.cropRegion.x2;
    
    r_image = imread(r_path);
    t_image = imread(t_path);
    if strcmpi(data.parameters.args.background_subtraction, "none")
        diff = r_image;
    elseif strcmpi(data.parameters.args.background_subtraction, "imsubtract")
        diff = r_image - t_image;
    else
        error("data.parameters.args.background_subtraction must be either none or imsubtract")
    end
    edges = logical(data.canny);
    % rescale edges so that it aligns with original image
    [drows,dcols,~] = size(diff);
    % fill in the rest of the edge matrix with zeros so we can see where edges are
    left = zeros(drows, x1-1);
    right = zeros(drows, dcols-x2);
    overlay = [left, edges, right];
    
    for i = 1:drows
        for j = 1:dcols
            if overlay(i,j) == 1
                diff(i,j,:) = 0;
                diff(i,j,1) = 255;
            end
        end
    end
end