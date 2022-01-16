// migrations/2_deploy.js
// SPDX-License-Identifier: MIT

const maxi = artifacts.require("ETHBTCMAXIv2.sol");

const baseURI = ''; //base token uri here

const rinkebyDevWallet = ''; //dev wallet here
const rinkebyxBTCAddress = '0x244aa29426fb6524760bd9acbb66ad53c5eb32ca'

const mainnetDevWallet = ''; //dev wallet here
const mainnetxBTCAddress = '0xB6eD7644C69416d67B522e20bC294A9a9B405B31'

module.exports = async function(deployer) {
  deployer.deploy(maxi,baseURI,rinkebyDevWallet,rinkebyxBTCAddress);
  //deployer.deploy(neoShift,baseURI,mainnetDevWallet,mainnetxBTCAddress); MAINNET
};