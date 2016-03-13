function optionPrice = upAndOutCallOption(S,r,d,v,x,b,T,dT)
    t = 0;
    while (t < T) && (S < b)
        t = t + dT;
        drift = (r - d - v*v/2)*dT;
        perturbation = v*sqrt( dT )*randn();
        S = S*exp(drift + perturbation);
    end
    if S<b
        % Within barrier, so price as for a European option.
        optionPrice = exp(-r*T) * max(0, S - x);
    else
        % Hit the barrier, so the option is withdrawn.
        optionPrice = 0;
    end
end