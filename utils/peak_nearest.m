function [I,value] = peak_nearest(array, target, threshold)
    if isempty(array) || isnan(target)
        value = -1;
        I = -1;
        return
    end
    [va,I] = min(abs(array-target));
    value = array(I);
    if nargin == 3 && ~isempty(threshold) && va > threshold
        value = -1;
        I = -1;
    end
end