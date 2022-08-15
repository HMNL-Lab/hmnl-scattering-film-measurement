% FUNCTION NAME:
%   imagej_csv_image_loader
%
% DESCRIPTION:
%   Preprocesser for Canny method of measuring images.
%   Takes in CSV generated by ImageJ macro matlab\imagej_macro\trans-reflect-rotation-correction.ijm.
%   Requires that Canny parameters (hysteresis threshold and standard deviation) are passed in.
%   Ensures that both images are the same size, and that they are valid file paths.
%   Outputs a struct needed to process images with [______]
%
% INPUT:
%   csv_path - (mustBeText) [1 X 1] a path to the CSV file generated by the ImageJ plugin
%   width - (optional, mustBeInteger, double) [1 X 1] Crop width for Canny method; defaults to 40
%   canny_threshold - (optional, mustBeVector, both elements between 0 and 1) [2 X 1] Hysteresis thresholds for Canny method; defaults to [0.01, 0.2]
%   canny_std - (optional, double) [1 X 1] Gaussian standard deviation for Canny method; defaults to 10
%   background_subtraction - (optional, string, can be 'none','imsubtract'); defaults to 'imsubtract'. Whether reflection image should be background subtracted using transmission image (imsubtract) or not (none)
%
% OUTPUT:
%   parameter_struct - (struct) struct with fields:
%       method_type: "ImageJ_Canny"
%       args:
%           reflection_image_path - (string) [1 X 1] the local path to the reflection image
%           transmission_image_path - (string) the local path to the transmission image
%           reflection_pos1 - (double) [2 X 1] first user selected [x, y] position when drawing line in reflection image in ImageJ macro, corrected for rotation angle
%           reflection_pos2 - (double) [2 X 1] second user selected [x, y] position when drawing line in reflection image in ImageJ macro, corrected for rotation angle
%           transmission_pos1 - (double) [2 X 1] first user selected [x, y] position when drawing line in transmission image in ImageJ macro, corrected for rotation angle
%           transmission_pos2 - (double) [2 X 1] second user selected [x, y] position when drawing line in transmission image in ImageJ macro, corrected for rotation angle
%           angle_degree - (double) [1 X 1] User specified rotation angle, in degrees
%           conversion - (double) [1 X 1] Pixel to real life unit conversion
%           width - (double, mustBeInteger) [1 X 1]  From input, crop width 
%           radius - (double) [1 X 1] = width / 2
%           canny_threshold - (double) [1 X 2] Hysteresis thresholds for Canny method
%           canny_std - (double) [1 X 1] Gaussian standard deviation for Canny method
%           background_subtraction - (string, can be 'none','imsubtract')
%
% ASSUMPTIONS AND LIMITATIONS:
%   Assumes that images have been corrected for rotation ImageJ macro matlab\imagej_macro\trans-reflect-rotation-correction.ijm.
%   By default, processed images of the ImageJ macro are stored \data\images\processed
%
% REVISION HISTORY:
%   26/07/2022 - Noah McAllister
%       * Initial implementation
%

function [parameter_struct] = imagej_csv_image_loader(csv_path, width, canny_threshold, canny_std, background_subtraction, transmission_exist)
    arguments
        csv_path {mustBeTextScalar, mustBeFile}
        width (1,1) double {mustBeInteger} = 40
        canny_threshold (2,1) double {mustBeVector, mustBeInRange(canny_threshold, 0.0, 1.0)} = [0.01 0.2]
        canny_std (1,1) double {mustBeInteger} = 10
        background_subtraction string {mustBeMember(background_subtraction, {'none', 'imsubtract'})} = "imsubtract"
        transmission_exist bool = true
    end

    % Load csv into table
    csv_data = readtable(convertCharsToStrings(csv_path));

    % Specify method
    parameter_struct.method_type = "ImageJ_Canny";
    if transmission_exist
            % Intialize images, check the files exist, and they are the same shape
        reflection_image_path = convertCharsToStrings(csv_data.Reflection);
        transmission_image_path = convertCharsToStrings(csv_data.Transmission);
        assert(isfile(reflection_image_path), "File at path to reflection image %s must exist.", reflection_image_path);
        assert(isfile(transmission_image_path), "File at path to transmission image %s must exist.", transmission_image_path);
        
        parameter_struct.args.reflection_image_path = reflection_image_path;
        parameter_struct.args.transmission_image_path = transmission_image_path;
        
        try
            reflection_image = imread(reflection_image_path);
        catch ME
            warning('Could not read reflection image at %s', reflection_image_path);
            rethrow(ME);
        end
    
        try
            transmission_image = imread(transmission_image_path);
        catch ME
            warning('Could not read transmission image at %s', transmission_image_path);
            rethrow(ME);
        end
        
        assert(isequal(size(reflection_image), size(transmission_image)), "Dimension mismatch: reflection and transmission images must be same size. \n Check that both have the same number of rows and cols, as well as that they are in the same colorspace.");
        
        % we don't need to do this yet
        % parameter_struct.args.reflection_image = double(reflection_image);
        % parameter_struct.args.transmission_image = double(transmission_image);
    
        % Initialize position and angle parameters from CSV
        parameter_struct.args.angle = csv_data.Angle;
        
        % check that x position are equal to the integer value
        parameter_struct.args.reflection_pos1 = [csv_data.x1_r; csv_data.y1_r];
        parameter_struct.args.reflection_pos2 = [csv_data.x2_r; csv_data.y2_r];
        parameter_struct.args.transmission_pos1 = [csv_data.x1_t; csv_data.y1_t];
        parameter_struct.args.transmission_pos2 = [csv_data.x2_t; csv_data.y2_t];
        
        assert(isequal(round(parameter_struct.args.reflection_pos1(1)), round(parameter_struct.args.reflection_pos2(1))), "Reflection x positions must be the same. \n This probably that shift was not held when drawing line.")
        assert(isequal(round(parameter_struct.args.transmission_pos1(1)), round(parameter_struct.args.transmission_pos2(1))), "Transmission x positions must be the same. \n This probably that shift was not held when drawing line.")
    
        % conversion factor
        parameter_struct.args.conversion = csv_data.Conversion;
        
        % assign parameters for Canny method
        parameter_struct.args.width = width;
        parameter_struct.args.radius = round(parameter_struct.args.width / 2);
        parameter_struct.args.canny_threshold = canny_threshold;
        parameter_struct.args.canny_std = canny_std;
        parameter_struct.args.background_subtraction = background_subtraction;
    else
                    % Intialize images, check the files exist, and they are the same shape
        reflection_image_path = convertCharsToStrings(csv_data.Reflection);
%         transmission_image_path = convertCharsToStrings(csv_data.Transmission);
        assert(isfile(reflection_image_path), "File at path to reflection image %s must exist.", reflection_image_path);
%         assert(isfile(transmission_image_path), "File at path to transmission image %s must exist.", transmission_image_path);
        
        parameter_struct.args.reflection_image_path = reflection_image_path;
%         parameter_struct.args.transmission_image_path = transmission_image_path;
        
        try
            reflection_image = imread(reflection_image_path);
        catch ME
            warning('Could not read reflection image at %s', reflection_image_path);
            rethrow(ME);
        end
    
%         try
%             transmission_image = imread(transmission_image_path);
%         catch ME
%             warning('Could not read transmission image at %s', transmission_image_path);
%             rethrow(ME);
%         end
        
%         assert(isequal(size(reflection_image), size(transmission_image)), "Dimension mismatch: reflection and transmission images must be same size. \n Check that both have the same number of rows and cols, as well as that they are in the same colorspace.");
        
        % we don't need to do this yet
        % parameter_struct.args.reflection_image = double(reflection_image);
        % parameter_struct.args.transmission_image = double(transmission_image);
    
        % Initialize position and angle parameters from CSV
        parameter_struct.args.angle = csv_data.Angle;
        
        % check that x position are equal to the integer value
        parameter_struct.args.reflection_pos1 = [csv_data.x1_r; csv_data.y1_r];
        parameter_struct.args.reflection_pos2 = [csv_data.x2_r; csv_data.y2_r];
%         parameter_struct.args.transmission_pos1 = [csv_data.x1_t; csv_data.y1_t];
%         parameter_struct.args.transmission_pos2 = [csv_data.x2_t; csv_data.y2_t];
        
        assert(isequal(round(parameter_struct.args.reflection_pos1(1)), round(parameter_struct.args.reflection_pos2(1))), "Reflection x positions must be the same. \n This probably that shift was not held when drawing line.")
%         assert(isequal(round(parameter_struct.args.transmission_pos1(1)), round(parameter_struct.args.transmission_pos2(1))), "Transmission x positions must be the same. \n This probably that shift was not held when drawing line.")
    
        % conversion factor
        parameter_struct.args.conversion = csv_data.Conversion;
        
        % assign parameters for Canny method
        parameter_struct.args.width = width;
        parameter_struct.args.radius = round(parameter_struct.args.width / 2);
        parameter_struct.args.canny_threshold = canny_threshold;
        parameter_struct.args.canny_std = canny_std;
        parameter_struct.args.background_subtraction = background_subtraction;
    end
    
end