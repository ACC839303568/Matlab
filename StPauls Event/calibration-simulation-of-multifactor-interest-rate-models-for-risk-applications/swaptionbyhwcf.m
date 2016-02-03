function SwaptionPrice = swaptionbyhwcf(inCurve,a,sigma,X,ExerciseDate,Maturity,varargin)
%SWAPTIONBYHWCF Compute swaption price using Hull White model
%
% Syntax:
%
%   Price = swaptionbyhwcf(ZeroCurve,a,sigma,Strike,ExerciseDate,Maturity)
%   Price = swaptionbyhwcf(ZeroCurve,a,sigma,Strike,ExerciseDate,Maturity,...
%                           'name1','val1')
%
% Description:
%
%   Compute swaption price for Hull White model
%
% Inputs:
%
%   ZeroCurve - IRDataCurve or RateSpec. This is the zero curve that is
%               used to evolve the path of future interest rates.
%
%   a - Mean reversion for 1st factor; specified as a scalar.
%
%   sigma - Volatility for 1st factor; specified as a scalar.
%
%   Strike - NumSwaptions x 1 vector of Strike values.
%
%   ExerciseDate - NumSwaptions x 1 vector of serial date numbers or date strings
%                  containing the swaption exercise dates.
%
%   Maturity - NumSwaptions x 1 vector of serial date numbers or date strings
%              containing the swap maturity dates.
%
% Optional Inputs:
%
%   Reset - NumSwaptions x 1 vector of reset frequencies of swaption -- default is 1.
%
%   Notional - NumSwaptions x 1 vector of notional values of swaption -- default is 100.
%
%   OptSpec - NumSwaptions x 1 cell array of strings 'call' or 'put'. A call
%             swaption entitles the buyer to pay the fixed rate. A put
%             swaption entitles the buyer to receive the fixed rate.
%             Default is call.
%
% Example:
%
%   Settle = datenum('15-Dec-2007');
%
%   ZeroTimes = [3/12 6/12 1 5 7 10 20 30]';
%   ZeroRates = [0.033 0.034 0.035 0.040 0.042 0.044 0.048 0.0475]';
%   CurveDates = daysadd(Settle,360*ZeroTimes,1);
%
%   irdc = IRDataCurve('Zero',Settle,CurveDates,ZeroRates);
%
%   a = .07;
%   sigma = .01;
%
%   Reset = 1;
%   ExerciseDate = daysadd(Settle,360*5,1);
%   Maturity = daysadd(ExerciseDate,360*[3;4],1);
%   Strike = .05;
%
%   Price = swaptionbyhwcf(irdc,a,sigma,Strike,ExerciseDate,Maturity,'Reset',Reset)
%
% Reference:
%
%   [1] Brigo, D and F. Mercurio. Interest Rate Models - Theory and
%   Practice. Springer Finance, 2006.
%
% See also HULLWHITE1F

narginchk(6, 12);

ExerciseDate = datenum(ExerciseDate);
Maturity = datenum(Maturity);

p = inputParser;

p.addParamValue('reset',1);
p.addParamValue('notional',100);
p.addParamValue('optspec',{'call'});

try
    p.parse(varargin{:});
catch ME
    newMsg = message('fininst:swaptionbylg2f:optionalInputError');
    newME = MException(newMsg.Identifier, getString(newMsg));
    newME = addCause(newME, ME);
    throw(newME)
end

Reset = p.Results.reset;
Notional = p.Results.notional;

if ischar(p.Results.optspec)
    OptSpec = cellstr(p.Results.optspec);
elseif iscell(p.Results.optspec)
    OptSpec = p.Results.optspec;
end

try
    [X, ExerciseDate, Maturity, Reset, Notional, OptSpec] = finargsz(1, X(:), ExerciseDate(:),Maturity(:),...
        Reset(:), Notional(:), OptSpec(:));
catch ME
    throwAsCaller(ME)
end

isCall = strcmpi(OptSpec,'call');

if isafin(inCurve,'RateSpec')
    inCurve = IRDataCurve('zero',inCurve.ValuationDate,inCurve.EndDates,inCurve.Rates);
end


if isafin(inCurve,'RateSpec')
    Settle = inCurve.ValuationDate;
    PM = @(t) intenvget(intenvset(inCurve,'EndDates',daysadd(Settle,round(t*360),1)),'Disc')';
else
    Settle = inCurve.Settle;
    PM = @(t) inCurve.getDiscountFactors(datemnth(Settle, 12*t))';
end

V = @(t,T) sigma^2/a^2*(T - t + 2/a*exp(-a*(T-t)) - 1/(2*a)*exp(-2*a*(T-t)) - 3/2/a);

B = @(t,T) (1 - exp(-a*(T-t)))./a;

A = @(t,T) PM(T)./PM(t) .*exp(1/2*(V(t,T) - V(0,T) + V(0,t)));

% fM = @(T) -(log(PM(T+1/360)) - log(PM(T-1/360)))/(2/360);
% A = @(t,T) PM(T)./PM(t).*exp(B(t,T)*fM(t) - sigma^2/(4*a)*(1 - exp(-2*a*t))*B(t,T).^2);

sigmap = @(T,S) sigma*sqrt((1 - exp(-2*a*T))/(2*a))*B(T,S);
h = @(T,S,X) 1./sigmap(T,S).*log(PM(S)./(PM(T).*X)) + sigmap(T,S)./2;

ZBC = @(T,S,X) PM(S).*normcdf(h(T,S,X)) - X*PM(T).*normcdf(h(T,S,X)-sigmap(T,S));
ZBP = @(T,S,X) -PM(S).*normcdf(-h(T,S,X)) + X.*PM(T).*normcdf(-h(T,S,X)+sigmap(T,S));

nSwaptions = length(Maturity);
SwaptionPrice = zeros(nSwaptions,1);

for swapidx=1:nSwaptions
    
    T = round(yearfrac(Settle,ExerciseDate(swapidx),inCurve.Basis));
    Tenor = round(yearfrac(ExerciseDate(swapidx),Maturity(swapidx),inCurve.Basis));
    
    ti = T:1/Reset(swapidx):(Tenor + T);
    tau = diff(ti);
    c = X(swapidx)*tau;
    c(end) = c(end) + 1;
    ti(1) = [];
    
    cA = c.*A(T,ti);
    
    rstar = fzero(@(rstar) 1 - sum(cA.*exp(-B(T,ti)*rstar)),.1);
    
    Xi = A(T,ti).*exp(-B(T,ti)*rstar);
    
    if isCall
        SwaptionPrice(swapidx) = Notional(swapidx)*nansum(c.*ZBP(T,ti,Xi));
    else
        SwaptionPrice(swapidx) = Notional(swapidx)*nansum(c.*ZBC(T,ti,Xi));
    end
end