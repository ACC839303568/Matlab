function [Aout,Bout,Cout,Dout,mean0,Cov0,stateType,Ydeflate] = ...
    g2ppssm(params,ZeroData,tau,deltaT,nPeriods,y)

tau = tau(:);

a = params(1);
b = params(2);
sigma = params(3);
eta = params(4);
rho = params(5);

Aout = diag([exp(-a*deltaT) exp(-b*deltaT)]);
Bout = diag([sigma*sqrt((1 - exp(-2*a*deltaT))./(2*a)) eta*sqrt((1 - exp(-2*b*deltaT))./(2*b))]);
Bout = Bout*(chol([1 rho;rho 1])');
Cout = [(1 - exp(-tau*a))./(a*tau) (1 - exp(-tau*b))./(b*tau)];
Dout = diag(params(6:end));

ZeroTimes = ZeroData(:,1);
ZeroRates = ZeroData(:,2);

R = @(t) interp1(ZeroTimes,ZeroRates,t,'linear','extrap');

V = @(t,T) sigma^2/a^2*(T - t + 2/a*exp(-a*(T-t)) - 1/(2*a)*exp(-2*a*(T-t)) - 3/2/a) + ...
    eta^2/b^2*(T - t + 2/b*exp(-b*(T-t)) - 1/(2*b)*exp(-2*b*(T-t)) - 3/2/b) + ...
    2*rho*sigma*eta/(a*b)*(T - t + (exp(-a*(T-t)) - 1)/a + (exp(-b*(T-t)) - 1)/b - ...
    (exp(-(a + b)*(T-t)) - 1)/(a + b));

t_k = (deltaT:deltaT:nPeriods*deltaT)';

e = zeros(nPeriods,length(tau));

for i=1:length(tau)
    e(:,i) = (t_k + tau(i))/tau(i).*R(t_k + tau(i)) - ...
         (t_k)/tau(i).*R(t_k) - ...
        1/(2*tau(i))*(V(t_k,t_k + tau(i)) - V(0,t_k + tau(i)) + V(0,t_k));
end

mean0 = [0 0];
Cov0 = diag([0 0]);
stateType = [];
Ydeflate = y-e;