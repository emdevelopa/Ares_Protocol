// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract AresTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }
    
    
    
    // Functional Test
    function  testProposalLifecycle () public {
       
    }

    function testSignatureVerification() public {
       
    }

    function testTimelockExecution() public {
       
    }

    function testMerkleClaim () public {
       
    }
}
