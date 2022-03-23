function [data, isImageExist] = loadImageIntoDataStruct(jsonFilePath)
data = loadjson(jsonFilePath);
% field names in struct data
data_fnames = convertCharsToStrings(fieldnames(data));
% fields that are bright/dark field microscope modes ie "bf" or "df"
modes_idx = "bf" == data_fnames | "df" == data_fnames;
% throw error if no fields are "bf" or "df"
if modes_idx == zeros(length(modes_idx), 1)
    msg = join(["Struct in file", jsonFilePath, "does not have 'bf' or 'df' has header fields. Please check JSON files."], " ");
    error(msg);
end
% loop over field names, and then read image into data struct
for i = 1:length(modes_idx)
    if modes_idx(i)
        subfields = convertCharsToStrings(fieldnames(data.(data_fnames(i))));
        subfields_idx = "reflect" == subfields | "trans" == subfields;
        if subfields_idx == zeros(length(subfields_idx), 1)
            msg = join(["Sub-struct in mode", data_fnames(i), "in file", jsonFilePath, "does not contain fields 'reflect' or 'trans'. Please check JSON files."], " ");
            error(msg);
        end
        for j = 1:length(subfields)
            if subfields_idx(j)
                data.(data_fnames(i)).(subfields(j)).Image = imread(data.(data_fnames(i)).(subfields(j)).Filename);
                isImageExist.(data_fnames(i)).(subfields(j)) = true;
            end
        end
    end
end
end

