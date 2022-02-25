const local_networks = [
    'development',
]

module.exports = function shouldDeployMocks(network) {
    return local_networks.includes(network)
}