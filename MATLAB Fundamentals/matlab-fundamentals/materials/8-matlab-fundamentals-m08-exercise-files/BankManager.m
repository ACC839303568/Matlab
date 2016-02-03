classdef BankManager
    methods (Static)
        function OfferOverdraft()
            disp('Would you like an overdraft?');
        end
        function Watch(account)
            addlistener(account,'InsufficientFunds', @(src, e)  BankManager.OfferOverdraft())
        end
    end
end
