// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address payable[] public players;
    address payable public recentWinner;
    uint256 public randomness;
    uint256 public usdEntryFee;

    event RequestedRandomness(bytes32 requestId);

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    LOTTERY_STATE public lottery_state;

    constructor() public {
        usdEntryFee = 50 * 1e18;
        lottery_state = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery is not open.");
        require(msg.value >= getEntranceFee(), "Not enough ETH.");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        (, int256 price, , , ) = ethUsdPriceFeed.latestRoundData();
        uint256 ajustedPrice = uint256(price) * 1e10; // chainlink retorna com 8 decimals mas precisamos de 18
        uint256 costToEnter = (usdEntryFee * 1e18) / ajustedPrice;
        return costToEnter;
    }

    function startLottery() public {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Lottery is not closed."
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public {
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery is not open.");

        // não usar parâmetros da blockchain pois eles podem ser inferidos ou
        // manipulados

        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyHash, oracleFee);
        emit RequestedRandomness(requestId);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER, "Not in calculating state.");
        require(_randomness > 0, "random not found");
        uint256 indexOfWinner = _randomness % players.length;
        randomness = _randomness;
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);

        // Reset the lottery
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
    }
}
