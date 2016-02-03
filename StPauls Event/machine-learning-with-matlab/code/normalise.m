function cmNorm = normalise( confusionMatrix )
%normalise  Normalise the confusion matrix

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

cmNorm = bsxfun( @rdivide, confusionMatrix, sum( confusionMatrix, 2 ) );