clear;clf;close all;clc;
[files, path] = uigetfile({'*.json;*.h5;*.hdf5'},'Select optical thickness files: ', 'MultiSelect','on');
files = string(files);
path = string(path);
for i = 1:length(files)
    if length(string(files)) == 1
        fullpath = fullfile(path, files);
    else
        fullpath = fullfile(path, files(i));
    end
    [folder, sample_name, ext] = fileparts(fullpath);
    data(i) = read_data_from_h5_or_json(fullpath);
    sample_names(i) = sample_name;
end

BackgroundSubtraction = strings(length(data), 1);

for i = 1:length(data)
    Mean(i) = data(i).mean;
    StdDeviation(i) = data(i).std;
    Min(i) = data(i).min;
    Max(i) = data(i).max;
    N(i) = data(i).n;
    BackgroundSubtraction(i, 1) = data(i).parameters.args.background_subtraction;
end

Mean = Mean';
StdDeviation = StdDeviation';
Min = Min';
Max = Max';
N = N';
% BackgroundSubtraction = BackgroundSubtraction';
sample_names = sample_names';

T = table(Mean, StdDeviation, Min, Max, N, BackgroundSubtraction, 'RowNames', sample_names);

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