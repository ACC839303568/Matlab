function varargout = converttempii(degreesC)
% converttempii converts temperature in degrees C
% to degrees F and maybe also K
% Format: converttempii(C temperature)

varargout{1} = 9/5*degreesC + 32;
n = nargout;
if n == 2
    varargout{2} = degreesC + 273.15;
end
end
