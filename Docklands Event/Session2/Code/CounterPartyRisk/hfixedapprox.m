function pv = hfixedapprox(Rate,Principal,Disc,LegReset)
%HFIXEDAPPROX Approximates the price of a fixed rate note.
%
%   This function is a price ESTIMATOR and should not be used when accurate
%   prices are required.

% Future value cash flows
fv = Rate/LegReset * Principal * ones(size(Disc));
fv(end) = fv(end) + Principal;

% Discount to PV
pv = sum(fv .* Disc);
