% Prompt the user for a number and print its sqrt
 
num = input('Please enter a number: ');
 
% If the user entered a negative number, change it
if num < 0
    num = 0;
end
fprintf('The  sqrt of %.1f is %.1f\n',num,sqrt(num))
