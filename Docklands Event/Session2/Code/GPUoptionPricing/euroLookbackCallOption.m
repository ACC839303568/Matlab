function optionPrice = euroLookbackCallOption(S,r,d,v,T,dT)
    t = 0;
    minPrice = S;
    while t < T
        t = t + dT;
        drift = (r - d - v*v/2)*dT;
        perturbation = v*sqrt( dT )*randn();
        S = S*exp(drift + perturbation);
        if S<minPrice
            minPrice = S;
        end
    end
    % Express the final price in today's money.
    optionPrice = exp(-r*T) * max(0, S - minPrice);
end