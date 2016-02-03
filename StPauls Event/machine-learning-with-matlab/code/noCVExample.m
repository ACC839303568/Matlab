%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

%% Load data
load dataBeforeCV.mat % contains data, labels, idxCategorical

%% No cross validation

X = table2array( varfun( @double, data(:,1:27) ) );
Y = data.defaulted;

%% Try a decision tree

% Train the classifier
tree = fitctree( X, Y, 'CategoricalPredictors', idxCategorical(1:27) );

% Make a prediction
[Y_tree, Yscore_tree] = tree.predict( X );

%% Confusion matrix

% Compute the confusion matrix
C_tree = confusionmat( Y, Y_tree );

% Display the confusion matrix
displayConfusionMatrix( C_tree, 'Decision Tree', labels );

%% ROC Curve

% Set up plot with random line and labels
x = 0:0.01:1;
plot( x, x, 'k--' )
hold on
xlabel( 'False Positive Rate (FPR)' )
ylabel( 'True Positive Rate (TPR)' )

% ROC curve
[rocx, rocy] = perfcurve( Y, Yscore_tree(:,2), labels{2} );
plot( rocx, rocy, 'b' )