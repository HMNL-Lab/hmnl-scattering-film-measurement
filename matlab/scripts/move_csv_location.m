clear;clf;close all;clc
dir = uigetdir('C:\Users\noahm\Documents\Rutgers\HMNL\hmnl-scattering-film-measurement\data\csv_data\', 'Select directory to move CSV files to (data\csv_data\)');
[files, path] = uigetfile('*.csv', 'Select CSV files to move (in data\images\processed\): ','MultiSelect','on');
