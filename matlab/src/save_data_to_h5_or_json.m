% FUNCTION NAME:
%   save_data_to_h5_or_json
%
% DESCRIPTION:
%   Saves data from canny_measurement.m to disk in either HDF5 or JSON format
%   Requires user input to overwrite existing file
%   
% INPUT:
%   data [1 X 1] (struct) data struct that will be saved
%   sample_name [1 X 1] (string) name of file
%   folder [1 X 1] (string, mustBeFolder) name of folder to save to
%   method [1 X 1] (string, "json" or "hdf5") what type of file to save as, HDF5 is default and is losslessly compressed
%
% OUTPUT:
%   No output
%   Saves files to location given by fullfile(folder, strjoin([sample_name, ".h5"/".json"], ''))
%
% ASSUMPTIONS AND LIMITATIONS:
%   Assumes that images have been corrected for rotation ImageJ macro matlab\imagej_macro\trans-reflect-rotation-correction.ijm.
%   By default, processed images of the ImageJ macro are stored \data\images\processed
%   Logical array in data.canny gets stored as a uint8 array in the hdf5
%   Logical array in data.canny gets stored as a double array in the json

%
% REVISION HISTORY:
%   01/08/2022 - Noah McAllister
%       * Initial implementation

function [] = save_data_to_h5_or_json(data, sample_name, folder, method)

    arguments
        data (1, 1) struct
        sample_name (1, 1) string
        folder (1, 1) string {mustBeFolder}
        method string {mustBeMember(method, {'json', 'hdf5'})} = "hdf5"
    end

    if strcmpi(method, "hdf5")
        save_to = fullfile(folder, strjoin([sample_name, ".h5"], ''));
        if isfile(save_to)
            warning('File exists.')
            str = input('[Y/N] to overwrite: ', 's');
            if str == 'Y'
                saveh5(data, save_to);
                fprintf('Sample %s successfully saved! \nSaved to %s \n\n', sample_name, save_to);
            else
                disp('Operation cancelled.');
            end
        else
            saveh5(data, save_to);
            fprintf('Sample %s successfully saved! \nSaved to %s \n\n', sample_name, save_to);
        end
    elseif strcmpi(method, "json")
        save_to = fullfile(folder, strjoin([sample_name, ".json"], ''));
        if isfile(save_to)
            warning('File exists.')
            str = input('[Y/N] to overwrite: ', 's');
            if str == 'Y'
                [~] = savejson('', data, char(save_to));
                fprintf('Sample %s successfully saved! \nSaved to %s \n\n', sample_name, save_to);
            else
                disp('Operation cancelled.');
            end
        else
            [~] = savejson('', data, char(save_to));
            fprintf('Sample %s successfully saved! \nSaved to %s \n\n', sample_name, save_to);
        end
    else
    end

end
