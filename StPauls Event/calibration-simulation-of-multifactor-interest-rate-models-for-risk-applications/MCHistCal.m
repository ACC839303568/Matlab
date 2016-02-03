%% Load Data
%
% Daily yield curve data, for tenors of 3M 6M 1Y 2Y 3Y 5Y 7Y 10Y 20Y from
% 1995 to 2010 will be used.

load HistData

tau = [3/12 6/12 1 2 3 5 7 10 20];

% Take the first day of data to be the zero curve
InitZeroRates = EstimationData(1,:);

deltaT = 1/252;
nObs = size(EstimationData,1);

%% Visualize the historical data
[D,T] = meshgrid(tau,EstimationDates);
figure
mesh(D,T,EstimationData)
set(gca,'View',[-51.5000 36.0000])
datetick y
title('Historical US Yield Curve -- 1995-2010')
xlabel('Tenor (years)')

%% Calibrate the Hull White Model to Historical Data

HW1FSSM = ssm(@(c)hwssm(c,[tau(:) InitZeroRates(:)],tau,deltaT,nObs,...
    EstimationData));

D0 = .1*ones(1,length(tau));

x0_HW = [.1 .01];
lb_HW = [0 0];
ub_HW = [1 1];

[KalmanHW,histHWParam] = estimate(HW1FSSM,EstimationData,[x0_HW D0],'lb',...
    [lb_HW zeros(1,length(tau))],'ub',[ub_HW ones(1,length(tau))],...
    'Display','iter','univariate',true);

Hist_HW_Alpha = histHWParam(1)
Hist_HW_Sigma = histHWParam(2)

%% Calibrate the G2++ to Historical Data

G2PPSSM = ssm(@(c)g2ppssm(c,[tau(:) InitZeroRates(:)],tau,deltaT,nObs,...
    EstimationData));

x0_G2PP = [.4 .1 .15 .007 -.5];
lb_G2PP = [.01 .01 .001 .001 -1];
ub_G2PP = [1 1 1 1 1];

opts = optimoptions('fmincon','TolFun',1e-5,'TolX',1e-5);

[KalmanG2PP,histG2PPParam] = estimate(G2PPSSM,EstimationData,[x0_G2PP D0],...
    'lb',[lb_G2PP zeros(1,length(tau))],'ub',[ub_G2PP ones(1,length(tau))],...
    'Display','iter','univariate',true,'options',opts);

Hist_G2PP_a = histG2PPParam(1)
Hist_G2PP_b = histG2PPParam(2)
Hist_G2PP_sigma = histG2PPParam(3)
Hist_G2PP_eta = histG2PPParam(4)
Hist_G2PP_rho = histG2PPParam(5)