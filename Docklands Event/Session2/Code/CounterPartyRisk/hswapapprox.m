function Price = hswapapprox(ZeroDates, ZeroRates, ZeroCompounding,LegRate,...
    Settle, Maturity, Principal, LegType, LatestFloatingRate, LegReset)
%HSWAPAPPROX Approximates the price of a vanilla interest rate swap.
%
%   This function is a swap price ESTIMATOR.  Exact valuation has been
%   sacrificed for overall function performance.  It is used when computing
%   swap prices in a CVA workflow but should not be used when accurate
%   prices are required.
%
%   Price =  hswapapprox(ZeroDates, ZeroRates, ZeroCompounding, LegRate, Settle,...
%            Maturity, Principal, LegType, LatestFloatingRate,LegReset)
%
%      ZeroDates - Dates associated with ZeroRates.
%      ZeroRates - Zero rates at date Settle.
%      ZeroCompounding - Zero rate compounding frequency.
%
%      For a description of the remaining arguments, see the documentation
%      for SWAPBYZERO.
%
%   This function has several additional restrictions relative to
%   SWAPBYZERO.  They are:
%
%      1) A single zero curve is used for all swaps.
%      2) Each leg of a swap must have the same reset value.  See the
%         documentation for LegReset in SWAPBYZERO for more information.
%      3) Actual/365 day count convention is used for all swaps (Basis is 3).
%      4) No additional Name/Value pair arguments are supported except for
%         LatestFloatingRate, which is a required argument for all swaps.
%
%   Outputs:
%      Price - NINSTx1 vector of swap price approximations.
%      Rec   - NINSTx1 vector of value approximations for receiving leg.
%      Pay   - NINSTx1 vector of value approximations for paying leg.

%   Copyright 2012 The MathWorks, Inc.

DaysPerYear = 365;
ZeroDatesInYears = (ZeroDates-Settle)/DaysPerYear;

NumSwaps = numel(Maturity);
Rec = zeros(NumSwaps,1);
Pay = Rec;
Price = Rec;

% Swap legs must have the same LegReset (Paying and Receiving)
LegReset = LegReset(:,1);

for i = 1:NumSwaps
    
    % Convert zero curve to match swap resets if necessary
    if ~isequal(LegReset(i),ZeroCompounding)
        ZeroRates = convertRateCompounding(ZeroRates,ZeroDates,...
            ZeroCompounding,LegReset(i),Settle,DaysPerYear);
        ZeroCompounding = LegReset(i);
    end
    
    % Coupon Dates
    CouponDates = fliplr(floor(Maturity(i):-DaysPerYear/LegReset(i):Settle))';
    if CouponDates(1) == Settle
        CouponDates(1) = [];
    end
    CouponYears = (CouponDates-Settle) / DaysPerYear;
    
    % Coupon Zero Rates
    CouponRates = ratetimes_local(ZeroRates, ZeroDatesInYears, CouponYears);
    CouponDiscounts = (1 + CouponRates/ZeroCompounding).^(-CouponYears*ZeroCompounding);
    
    % Price Receiving Leg
    if LegType(i,1) == 1
        % Receiving is fixed
        FixedRate = LegRate(i,1);
        Rec(i) = hfixedapprox(FixedRate,Principal(i),CouponDiscounts,LegReset(i));
    else
        % Receiving is floating
        Spread = LegRate(i,1) / 1e4;
        Rec(i) = hfloatapprox(Spread,Principal(i),CouponDiscounts,CouponYears,CouponRates,LatestFloatingRate(i),LegReset(i));
    end
    
    % Price Paying Leg
    if LegType(i,2) == 1
        % Paying is fixed
        FixedRate = LegRate(i,2);
        Pay(i) = hfixedapprox(FixedRate,Principal(i),CouponDiscounts,LegReset(i));
    else
        % Paying is floating
        Spread = LegRate(i,2) / 1e4;
        Pay(i) = hfloatapprox(Spread,Principal(i),CouponDiscounts,CouponYears,CouponRates,LatestFloatingRate(i),LegReset(i));
    end
    
    Price(i) = Rec(i) - Pay(i);
end


%------------------------------------------------
function EndRates = ratetimes_local(RefRates, RefEndTimes, EndTimes)

% Interpolate or constant extrapolate the Ending rates
MaskMin = ( EndTimes <= RefEndTimes(1) );
MaskMax = ( EndTimes >= RefEndTimes(end) );
MaskInt = ~( MaskMin | MaskMax );

EndRates = zeros(size(EndTimes));
if any(MaskMin)
    EndRates(MaskMin) = RefRates(1) * ones(sum(MaskMin),1);
end
if any(MaskMax)
    EndRates(MaskMax) = RefRates(end) * ones(sum(MaskMax),1);
end
if any(MaskInt)
    EndRates(MaskInt) = interp1q(RefEndTimes, RefRates, EndTimes(MaskInt));
end


%------------------------------------------------
function outRate = convertRateCompounding(RefRates,RefDates,RefComp,outComp,Settle,DaysPerYear)
% getAnnualRates Converts compounding and to annual.  See IRDataCurve for
% more detailed version.  Assumes basis of 12 (Actual/365).

% Compute accrual factors
Times = (RefDates - Settle) / DaysPerYear;

outRate = zeros(size(RefRates));

% Convert rates
if RefComp > 0 && outComp > 0
    outRate = ((1 + RefRates/RefComp).^(Times*RefComp./(Times*outComp)) - 1)*outComp;
elseif RefComp == -1 && outComp > 0
    outRate = ((exp(Times.*RefRates).^(1./(Times*outComp))) - 1)*outComp;
end

% Handle the case when the input date is a settle
outRate(Times == 0) = RefRates(Times == 0);

