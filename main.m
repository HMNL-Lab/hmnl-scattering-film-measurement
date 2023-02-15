%% NOTE: Run each section individually with "Run Section" button in Editor Tab
%% Step 1. Add required directories
run('startup.m')
%% Step 2a. Canny Method
%% Step 2a.1.
% Assumes that images have been corrected in their rotation so that the
% spray is vertical

% Read in CSV files generated from ImageJ Macro:
[files, path] = uigetfile('*.csv', 'Select batch CSV files generated by ImageJ Macro: ','MultiSelect','on');

% EDIT these
% search width
width = 40;

% edge() thresholds
threshold = [0.01, 0.2];

% edge std dev
gaussian_std = 10;

% background subtraction method: can be "none" or "imsubtract"
background_subtraction = "imsubtract";

% transmission image exists?
transmission_exist = true;

files = string(files);
path = string(path);

for i = 1:length(files)
    if length(string(files)) == 1
        fullpath = fullfile(path, files);
    else
        fullpath = fullfile(path, files(i));
    end
    parameter_struct(i) = imagej_csv_image_loader(fullpath, width, threshold, gaussian_std, background_subtraction, transmission_exist);
end

%% Step 2a.2. Batch process files from parameter struct

for i = 1:length(parameter_struct)
    [~, sample_name, ~] = fileparts(parameter_struct(i).args.reflection_image_path);
    try
        data(i) = canny_measurement(parameter_struct(i));
    catch ME
        if (strcmp(ME.identifier, "canny_measurement:thickness_error"))
            warning("Edge detection procedure failed with background subtraction. Trying with no background subtraction.")
            parameter_struct(i).args.background_subtraction = "none";
            data(i) = canny_measurement(parameter_struct(i));
        end
    end
    
    fprintf('Completed processing %s ! \n\n', sample_name)
end

%% Step 2a.3. Save data to HDF5 or JSON
% Requires JSONLab or EasyH5 respectively:
% JSONLab: https://github.com/fangq/jsonlab
% EasyH5: https://github.com/fangq/easyh5

folder = uigetdir('C:\Users\noahm\Documents\Rutgers\HMNL\hmnl-scattering-film-measurement\data\csv_data\', 'Select directory to save new JSON/HDF5 files to');
for i = 1:length(data)
    [~, sample_name, ~] = fileparts(data(i).parameters.args.reflection_image_path);
    save_data_to_h5_or_json(data(i), sample_name, folder, "json")
end

%% Step 2a.4. Generated edge overlays
run('matlab\scripts\batch_process_overlays.m');

%% Step 2a.5. Save data to a table
run("matlab\scripts\data_to_excel_table.m");

