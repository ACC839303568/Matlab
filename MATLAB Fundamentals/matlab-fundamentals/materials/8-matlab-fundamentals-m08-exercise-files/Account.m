classdef Account < handle
    properties
        Balance = 0
    end
    events
        InsufficientFunds
    end
    methods
        function Deposit(obj,amount)
            obj.Balance = obj.Balance + amount;
        end
        
        function Withdraw(obj,amount)
            if (amount <= obj.Balance)
                obj.Balance = obj.Balance - amount;
            else
                notify(obj,'InsufficientFunds');
                disp('insufficient funds')
            end
        end
    end
end