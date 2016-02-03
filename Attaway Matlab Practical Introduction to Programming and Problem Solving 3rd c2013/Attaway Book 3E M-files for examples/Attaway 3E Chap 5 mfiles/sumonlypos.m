% Sums only positive numbers from file
% Reads from the file into a matrix and then
%   calculates and prints the sum of only the
%   positive numbers from each row

load datavals.dat
[r, c] = size(datavals);

for row = 1:r
    runsum = 0;
    for col = 1:c
        if datavals(row,col) >= 0
            runsum = runsum + datavals(row,col);
        end
    end
    fprintf('The sum for row %d is %d\n',row,runsum)
end
