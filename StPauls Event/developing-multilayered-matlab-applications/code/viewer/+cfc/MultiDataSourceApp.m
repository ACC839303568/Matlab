function [f, m] = MultiDataSourceApp()
%cfc.MultiDataSourceApp  Launch application
%
%  cfc.MultiDataSourceApp launches the application.
%
%  [f,m] = cfc.MultiDataSourceApp also returns the figure window f and the
%  application data model m.

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $

% Create model
m = cfc.DataViewerModel();

% Create figure
f = figure( 'HandleVisibility', 'off', 'IntegerHandle', 'off', ...
    'MenuBar', 'none', 'NumberTitle', 'off', ...
    'Name', 'Multi Data Source Demo' );

% Create views
b = uiextras.VBox( 'Parent', f, 'Padding', 5, 'Spacing', 5 );
cfc.DateView( m, b );
cfc.TimeSeriesView( m, b );
b.Sizes = [20 -1];

% Create menus
mData = uimenu( 'Parent', f, 'Label', 'Data' );
uimenu( 'Parent', mData', 'Label', 'MAT-Files...', 'Callback', @onMAT );
uimenu( 'Parent', mData', 'Label', 'CSV-Files...', 'Callback', @onCSV );
uimenu( 'Parent', mData', 'Label', 'Database...', 'Callback', @onDatabase );

    function onMAT( ~, ~ )
        
        d = uigetdir( pwd, 'Select Folder' );
        if isequal( d, 0 )
            % User cancelled
        else
            m.DataSource = cfc.MATDataSource( d );
        end
        
    end % onMAT

    function onCSV( ~, ~ )
        
        d = uigetdir( pwd, 'Select Folder' );
        if isequal( d, 0 )
            % User cancelled
        else
            m.DataSource = cfc.CSVDataSource( d );
        end
        
    end % onCSV

    function onDatabase( ~, ~ )
        
        [fn, pn] = uigetfile( {'*.sqlite','SQLite Databases'}, 'Select Database' );
        if isequal( fn, 0 ) || isequal( pn, 0 )
            % User cancelled
        else
            s = sprintf( 'Data Source="%s";Version=3;', fullfile( pn, fn ) );
            m.DataSource = cfc.DatabaseDataSource( s );
        end
        
    end % onDatabase

end % MultiDataSourceApp