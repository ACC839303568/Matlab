%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

%% Load data
load dataWithTotalPaymentAmount.mat % contains data, labels, idxCategorical

%% Cross-validation

X = table2array( varfun( @double, data(:,1:27) ) );
Y = data.defaulted;

cv = cvpartition( height( data ), 'holdout', 0.40 );

% Training set
Xtrain = X(training(cv),:);
Ytrain = Y(training(cv),:);

% Test set
Xtest = X(test(cv),:);
Ytest = Y(test(cv),:);

%% Decision tree

% Train the classifier
tree = fitctree( Xtrain, Ytrain, 'CategoricalPredictors', idxCategorical(1:27) );

% Make a prediction for the test set
[Y_tree, Yscore_tree] = tree.predict( Xtest );

%% Confusion matrix

% Compute the confusion matrix
CM_tree = confusionmat( Ytest, Y_tree );

% Display the confusion matrix
displayConfusionMatrix( CM_tree, 'Decision Tree', labels );

%% ROC Curve

% Set up plot with random line and labels
x = 0:0.01:1;
plot( x, x, 'k--', 'HandleVisibility', 'off' )
hold on
xlabel( 'False Positive Rate (FPR)' )
ylabel( 'True Positive Rate (TPR)' )

% ROC curve
[rocx, rocy] = perfcurve( Ytest, Yscore_tree(:,2), labels{2} );
plot( rocx, rocy, 'b' )