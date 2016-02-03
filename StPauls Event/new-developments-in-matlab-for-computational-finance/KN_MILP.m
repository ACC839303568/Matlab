%% Cash-Flow Matching with Optimization
% This example shows how to use linear programming and mixed-integer linear
% programming techniques to determine which bonds should be purchased to
% cover a given cash-flow.

% Copyright (c) 2014, MathWorks, Inc.

%% Problem Data
Settle = datenum('15-Jun-2014');
Obligations = [4E5 6E5 7E5 7E5 7E5 1.2E6 1.1E6 1.2E6]';
ObligationDates = datemnth(Settle,12*(.5:.5:4));

lotSize = 1000;

Bonds = readtable('BondPortfolio.xlsx');
Bonds.Maturity = datenum(Bonds.Maturity,getLocalDateFormat);

%% Generate Bond Cash Flows
CashFlows = cfamounts(Bonds.Coupon,Settle,Bonds.Maturity);
CashFlows(isnan(CashFlows)) = 0;
CashFlows = CashFlows(:,2:end)';

%% Linear Programming
lb = zeros(size(Bonds,1),1);
n = linprog(Bonds.Price,-CashFlows,-Obligations/lotSize,[],[],lb);

%% Mixed Integer Linear Programming
intcon = 1:5;
x = intlinprog(Bonds.Price,intcon,-CashFlows,-Obligations/lotSize,[],[],lb);

%% Compare solutions

rounded_LP = lotSize*round(n);
cost_rounded_LP = Bonds.Price'*rounded_LP;

cost_MILP = Bonds.Price'*x*lotSize;

bar([rounded_LP/lotSize x]);
legend('Rounded LP Solution','MILP Solution');
title('Lots Purchased (With Round Lots)');

CostString{1} = ['Rounded LP Cost:' num2str(cost_rounded_LP)];
CostString{2} = ['           MILP Cost:' num2str(cost_MILP)];

text(3,80,CostString)