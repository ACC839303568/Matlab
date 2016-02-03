classdef DataViewerModel < handle
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( Dependent, AbortSet = true )
        DataSource % data source
        Day % day
    end
    
    properties( Dependent, SetAccess = private )
        Times % times
        Values % values
    end
    
    properties( Access = private )
        DataSource_ = [] % backing for DataSource
        Day_ = NaN % backing for Day
        Times_ = zeros( [0 1] ) % backing for Times
        Values_ = zeros( [0 1] ) % backing for Values
    end
    
    events( NotifyAccess = private )
        DataSourceChanged % data source changed
        DayChanged % day changed
    end
    
    methods
        
        function value = get.DataSource( obj )
            
            value = obj.DataSource_;
            
        end % get.DataSource
        
        function set.DataSource( obj, value )
            
            % Check
            assert( isequal( value, [] ) || ...
                ( isa( value, 'cfc.DataSource' ) && isscalar( value ) ), ...
                'cfc:InvalidArgument', ...
                'Property ''DataSource'' must be of type ''cfc.DataSource'' or [].' )
            
            % Set
            if isequal( value, [] )
                obj.DataSource_ = value;
                obj.Day_ = NaN;
                obj.Times_ = zeros( [0 1] );
                obj.Values_ = zeros( [0 1] );
            else
                startTime = floor( value.getFinishTime() );
                finishTime = startTime + 1;
                [times, values] = value.getData( startTime, finishTime );
                obj.DataSource_ = value;
                obj.Day_ = startTime;
                obj.Times_ = times;
                obj.Values_ = values;
            end
            notify( obj, 'DataSourceChanged' )
            
        end % set.DataSource
        
        function value = get.Day( obj )
            
            value = obj.Day_;
            
        end % get.Day
        
        function set.Day( obj, value )
            
            dataSource = obj.DataSource_;
            if isequal( dataSource, [] )
                % Check
                assert( isequaln( value, NaN ), 'cfc:InvalidArgument', ...
                    'Property ''Day'' must be NaN if property ''DataSource'' is unset.' )
                % Data is empty
                times = zeros( [0 1] );
                values = zeros( [0 1] );
            else
                % Check
                assert( isnumeric( value ) && isscalar( value ) && ...
                    rem( value, 1 ) == 0, 'cfc:InvalidArgument', ...
                    'Property ''Day'' must be an integer date number.' )
                % Get data
                [times, values] = dataSource.getData( value, value + 1 );
            end
            % Update state
            obj.Day_ = value;
            obj.Times_ = times;
            obj.Values_ = values;
            % Raise event
            notify( obj, 'DayChanged' )
            
        end % set.Day
        
        function value = get.Times( obj )
            
            value = obj.Times_;
            
        end % get.Times
        
        function value = get.Values( obj )
            
            value = obj.Values_;
            
        end % get.Times
        
    end % accessors
    
end % classdef