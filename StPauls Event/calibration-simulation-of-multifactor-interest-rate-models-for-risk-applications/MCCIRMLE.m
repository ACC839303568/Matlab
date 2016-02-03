%% Load Data
load CIR_Data

%% Plot Data
plot(Dates,ShortRates)
datetick
title('3-Month Treasury Constant Maturity Rate')

%% Use MLE to Estimate Parameters
dt = 1/12;
x0 = [0.1 mean(ShortRates) sqrt(2*0.1*mean(ShortRates))/1.5];
[CIR_Param,CIR_CI] = mle(ShortRates(2:end), 'pdf', {@cirpdf, dt, ...
    ShortRates(1:end-1)},'start',x0,'lowerbound', [0 0 0],'optimfun','fmincon')

a = CIR_Param(1);
b = CIR_Param(2);
Sigma = CIR_Param(3);

%% Simulate CIR Model
CIR = cir(a, b, Sigma,'StartState',ShortRates(end));

dt = 1/12;
nPeriods = 12*2;
nTrials = 10000;
Paths = simulate(CIR,nPeriods,'nTrials',nTrials,'DeltaTime',dt);
SimDates = datemnth(Dates(end),1:24);