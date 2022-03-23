function [data] = loadImageIntoDataStruct(jsonFilePath)
data = loadjson(jsonFilePath);
% field names in struct data
data_fnames = convertCharsToStrings(fieldnames(data));
% fields that are bright/dark field microscope modes ie "bf" or "df"
modes_idx = "bf" == data_fnames | "df" == data_fnames;
% throw error if no fields are "bf" or "df"
if modes_idx == zeros(length(modes_idx), 1)
    msg = join(["Struct in file", file, "does not have 'bf' or 'df' has header fields. Please check JSON files."], " ");
    error(msg);
end
% loop over field names, and then read image into data struct
for i = 1:length(modes_idx)
    if modes_idx(i)
        subfields = convertCharsToStrings(fieldnames(data.(data_fnames(i))));
        for j = 1:length(subfields)
            if strcmp(subfields(j), "reflect") | strcmp(subfields(j), "trans")
                data.(data_fnames(i)).(subfields(j)).Image = imread(data.(data_fnames(i)).(subfields(j)).Filename);
            end
        end
    end
end
end

