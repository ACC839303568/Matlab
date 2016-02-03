function outv = mysort(vec)
% mysort sorts a vector using the selection sort
% Format: mysort(vector)
 
% Loop through the elements in the vector to end-1
for i = 1:length(vec)-1
    indlow = i;  % stores the index of the smallest
    % Find where the smallest number is 
    %   in the rest of the vector
    for j=i+1:length(vec)
        if vec(j) < vec(indlow)
            indlow = j;
        end
    end
    % Exchange elements
    temp = vec(i);
    vec(i) = vec(indlow);
    vec(indlow) = temp;
end
outv = vec;
end
