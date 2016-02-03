fid = fopen('xypoints.dat');
 
if fid == -1
    disp('File open not successful')
else
   % Create x and y vectors for the data points
   % Using fgetl
   
   x = [];
   y = [];
   while feof(fid) == 0
       aline = fgetl(fid);
       aline = aline(2:end);
       [xstr, rest] = strtok(aline,'y');
       x = [x str2double(xstr)];
       ystr = rest(2:end);
       y = [y str2double(ystr)];
   end

   % Plot the points
   plot(x,y,'k*')
   xlabel('x')
   ylabel('y')
   
   % Close the file
   closeresult = fclose(fid);   
   if closeresult == 0
       disp('File close successful')
   else
       disp('File close not successful')
   end
end
