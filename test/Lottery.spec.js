const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised)
const expect = chai.expect

const Lottery = artifacts.require('Lottery')
const BN = require('bn.js')

contract('Lottery.sol', (accounts) => {
    const deployer = accounts[0]
    const from = accounts[1]
    let instance = null

    beforeEach(async () => {
        instance = await Lottery.deployed()
    })

    it('should have a starting balance of 0', async () => {
        const balance = await web3.eth.getBalance(instance.address)

        expect(balance).to.eq('0')
    })

    it('can start lottery', async () => {
        await instance.startLottery({
            from: deployer
        })

        let currentState = await instance.lottery_state.call()
        expect(currentState.toNumber()).to.eq(0)
    })

    it('must not enter lottery if value is smaller than entrance fee', async () => {
        let promise = instance.enter({
            from,
            value: 0
        })

        await expect(promise).to.eventually.be.rejectedWith('Not enough ETH')
    })

    it('deployer can enter lottery', async () => {
        let entranceFee = await instance.getEntranceFee.call()
        let promise = instance.enter({
            from: deployer,
            value: entranceFee
        })

        await expect(promise).to.eventually.be.fulfilled
    })

    it('another account can enter lottery', async () => {
        let entranceFee = await instance.getEntranceFee.call()
        let promise = instance.enter({
            from,
            value: entranceFee
        })

        await expect(promise).to.eventually.be.fulfilled
    })

    it('can end lottery', async () => {
        let previousContractBalance = await web3.eth.getBalance(instance.address)
        let previousWinnerBalance = await web3.eth.getBalance(from)

        await instance.endLottery({
            from: deployer
        })

        // Should have closed state
        let currentState = await instance.lottery_state.call()
        expect(currentState.toNumber()).to.eq(1)

        // Should have empty balance
        let balance = await web3.eth.getBalance(instance.address)
        expect(balance).to.eq('0')

        // Previous balance should be added to winner's balance
        let currentWinnersBalance = await web3.eth.getBalance(from)

        // Convert balances to BN to do arithmetics
        currentWinnersBalance = new BN(currentWinnersBalance, 10)
        previousWinnerBalance = new BN(previousWinnerBalance, 10)
        previousContractBalance = new BN(previousContractBalance, 10)

        expect(currentWinnersBalance.eq(previousWinnerBalance.add(previousContractBalance))).to.be.true
    })

    it('must not enter lottery if status is closed', async () => {
        let promise = instance.enter({
            from: deployer
        })

        await expect(promise).to.be.eventually.rejectedWith('Lottery is not open')
    })

})