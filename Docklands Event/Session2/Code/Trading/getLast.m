function y = getLast( x, y )
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    
    instrData = getData(x, {'Exchange', 'Last', 'Bid', 'BidQty', 'Ask', 'AskQty'});
    y = [y; instrData.Last(1)];
    
end

