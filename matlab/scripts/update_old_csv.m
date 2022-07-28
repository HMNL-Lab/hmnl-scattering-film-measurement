clear;clf;close all;clc
dir = uigetdir('C:\Users\noahm\Documents\Rutgers\HMNL\hmnl-scattering-film-measurement\data\csv_data\', 'Select directory to save new CSV files to');
[files, path] = uigetfile('*.csv', 'Select batch CSV file: ','MultiSelect','on');
if isequal(files,0)
    disp('User selected Cancel');
else
    for i = 1:length(files)
        fullpath = fullfile(path, files(i));
        old_csv_data = readtable(convertCharsToStrings(fullpath));

        angle = old_csv_data.Angle;
        pos_1_r = [old_csv_data.x1_r; old_csv_data.y1_r];
        pos_2_r = [old_csv_data.x2_r; old_csv_data.y2_r];
        % pos_1_t = [old_csv_data.x1_t; old_csv_data.y1_t];
        % pos_2_t = [old_csv_data.x2_t; old_csv_data.y2_t];

        pos_1_r = [cosd(angle), -sind(angle); sind(angle), cosd(angle)] * pos_1_r;
        pos_2_r = [cosd(angle), -sind(angle); sind(angle), cosd(angle)] * pos_2_r;

        new_csv_data = old_csv_data;

        new_csv_data.x1_r = pos_1_r(1);
        new_csv_data.y1_r = pos_1_r(2);

        new_csv_data.x2_r = pos_2_r(1);
        new_csv_data.y2_r = pos_2_r(2);
        
        save_path = convertCharsToStrings(fullfile(dir, files(i)));
        writetable(new_csv_data, save_path);
    end
end