classdef DatabaseDataSource < cfc.DataSource
    
    %  Copyright 2014 The MathWorks, Inc.
    %  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $
    
    properties( SetAccess = private )
        Connection % database connection
    end
    
    methods
        
        function obj = DatabaseDataSource( connectionString )
            %cfc.DatabaseDataSource  Data source backed by SQLite database
            %
            %  s = cfc.CSVDataSource(c) creates a data source backed by an
            %  SQLite database using a connection string c.
            
            % Make .NET assembly is visible to MATLAB
            dll = fullfile( fileparts( fileparts( mfilename( 'fullpath' ) ) ), ...
                'bin', 'System.Data.SQLite.dll' );
            NET.addAssembly( dll );
            
            % Create connection
            connection = System.Data.SQLite.SQLiteConnection( connectionString );
            
            % Open connection
            connection.Open()
            
            % Store properties
            obj.Connection = connection;
            
        end % constructor
        
        function delete( obj )
            %delete  Destructor
            %
            %  obj.delete()
            
            % Close connection
            connection = obj.Connection;
            if isvalid( connection )
                connection.Close()
            end
            
        end % destructor
        
        function [times, values] = getData( obj, startTime, finishTime )
            %getData  Get data
            %
            %  [t,v] = s.getData(ts,tf) gets times t and values v from the
            %  data source s from time ts to time tf.
            
            times = zeros( [0 1] ); % initialize
            values = zeros( [0 1] ); % initialize
            if isnan( startTime ) || isnan( finishTime ), return, end
            sql = sprintf( 'select time, value from data where time >= %d and time < %d order by time asc', ...
                int64( startTime*24*60*60 ), ...
                int64( finishTime*24*60*60 ) );
            reader = obj.query( sql );
            while reader.Read()
                times(end+1,:) = double( reader.GetInt64( 0 ) )/24/60/60; %#ok<AGROW>
                values(end+1,:) = double( reader.GetInt64( 1 ) )/100; %#ok<AGROW>
            end
            
        end % getData
        
        function time = getStartTime( obj )
            %getStartTime  Get start time
            %
            %  ts = s.getStartTime() returns the start time ts for the data
            %  source s.
            
            sql = 'select time from data order by time asc limit 1';
            reader = obj.query( sql );
            if reader.Read()
                time = double( reader.GetInt64( 0 ) )/24/60/60;
            else
                time = NaN;
            end
            
        end % getStartTime
        
        function time = getFinishTime( obj )
            %getFinishTime  Get finish time
            %
            %  ts = s.getFinishTime() returns the finish time tf for the
            %  data source s.
            
            sql = 'select time from data order by time desc limit 1';
            reader = obj.query( sql );
            if reader.Read()
                time = double( reader.GetInt64( 0 ) )/24/60/60;
            else
                time = NaN;
            end
            
        end % getFinishTime
        
    end % methods
    
    methods( Access = private )
        
        function reader = query( obj, sql )
            %query  Execute database query
            %
            %  r = obj.query(s) executes the SQL query s and returns a
            %  reader r.
            
            fprintf( 1, 'Executing query ''%s''... ', sql );
            command = System.Data.SQLite.SQLiteCommand( sql, obj.Connection );
            fprintf( 1, 'done.\n' );
            reader = command.ExecuteReader();
            
        end % query
        
    end % helpers
    
end % classdef