function scenario = hgenerateScenario(calibration,Settle,simulationDates)
% Generate a complete path of the term structure through the simulation
% Dates.
%
% Output:
% -------
% scenario.Rates = [Tenor x simulationDates] rate curves
% scenario.Tenor = calibration.tenorMonths;
% scenario.Dates = simulationDates;
% scenario.Disc = Discount factors at each date

RateCurveObj = calibration.RateCurveObj;
Tenor        = calibration.Tenor;
hw1          = calibration.ShortRateModel;
Alpha        = calibration.Alpha;
Sigma        = calibration.Sigma;

numDates = numel(simulationDates);
numRates = numel(Tenor);

% Compute short rates (the simulate method returns t0/r0 rate as well)
delta_ts = (simulationDates' - [Settle;simulationDates(1:end-1)']) / 365;
shortRates = hw1.simulate(numDates,'DeltaTime',delta_ts);
% Discard the initial state
shortRates = shortRates(2:end);

% Allocate interest rate paths
Rates = zeros(numRates,numDates);

% Compute full term structures
for i = 1:numDates
    Rates(:,i) = hw1TermStructure(simulationDates(i),shortRates(i),...
        RateCurveObj,Tenor,Alpha,Sigma);
end

% Add current term structure for discounting
Rates = [RateCurveObj.Data Rates];

% Compute discount factors
simulationDatesExp = [Settle; simulationDates(:)];
Disc = ones(1,numel(simulationDatesExp));
for i=2:numel(simulationDatesExp)
   tenorDates = datemnth(simulationDatesExp(i-1),Tenor);
   rateAtNextSimDate = interp1(tenorDates,Rates(:,i-1),...
      simulationDatesExp(i),'linear','extrap');
   Disc(i) = Disc(i-1) * zero2disc(rateAtNextSimDate,...
      simulationDatesExp(i),simulationDatesExp(i-1));
end

% Package up data into our scenario struct
scenario.Rates = Rates(:,2:end);
scenario.Disc  = Disc;
scenario.Tenor = Tenor;
scenario.Dates = simulationDates;
