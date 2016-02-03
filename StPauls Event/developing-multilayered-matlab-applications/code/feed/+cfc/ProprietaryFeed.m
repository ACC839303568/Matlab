classdef ProprietaryFeed < cfc.Feed
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( Access = private )
        Timer % timer
        Value % value
    end
    
    properties( SetAccess = private, Dependent = true )
        Running % whether the feed is running
    end
    
    methods
        
        function obj = ProprietaryFeed( value )
            %cfc.ProprietaryFeed  Proprietary feed
            %
            %  f = cfc.ProprietaryFeed(v) creates a feed with initial value
            %  v.
            
            % Create timer
            timer = cfc.internal.Timer( 'ExecutionMode', 'fixedRate', ...
                'Period', 1, 'TimerFcn', @obj.onTick );
            
            % Store properties
            obj.Timer = timer;
            obj.Value = value;
            
        end
        
        function value = get.Running( obj )
            
            value = obj.Timer.Running;
            
        end % get.Value
        
        function start( obj )
            
            obj.Timer.start()
            
        end % start
        
        function stop( obj )
            
            obj.Timer.stop()
            
        end % stop
        
        function onTick( obj, ~, ~ )
            %onTick  Event handler
            
            % Compute new value
            value = obj.Value + 0.02 * rand() - 0.01;
            
            %Raise event
            notify( obj, 'Tick', ...
                cfc.TickEventData( 'ACME', now, value ) )
            
            % Update value
            obj.Value = value;
            
        end % onTick
        
    end % methods
    
end % classdef