// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "../../src/treasury.sol";

contract ReentrantAttacker {
    Treasury public treasury;

    constructor(address payable _treasury) {
        treasury = Treasury(_treasury);
    }

    function attack() external {
        treasury.sendFunds(address(this), 1 ether);
    }

    function getAttackerBalance() public returns (uint) {
        return address(this).balance;
    }

    receive() external payable {
        if(address(this).balance < 0){
            treasury.sendFunds(address(this), 1 ether);
        }
    }
}
