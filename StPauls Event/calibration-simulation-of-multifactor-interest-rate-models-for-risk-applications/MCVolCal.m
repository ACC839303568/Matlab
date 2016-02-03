%% Example Data
%
% Daily yield curve data, for tenors of 3M 6M 1Y 2Y 3Y 5Y 7Y 10Y 20Y from
% 1995 to 2010 will be used.


Settle = datenum('15-Feb-2011');
ZeroTimes = [3/12 6/12 1 2 3 5 7 10 20]';
ZeroRates = [0.0013 0.0017 0.003 0.0084 0.0139 0.0235 0.0303 0.0361 0.0445]';
CurveDates = datemnth(Settle,12*ZeroTimes);
RateSpec = intenvset('Rates',ZeroRates,'EndDates',CurveDates,'StartDate',Settle);

SwaptionBlackVol = [55 57 54 43 36 28 22
    50 55 49 40 33 25 20
    46 41 36 30 26 23 21
    38 33 29 25 23 22 20
    30 27 25 23 21 20 19
    26 24 22 21 20 19 18
    23 22 21 20 19 18 17]/100;
SwaptionExpiry = [1:5 7 10]';
SwaptionMaturity = [1:5 7 10];

SwaptionExpDates = datemnth(Settle,12*SwaptionExpiry);

ExpDatesFull = repmat(SwaptionExpDates,1,length(SwaptionMaturity));
MatDatesFull = datemnth(ExpDatesFull,repmat(12*SwaptionMaturity,length(SwaptionExpiry),1));

%% Plot Swaption Volatility Surface
[M,E] = meshgrid(SwaptionExpiry,SwaptionMaturity);
mesh(M,E,SwaptionBlackVol,'facecolor','none')

xlabel('Swap Maturity')
ylabel('Expiry')
title('Implied Swaption Black Volatility')

%% Compute Swaption Prices Using Black's Model
% Swaption volatilities are quoted using Black's model. Prices can be
% computed using the MATLAB function |swaptionbyblk|. These quotes are for
% at-the-money (ATM) quotes which can be computed with the MATLAB function
% |swapbyzero|.

[~,SwaptionStrike] = swapbyzero(RateSpec,[NaN 0], Settle, MatDatesFull(:),...
    'StartDate',ExpDatesFull(:));
SwaptionBlackPrices = swaptionbyblk(RateSpec, 'call', SwaptionStrike(:),Settle,...
    ExpDatesFull(:), MatDatesFull(:), SwaptionBlackVol(:));
SwaptionBlackPrices = reshape(SwaptionBlackPrices,size(SwaptionBlackVol));

%% Calibrate the Hull White Model to Swaption Data

HW1Fobjfun = @(x) SwaptionBlackPrices(:) - swaptionbyhwcf(RateSpec,x(1),x(2),...
    SwaptionStrike,ExpDatesFull,MatDatesFull);
opts = optimoptions('lsqnonlin','disp','iter','MaxFunEvals',1000,'TolFun',...
                            1e-4,'TolX',1e-4);

x0_HW = [.1 .01];
lb_HW = [0 0];
ub_HW = [1 1];
[HW1Fparams,resnorm,residual,exitflag] = lsqnonlin(HW1Fobjfun,x0_HW,lb_HW,ub_HW,opts);
HW1Fparams

%% Calibrate the G2++ Model to Swaption Data
G2PPobjfun = @(x) SwaptionBlackPrices(:) - swaptionbylg2f(RateSpec,x(1),x(2),...
    x(3),x(4),x(5),SwaptionStrike,ExpDatesFull,MatDatesFull);
x0_G2PP = [.4 .1 .15 .007 -.5];
lb_G2PP = [.01 .01 .001 .001 -1];
ub_G2PP = [1 1 1 1 1];
G2PPparams = lsqnonlin(G2PPobjfun,x0_G2PP,lb_G2PP,ub_G2PP,opts)

%% Calibrate the Hull White Model to Swaption Data using Simulated Annealing

opts = optimset('disp','iter','TolFun',1e-4,'TolX',1e-4);
HW1Fobjfun_PS = @(x) sum(HW1Fobjfun(x).^2);
HW1Fparams_PS = simulannealbnd(HW1Fobjfun_PS,x0_HW,lb_HW,ub_HW,opts);

%% Calibrate the Hull White Model to Swaption Data using MultiStart
opts = optimset('disp','final-detailed','MaxFunEvals',1000,'TolFun',1e-4);
problem = createOptimProblem('lsqnonlin','objective',HW1Fobjfun,'x0',x0_HW,...
    'lb',lb_HW,'ub',ub_HW,'options',opts);
ms = MultiStart('UseParallel',true);
[HW1Fparams_MS,fval,exitflag] = run(ms,problem,8)