function outlog = myisletter(inchar)
% myisletter returns true if the input argument 
% is a letter of the alphabet or false if not
% Format of call: myisletter(inputCharacter)
% Returns logical 1 or 0
 
outlog = inchar >= 'a' && inchar <= 'z' ...
        || inchar >= 'A' && inchar <= 'Z';
end
