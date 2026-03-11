// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


contract SimpleTreasury{

    address admin;

    constructor(){
        admin = msg.sender;
    }

    modifier onlyAdmin(){
        
    }



    function receive() external payable{}
}