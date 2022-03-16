%% Step 1. Add required directories
run('startup.m')
%% Step 2a. Create batch of images to process.
% Optionally, you can create a csv file to save the location of the batch
% of images.
batch = intializeImages();
%% Step 2b. Load images from batch CSV file.

%% Step 3a. Canny Method
% Assumes that images have been corrected in their rotation so that the
% spray is vertical