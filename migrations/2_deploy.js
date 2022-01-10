// migrations/2_deploy.js
// SPDX-License-Identifier: MIT

const neoShift = artifacts.require("ETHBTCMAXI.sol");

const baseURI = '';

const openseaRinkebyRegistry = '0xf57b2c51ded3a29e6891aba85459d600256cf317';
const openseaMainnetRegistry = '0xa5409ec958c83c3f309868babaca7c86dcb077c1';

const rinkebyDevWallet = '0x33DE4ef4285b5ee3FA4724Bf514142c5791139C0';
const mainnetDevWallet = ''; //  UPDATE THIS!!!!!!!!!!!!!!!!!

const rinkebyxBTCWallet = '0x244aa29426fb6524760bd9acbb66ad53c5eb32ca'
const mainnetxBTCWallet = '0xb6ed7644c69416d67b522e20bc294a9a9b405b31'

module.exports = async function(deployer) {
  deployer.deploy(neoShift,baseURI,openseaRinkebyRegistry,rinkebyDevWallet,rinkebyxBTCWallet);
  //deployer.deploy(neoShift,baseURI,openseaMainnetRegistry,mainnetDevWallet,mainnetxBTCWallet); MAINNET
};