%% X_Trader Order Submission Example
% This example shows how to create an order and submit it.    Note that X_Trader is a 32-bit application and will only
% work with 32-bit Windows installations of MATLAB.
%
%  Copyright 2012 The MathWorks, Inc.
%% Start or connect to XTrader
x = xtrdr;


%% Create instruments

% CONF Futures are based on notional debt instruments with a term of 1.75 
% to 13 years, and a notional coupon rate of 6 percent, issued by Germany, 
% Italy, France or the Swiss Confederation. 
x.createInstrument('Exchange','EUREX-C', ...
    'Product','CONF',...
    'ProdType','Future',...
    'Contract','Jun13');

% LONG TERM EURO-BTP-FUTURES (short-, medium- and long-term futures on 
% Italian government bonds)
x.createInstrument('Exchange','EUREX-C', ...
    'Product','FBTP',...
    'ProdType','Future',...
    'Contract','Jun13');

% Get instrument data.
instrData = getData(x, {'Exchange', 'Last', 'Bid', 'BidQty', 'Ask', 'AskQty'});

% Create event notifier (to invoke a callback every time an event occurrs, 
% e.g. display the price every time the price get changed
x.createNotifier

% Define events
x.InstrNotify.registerevent({'OnNotifyFound',@(varargin)ttinstrumentfound(varargin{:})})
x.InstrNotify.registerevent({'OnNotifyNotFound',@(varargin)ttinstrumentnotfound(varargin{:})})
x.InstrNotify.registerevent({'OnNotifyUpdate',@(varargin)ttinstrumentupdate(varargin{:},x)})

% Attach instruments to a notifier
x.InstrNotify.AttachInstrument(x.Instrument(1))
x.InstrNotify.AttachInstrument(x.Instrument(2))

% Start monitoring events
x.Instrument(2).Open;

%% Stop the notification of events
x.InstrNotify.DetachInstrument(x.Instrument(2))

%% Register event handler for order server (another type of event handler)
sExchange = x.Instrument(2).Exchange;

% On exchange state update, display info on the screen.
x.Gate.registerevent({'OnExchangeStateUpdate',@(varargin)ttorderserverstatus(varargin{:},sExchange)})

% Create OrderSet
x.createOrderSet;

% Set order: set properties and detail level of order status events
% Set a notification to display when order is rejected.
x.OrderSet(1).EnableOrderRejectData = 1;
x.OrderSet(1).EnableOrderUpdateData = 1;
x.OrderSet(1).OrderStatusNotifyMode = 'ORD_NOTIFY_NORMAL';

% Set the maximum number of shares you can trade. You can do more complex 
%orders in X_TRADER, but we are only going to show some basic examples here: 
%how to set limit orders and market orders.
x.OrderSet(1).Set('NetLimits',false)

% Set events to get status of order
%The command
%
% events(x.OrderSet)
%
%shows the events associated with the OrderSet object
x.OrderSet.registerevent({'OnOrderFilled',@(varargin)ttorderevent(varargin{:},x)})
x.OrderSet.registerevent({'OnOrderRejected',@(varargin)ttorderevent(varargin{:},x)})
x.OrderSet.registerevent({'OnOrderSubmitted',@(varargin)ttorderevent(varargin{:},x)})
x.OrderSet.registerevent({'OnOrderDeleted',@(varargin)ttorderevent(varargin{:},x)})

% Enable send orders (we first have to open the connection)
x.OrderSet.Open(1);


% Build order profile with existing instrument 
orderProfile = x.createOrderProfile;
orderProfile.Instrument = x.Instrument(2);

% Set customer default property (we are using a default customer profile)
orderProfile.Customer = '<Default>';


% Set up order profile as a market order to buy 100 shares
orderProfile.Set('BuySell','Buy');
orderProfile.Set('Qty','100');

% This is what you would type if you wanted to submit a market order
%orderProfile.Set('OrderType','M');

%Limit order, set the ordertype and limit order price
%
orderProfile.Set('OrderType','L');
orderProfile.Set('Limit$','114.1');


% If we did all this, this just creates an order definition, but does not
% send the order to the market.

%
%Check order server status before submitting order, added counter so that
%demo never gets stuck
nCounter = 1;
while ~exist('bServerUp','var') && nCounter < 20
  %bServerUp is created by ttorderserverstatus
  pause(1)
  nCounter = nCounter + 1;
end

% If the order server is up,we submit the order using the following command
if exist('bServerUp','var') && bServerUp
  %Submit the order
  submittedQuantity = x.OrderSet(1).SendOrder(orderProfile);
  disp(['Quantity Sent: '  num2str(submittedQuantity)])
else
  disp('Order server is down.  Unable to submit order.')
end

% Now check the command line and go to X_TRADER (current working orders). 
% We can see in command line is submitted.

%%
%To delete an order
OrderObj = orderProfile.GetLastOrder;
if ~isempty(OrderObj)
  if ~OrderObj.IsNull
    OrderObj.DeleteOrder;
  end
end

%
disp('Shutting down communications to X_Trader.')
close(x)

% This is the process for trading with MATLAB through X_TRADER
% If the market is busy and MATLAB gets lot of submissions, orders will not
% be cancelled, but put in the queue for .NET boundary for the COM object.
% However, the latencies can be occur. You can try to use parallel
% computing to speed things up.