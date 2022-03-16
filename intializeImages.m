function batch = intializeImages()
% Files should be of the following format:
% [sampleID]_[positionID]_[bf/df]_[reflect/trans]-[extra-info-here]-.tif
init_dir = pwd;
[files, path] = uigetfile('*.tif;*.tiff;*.png', 'Select image files: ','MultiSelect','on');
dir = uigetdir(pwd, 'Select directory JSON files to');
cd(dir);

if isequal(files,0)
    disp('User selected Cancel');
else
    sample  = strings(1, length(files));
    pos     = strings(1, length(files));
    field   = strings(1, length(files));
    mode    = strings(1, length(files));
    sample_pos    = strings(1, length(files));
    %    disp(['User selected ', fullfile(path,file)]);
    for i = length(files):-1:1 %struct size is created on first instance
        %         path to load image from
        load_name = fullfile(path,files(i));
        % get file name of image to extract sample, position, etc info from
        % convert to string
        filename = string(files(i));
        % remove file extension
        filename = extractBefore(filename, ".");
        % split along underscore delimiters
        filename    = split(filename, "_");
        sample(i)   = filename(1);
        pos(i)      = filename(2);
        field(i)    = filename(3);
        mode(i)     = filename(4);
        
        % load image information
        info(i) = imfinfo(string(load_name));
        msg = join(['Loaded metadata for', files(i)]);
        disp(msg{1});
        sample_pos(i) = join([sample(i), pos(i)], "_");
    end
    
    %     combine files
    [~, ia, ic] = unique(sample_pos);
    saveTo_fullpath = strings(1, length(ia));
    for i = 1:length(ia)
        load_idx = (i == ic);
        for j = 1:length(load_idx)
            if load_idx(j) == 1
                data.(field(j)).(mode(j)) = info(j);
            end
        end
        data.Sample     = sample(ia(i));
        data.Position   = pos(ia(i));
        saveTo_file     = join([sample(ia(i)), pos(ia(i)), "json"], ["_", "."]);
        saveTo_fullpath(i) = fullfile(dir, saveTo_file);
        if isfile(saveTo_fullpath(i))
            msg = join(saveTo_file, "already exists.");
            warning(char(msg))
            str = input('[Y/N] to overwrite: ', 's');
            if str == 'Y'
                [~] = savejson('',data, char(saveTo_fullpath(i)));
                msg = join([saveTo_file, "successfully saved!"]);
                disp(msg);
            else
                disp('Operation cancelled.');
            end
        else
            [~] = savejson('',data, char(saveTo_fullpath(i)));
            msg = join([saveTo_file, "successfully saved!"]);
            disp(msg);
        end
        clear data
    end
end
batch = saveTo_fullpath;

saveToCSV = input('Save this batch to CSV file? [Y/N] ', 's');
if saveToCSV == 'Y'
    csv_exportFile = input('Enter output file name: ', 's');
    csv_dir = uigetdir(init_dir, 'Select directory to save to');
    csv_saveTo = fullfile(csv_dir, join([csv_exportFile, '.csv']));
    if isfile(csv_saveTo)
        warning('Batch file of the same name already exists.')
        str = input('[Y/N] to overwrite: ', 's');
        if str == 'Y'
            writetable(T, csv_saveTo, 'WriteRowNames', true);
            disp('Batch successfully saved!');
        else
            disp('Operation cancelled.');
        end
    else
        writetable(T, csv_saveTo, 'WriteRowNames', true);
        disp('Data successfully saved!');
    end
end
cd(init_dir);
end