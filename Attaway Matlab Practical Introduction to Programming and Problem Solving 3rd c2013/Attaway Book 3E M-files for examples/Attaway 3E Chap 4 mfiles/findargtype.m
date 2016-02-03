function outtype = findargtype(inputarg)
% findargtype determines whether the input
%    argument is a scalar, vector, or matrix
% Format of call: findargtype(inputArgument)
% Returns a string
 
[r c] = size(inputarg);
if r == 1 && c == 1
    outtype = 'scalar';
elseif r == 1 || c == 1
    outtype = 'vector';
else
    outtype = 'matrix';
end
end
