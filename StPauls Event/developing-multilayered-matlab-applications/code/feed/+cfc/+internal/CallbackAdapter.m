classdef CallbackAdapter < handle
    %cfc.internal.CallbackAdapter  Callback adapter
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: $  $Date: $
    
    events
        CallbackFired
    end % events
    
    methods( Access = public )
        
        function obj = CallbackAdapter( o, cb )
            %cfc.internal.CallbackAdapter  Callback adapter
            %
            %  cba = cfc.internal.CallbackAdapter(o,cb) creates an adapter
            %  to the callback cb of the object o, such that when that
            %  callback is fired, an event CallbackFired is raised on cba.
            
            o.( cb ) = @obj.onCallbackFired;
            
        end % constructor
        
    end % structors
    
    methods( Access = protected )
        
        function onCallbackFired( obj, ~, ~ )
            
            % Raise event
            notify( obj, 'CallbackFired' );
            
        end % onCallbackFired
        
    end % event handlers
    
end % classdef