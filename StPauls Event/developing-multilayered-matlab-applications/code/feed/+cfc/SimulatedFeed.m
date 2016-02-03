classdef SimulatedFeed < cfc.Feed
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( Dependent = true )
        Period % timer period
        Rate % rate relative to real time
        Time % current time
    end
    
    properties( SetAccess = private, Dependent = true )
        Running % whether the feed is running
    end
    
    properties( Access = private )
        Timer % timer
        Times % times
        Values % values
        Time_ % backing for Time
        Rate_ = 1 % backing for Rate
    end
    
    methods
        
        function obj = SimulatedFeed( times, values )
            %cfc.SimulatedFeed  Simulated data feed
            %
            %  f = cfc.Simulated Feed(t,v) creates a simulated feed for the
            %  times t and the values v.
            
            % Create timer
            timer = cfc.internal.Timer( 'ExecutionMode', 'fixedRate', ...
                'Period', 1, 'TimerFcn', @obj.onTick );
            
            % Store properties
            obj.Timer = timer;
            obj.Times = times;
            obj.Values = values;
            obj.Time_ = times(1);
            
        end % constructor
        
    end % stuctors
    
    methods
        
        function value = get.Running( obj )
            
            value = obj.Timer.Running;
            
        end % get.Value
        
        function value = get.Period( obj )
            
            value = obj.Timer.Period;
            
        end % get.Period
        
        function set.Period( obj, value )
            
            obj.Timer.Period = value;
            
        end % set.Period
        
        function value = get.Rate( obj )
            
            value = obj.Rate_;
            
        end % get.Rate
        
        function set.Rate( obj, value )
            
            % Check
            assert( isnumeric( value ) && isscalar( value ) && ...
                value > 0, 'cfc:InvalidArgument', ...
                'Property ''Rate'' must be a positive scalar.' )
            
            % Set
            obj.Rate_ = value;
            
        end % set.Rate
        
        function value = get.Time( obj )
            
            value = obj.Time_;
            
        end % get.Time
        
        function set.Time( obj, value )
            
            % Check
            assert( isnumeric( value ) && isscalar( value ), ...
                'Property ''Time'' must be a numeric scalar.' )
            
            % Set
            obj.Time_ = value;
            
        end % set.Time
        
    end % accessors
    
    methods
        
        function start( obj )
            %start  Start the feed
            %
            %  f.start()
            
            obj.Timer.start()
            
        end % start
        
        function stop( obj )
            %stop  Stop the feed
            %
            %  f.stop()
            
            obj.Timer.stop()
            
        end % stop
        
    end % operations
    
    methods( Access = private )
        
        function onTick( obj, ~, ~ )
            %onTick  Event handler for timer tick
            
            % Compute new time from old time, period and rate
            oldTime = obj.Time_;
            period = obj.Timer.Period;
            newTime = oldTime + period/24/60/60 * obj.Rate_;
            
            % Find values between old time and new time and raise events
            times = obj.Times;
            values = obj.Values;
            index = find( times >= oldTime & times < newTime );
            for ii = 1:numel( index )
                notify( obj, 'Tick', ...
                    cfc.TickEventData( 'ACME', newTime, values(index(ii)) ) )
            end
            
            % Update time
            obj.Time_ = newTime;
            
        end % onTick
        
    end % event handlers
    
end % classdef