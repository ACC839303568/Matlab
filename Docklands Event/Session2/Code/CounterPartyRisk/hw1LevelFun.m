function level = hw1LevelFun(t0,dt,FwdRates,Alpha,Sigma)
% Compute the level function for the single factor Hull-White short rate
% model.

% Theta function
t = max(t0 + round(dt * 365),t0+1);
theta = Ft(t) + Alpha * F(t) + (Sigma^2/(2*Alpha)) * (1 - exp(-2*Alpha*dt));
% HW1 level is theta/alpha
level = theta / Alpha;

    function r = F(t)
        % Instantaneous forward rate
        r = FwdRates(t+1-t0);
    end

    function dr = Ft(t)
        % Derivative of the instantaneous forward rate w/ respect to time
        Rates = FwdRates(t-t0:t+2-t0);
        dr = (Rates(3) - Rates(2)) / (1/365);
    end

end
