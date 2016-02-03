function outv = mystructsort(structarr)
% mystructsort sorts a vector of structs on the price field
% Format: mystructsort(structure vector)
 
for i = 1:length(structarr)-1
    indlow = i;
    for j=i+1:length(structarr)
        if structarr(j).price < structarr(indlow).price
            indlow = j;
        end
    end
    % Exchange elements
    temp = structarr(i);
    structarr(i) = structarr(indlow);
    structarr(indlow) = temp;
end
outv = structarr;
end
