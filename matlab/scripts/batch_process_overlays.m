dir = uigetdir('C:\Users\noahm\Documents\Rutgers\HMNL\hmnl-scattering-film-measurement\test-scripts\tmp\', 'Select directory to save new overlay image files to');
[files, path] = uigetfile({'*.json;*.h5;*.hdf5'},'Select optical thickness files: ', 'MultiSelect','on');

for i = 1:length(files)
    fullpath = string(fullfile(path, files(i)));
    [folder, sample_name, ext] = fileparts(fullpath);
    data = read_data_from_h5_or_json(fullpath);
    image = overlay_edges(data);
    save_to = fullfile(dir, strjoin([sample_name, "_overlay.tif"], ''));
    if isfile(save_to)
        warning('File exists.')
        str = input('[Y/N] to overwrite: ', 's');
        if str == 'Y'
            imwrite(image, save_to);
            fprintf('Sample %s successfully saved! \nSaved to %s \n\n', sample_name, save_to);
        else
            disp('Operation cancelled.');
        end
    else
        imwrite(image, save_to);
        fprintf('Sample %s successfully saved! \nSaved to %s \n\n', sample_name, save_to);
    end
    clear image;
end