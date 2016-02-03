classdef DataSource < handle
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    methods( Abstract = true )
        [times, values] = getData( obj, startTime, finishTime )
        time = getStartTime( obj )
        time = getFinishTime( obj )
    end
    
end