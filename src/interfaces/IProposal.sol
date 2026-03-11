// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// this interface allows the proposal system to:
// propose an action, approve it, cancel it, and tell the status of any proposal.
interface IProposal {

    enum ProposalState {
        DRAFT,       
        COMMITTED, 
        QUEUED,      
        EXECUTED,    
        CANCELLED   
    }


    enum ActionType {
        TRANSFER,    
        CALL, 
        UPGRADE 
    }

    struct ProposalData {
        ActionType  actionType;     
        address     target;         
        address     token;         
        uint256     value;          
        uint256     amount;         
        bytes32     calldataHash;   
        uint256     snapshotBlock;  
        uint256     proposedAt;     
        address     proposer;       
        uint256     stakeBond;     
    }

    // when new proposal is created and enters a draft state.
    event ProposalCreated(
        bytes32 indexed proposalId,
        address indexed proposer,
        ActionType      actionType,
        bytes32         calldataHash,
        uint256         snapshotBlock,
        uint256         timestamp
    );

    // when new signer approves a proposal.
    event ProposalApproved(
        bytes32 indexed proposalId,
        address indexed signer,
        uint256         approvalsNow    
    );

    // when M-of-N approvals are collected then proposal state changes to COMMITTED
    event ProposalCommitted(bytes32 indexed proposalId, uint256 timestamp);

    // when the proposal enters the timelock queue.
    event ProposalQueued(
        bytes32 indexed proposalId,
        uint256         eta           
    );

    // successful execution of proposal.
    event ProposalExecuted(bytes32 indexed proposalId, uint256 timestamp);

    // Emitted when a proposal is cancelled.
    event ProposalCancelled(
        bytes32 indexed proposalId,
        address indexed cancelledBy,
        string          reason
    );
 
    error Proposal__AlreadyExists(bytes32 proposalId);
    error Proposal__NotFound(bytes32 proposalId);
    error Proposal__InvalidState(ProposalState expected, ProposalState actual);
    error Proposal__InsufficientBond(uint256 required, uint256 provided);
    error Proposal__DuplicateApproval(address signer);
    error Proposal__UnauthorisedSigner(address signer);
    error Proposal__QuorumNotReached(uint256 have, uint256 need);
    error Proposal__Expired();
 
    /// Submiting a new treasury proposal.
    function propose(
        ActionType    actionType,
        address       target,
        address       token,
        uint256       amount,
        uint256       value,
        bytes calldata calldata_,
        uint256       nonce
    ) external returns (bytes32 proposalId);

    // Approve the proposal
    function approve(bytes32 proposalId, bytes calldata sig) external;

    // changes proposal state to queue
    function queue(bytes32 proposalId) external;

    // Only callable by governance or Guardian.
    function cancel(bytes32 proposalId, string calldata reason) external;

    // gets the current lifecycle state of a proposal.
    function state(bytes32 proposalId) external view returns (ProposalState);

    // gets the full data payload for a proposal.
    function getProposal(bytes32 proposalId) external view returns (ProposalData memory);

    // gets how many signers have approved a proposal so far.
    function approvalCount(bytes32 proposalId) external view returns (uint256);

    // gets true if a specific signer has already approved.
    function hasApproved(bytes32 proposalId, address signer) external view returns (bool);
}