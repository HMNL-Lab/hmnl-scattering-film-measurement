function [data] = cannyThickness(jsonFilePath, opts)
% load data using loadImageIntoDataStruct
[data, isImageExist] = loadImageIntoDataStruct(jsonFilePath);
%
exist_fields = convertCharsToStrings(fieldnames(isImageExist));
%
% throw error if reflect and trans are both not true in isImageExist
for i = 1:length(exist_fields)
    % find subfields -- guaranteed to exist because loadImageIntoDataStruct
    % checks for this
    exist_subfields = convertCharsToStrings(fieldnames(isImageExist.(exist_fields(i))));
    if length(exist_subfields) ~= 2
        warning("The number of subfields in current file is not 2. This could be an issue later.")
        if length(exist_subfields) > 2
            msg = join(["There are more than two subfields in the struct loaded from ",...
                jsonFilePath, " in mode '", exist_fields(i),...
                "'. The only valid subfields are 'reflect' and 'trans'."], "");
            error(msg);
        else
            msg = join(["There are less than two subfields in the struct loaded from ",...
                jsonFilePath, " in mode '", exist_fields(i),...
                "'. The only valid subfields are 'reflect' and 'trans'."], "");
            error(msg);
        end
    end
    for j = 1:length(exist_subfields)
        if ~(isImageExist.(exist_fields(i)).(exist_subfields(j)))
            msg = join(["The current method requires that both a reflection and transmission image be loaded. '",...
                exist_subfields(j), "' does not have an image loaded."], "");
            error(msg);
        end
    end
end
%
% check that necessary parameters exist
for i = 1:length(exist_fields)
    % throw error if necessary field does not exist
    if ~isfield(data.(exist_fields(i)).reflect, 'XResolution')
        msg = join(["Necessary field 'XResolution' in ", exist_fields(i), " does not exist."], "");
        error(msg);
    elseif ~isfield(data.(exist_fields(i)).trans, 'XResolution')
        msg = join(["Necessary field 'XResolution' in ", exist_fields(i), " does not exist."], "");
        error(msg);
    elseif ~isfield(data.(exist_fields(i)).reflect, 'YResolution')
        msg = join(["Necessary field 'YResolution' in ", exist_fields(i), " does not exist."], "");
        error(msg);
    elseif ~isfield(data.(exist_fields(i)).trans, 'YResolution')
        msg = join(["Necessary field 'YResolution' in ", exist_fields(i), " does not exist."], "");
        error(msg);
    elseif ~isfield(data.(exist_fields(i)).reflect, 'UserSelectedX')
        msg = join(["Necessary field 'UserSelectedX' in ", exist_fields(i), " does not exist."], "");
        error(msg);
    elseif ~isfield(data.(exist_fields(i)).trans, 'UserSelectedX')
        msg = join(["Necessary field 'UserSelectedX' in ", exist_fields(i), " does not exist."], "");
        error(msg);
    elseif ~isfield(data.(exist_fields(i)).reflect, 'ImageDescription')
        msg = join(["Necessary field 'ImageDescription' in ", exist_fields(i), " does not exist."], "");
        error(msg);
    elseif ~isfield(data.(exist_fields(i)).trans, 'ImageDescription')
        msg = join(["Necessary field 'ImageDescription' in ", exist_fields(i), " does not exist."], "");
        error(msg);
    end
end
%
% throw error if XResolution and YResolution are not same
for i = 1:length(exist_fields)
    % throw error if necessary field does not exist
    if data.(exist_fields(i)).reflect.XResolution ~= data.(exist_fields(i)).reflect.YResolution
        msg = "XResolution and YResolution should be the same. Check microscope settings.";
        error(msg);
    end
end
%
% throw error if trans and reflect resolution are not same
for i = 1:length(exist_fields)
    % throw error if necessary field does not exist
    if data.(exist_fields(i)).reflect.XResolution ~= data.(exist_fields(i)).trans.XResolution
        msg = "XResolution should be the same in reflect. Images need to taken with the same magnification.";
        error(msg);
    end
end
%
% throw error if Image was not saved by ImageJ (ie. rotation corrected)
for i = 1:length(exist_fields)
    % throw error if necessary field does not exist
    if ~(contains(string(data.(exist_fields(i)).reflect.ImageDescription), "ImageJ"))
        msg = "Field 'ImageDescription' must contain 'ImageJ'. This probably means you did not rotation correct the files.";
        error(msg);
    elseif ~(contains(string(data.(exist_fields(i)).reflect.ImageDescription), "ImageJ"))
        msg = "Field 'ImageDescription' must contain 'ImageJ'. This probably means you did not rotation correct the files.";
        error(msg);
    end
end

%
% actual measurement part
for i = 1:length(exist_fields)
    data.(exist_fields(i)).Canny.width = opts.width;
    data.(exist_fields(i)).Canny.radius = round(opts.width/2);
    data.(exist_fields(i)).Canny.cannyThreshold = opts.cannyThreshold;
    data.(exist_fields(i)).Canny.cannyStd = opts.cannyStd;
    
    % Load reflection image
    % r_image.color = double(data.(exist_fields(i)).reflect.Image);
    data.(exist_fields(i)).reflect.Image = double(data.(exist_fields(i)).reflect.Image);
    % [data.r.rows, data.r.cols, ~] = size(data.(exist_fields(i)).reflect.Image);
    
    % Load transmission image
    % t_image.color = double(data.(exist_fields(i)).trans.Image);
    data.(exist_fields(i)).trans.Image = double(data.(exist_fields(i)).trans.Image);
    % [data.t.rows, data.t.cols, ~] = size(data.(exist_fields(i)).trans.Image);
    
    % check both images are in the same color format
    if size(data.(exist_fields(i)).reflect.Image, 3) ~= size(data.(exist_fields(i)).trans.Image, 3)
        error("The color space of transmission and reflection images must be the same");
    end
    
    % take the difference between the reflection and transmission
    diff.color = data.(exist_fields(i)).reflect.Image - data.(exist_fields(i)).trans.Image;
    
    % crop difference between rpos - radius and tpos + radius
    data.(exist_fields(i)).Canny.x1 = data.(exist_fields(i)).reflect.UserSelectedX - data.(exist_fields(i)).Canny.radius;
    data.(exist_fields(i)).Canny.x2 = data.(exist_fields(i)).trans.UserSelectedX + data.(exist_fields(i)).Canny.radius;
    
    diff.color = diff.color(:,[(data.(exist_fields(i)).Canny.x1):(data.(exist_fields(i)).Canny.x2)],:);
    
    % convert to gray scale for Canny
    if (size(diff.color, 3) == 3)
        diff.gray = rgb2gray(diff.color);
    else
        error("Original images must be RGB.")
    end
    
    % find edges using Canny method with specified threshold and standard deviation
    data.(exist_fields(i)).Canny.canny = edge(diff.gray, 'Canny', data.(exist_fields(i)).Canny.cannyThreshold, data.(exist_fields(i)).Canny.cannyStd);
    
    % find thickness using thicknessArray function
    data.(exist_fields(i)).Canny.thickness = thicknessArray(data.(exist_fields(i)).Canny.canny) ./ data.(exist_fields(i)).reflect.XResolution;
    
    % remove outliers
    % data.(exist_fields(i)).Canny.thickness = rmoutliers(data.(exist_fields(i)).Canny.thickness, 'median');
    % statistics
    
    data.(exist_fields(i)).Canny.mean = mean(data.(exist_fields(i)).Canny.thickness);
    data.(exist_fields(i)).Canny.std = std(data.(exist_fields(i)).Canny.thickness);
    data.(exist_fields(i)).Canny.min = min(data.(exist_fields(i)).Canny.thickness);
    data.(exist_fields(i)).Canny.max = max(data.(exist_fields(i)).Canny.thickness);
    data.(exist_fields(i)).Canny.n = length(data.(exist_fields(i)).Canny.thickness);
    clear diff
end

%
% want to remove "Image" fields from the structure so they are not saved to disk
for i = 1:length(exist_fields)
    data.(exist_fields(i)).reflect = rmfield(data.(exist_fields(i)).reflect, 'Image');
    data.(exist_fields(i)).trans = rmfield(data.(exist_fields(i)).trans, 'Image');
end

% save data into same file
[~] = savejson('', data, char(jsonFilePath));
end

