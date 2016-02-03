classdef Feed < handle
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( Abstract = true, SetAccess = private )
        Running
    end
    
    events( NotifyAccess = protected )
        Tick
    end
    
    methods( Abstract = true )
        start( obj )
        stop( obj )
    end
    
end