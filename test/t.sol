// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
// import "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {Treasury} from "../src/treasury.sol";
import {ReentrantAttacker} from "../src/mocks/ReentrantAttacker.sol";
import {ProposalManager} from "../src/ProposalManager.sol";

contract CounterTest is Test {
    Treasury public treasury;
    ProposalManager public proposalManager;

    address admin = address(1);
    address user = address(2);
    address recipient = address(3);

    function setUp() public {
        vm.startPrank(admin);

        treasury = new Treasury();
        proposalManager = new ProposalManager(address(treasury));

        vm.stopPrank();

        vm.deal(address(treasury), 10 ether);

        // vm.deal(address(treasury), 10 ether);
    }

    function test_Admin_Send() public {
        uint balB = recipient.balance;

        vm.prank(admin);

        treasury.sendFunds(recipient, 2 ether);

        // treasury.sendFunds(recipient, 2 ether);
        uint balA = recipient.balance;

        assertEq(balA, balB + 2 ether);
    }

    function test_RevertIfNotAdmin() public {
        vm.prank(user);

        vm.expectRevert();

        treasury.sendFunds(recipient, 2 ether);
    }

    function test_TreasuryReceiveFunds() public {
        // uint balB = recipient.balance;
        vm.deal(user, 4 ether);

        vm.prank(user);

        (bool success, ) = payable(address(treasury)).call{value: 1 ether}("");

        assertEq(address(treasury).balance, 11 ether);
    }

    function test_ReentrancyAttackFails() public {
        ReentrantAttacker attacker = new ReentrantAttacker(
            payable(address(treasury))
        );
        vm.prank((admin));

        // vm.deal(address(treasury), 10 ether);

        treasury.sendFunds(address(attacker), 1 ether);

        assertEq(address(attacker).balance, 1 ether);

        assertEq(address(treasury).balance, 9 ether);
    }

    // function test_ReentrancyAttackDrainsSuccessfully() public {
    //     console.log("Treasury bal before", address(treasury).balance / 1e18);

    //     ReentrantAttacker attacker = new ReentrantAttacker(
    //         payable(address(treasury))
    //     );
    //     console.log("Attacker bal before", address(attacker).balance / 1e18);

    //     attacker.attack();
    //     // vm.expectRevert();

    //     console.log("Attacker bal after", address(attacker).balance / 1e18);
    //     console.log("Treasury bal after", address(treasury).balance / 1e18);
    // }

    // ========Proposal Manager =============

    enum ProposalStatus {
        CREATED,
        APPROVED,
        EXECUTED
    }

    function test_ProposalManagerCreateProposal() public {
        vm.prank(user);
        proposalManager.createProposal(recipient, 2);

        assertEq(proposalManager.getProposalByid(1).recipient, recipient);
        assertEq(proposalManager.getProposalByid(1).amount, 2);

        assertEq(
            uint(proposalManager.getProposalByid(1).status),
            uint(ProposalStatus.CREATED)
        );
    }

    function test_ProposalManagerApproveProposal() public {
        vm.prank(user);
        proposalManager.createProposal(recipient, 2);

        vm.prank(admin);
        proposalManager.approveProposal(1);

        assertEq(
            uint(proposalManager.getProposalByid(1).status),
            uint(ProposalStatus.APPROVED)
        );
    }

    function test_ProposalManagerExecutedProposal() public {
        vm.prank(admin);
        treasury.setAdmin(address(proposalManager));
        vm.prank(user);
        proposalManager.createProposal(recipient, 3);

        vm.prank(admin);
        proposalManager.approveProposal(1);

        vm.prank(admin);
        proposalManager.executeProposal(1);

        // console.log("bbb", proposalManager.getProposalByid(1));
        assertEq(
            uint(proposalManager.getProposalByid(1).status),
            uint(ProposalStatus.EXECUTED)
        );

        assertEq(address(recipient).balance, 3);
    }
}
