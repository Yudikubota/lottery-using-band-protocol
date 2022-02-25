const get_env = require("./get_env")
const shouldDeployMocks = require("./shouldDeployMocks")

const contract_names = {
    'band': {
        mock: 'StdReferenceMock',
        env : 'BAND_CONTRACT',
    },
}

module.exports = async function get_contract(contract_name, network) {
    // If not local network just return the address from the environment variables
    if (!shouldDeployMocks(network)) {
        return get_env(contract_names[contract_name].env)
    }

    // Else require the latest deployed mock contract
    const MockContract = artifacts.require(contract_names[contract_name].mock);
    const instance = await MockContract.deployed()
    return instance.address
}