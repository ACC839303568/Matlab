classdef TickEventData < event.EventData
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties
        Symbol % symbol
        Time % time
        Value % value
    end
    
    methods
        
        function obj = TickEventData( symbol, time, value )%
            %cfc.TickEventData  Event data
            %
            %  e = cfc.TickEventData(symbol,time,value)
            
            obj.Symbol = symbol;
            obj.Time = time;
            obj.Value = value;
            
        end % constructor
        
    end % methods
    
end % classdef