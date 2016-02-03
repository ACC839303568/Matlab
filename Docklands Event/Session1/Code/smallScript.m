%% Import data.
importFromDB
returns = tick2ret(prices, dates, 'Continuous');

%% Calculate statistics.
m = mean(returns);
covMx = cov(returns)
C = corrcoef(returns)

%% Visualise.
corrplot(returns)
correlationPlot(C, names)
figure
normplot(returns)
legend(names)

%% Create distribution fits.
[pd1, pd2] = createFit(returns(:, 1))
