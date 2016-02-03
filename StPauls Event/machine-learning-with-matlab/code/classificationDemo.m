%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

%% Load data
load data.mat

%% Make it a binary classification problem

% Define defaulted loan status
defaultedLoanStatus = { 'Charged Off', 'Default', ...
    'Late (16-30 days)', 'Late (31-120 days)' };

% Create a binary output
data.defaulted = ismember( data.loan_status, defaultedLoanStatus );

% Convert output to categorical
labels = {'Paid off','Defaulted'};
data.defaulted = categorical( data.defaulted, [false,true], labels );

% Remove original loan_status
data.loan_status = [];

%% Look at features
gplotFeatures = {'loan_amnt', 'funded_amnt', 'id', 'emp_length', ...
    'int_rate', 'total_rec_prncp', 'policy_code' };
gplotmatrix( data{:,gplotFeatures}, [], data.defaulted, [], [], [], ...
    'on', 'hist', gplotFeatures, gplotFeatures )

%% Feature Selection

% Remove features where values are all empty
data(:, varfun( @(x)numel( unique( x ) ) == 1 && iscell( x ) && isempty( x{1} ), ...
    data, 'OutputFormat', 'uniform' )) = [];

% Remove features where data is mostly missing
data(:, varfun( @(x)isMostlyNan(x,0.5), data, 'OutputFormat', 'uniform' )) = [];

% Remove unique features
data(:, varfun( @(x)numel(unique(x)), data, 'OutputFormat', 'uniform' ) ...
    == height( data )) = [];

% Remove features where values are all the same
data(:, varfun( @isInvariant, data, 'OutputFormat', 'uniform' )) = [];

% Remove irrelevant features
data(:, { 'addr_city', 'accept_d', 'exp_d', 'list_d', 'issue_d' } ) = [];

% Remove leaks from the future
futureFeatures = { 'total_pymnt', 'total_pymnt_inv', ...
    'total_rec_prncp', 'total_rec_int', 'out_prncp', 'out_prncp_inv', ...
    'recoveries', 'total_rec_late_fee', 'collection_recovery_fee',  ...
    'last_pymnt_d', 'next_pymnt_d', 'last_credit_pull_d' };
data(:,futureFeatures) = [];

%% Replace NaNs
data(:,:) = varfun( @(x)replaceNans(x,0), data );

%% Categorical variables
[data, idxCategorical] = convertCategoricals( data );

%% Cross-validation
rng( 'default' )
X = table2array( varfun( @double, data(:,1:27) ) );
Y = data.defaulted;

cv = cvpartition( height(data), 'holdout', 0.40 );

% Training set
Xtrain = X( training(cv), : );
Ytrain = Y( training(cv), : );

% Test set
Xtest = X( test(cv), : );
Ytest = Y( test(cv), : );

% Display
disp( 'Training Set' )
tabulate( Ytrain )
disp( 'Test Set' )
tabulate( Ytest )

%% Try a decision tree

% Train the classifier
tree = fitctree( Xtrain, Ytrain, 'CategoricalPredictors', idxCategorical(1:27) );

% Make a prediction for the test set
[Y_tree, Yscore_tree] = tree.predict( Xtest );

%% View tree
view( tree, 'Mode', 'Graph' )

%% Confusion matrix

% Compute the confusion matrix
CM_tree = confusionmat( Ytest, Y_tree );

% Display the confusion matrix
displayConfusionMatrix( CM_tree, 'Decision Tree', labels );

%% ROC Curve

% Set up plot with random line and labels
plot( 0:0.01:1, 0:0.01:1, 'k--', 'HandleVisibility', 'off' )
hold on
xlabel( 'False Positive Rate (FPR)' )
ylabel( 'True Positive Rate (TPR)' )

% ROC curve
[rocx, rocy] = perfcurve( Ytest, Yscore_tree(:,2), 'Defaulted' );
plot( rocx, rocy, 'b' )

% Highlight confusion matrix position on ROC curve
CMnorm_tree = normalise( CM_tree );
plot( CMnorm_tree(1,2), CMnorm_tree(2,2), 'bo', 'HandleVisibility', 'off' )

%% Pruning the tree
prunedTree = prune( tree, 'Level', 50 );
view( prunedTree, 'Mode', 'Graph' )

%% Evaluate the pruned tree

% Make a prediction for the test set
[Y_pt, Yscore_pt] = prunedTree.predict( Xtest );

% Compute the confusion matrix
CM_pt = confusionmat( Ytest, Y_pt );

% Display the confusion matrix
displayConfusionMatrix( CM_pt, 'Pruned Classification Tree', labels );

% ROC Curve
[rocx, rocy] = perfcurve( Ytest, Yscore_pt(:,2), 'Defaulted' );
plot( rocx, rocy, 'm' )

% Highlight confusion matrix position on ROC curve
CMnorm_pt = normalise( CM_pt );
plot( CMnorm_pt(1,2), CMnorm_pt(2,2), 'mo', 'HandleVisibility', 'off' )

%% Treebagger

% Train the classifier
Ytrain_tb = Ytrain == 'Defaulted';
Ytest_tb = Ytest == 'Defaulted';
baggedTree = TreeBagger( 10, Xtrain, Ytrain_tb, ...
    'Method', 'Classification', 'OOBVarImp', 'on' );  

% Make a prediction for the test set
[Y_tb, Yscore_tb] = baggedTree.predict( Xtest );
Y_tb = strcmp( Y_tb, '1' );

% Compute the confusion matrix
CM_tb = confusionmat( Ytest_tb, Y_tb );

% Display the confusion matrix
displayConfusionMatrix( CM_tb, 'Bagged Trees', labels );

% Add to the ROC curve
[rocx, rocy] = perfcurve( Ytest_tb, Yscore_tb(:,2), true );
plot( rocx, rocy, 'g' )

% Highlight confusion matrix position on ROC curve
CMnorm_tb = normalise( CM_tb );
plot( CMnorm_tb(1,2), CMnorm_tb(2,2), 'go', 'HandleVisibility', 'off' )

% Add legend
legend( 'Decision Tree', 'Pruned Decision Tree', 'Treebagger', 'Location', 'SouthEast' )