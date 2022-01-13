# publicSolContracts

These two smart contracts are intended to work together. One (MyToken) is creating a token. The other one (MyMarketPlace) is used to interact with this token as a marketplace.

Process to deploy the Smart Contracts:

1. Deploy MyMarketPlace 
2. Deploy MyToken setting the MarketPlace address in the constructor
3. Call the MarketPlace "setAddress" function with the Token address as parameter

All of this process is protected and has to be executed from the same address.
