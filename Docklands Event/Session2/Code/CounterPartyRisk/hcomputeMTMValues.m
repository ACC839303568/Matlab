function mtmValues = hcomputeMTMValues(swaps,simulationDates,scenario,todaysDate,baseOneYearRate)
% Computes the mark-to-market value of a portfolio of swaps
numSwaps = numel(swaps.Maturity);

% Allocate mtmValues matrix
mtmValues = zeros(numSwaps,numel(simulationDates));

% Since the swaps are priced on dates that are different from the cash flow
% dates, the swaps' current floating rate will not be specified in the
% provided zero curve (the zero curve at that pricing date).  To accurately
% price the swaps we need the floating rate from the previous cash flow
% date, when the swap's floating leg was set for the current period. We
% estimate these latest floating rates by interpolating between the rate
% curves that we do have in each interest rate path.  The latest floating
% rate we use is simply the interpolated 1-year rate (swaps have period ==
% 1) at the previous coupon date, interpolated between the rate curves that
% we did simulate.
oneYearIdx   = 3;
oneYearRates = [baseOneYearRate scenario.Rates(oneYearIdx,:)];
lastRates = zeros(numSwaps,numel(simulationDates));
for swapIdx = 1:numSwaps
    lastRates(swapIdx,:) = interp1([todaysDate simulationDates],oneYearRates,swaps.LastFloatingDate(swapIdx,:),'linear',swaps.LatestFloatingRate(swapIdx));
end

% Price the swaps at each simulation date
for dateIdx = 1:numel(simulationDates)
    
    % Find interest rate curve for this evaluation date
    thisDate     = simulationDates(dateIdx);
    thisRateIdx  = find(scenario.Dates <= thisDate,1,'last');
    theseRates = scenario.Rates(:,thisRateIdx);
    theseDates = datemnth(thisDate,scenario.Tenor);
    thisCompounding = -1;
    
    % Do not value matured swaps
    validIdx   = swaps.Maturity > thisDate;
    maturedIdx = swaps.Maturity <= thisDate;
    
    % compute values for all valid instruments
    if sum(validIdx(:)) > 0
        
        % Price all instruments using price approximator
        prices = hswapapprox(theseDates,theseRates, ...
            thisCompounding,swaps.LegRate(validIdx,:),thisDate,...
            swaps.Maturity(validIdx),swaps.Principal(validIdx),...
            swaps.LegType(validIdx,:),lastRates(validIdx,dateIdx),...
            swaps.LegReset);
        
        % Matured instruments have zero mtmValues
        mtmValues(maturedIdx,dateIdx) = 0;
        mtmValues(validIdx,  dateIdx) = prices;
    end
    
end
