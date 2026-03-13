// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

error Not_Admin();
error Not_Enough_Balance();

contract Treasury {
    address admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin(uint _amount) {
        if(admin != msg.sender) revert Not_Admin();

        if (address(this).balance < _amount) revert Not_Enough_Balance();
        _;
    }

    function sendFunds(
        address recipient,
        uint amount
    ) external onlyAdmin(amount) returns (bool) {
        
        (bool success, ) = payable(recipient).call{value: amount}("");

        return success;
    }

  

    receive() external payable {}
    // fallback()external{}
}
