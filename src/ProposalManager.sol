// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;


error Not_Admin();
error INVALID_PROPOSAL_STATUS();

contract ProposalManager {

    address public admin;

constructor(){
    admin = msg.sender;
}

    enum ProposalStatus {
        CREATED,
        APPROVED,
        EXECUTED
    }

    struct Proposal {
        uint256 id;
        address proposer;
        address recipient;
        uint256 amount;
        ProposalStatus status;
    }

    uint256 public proposalCount;

    // 1 => {0x23, 0x24, 2, false}
    // proposal #1, 0x23 says sends 2eth to 0x24
    mapping(uint256 => Proposal) public proposals;

    modifier onlyAdmin(){
        if (admin != msg.sender) revert Not_Admin();
        _;
    }

    function createProposal(address recipient, uint256 amount) external {
        proposalCount++;

        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            recipient: recipient,
            amount: amount,
            status: ProposalStatus.CREATED
        });
    }

    function approveProposal(uint _id)external onlyAdmin {
        Proposal storage proposal = proposals[_id];
        if(proposal.status != ProposalStatus.CREATED) revert INVALID_PROPOSAL_STATUS();
        proposals[_id].status = ProposalStatus.APPROVED;
    }

    function executeProposal(uint _id)external onlyAdmin {
        Proposal storage proposal = proposals[_id];
        if(proposal.status != ProposalStatus.APPROVED) revert INVALID_PROPOSAL_STATUS();
        proposals[_id].status = ProposalStatus.EXECUTED;
    }

    function getProposalByid(uint _id) external view returns (Proposal memory) {
        return proposals[_id];
    }
}
