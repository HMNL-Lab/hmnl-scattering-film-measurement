clear;clf;close all;clc;
% This script must be run first when in the directory if one wants to use
% hmnl-scattering-film-measurement. Make sure that you are in the directory
% hmnl-scattering-film-measurement

% jsonlab information
% Name: jsonlab
% Version: 2.0
% Date: 2020-13-06
% Title: A JSON/UBJSON/MessagePack encoder/decoder for MATLAB/Octave
% Author: Qianqian Fang <fangqq@gmail.com>
% Maintainer: Qianqian Fang <fangqq@gmail.com>

% Get current path (pwd = present working directory)
paths = fullfile(pwd, {'matlab/jsonlab-2.0', 'matlab/src', 'matlab/scripts', 'matlab'});

% add paths to MATLAB search path
for i = 1:length(paths)
    addpath(paths{i});
end

clear;clc