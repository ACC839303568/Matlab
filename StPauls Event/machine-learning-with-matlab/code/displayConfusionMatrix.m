function displayConfusionMatrix( confusionMatrix, name, labels )
%displayConfusionMatrix  Display the given confusion matrix

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

% Handle input arguments
narginchk( 1, 3 )
if nargin < 2, name = 'Model'; end
if nargin < 3, labels = {'No', 'Yes'}; end

% Check input arguments
assert( isnumeric( confusionMatrix ) )
assert( size( confusionMatrix, 1 ) == size( confusionMatrix, 2 ) )
assert( ischar( name ) )
assert( iscellstr( labels ) )
assert( numel( labels ) == size( confusionMatrix, 1 ) )

% Row headings
numRows = numel( labels ) + 1;
rowHeadings = cell(numRows,1);
rowHeadings{1,:} = ''; % column headings
rowHeadings(2:end,:) = cellfun( @(x)sprintf('Actual %s', x), labels', ...
    'UniformOutput', false );
contents = char( rowHeadings );

% Get confusion matrix in % terms
cmPct = normalise( confusionMatrix ) * 100;

% Generate columns
columnHeadings = cellfun( @(x)sprintf('Predicted %s', x), labels, ...
    'UniformOutput', false );
values = arrayfun( @(x,y)sprintf('%5.2f%% (%d)',x,y), ...
    cmPct, confusionMatrix, 'UniformOutput', false );
columns = [columnHeadings;values];

% Define gap between columns
gap = repmat( '    ', numRows, 1 );

% Add each column in turn to the display contents
for ii = 1:size( columns, 2 )
    contents = [contents, gap, char(columns(:,ii)) ];  %#ok<AGROW>
end

% Display
fprintf( 'Performance of %s:\n', name );
disp( contents )