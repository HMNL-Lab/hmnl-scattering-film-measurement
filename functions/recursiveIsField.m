function isFieldResult = recursiveIsField (inStruct, fieldName)
% from https://www.mathworks.com/matlabcentral/answers/95923-is-there-a-matlab-function-that-can-check-if-a-field-exists-in-a-matlab-structure
% inStruct is the name of the structure or an array of structures to search
% fieldName is the name of the field for which the function searches
isFieldResult = 0;
f = fieldnames(inStruct(1));
for i=1:length(f)
    if(strcmp(f{i},strtrim(fieldName)))
        isFieldResult = 1;
        return;
    elseif isstruct(inStruct(1).(f{i}))
        isFieldResult = recursiveIsField(inStruct(1).(f{i}), fieldName);
        if isFieldResult
            return;
        end
    end
end