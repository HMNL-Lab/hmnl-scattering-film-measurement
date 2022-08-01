clear;clf;close all;clc;
[files, path] = uigetfile({'*.json;*.h5;*.hdf5'},'Select optical thickness files: ', 'MultiSelect','on');

for i = 1:length(files)
    fullpath = string(fullfile(path, files(i)));
    [folder, sample_name, ext] = fileparts(fullpath);
    data(i) = read_data_from_h5_or_json(fullpath);
    sample_names(i) = sample_name;
end

for i = 1:length(data)
    Mean(i) = data(i).mean;
    StdDeviation(i) = data(i).std;
    Min(i) = data(i).min;
    Max(i) = data(i).max;
    N(i) = data(i).n;
end
Mean = Mean';
StdDeviation = StdDeviation';
Min = Min';
Max = Max';
N = N';
sample_names = sample_names';

T = table(Mean, StdDeviation, Min, Max, N, 'RowNames', sample_names);

saveToExcel = input('Save this data to an Excel file? [Y/N] ', 's');
if saveToExcel == 'Y'
    exportFile = input('Enter output file name: ', 's');
    dir = uigetdir('C:\Users\noahm\Documents\Rutgers\HMNL\hmnl-scattering-film-measurement\data', 'Select directory to save to');
    saveTo = strcat({dir, '\', exportFile, '.xlsx'});
    saveTo = strjoin(saveTo, '');
    if isfile(saveTo)
        warning('File exists.')
        str = input('[Y/N] to overwrite: ', 's');
        if str == 'Y'
            writetable(T, saveTo, 'WriteRowNames', true);
            disp('Data successfully saved!');
        else
            disp('Operation cancelled.');
        end
    else
        writetable(T, saveTo, 'WriteRowNames', true);
        disp('Data successfully saved!');
    end
end