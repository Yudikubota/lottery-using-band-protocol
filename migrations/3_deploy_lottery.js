const get_env = require('../utils/get_env');
const get_contract = require('../utils/get_contract');
const Lottery = artifacts.require("Lottery");

module.exports = function (deployer, network, accounts) {
  const {
    DEPLOYER_ADDRESS,
  } = get_env(network)

  deployer.then(async () => {
    const bandContract = await get_contract('band', network)

    await deployer.deploy(Lottery, bandContract, {
      overwrite: false,
      from: DEPLOYER_ADDRESS || accounts[0]
    })
  })
};