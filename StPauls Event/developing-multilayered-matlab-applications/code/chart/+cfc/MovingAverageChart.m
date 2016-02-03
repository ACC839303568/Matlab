classdef MovingAverageChart < hgsetget
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( Dependent )
        Parent % parent
        Units % units
        Position % position
        XData % times
        YData % values
        Window % window length for moving average
    end
    
    properties( Access = private )
        Window_ = 0 % backing for Window
        Filter % filter for computing moving average
        Container = -1 % container
        Axes = -1 % axes
        MainLine = -1 % line for original data
        AverageLine = -1 % line for moving average
    end
    
    methods
        
        function obj = MovingAverageChart( varargin )
            %cfc.MovingAverageChart  Moving average chart
            %
            %  c = cfc.MovingAverageChart() creates a new moving average
            %  chart.
            %
            %  c = cfc.MovingAverageChart(p1,v1,p2,v2,...) sets property p1
            %  to value v1, etc.
            
            % Process inputs
            p = varargin(1:2:end);
            v = varargin(2:2:end);
            iParent = find( strcmp( p, 'Parent' ) );
            if isempty( iParent )
                hParent = gcf;
            else
                hParent = v{iParent};
                p(iParent) = [];
                v(iParent) = [];
            end
            
            % Create graphics
            hContainer = uicontainer( 'Parent', hParent );
            hAxes = axes( 'Parent', hContainer, ...
                'XGrid', 'on', 'YGrid', 'on' );
            xlabel( hAxes, 'Time' );
            ylabel( hAxes, 'Value' );
            hMainLine = line( 'Parent', hAxes, 'XData', zeros( [1 0] ), ...
                'YData', zeros( [1 0] ), 'Color', [0 0 1], 'LineStyle', '-' );
            hAverageLine = line( 'Parent', hAxes, 'XData', zeros( [1 0] ), ...
                'YData', zeros( [1 0] ), 'Color', [1 0 0], 'LineStyle', '--' );
            
            % Store properties
            obj.Container = hContainer;
            obj.Axes = hAxes;
            obj.MainLine = hMainLine;
            obj.AverageLine = hAverageLine;
            setappdata( hContainer, 'MovingAverageChart', obj )
            
            % Set callbacks
            set( hContainer, 'DeleteFcn', @obj.onDeleted, ...
                'ResizeFcn', @obj.onResized )
            
            % Update
            obj.update()
            
            % Set further properties
            if numel( p ) > 0
                pv = transpose( [p(:) v(:)] );
                set( obj, pv{:} );
            end
            
        end % constructor
        
        function delete( obj )
            %delete  Destructor
            
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
        
        function value = get.Units( obj )
            
            value = get( obj.Container, 'Units' );
            
        end % get.Units
        
        function set.Units( obj, value )
            
            set( obj.Container, 'Units', value )
            
        end % set.Units
        
        function value = get.Position( obj )
            
            value = get( obj.Container, 'Position' );
            
        end % get.Position
        
        function set.Position( obj, value )
            
            set( obj.Container, 'Position', value )
            
        end % set.Position
        
        function value = get.XData( obj )
            
            value = get( obj.MainLine, 'XData' );
            
        end % get.XData
        
        function set.XData( obj, value )
            
            % Set raw line
            set( obj.MainLine, 'XData', value )
            
            % Update
            obj.update()
            
        end % set.XData
        
        function value = get.YData( obj )
            
            value = get( obj.MainLine, 'YData' );
            
        end % get.YData
        
        function set.YData( obj, value )
            
            % Set raw line
            set( obj.MainLine, 'YData', value )
            
            % Update
            obj.update()
            
        end % set.YData
        
        function value = get.Window( obj )
            
            value = obj.Window_;
            
        end % get.Window
        
        function set.Window( obj, value )
            
            % Check
            assert( isnumeric( value ) && isscalar( value ) && ...
                value >= 0 && rem( value, 1 ) == 0, ...
                'cfc:InvalidArgument', ...
                'Property ''Window'' must be a positive integer.' )
            
            % Set
            if value == 0
                filter = [];
            else
                filter = ones( [1 value] ) / value;
            end
            obj.Window_ = value;
            obj.Filter = filter;
            
            % Update
            obj.update()
            
        end % set.Window
        
    end % accessors
    
    methods( Access = private )
        
        function onDeleted( obj, ~, ~ )
            
            % Call destructor
            obj.delete()
            
        end % onDeleted
        
        function onResized( obj, ~, ~ )
            
            datetick( obj.Axes, 'x', 'keeplimits' )
            
        end % onResized
        
    end % event handlers
    
    methods( Access = private )
        
        function update( obj )
            %update  Update chart after data or filter change
            %
            %  c.update() updates the chart in response to a change of data
            %  or window length by computing and plotting the moving
            %  average.
            
            % Get main data
            xData = get( obj.MainLine, 'XData' );
            yData = get( obj.MainLine, 'YData' );
            
            % Compute average data
            if obj.Window == 0
                sData = NaN( size( yData ) );
            else
                sData = filter( obj.Filter, 1, yData );
                sData(1:obj.Window_-1) = NaN;
            end
            
            % Update graphics
            set( obj.AverageLine, 'XData', xData, 'YData', sData )
            id = 'MATLAB:hg:line:XDataAndYDataLengthsMustBeEqual';
            ws = warning( 'query', id ); % capture warning state
            warning( 'off', id ) % disable warning
            datetick( obj.Axes, 'x', 'keeplimits' )
            warning( ws.state, id ) % restore warning state
            
        end % update
        
    end % helpers
    
end % classdef