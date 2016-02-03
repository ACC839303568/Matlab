function startup()
%startup  Configure environment

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 50 $  $Date: 2012-06-26 09:51:24 +0100 (Tue, 26 Jun 2012) $

d = fileparts( mfilename( 'fullpath' ) );
addpath( fullfile( d, 'chart' ) )
addpath( fullfile( d, 'feed' ) )
addpath( fullfile( d, 'historic' ) )
addpath( fullfile( d, 'viewer' ) )

end % startup