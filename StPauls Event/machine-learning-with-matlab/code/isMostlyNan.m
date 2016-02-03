function tf = isMostlyNan( x, threshold )
%isMostlyNan

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

if isnumeric( x )
    tf = sum( isnan( x ) ) / numel( x ) > threshold;
else
    tf = false;
end