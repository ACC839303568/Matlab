function outvec = myveccumsum(vec)
% myveccumsum simulates cumsum for a vector
% It preallocates the vector
% Format: myveccumsum(vector)
 
outvec = zeros(size(vec));
runsum = 0;
for i = 1:length(vec)
    runsum = runsum + vec(i);
    outvec(i) = runsum;
end
end
