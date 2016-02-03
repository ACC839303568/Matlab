function [f, m] = ConfiguredDataSourceApp()
%cfc.ConfiguredDataSourceApp  Launch application
%
%  cfc.ConfiguredDataSourceApp launches the application.
%
%  [f,m] = cfc.ConfiguredDataSourceApp also returns the figure window f and
%  the application data model m.

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $

% Create model
m = cfc.DataViewerModel();

% Create figure
f = figure( 'HandleVisibility', 'off', 'IntegerHandle', 'off', ...
    'MenuBar', 'none', 'NumberTitle', 'off', ...
    'Name', 'Configured Data Source Demo' );

% Create views
b = uiextras.VBox( 'Parent', f, 'Padding', 5, 'Spacing', 5 );
cfc.DateView( m, b );
cfc.TimeSeriesView( m, b );
b.Sizes = [20 -1];

% Create menus
mData = uimenu( 'Parent', f, 'Label', 'Data' );
uimenu( 'Parent', mData, 'Label', 'Reload', 'Callback', @onReload );

% Force reload
onReload()

    function onReload( ~, ~ )
        
        try
            
            % Read configuration
            [type, parameters] = cfc.cfgread( 'DataSource.cfg' );
            
            % Construct data source
            ds = feval( sprintf( 'cfc.%sDataSource', type ), parameters{:} );
            
            % Set data source
            m.DataSource = ds;
            
        catch e
            
            % Show error dialog
            errordlg( e.message, 'Error' )
            
        end
        
    end % onReload

end % ConfiguredDataSourceApp