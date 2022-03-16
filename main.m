%% Step 1. Add required directories
run('startup.m')
%% Step 2. Create batch of images to process.
% Optionally, you can create a csv file to save the location of the batch
% of images.
batch = intializeImages();

%% Step 3. 