%% Example Data
%
% Daily yield curve data, for tenors of 3M 6M 1Y 2Y 3Y 5Y 7Y 10Y 20Y from
% 1995 to 2010 will be used.

Settle = datenum('15-Feb-2011');
ZeroTimes = [3/12 6/12 1 2 3 5 7 10 20]';
ZeroRates = [0.0013 0.0017 0.003 0.0084 0.0139 0.0235 0.0303 0.0361 0.0445]';
CurveDates = datemnth(Settle,12*ZeroTimes);
RateSpec = intenvset('Rates',ZeroRates,'EndDates',CurveDates,'StartDate',Settle);

%% Simulation

a = .14;
b = .01;
sigma = .027;
eta = .013;
rho = -.76;

G2PP = LinearGaussian2F(RateSpec,a,b,sigma,eta,rho);

DeltaTime = 1/12;
Tenor = ZeroTimes;
nTrials = 1000;
nPeriods = 60; % 5 years of monthly data

rng default
G2PPSimPaths = simTermStructs(G2PP,nPeriods,'NTRIALS',nTrials,...
    'DeltaTime',DeltaTime,'Tenor',Tenor,'antithetic',true);

SimDates = datemnth(Settle,0:nPeriods);
SimDF = cumprod(exp(-G2PPSimPaths(2:end,1,:)*DeltaTime),1);

%% Plot one trial
trialIdx = 600;
figure
surf(Tenor,SimDates,G2PPSimPaths(:,:,trialIdx))
datetick y keepticks keeplimits
title(['Evolution of the Zero Curve for Trial:' num2str(trialIdx) ' of G2++ Model'])
xlabel('Tenor (Years)')

%% Read in Portfolio

SwapPort = readtable('SwapPortfolio.xlsx');
nSwaps = size(SwapPort,1);
disp(SwapPort)

SwapPort.Maturity = datenum(SwapPort.Maturity,getLocalDateFormat);

%% Valuation
Values = zeros(nPeriods,nSwaps,nTrials);
parfor periodidx=1:nPeriods
    tmpSettle = SimDates(periodidx+1);
    tmpRateSpec = intenvset('StartDate',tmpSettle,'EndDates',...
        datemnth(tmpSettle,12*Tenor),'Rates',...
        permute(G2PPSimPaths(periodidx+1,:,:),[2 3 1]));
    Values(periodidx,:,:) = swapbyzero(tmpRateSpec,...
        [SwapPort.RecRate SwapPort.PayRate], tmpSettle, SwapPort.Maturity,...
        'LegType',[SwapPort.RecType SwapPort.PayType],'LegReset',...
        [SwapPort.RecReset SwapPort.PayReset],'Principal',SwapPort.Notional); %#ok<PFBNS>
end

%% Compute CCR Measures

Exposures = creditexposures(Values,ones(nSwaps,1));

Profiles = exposureprofiles(SimDates(2:end),Exposures);

% Visualize portfolio exposure profiles
figure
plot(SimDates(2:end),Profiles.PFE,...
    SimDates(2:end),Profiles.MPFE * ones(nPeriods,1),...
    SimDates(2:end),Profiles.EE,...
    SimDates(2:end),Profiles.EPE * ones(nPeriods,1),...
    SimDates(2:end),Profiles.EffEE,...
    SimDates(2:end),Profiles.EffEPE * ones(nPeriods,1));
legend({'PFE (95%)','Max PFE','Exp Exposure (EE)','Time-Avg EE (EPE)',...
    'Max past EE (EffEE)','Time-Avg EffEE (EffEPE)'},'location','best')

datetick('x','mmmyy')
title('Exposure Profiles');
ylabel('Exposure ($)')
xlabel('Simulation Dates')

%% Compute CVA

CounterpartyCDSTimes = (1:5)';
CounterpartyCDSDates = datemnth(Settle,12*CounterpartyCDSTimes);
CounterpartyCDSSpreads = [140 185 215 275 340]';

DiscExp = SimDF.*Exposures;
DiscProfiles = exposureprofiles(SimDates(2:end),DiscExp,'ProfileSpec','EE');

discEE = [DiscProfiles.EE];

ProbData = cdsbootstrap([CurveDates ZeroRates], [CounterpartyCDSDates ...
    CounterpartyCDSSpreads],Settle,'probDates', SimDates(2:end)');

Recovery = 0.4;
CVA = (1-Recovery) * sum(discEE(2:end,:) .* diff(ProbData(:,2)));
disp(['CVA for this portfolio is: ' num2str(CVA)])