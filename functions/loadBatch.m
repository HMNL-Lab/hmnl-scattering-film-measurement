function [batch] = loadBatch()
%LOADBATCH Summary of this function goes here
%   Detailed explanation goes here
[files, path] = uigetfile('*.csv', 'Select batch CSV file: ','MultiSelect','off');
if isequal(files,0)
    disp('User selected Cancel');
else
    fullpath = fullfile(path, files);
    raw = importdata(fullpath);
    batch = raw(2:end);
    batch = convertCharsToStrings(batch);
end
end

