// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    address payable[] public players;
    address payable public recentWinner;
    uint256 public randomness;
    uint256 public usdEntryFee;

    // IStdReference ref;

    event PlayerEntered(address player, uint256 bet);
    event LotteryEnded(address winner, uint256 prize);

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    LOTTERY_STATE public lottery_state;

    constructor() {
        usdEntryFee = 50 * 1e18;
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    // _usdEntryFee is USD with 8 decimals
    function setUsdEntryFee(uint256 _usdEntryFee) onlyOwner public {
        require(lottery_state == LOTTERY_STATE.CLOSED, "Lottery is not closed.");
        usdEntryFee = _usdEntryFee * 1e10;
    }

    function enter() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery is not open.");
        require(msg.value >= getEntranceFee(), "Not enough ETH.");
        players.push(payable(msg.sender));
        emit PlayerEntered(msg.sender, msg.value);
    }

    function getEntranceFee() public view returns (uint256) {
        // [TODO] Get price feed from BAND Protocol

        int256 price = 2000 * 1e18; // [MOCK]
        uint256 ajustedPrice = uint256(price) * 1e10; // chainlink retorna com 8 decimals mas precisamos de 18
        uint256 costToEnter = (usdEntryFee * 1e18) / ajustedPrice;
        return costToEnter;
    }

    function startLottery() onlyOwner public {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Lottery is not closed."
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() onlyOwner public {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery is not open.");
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;

        // [MOCK] Generate randomness
        // uint256 _randomness = _unsafePseudoRandom();
        uint256 _randomness = 1;

        // Pick winner
        require(_randomness > 0, "random not found");
        uint256 indexOfWinner = _randomness % players.length;
        randomness = _randomness;
        recentWinner = players[indexOfWinner];

        // Transfer
        emit LotteryEnded(recentWinner, address(this).balance);
        recentWinner.transfer(address(this).balance);

        // Reset the lottery
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    // [WARN] This is not the recommended way to generate
    // random numbers. DO NOT USE IN PRODUCTION ENVIRONMENTS.
    // I'm using it here because BAND does not offer
    // randomness yet
    function _unsafePseudoRandom() private view returns (uint) {
        // sha3 and now have been deprecated
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
        // convert hash to integer
        // players is an array of entrants
    }

}
