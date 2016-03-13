function optionPrice = asianCallOption(S,r,d,v,x,T,dT)
    t = 0;
    cumulativePrice = 0;
    while t < T
        t = t + dT;
        drift = (r - d - v*v/2)*dT;
        perturbation = v*sqrt( dT )*randn();
        S = S*exp(drift + perturbation);
        cumulativePrice = cumulativePrice + S;
    end
    numSteps = (T/dT);
    meanPrice = cumulativePrice / numSteps;
    % Express the final price in today's money.
    optionPrice = exp(-r*T) * max(0, meanPrice - x);
end