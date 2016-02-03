function [data,idxCategorical] = convertCategoricals( data )
%convertCategoricals  Convert cell arrays of strings to categoricals

%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

assert( istable( data ) )

% Find variables of type cell array of strings
tfCellStr = varfun( @iscellstr, data, 'OutputFormat', 'uniform' );
idxCellStr = find( tfCellStr );

variableNames = data.Properties.VariableNames;

for ii = 1:numel( idxCellStr )
    
    % Get variable name
    varName = variableNames{idxCellStr(ii)};
    
    % Convert variable to categorical
    if ismember( varName, {'grade', 'sub_grade'} ) % specific to this dataset
        % ordinals
        data.(varName) = categorical( data.(varName), 'Ordinal', true );
    else
        data.(varName) = categorical( data.(varName) );
    end
end

% Return logical index of categorical variables
idxCategorical = tfCellStr';