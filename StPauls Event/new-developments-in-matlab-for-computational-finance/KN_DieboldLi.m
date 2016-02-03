%% Using a Kalman Filter to Estimate and Forecast the Diebold-Li Yield Curve Model  

% Copyright 2014 The MathWorks, Inc.

%% The Yield Curve Data

% Unsmoothed Fama-Bliss (AER, 1987) forward rates converted to zero rates
load Data_DieboldLi
maturities = maturities(:);

horizon = 12;                                    
Yields = Data(1:(end - horizon),:);              % in-sample yields
futureYields = Data((end - horizon + 1):end,:);  % out-of-sample yields
dates = dates(1:(end - horizon));                % in-sample dates
futureDates = dates((end - horizon + 1):end);    % out-of-sample dates

%% The Diebold-Li Two-Step Estimation Approach

lambda0 = 0.0609;
X = [ones(size(maturities)) (1 - exp(-lambda0*maturities))./(lambda0*maturities) ...
    ((1 - exp(-lambda0*maturities))./(lambda0*maturities) - exp(-lambda0*maturities))];

beta = zeros(size(Yields,1),3);                       
residuals = zeros(size(Yields,1), numel(maturities));

for i = 1:size(Yields,1)
    FittedLM = fitlm(X, Yields(i,:)', 'Intercept', false);
    beta(i,:) = FittedLM.Coefficients.Estimate';
    residuals(i,:) = FittedLM.Residuals.Raw';
end

%% Fit VAR(1) Model

Model = vgxset('nAR', 1, 'n', 3, 'Constant', true);       
FittedVAR = vgxvarx(Model, beta(2:end,:), [], beta(1,:));

%% SSM Estimation of the Diebold-Li Model 

A0 = FittedVAR.AR{1};  % get the VAR(1) matrix (stored as a cell array)
A0 = A0(:);            % stack it columnwise
Q0 = FittedVAR.Q;      % get the VAR(1) estimated innovations covariance matrix
B0 = [sqrt(Q0(1,1)) ; 0 ; sqrt(Q0(2,2)) ; 0 ; 0 ; sqrt(Q0(3,3))];
H0 = cov(residuals);   % sample covariance matrix of VAR(1) residuals
D0 = sqrt(diag(H0));   % diagonalize the D matrix
mean0 = mean(beta)';
param0 = [A0 ; B0 ; D0 ; mean0 ; lambda0];

options = optimoptions('fminunc','MaxFunEvals',25000,'algorithm','quasi-newton', ...
                       'TolFun' ,1e-8,'TolX',1e-8,'MaxIter',1000,'Display','off');

Model = ssm(@(params)Example_DieboldLi(params, Yields, maturities));

[FittedSSM, estParam] = estimate(Model, Yields, param0, 'Display', 'off', ...
                                'options', options, 'Univariate', true);

estLambda = estParam(end);        % get the estimated decay rate    
estMean = estParam(end-3:end-1)'; % get the estimated factor means

%% Comparison of Inferred Latent States

intercept = FittedSSM.C * estMean';
deflatedYields = bsxfun(@minus, Yields, intercept');
deflatedStates = smooth(FittedSSM, deflatedYields);
EstimatedStates = bsxfun(@plus, deflatedStates, estMean);

figure
subplot(3,1,1)
plot(dates, [beta(:,1) EstimatedStates(:,1)])
title 'Level (Long-Term Factor)'
ylabel 'Percent'
datetick x
legend({'Two-Step','State-Space Model'},'location','best')

subplot(3,1,2)
plot(dates, [beta(:,2) EstimatedStates(:,2)])
title 'Slope (Short-Term Factor)'
ylabel 'Percent'
datetick x
legend({'Two-Step','State-Space Model'},'location','best')

subplot(3,1,3)
plot(dates, [beta(:,3) EstimatedStates(:,3)])
title 'Curvature (Medium-Term Factor)'
ylabel 'Percent'
datetick x
legend({'Two-Step','State-Space Model'},'location','best')

tau = 0:(1/12):max(maturities);    % maturity in months
lambda = [0.0609 estLambda];
curvatureLoading = @(tau) ((1 - exp(-lambda*tau))./(lambda*tau) - exp(-lambda*tau));
loading = zeros(numel(tau), 2);

for i = 1:numel(tau)
    loading(i,:) = curvatureLoading(tau(i)); 
end

figure
plot(tau, loading)
title 'Loading on Curvature (Medium-Term Factor)'
xlabel 'Maturity (Months)'
ylabel 'Curvature Loading'
legend({'\lambda = 0.0609 Fixed by Two-Step', ['\lambda = ' num2str(estLambda) ' Estimated by SSM'],},'location','best')

%% Monte Carlo Simulation Forecasts
%

[forecastedDeflatedYields,yMSE] = forecast(FittedSSM, horizon, deflatedYields);
forecastedYieldsSSM = bsxfun(@plus, forecastedDeflatedYields, intercept');

[DS,~,O] = smooth(FittedSSM, deflatedYields);  % FILTER could also be used
FittedSSM.Mean0 = O(end).SmoothedStates;
FittedSSM.Cov0 = O(end).SmoothedStatesCov;

rng default

simulatedDeflatedYields = simulate(FittedSSM, horizon, 500);
simulatedYields = bsxfun(@plus, simulatedDeflatedYields, intercept');

figure
hold on
plot(maturities,squeeze(simulatedYields(horizon,:,:)),'color', [0.5 0.5 0.5])
plot(maturities, forecastedYieldsSSM(horizon,:)','r','linewidth',5)
title '12-Month-Ahead Forecasts: Closed Form Forecast & Monte Carlo'
xlabel 'Maturity (Months)'
ylabel 'Percent'
[~,a,~,~] = legend({'Forecast', 'Monte Carlo'},'location','best');
set(a(3),'Color','r')