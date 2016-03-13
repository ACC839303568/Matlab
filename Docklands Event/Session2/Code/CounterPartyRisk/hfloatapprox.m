function pv = hfloatapprox(Spread,Principal,Disc,CouponYears,CouponRates,LatestFloatingRate,LegReset)
%HFLOATAPPROX Approximates the price of a floating rate note.
%
%   This function is a price ESTIMATOR and should not be used when accurate
%   prices are required.

% Coupon Forward Rates
ForwardRates = zeros(size(CouponRates));
ForwardRates(1) = CouponRates(1);
for j = 2:numel(ForwardRates)
    d1 = CouponYears(j-1);
    d2 = CouponYears(j);
    ddiff = d2 - d1;
    r1 = CouponRates(j-1);
    r2 = CouponRates(j);
    ForwardRates(j) = (((1+r2)^d2) / ((1+r1)^d1)) ^ (1 / ddiff) - 1;
end

% Allocate future value variable
fv = zeros(size(ForwardRates));

% First Coupon
fv(1) = Principal * LatestFloatingRate / LegReset;

% Other Coupons
for i = 2:numel(ForwardRates)
    fwdrate = ForwardRates(i) + Spread;
    fv(i) = Principal * fwdrate / LegReset;
end

% Add the principal
fv(end) = fv(end) + Principal;

% Discount
pv = sum(fv .* Disc);


