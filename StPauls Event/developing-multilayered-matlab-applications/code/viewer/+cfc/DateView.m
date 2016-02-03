classdef DateView < handle
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( Dependent )
        Parent % parent
    end
    
    properties( Access = private )
        Model % model
        Container % container
        Popup % popup
        Listeners % listeners
    end
    
    methods
        
        function obj = DateView( model, parent )
            %cfc.DateView  Date view
            %
            %  v = cfc.DateView(m,p) creates the date view of the model m
            %  with the parent p.
            
            % Create graphics
            hContainer = uiextras.HButtonBox( 'Parent', parent );
            hPopup = uicontrol( 'Parent', hContainer, ...
                'Style', 'popupmenu', 'Visible', 'off', ...
                'Callback', @obj.onPopup );
            
            % Create listener
            listeners{1} = event.listener( model, 'DataSourceChanged', ...
                @obj.onDataSourceChanged );
            listeners{2} = event.listener( model, 'DayChanged', ...
                @obj.onDayChanged );
            
            % Store properties
            obj.Model = model;
            obj.Container = hContainer;
            obj.Popup = hPopup;
            obj.Listeners = listeners;
            setappdata( hContainer, 'DateView', obj )
            
            % Set callbacks
            set( hContainer, 'DeleteFcn', @obj.onDeleted )
            
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
        
        function onDataSourceChanged( obj, ~, ~ )
            %onDataSourceChanged  Handler for model data source changed
            
            % Update
            obj.update()
            
        end % onDataChanged
        
        function onDayChanged( obj, ~, ~ )
            %onDayChanged  Handler for model day changed
            
            dateStrings = get( obj.Popup, 'String' );
            value = find( strcmp( dateStrings, ...
                datestr( obj.Model.Day, 'dd mmmm yyyy' ) ) );
            set( obj.Popup, 'Value', value )
            
        end % onDayChanged
        
        function onPopup( obj, ~, ~ )
            %onPopup  Popup callback
            
            % Get start time from control
            hPopup = obj.Popup;
            dateStrings = get( hPopup, 'String' );
            value = get( hPopup, 'Value' );
            date = dateStrings(value);
            
            % Set day
            obj.Model.Day = datenum( date, 'dd mmmm yyyy' );
            
        end % onPopup
        
    end % event handlers
    
    methods( Access = private )
        
        function update( obj )
            %update  Update view
            %
            %  v.update() updates the view during construction or in
            %  response to a change of data source.
            
            model = obj.Model;
            dataSource = model.DataSource;
            if isequal( dataSource, [] )
                % Hide popup
                set( obj.Popup, 'Visible', 'off', 'String', '', 'Value', 1 )
            else
                % Update popup strings based on start and finish times
                startTime = dataSource.getStartTime();
                finishTime = dataSource.getFinishTime();
                dates = transpose( floor( startTime ):floor( finishTime ) );
                dateStrings = arrayfun( @(x)datestr(x,'dd mmmm yyyy'), dates, ...
                    'UniformOutput', false );
                value = find( model.Day == dates );
                set( obj.Popup, 'Visible', 'on', 'String', dateStrings, ...
                    'Value', value )
            end
            
        end % update
        
    end % event handlers
    
end % classdef