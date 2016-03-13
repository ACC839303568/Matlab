%% Import the data.
importFromDB

%% Calculate return statistics
createfigure(dates, prices)
returns = tick2ret(prices, dates, 'Continuous');
m = mean(returns);
covMx = cov(returns)
C = corrcoef(returns)
corrplot(returns)
correlationPlot(C, names)
figure
normplot(returns)

%% Distribution fit.
[pd1, pd2] = createFit(returns(:, 1))
