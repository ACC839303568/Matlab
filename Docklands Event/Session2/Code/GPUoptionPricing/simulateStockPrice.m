function finalStockPrice = simulateStockPrice(S,r,d,v,T,dT)
    t = 0;
    while t < T
        t = t + dT;
        drift = (r - d - v*v/2)*dT;
        perturbation = v*sqrt( dT )*randn();
        S = S*exp(drift + perturbation);
    end
    finalStockPrice = S;
end