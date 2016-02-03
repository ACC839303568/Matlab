function logresult = xxx(vec)
% QQ for you - what does this do?
 
logresult = false;
i = 1;
while i <= length(vec) && logresult == false
    if vec(i) ~= 0
        logresult = true;
    end
    i = i + 1;
end
end

