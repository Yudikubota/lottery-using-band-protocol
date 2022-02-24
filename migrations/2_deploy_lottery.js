const getenv = require('../utils/getenv');
const Lottery = artifacts.require("Lottery");

module.exports = function (deployer, network, accounts) {
  const { DEPLOYER_ADDRESS } = getenv(network)

  deployer.deploy(Lottery, {
    overwrite: false,
    from: DEPLOYER_ADDRESS || accounts[0]
  });
};
