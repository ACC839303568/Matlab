function createStackedBarGraph(pwgt,names)
% CREATESTACKEDBARGRAPH
n = length(names);  % number of assets
bar(pwgt','stack')
axis tight
colormap(1-copper)
title('Asset allocation along the efficient frontier')
ylabel('Portfolio Weights')
legend(names,'FontSize',7)
colorbar('Ytick',1 + ((0:(n-1)) + 0.5).*((n-1)/n),  'YTicklabel',names)
    
