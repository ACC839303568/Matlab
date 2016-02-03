function tf = isInvariant( x )
%isInvariant  Checks whether all values are the same

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

% Ignore NaNs and empty strings
if isnumeric( x )
    x(isnan( x )) = [];
elseif iscellstr( x )
    x(strcmp( x, '' )) = [];
end

% Test for all values being the same
tf = numel( unique( x ) ) == 1;