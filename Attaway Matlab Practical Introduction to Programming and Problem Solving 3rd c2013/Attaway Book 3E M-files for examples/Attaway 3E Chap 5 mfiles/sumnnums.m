function runsum = sumnnums(n)
% suminputnums returns the sum of the n numbers 
%  entered by the user
% Format of call: suminputnums(n) 

runsum = 0;
for i = 1:n
    inputnum = input('Enter a number: ');
    runsum = runsum + inputnum;
end
end
