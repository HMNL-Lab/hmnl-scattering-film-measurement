% FUNCTION NAME:
%   canny_measurement
%
% DESCRIPTION:
%
% INPUT:
%
% OUTPUT:
%
% ASSUMPTIONS AND LIMITATIONS:
%   Assumes that images have been corrected for rotation via ImageJ macro matlab\imagej_macro\trans-reflect-rotation-correction.ijm.
%   By default, processed images of the ImageJ macro are stored \data\images\processed
%
% REVISION HISTORY:
%   26/07/2022 - Noah McAllister
%       * Initial implementation
%

function [data] = canny_measurement(parameter_struct)
    arguments
        parameter_struct (1,1) struct
    end
    assert(strcmp(parameter_struct.method_type, "ImageJ_Canny"))
    
    % Load reflection image
    r_image.color = imread(parameter_struct.args.reflection_image_path);
    [data.r.rows, data.r.cols, ~] = size(r_image.color);

    % Load transmission image
    t_image.color = imread(parameter_struct.args.transmission_image_path);
    [data.t.rows, data.t.cols, ~] = size(t_image.color);

    % crop difference between rpos - radius and tpos + radius
    data.cropRegion.x1 = round(parameter_struct.args.reflection_pos1(1) - parameter_struct.args.radius);
    data.cropRegion.x2 = round(parameter_struct.args.transmission_pos1(1) + parameter_struct.args.radius);

    if strcmpi(parameter_struct.args.background_subtraction, "none")
        % uses just the reflection image
        diff.color = r_image.color;        
    elseif strcmpi(parameter_struct.args.background_subtraction, "imsubtract")
        % take the difference between the reflection and transmission using imsubtract
        diff.color = imsubtract(r_image.color, t_image.color);
    end

    diff.color = diff.color(:,data.cropRegion.x1:data.cropRegion.x2,:);

    % convert to gray scale for Canny
    if (size(diff.color, 3) == 3)
        diff.gray = rgb2gray(diff.color);
    else
        diff.gray = diff.color;
    end

    % find edges using Canny method with specified threshold and standard deviation
    data.canny = edge(diff.gray, 'Canny', parameter_struct.args.canny_threshold, parameter_struct.args.canny_std);

    % find thickness using thicknessArray internal function
    data.thickness = thicknessArray(data.canny) ./ parameter_struct.args.conversion;

    data.mean = mean(data.thickness);
    data.std = std(data.thickness);
    data.min = min(data.thickness);
    data.max = max(data.thickness);
    data.n = length(data.thickness);
    data.parameters = parameter_struct;

    function [thickness] = thicknessArray(cannyImage)
    [rows,cols] = size(cannyImage);
    idx = 1;
    thickidx = 1;
    edgePt = [];
    thickness = [];
    for i = 1:rows
        for j = 1:cols
            if cannyImage(i,j) == 1
                edgePt(idx) = j;
                idx = idx + 1;
            end
        end
        idx = 1;
        if size(edgePt, 1) ~= 0
            thickness(thickidx) = max(edgePt) - min(edgePt);
        end
        thickidx = thickidx + 1;
        edgePt = [];
    end
    assert(~isempty(thickness), "canny_measurement:thickness_error", "Thickness array empty. Check that image is valid.")
    thickness = thickness(thickness ~= 0); % remove single thicknesses from thickness array
    end
end