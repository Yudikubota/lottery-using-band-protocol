const get_env = require('../utils/get_env');
const shouldDeployMocks = require('../utils/shouldDeployMocks');
const StdReferenceMock = artifacts.require("StdReferenceMock");

module.exports = function (deployer, network, accounts) {

  if (!shouldDeployMocks(network)) {
    return
  }

  const {
    DEPLOYER_ADDRESS,
  } = get_env(network)

  deployer.deploy(StdReferenceMock, {
    overwrite: false,
    from: DEPLOYER_ADDRESS || accounts[0]
  })
};