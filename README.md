# district-contract

REQUISITES:

Yarn, NPM


USAGE:

1. yarn install
2. edit truffle-config.js, create a file named .secret and insert the deployer's pkey (Use a throwaway metamask account that you only fund for the deployment and remove it after giving ownership of the contract to a safer account)
3. edit 2_deploy.js and the contracts with the paremeters you wish.
4.  yarn truffle deploy (add --network rinkeby for testnet deploy)
5.   yarn truffle run verify [CONTRACTNAME] (verifies contract on etherscan)
