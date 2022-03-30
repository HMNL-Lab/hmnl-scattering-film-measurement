%% Step 1. Add required directories
run('startup.m')
%% Step 2a. Create batch of images to process.
% Optionally, you can create a csv file to save the location of the batch
% of images.
batch = intializeImages();
%% Step 2b. Load images from batch CSV file.
batch = loadBatch();
%% Step 3a. Canny Method
%% Step 3a.1.
% Assumes that images have been corrected in their rotation so that the
% spray is vertical
% First, load user selected positioning information into JSON files
userCoordsToJSON();
%% Step 3a.2. Batch process files contained in variable 'batch'
% set options used in Canny method

% search width
opts.width = 40;
% threshold
opts.cannyThreshold = [0.01 0.2];
% Gaussian standard deviation of filter
opts.cannyStd = 10;
for i = length(batch)
    % data is saved to same location as selected file
    [~] = cannyThickness(batch(i), opts);
end