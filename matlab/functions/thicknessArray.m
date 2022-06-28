function [thickness] = thicknessArray(cannyImage)
[rows,cols] = size(cannyImage);
idx = 1;
thickidx = 1;
edgePt = [];
for i = 1:rows
    for j = 1:cols
        if cannyImage(i,j) == 1
            edgePt(idx) = j;
            idx = idx + 1;
        end
    end
    idx = 1;
    if size(edgePt, 1) ~= 0
        thickness(thickidx) = max(edgePt) - min(edgePt);
    end
    thickidx = thickidx + 1;
    edgePt = [];
end
thickness = thickness(thickness ~= 0); % remove single thicknesses from thickness array
end