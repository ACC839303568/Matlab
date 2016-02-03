classdef TimeSeriesView < handle
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( Dependent )
        Parent % parent
    end
    
    properties( Access = private )
        Model % application model
        Container % container
        Axes % axes
        Listeners % listeners
    end
    
    methods
        
        function obj = TimeSeriesView( model, parent )
            %cfc.TimeSeriesView  Time series view
            %
            %  v = cfc.TimeSeriesView(m,p) creates the time series view of
            %  the model m with the parent p.
            
            % Create graphics
            hContainer = uicontainer( 'Parent', parent );
            hAxes = axes( 'Parent', hContainer, 'XGrid', 'on', 'YGrid', 'on' );
            
            % Create listener
            listeners{1} = event.listener( model, 'DataSourceChanged', ...
                @obj.onDataChanged );
            listeners{2} = event.listener( model, 'DayChanged', ...
                @obj.onDayChanged );
            
            % Store properties
            obj.Model = model;
            obj.Container = hContainer;
            obj.Axes = hAxes;
            obj.Listeners = listeners;
            setappdata( hContainer, 'TimeSeriesView', obj )
            
            % Set callbacks
            set( hContainer, 'DeleteFcn', @obj.onDeleted, ...
                'ResizeFcn', @obj.onResized )
            
            % Update
            obj.update()
            
        end % constructor
        
        function delete( obj )
            %delete  Destructor
            %
            %  v.delete()
            
            hContainer = obj.Container;
            if ishghandle( hContainer ) && ...
                    strcmp( get( hContainer, 'BeingDeleted' ), 'off' )
                delete( hContainer )
            end
            
        end % destructor
        
    end % structors
    
    methods
        
        function value = get.Parent( obj )
            
            value = get( obj.Container, 'Parent' );
            
        end % get.Parent
        
        function set.Parent( obj, value )
            
            set( obj.Container, 'Parent', value )
            
        end % set.Parent
        
    end % accessors
    
    methods
        
        function onDeleted( obj, ~, ~ )
            
            % Call destructor
            obj.delete()
            
        end % onDeleted
        
        function onResized( obj, ~, ~ )
            
            datetick( obj.Axes, 'x', 'keeplimits' )
            
        end % onResized
        
        function onDataChanged( obj, ~, ~ )
            
            % Update
            obj.update()
            
        end % onDataChanged
        
        function onDayChanged( obj, ~, ~ )
            
            % Update
            obj.update()
            
        end % onDayChanged
        
    end % event handlers
    
    methods( Access = private )
        
        function update( obj )
            %update  Update view
            %
            %  v.update() updates the view during construction or in
            %  response to a change of data source or day.
            
            % Retrieve and plot data
            model = obj.Model;
            hAxes = obj.Axes;
            times = model.Times;
            values = model.Values;
            plot( hAxes, times, values )
            
            % Update axes based on whether or not there is data
            if isempty( times )
                set( hAxes, 'Visible', 'off', 'XLim', [0 1] )
            else
                set( hAxes, 'Visible', 'on', 'XLim', model.Day + [0 1], ...
                    'XGrid', 'on', 'YGrid', 'on' )
                xlabel( hAxes, 'Time' );
                ylabel( hAxes, 'Value' );
            end
            datetick( hAxes, 'x', 'keeplimits' )
            
        end % update
        
    end % helpers
    
end % classdef