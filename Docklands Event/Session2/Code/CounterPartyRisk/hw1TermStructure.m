function ZeroCurve = hw1TermStructure(t,rt,RateCurveObj,Tenor,Alpha,Sigma)
% Compute the full term structure from the Hull-White single factor short
% rate.

settle = RateCurveObj.Settle;
tInYears = (t - settle) / 365;
T = datemnth(t,Tenor);
TInYears = (T - settle) / 365;
dt = TInYears - tInYears;
term1 = -1 ./ dt .* logA();
term2 =  1 ./ dt .* B();
ZeroCurve = term1 + term2 * rt;


    function Avalue = logA()
        local_term1 = log(Price0(T,TInYears) ./ Price0(t,tInYears));
        local_term2 = B() * Ft();
        term3 = -1 / (4 * Alpha ^ 3) * Sigma ^ 2 * (exp(-Alpha * TInYears) - exp(-Alpha * tInYears)) .^ 2 * (exp(2 * Alpha * tInYears) - 1);
        
        Avalue = local_term1 + local_term2 + term3;
    end

    function Bvalue = B()
        Bvalue = (1 - exp(-Alpha * dt)) / Alpha;
    end


    function v = Price0(local_t,local_tInYears)
        % Price of zero coupon bond with maturity T
        r = RateCurveObj.getZeroRates(local_t,'Compounding',-1);
        v = exp(-r .* local_tInYears);
    end


    function r = Ft()
        % Instantaneous forward rate
        FwdRates = RateCurveObj.getForwardRates(t:t+1,'Compounding', -1);
        r = FwdRates(2);
    end

end

