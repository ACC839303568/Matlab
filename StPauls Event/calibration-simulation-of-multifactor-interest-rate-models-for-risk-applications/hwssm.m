function [A,B,C,D,mean0,Cov0,stateType,Ydeflate] = ...
                hwssm(params,ZeroData,tau,deltaT,nPeriods,y)

tau = tau(:);

a = params(1);
sigma = params(2);

A = exp(-a*deltaT);
B = sigma*sqrt((1 - exp(-2*a*deltaT))./(2*a));
C = (1 - exp(-tau*a))./(a*tau);
D = diag(params(3:end));

ZeroTimes = ZeroData(:,1);
ZeroRates = ZeroData(:,2);

R = @(t) interp1(ZeroTimes,ZeroRates,t,'linear','extrap');

V = @(t,T) sigma^2/a^2*(T - t + 2/a*exp(-a*(T-t)) - 1/(2*a)*exp(-2*a*(T-t)) - 3/2/a);

t_k = (deltaT:deltaT:nPeriods*deltaT)';

e = zeros(nPeriods,length(tau));

for i=1:length(tau)
    e(:,i) = (t_k + tau(i))/tau(i).*R(t_k + tau(i)) - ...
         (t_k)/tau(i).*R(t_k) - ...
        1/(2*tau(i))*(V(t_k,t_k + tau(i)) - V(0,t_k + tau(i)) + V(0,t_k));
end

mean0 = 0;
Cov0 = 0;
stateType = [];
Ydeflate = y-e;