function outv = generalPackSort(inputarg, fname)
% generalPackSort sorts a vector of structs
% based on the field name passed as an input argument
 
if isfield(inputarg,fname)
   for i = 1:length(inputarg)-1
       indlow = i;
       for j=i+1:length(inputarg)
           if eval(['inputarg(' int2str(j) ').' fname]) < ...
              eval(['inputarg(' int2str(indlow)  ').' fname])
               indlow = j;
           end
       end
       % Exchange elements
       temp = inputarg(i);
       inputarg(i) = inputarg(indlow);
       inputarg(indlow) = temp;
   end
   outv = inputarg;
else
   outv = [];
end
end
