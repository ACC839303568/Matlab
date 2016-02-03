classdef Timer < handle
    %cfc.Timer  Timer object
    %
    %   Timer is a wrapper for the class in toolbox/matlab/iofun.
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: $  $Date: $
    
    properties( Access = protected )
        MWTimer
        Listeners = cell( 0, 1 )
    end % private properties
    
    properties( Dependent, GetAccess = public, SetAccess = private )
        AveragePeriod
    end % dependent read-only properties
    
    properties( Dependent, GetAccess = public, SetAccess = public )
        BusyMode % [drop|error|queue]
        ExecutionMode % [singleShot|fixedDelay|fixedRate|fixedSpacing]
    end % dependent properties
    
    properties( Dependent, GetAccess = public, SetAccess = private )
        InstantPeriod
    end % dependent read-only properties
    
    properties( Dependent, GetAccess = public, SetAccess = public )
        Period
    end % dependent properties
    
    properties( Dependent, GetAccess = public, SetAccess = private )
        Running % [on|off]
    end % dependent read-only properties
    
    properties( Dependent, GetAccess = public, SetAccess = public )
        StartDelay
        Tag
    end % dependent properties
    
    properties( Dependent, GetAccess = public, SetAccess = private )
        TasksExecuted
    end % dependent read-only properties
    
    properties( Dependent, GetAccess = public, SetAccess = public )
        TasksToExecute
    end % dependent properties
    
    properties
        UserData
        TimerFcn
        ErrorFcn
        StartFcn
        StopFcn
    end % public properties
    
    methods
        
        function obj = Timer( varargin )
            %cfc.Timer  Timer object
            %
            %   t = cfc.Timer(p1,v1,p2,v2,...) creates a timer with
            %   property p1 set to value v1, etc.
            
            % Create underlying timer
            obj.MWTimer = timer( 'ObjectVisibility', 'off' );
            
            % Set up listeners
            obj.Listeners{end+1,1} = event.listener( ...
                cfc.internal.CallbackAdapter( obj.MWTimer, 'TimerFcn' ), ...
                'CallbackFired', @obj.onTick );
            obj.Listeners{end+1,1} = event.listener( ...
                cfc.internal.CallbackAdapter( obj.MWTimer, 'ErrorFcn' ), ...
                'CallbackFired', @obj.onError );
            obj.Listeners{end+1,1} = event.listener( ...
                cfc.internal.CallbackAdapter( obj.MWTimer, 'StartFcn' ), ...
                'CallbackFired', @obj.onStart );
            obj.Listeners{end+1,1} = event.listener( ...
                cfc.internal.CallbackAdapter( obj.MWTimer, 'StopFcn' ), ...
                'CallbackFired', @obj.onStop );
            
            % Handle inputs
            if rem( nargin, 2 ) ~= 0
                error( 'demo:InvalidArgument', ...
                    'Inputs arguments must be parameter value pairs.' )
            end
            p = varargin(1:2:end);
            v = varargin(2:2:end);
            if numel( p ) ~= numel( v )
                error( 'demo:InvalidArgument', ...
                    'Number of parameters must equal number of values.' )
            elseif ~iscellstr( p )
                error( 'demo:InvalidArgument', ...
                    'Parameters must be strings.' )
            elseif numel( p ) ~= numel( unique( p ) )
                error( 'demo:InvalidArgument', ...
                    'Parameters must be unique.' )
            end
            for ii = 1:numel( p )
                % Check
                mp = findprop( obj, p{ii} );
                assert( ~isempty( mp ) && strcmp( mp.SetAccess, 'public' ), ...
                    'demo:InvalidArgument', ...
                    'No public field ''%s'' exists for class ''%s''.', ...
                    p{ii}, class( obj ) )
                % Set
                obj.( p{ii} ) = v{ii};
            end
            
        end % constructor
        
        function delete( obj )
            
            % Explicitly delete underlying timer
            delete( obj.MWTimer )
            
        end % destructor
        
    end
    
    methods
        
        function value = get.AveragePeriod( obj )
            
            value = obj.MWTimer.AveragePeriod;
            
        end % get.AveragePeriod
        
        function value = get.BusyMode( obj )
            
            value = obj.MWTimer.BusyMode;
            
        end % get.BusyMode
        
        function set.BusyMode( obj, value )
            
            obj.MWTimer.BusyMode = value;
            
        end % set.BusyMode
        
        function value = get.ExecutionMode( obj )
            
            value = obj.MWTimer.ExecutionMode;
            
        end % get.ExecutionMode
        
        function set.ExecutionMode( obj, value )
            
            obj.MWTimer.ExecutionMode = value;
            
        end % set.ExecutionMode
        
        function value = get.InstantPeriod( obj )
            
            value = obj.MWTimer.InstantPeriod;
            
        end % get.InstantPeriod
        
        function value = get.Period( obj )
            
            value = obj.MWTimer.Period;
            
        end % get.Period
        
        function set.Period( obj, value )
            
            obj.MWTimer.Period = value;
            
        end % set.Period
        
        function value = get.Running( obj )
            
            value = obj.MWTimer.Running;
            
        end % get.Running
        
        function value = get.StartDelay( obj )
            
            value = obj.MWTimer.StartDelay;
            
        end % get.StartDelay
        
        function set.StartDelay( obj, value )
            
            obj.MWTimer.StartDelay = value;
            
        end % set.StartDelay
        
        function value = get.Tag( obj )
            
            value = obj.MWTimer.Tag;
            
        end % get.Tag
        
        function set.Tag( obj, value )
            
            obj.MWTimer.Tag = value;
            
        end % set.Tag
        
        function value = get.TasksExecuted( obj )
            
            value = obj.MWTimer.TasksExecuted;
            
        end % get.TasksExecuted
        
        function value = get.TasksToExecute( obj )
            
            value = obj.MWTimer.TasksToExecute;
            
        end % get.TasksToExecute
        
        function set.TasksToExecute( obj, value )
            
            obj.MWTimer.TasksToExecute = value;
            
        end % set.TasksToExecute
        
        function set.TimerFcn( obj, value )
            
            % Check
            assert( obj.isCallback( value ), 'demo:InvalidArgument', ...
                'Callback ''TimerFcn'' must be a function handle, string, or [].' )
            
            % Set
            obj.TimerFcn = value;
            
        end % set.TimerFcn
        
        function set.ErrorFcn( obj, value )
            
            % Check
            assert( obj.isCallback( value ), 'demo:InvalidArgument', ...
                'Callback ''ErrorFcn'' must be a function handle, string, or [].' )
            
            % Set
            obj.ErrorFcn = value;
            
        end % set.ErrorFcn
        
        function set.StartFcn( obj, value )
            
            % Check
            assert( obj.isCallback( value ), 'demo:InvalidArgument', ...
                'Callback ''StartFcn'' must be a function handle, string, or [].' )
            
            % Set
            obj.StartFcn = value;
            
        end % set.StartFcn
        
        function set.StopFcn( obj, value )
            
            % Check
            assert( obj.isCallback( value ), 'demo:InvalidArgument', ...
                'Callback ''StopFcn'' must be a function handle, string, or [].' )
            
            % Set
            obj.StopFcn = value;
            
        end % set.StopFcn
        
    end % accessors
    
    methods
        
        function start( obj )
            
            start( obj.MWTimer )
            
        end % start
        
        function startAt( obj, varargin )
            
            startAt( obj, varargin{:} )
            
        end % startAt
        
        function stop( obj )
            
            stop( obj.MWTimer )
            
        end % stop
        
        function wait( obj )
            
            wait( obj.MWTimer )
            
        end
        
    end % operations
    
    methods( Access = private )
        
        function onTick( obj, varargin )
            
            % Call callback
            obj.feval( obj.TimerFcn )
            
        end % onTick
        
        function onError( obj, varargin )
            
            % Call callback
            obj.feval( obj.ErrorFcn )
            
        end % onTick
        
        function onStart( obj, varargin )
            
            % Call callback
            obj.feval( obj.StartFcn )
            
        end % onTick
        
        function onStop( obj, varargin )
            
            % Call callback
            obj.feval( obj.StopFcn )
            
        end % onTick
        
    end % event handlers
    
    methods( Static, Access = protected )
        
        function tf = isCallback( cb )
            %isCallback  Test for valid callback
            %
            %  tf = cfc.internal.Timer.isCallback(cb) returns true if cb is
            %  a valid callback, and false otherwise.  Valid callbacks are
            %  function handles, strings, and [].
            
            if isequal( cb, [] )
                tf = true;
            elseif ischar( cb )
                tf = true;
            elseif isa( cb, 'function_handle' ) && isequal( size( cb ), [1 1] )
                tf = true;
            else
                tf = false;
            end
            
        end % isCallback
        
        function feval( cb )
            %feval  Call callback
            %
            %  cfc.internal.Timer.feval(cb) calls the callback cb.
            
            if isequal( cb, [] )
                % do nothing
            elseif ischar( cb )
                eval( cb )
            elseif isa( cb, 'function_handle' ) && isequal( size( cb ), [1 1] )
                feval( cb )
            else
                error( 'demo:InvalidArgument', 'Invalid callback.' )
            end
            
        end % feval
        
    end % private static methods
    
end % classdef