%  Copyright 2014 The MathWorks, Inc.
%  $Revision: 17 $  $Date: 2014-06-26 15:49:49 +0100 (Thu, 26 Jun 2014) $

%% Load data
load data.mat

% Only include charged off loans
badLoans = data( strcmp( data.loan_status, 'Charged Off' ), : );

% Look at amount paid off as % of loan amount as output
Y = badLoans.total_rec_prncp ./ badLoans.funded_amnt;

% Choose some specific features for this simple example
badLoans.grade = cellfun( @double, badLoans.grade );
X = [ badLoans{:, {'funded_amnt','funded_amnt_inv','term','int_rate',...
    'installment','annual_inc','grade','emp_length','total_acc','dti'} } ];

%% Cross-validation
rng( 'default' )
cv = cvpartition( length(Y), 'holdout', 0.40 );

% Training set
Xtrain = X( training(cv),: );
Ytrain = Y( training(cv),: );

% Test set
Xtest = X( test(cv),: );
Ytest = Y( test(cv),: );

%% Linear regression
mdl = fitlm( Xtrain, Ytrain );

%% Make a prediction for the test set
Y_lr = mdl.predict( Xtest );

%% Evaluation

% Correlation coefficient
corrcoef( [Ytest(Y_lr>0) Y_lr(Y_lr>0)] )

% Plot results
Ytest( isnan( Y_lr ) ) = NaN;
scatter( Ytest*100, Y_lr*100, '.' )
xlabel( 'Actual % paid-off' )
ylabel( 'Predicted % paid-off' )

% Contour overlay
[N,C] = hist3( [Ytest*100 Y_lr*100], [10 10] );
[Xg,Yg] = ndgrid(C{1},C{2});
hold on
contour(Xg,Yg,N)
hold off

axis( [0 100 0 100] )