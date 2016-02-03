function logresult = yyy(mat)
% QQ for you - what does this do?
 
count = 0;
[r, c] = size(mat);
for i = 1:r
    for j = 1:c
        if mat(i,j) ~= 0
            count = count + 1;
        end
    end
end
 
logresult = count == numel(mat);
end
