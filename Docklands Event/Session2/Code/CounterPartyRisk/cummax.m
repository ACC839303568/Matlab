function b = cummax(a, dim)

if nargin < 2
    dim = 1;
end
if dim == 2
    a = a';
end
b = nan(size(a));
b(1,:) = a(1,:);
for i = 2:size(b,1)
    b(i,:) = max(a(i,:), b(i-1,:));
end

if dim == 2
    b = b;
end