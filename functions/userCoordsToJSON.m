function [] = userCoordsToJSON()
[csvFiles, path] = uigetfile('*.csv', 'Select batch CSV file: ','MultiSelect','on');
init_dir = pwd;
if isequal(csvFiles,0)
    disp('User selected Cancel');
else
    % itinitialize variables
    csvSample   = strings(1, length(csvFiles));
    csvPosition = strings(1, length(csvFiles));
    csvMode     = strings(1, length(csvFiles));
    sample_pos  = strings(1, length(csvFiles));
    
    for i = 1:length(csvFiles)
        tmp = convertCharsToStrings(split(extractBefore(csvFiles(i), "."), "_"));
        csvSample(i) = tmp(1);
        csvPosition(i) = tmp(2); %position of image, not position in reflect/trans
        csvMode(i) = tmp(3);
        if ~(strcmp(csvMode, "bf") | strcmp(csvMode, "df"))
            msg = join(["CSV file", csvFiles(i), "does not specify the mode the micrograph was taken in, or is not [sample]_[position]_[bf/df]_[trans/reflect] file naming format."]);
            error(msg)
        end
        sample_pos(i) = join([csvSample(i), csvPosition(i)], "_");
    end

    msg = join(["Select directory that JSON files for Samples ", csvSample(1), ...
        " through ", csvSample(end), " are located in:"], "");
    dir = uigetdir(pwd, msg);
    cd(dir);
    % ic contains indices such that input = unique_array(ic);
    % ia is a column vector of indices to the first occurrence of repeated elements
    [~, ia, ic] = unique(sample_pos);
    unique_sample_pos = strings(1, length(ia));
    
    for i = 1:length(ia)
        % load JSON file with name sample_pos(ia(i))
        jsonPath = join([sample_pos(ia(i)), ".json"], "");
        jsonPath = fullfile(dir,jsonPath);
        data = loadjson(jsonPath);
        load_idx = (i == ic);
        for j = 1:length(load_idx)
            if load_idx(j) == 1
                csvPath = convertCharsToStrings(fullfile(path,csvFiles(j)));
                csvData = readtable(csvPath);
                % m is the current mode (bf/df)
                m = csvMode(j);
                data.(m).Angle = csvData.Angle;
                data.(m).AngleUnits = "Degrees";
                data.(m).reflect.UserSelectedCoordNoRotationCorrection = [csvData.x1_r; csvData.y1_r];
                data.(m).trans.UserSelectedCoord = [csvData.x1_t; csvData.y1_t];
                % rotation matrix M, to convert reflection coordinates to correct
                % area
                M = [cosd(data.(m).Angle), -sind(data.(m).Angle); sind(data.(m).Angle), cosd(data.(m).Angle)];
                data.(m).reflect.UserSelectedCoord = M * data.(m).reflect.UserSelectedCoordNoRotationCorrection;
                data.(m).reflect.UserSelectedX  = round(data.(m).reflect.UserSelectedCoord(1));
                data.(m).trans.userSelectedX    = round(data.(m).trans.UserSelectedCoord(1));
            end
            clear csvData
        end
        [~] = savejson('', data, char(jsonPath));
        msg = join(["Saved data from CSV in Sample ", sample_pos(ia(i)), " to ", jsonPath], "");
        disp(msg);
        clear data
    end
end
cd(init_dir);
end

