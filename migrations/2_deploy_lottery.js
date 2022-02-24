const getenv = require('../utils/getenv');
const Lottery = artifacts.require("Lottery");

module.exports = function (deployer, network, accounts) {
  const { DEPLOYER_ADDRESS, BAND_CONTRACT } = getenv(network)

  // [TEMP] Trocar por env 0xDA7a001b254CD22e46d3eAB04d937489c93174C3
  // deployer.deploy(Lottery, '0xDA7a001b254CD22e46d3eAB04d937489c93174C3', {
  deployer.deploy(Lottery, get_contract(''), {
    overwrite: false,
    from: DEPLOYER_ADDRESS || accounts[0]
  });
};
