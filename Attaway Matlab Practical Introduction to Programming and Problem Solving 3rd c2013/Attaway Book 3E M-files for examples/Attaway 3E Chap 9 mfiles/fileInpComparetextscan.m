fid = fopen('xypoints.dat');
 
if fid == -1
    disp('File open not successful')
else
   % Using textscan
   
   xydat = textscan(fid, 'x%fy%f');
   x = xydat{1};
   y = xydat{2};

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
