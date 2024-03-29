% FUNCTION NAME:
%   read_data_from_h5_or_json
%
% DESCRIPTION:
%   Reads data struct generated by save_data_to_h5_or_json.m to struct data
%   
% INPUT:
%   filepath [1 X 1] (string, mustBeFile) HDF5 or JSON file to read
%
% OUTPUT:
%   data [1 X 1] (struct) struct of data contained within file
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

function [data] = read_data_from_h5_or_json(filepath)
    arguments
        filepath (1,1) string {mustBeFile}
    end

    [~,sample_name,ext] = fileparts(filepath);
    if strcmpi(ext, ".h5")
        tmp = loadh5(filepath);
        data = tmp.data;
        fprintf('Loaded Sample %s ! \nLoaded from %s \n\n', sample_name, filepath)
    elseif strcmpi(ext, ".json")
        data = loadjson(filepath);
        fprintf('Loaded Sample %s! \nLoaded from %s \n\n', sample_name, filepath)
    else
        error('File type must be .h5 or .json');
    end
end