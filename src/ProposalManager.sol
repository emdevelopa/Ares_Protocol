// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./treasury.sol";


error Not_Admin();
error INVALID_PROPOSAL_STATUS();
error PROPOSAL_DOES_NOT_EXIST();
 

contract ProposalManager {

    Treasury public treasury;

    address public admin;

constructor(address _treasury){
    admin = msg.sender;
    treasury = Treasury(payable(_treasury))
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

      modifier proposalExists(uint256 proposalId) {
        if(proposalCount > 0 && proposalId != proposalCount) revert PROPOSAL_DOES_NOT_EXIST(); 
        _;
      }

    event proposalCreated(address indexed proposer, address recipient, uint amount);
    event proposalApproved(uint indexed proposer_id);
    event proposalexecuted(uint indexed proposer_id);

    function createProposal(address _recipient, uint256 _amount) external {
        proposalCount++;

        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            recipient: _recipient,
            amount: _amount,
            status: ProposalStatus.CREATED
        });

        emit proposalCreated(msg.sender, _recipient, _amount);
    }

    function approveProposal(uint _id)external onlyAdmin proposalExists(_id){
        Proposal storage proposal = proposals[_id];
        if(proposal.status != ProposalStatus.CREATED) revert INVALID_PROPOSAL_STATUS();
        proposals[_id].status = ProposalStatus.APPROVED;

        emit proposalApproved(_id);
    }

    function executeProposal(uint _id)external onlyAdmin proposalExists(_id){
        Proposal storage proposal = proposals[_id];
        if(proposal.status != ProposalStatus.APPROVED) revert INVALID_PROPOSAL_STATUS();
        proposals[_id].status = ProposalStatus.EXECUTED;

        treasury.sendFunds(proposal.recipient, proposal.amount);

        emit proposalexecuted(_id);
    }

    function getProposalByid(uint _id) external view returns (Proposal memory) {
        return proposals[_id];
    }
}
