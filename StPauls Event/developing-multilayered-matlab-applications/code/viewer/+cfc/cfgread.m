function [t, p] = cfgread( filename )
%cfc.cfgread  Read data source configuration file
%
%  [t,p] = cfc.cfgread(f) reads the configuration file f and returns the
%  data source type t and its parameters p.

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $

% Read contents line by line
f = fopen( filename, 'r' );
if f == -1
    error( 'cfc:FileNotFound', 'File ''%s'' not found.', filename )
end
contents = textscan( f, '%s', 'Delimiter', '\n' );
fclose( f );
contents = contents{:};

% Ignore lines beginning with #
contents(strncmp( contents, '#', 1 ),:) = [];

% Return type and parameters
t = contents{1};
p = transpose( contents(2:end) );

end % cfgread