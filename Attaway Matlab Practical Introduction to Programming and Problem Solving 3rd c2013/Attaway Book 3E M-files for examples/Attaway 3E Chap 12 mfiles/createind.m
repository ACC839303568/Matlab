function indvec = createind(vec)
% createind returns an index vector for the 
%  input vector in ascending order
% Format: createind(inputVector)

% Initialize the index vector
len = length(vec);
indvec = 1:len;

for i = 1:len-1
    indlow = i;
    for j=i+1:len
        % Compare values in the original vector
        if vec(indvec(j)) < vec(indvec(indlow))
            indlow = j;           
        end
     end
    % Exchange elements in the index vector
    temp = indvec(i);
    indvec(i) = indvec(indlow);
    indvec(indlow) = temp;
end
end
