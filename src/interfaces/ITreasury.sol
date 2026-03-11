// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title  ITreasury
/// @notice Defines the external surface of the ARES Treasury vault.
///
/// The Treasury is the ONLY contract that holds funds.
/// It cannot be called directly — all calls must come from the
/// TimelockQueue (after a proposal has been approved and delayed).
///
/// This separation is the core security boundary:
///   Proposer → ProposalEngine → TimelockQueue → Treasury
///                                                    ↓
///                                              actual transfer
interface ITreasury {

    // when ERC-20 tokens leave the treasury.
    event TreasuryTransfer(
        bytes32 indexed proposalId,
        address indexed token,
        address indexed recipient,
        uint256         amount
    );

    // when the treasury makes an arbitrary external call.
    event TreasuryCall(
        bytes32 indexed proposalId,
        address indexed target,
        uint256         value,
        bytes           data
    );

    // when a proxy implementation is upgraded.
    event TreasuryUpgrade(
        bytes32 indexed proposalId,
        address indexed proxy,
        address indexed newImplementation
    );

    // when ETH is received (e.g. protocol fees flowing in).
    event EthReceived(address indexed sender, uint256 amount);

    error Treasury__CallerNotTimelock(address caller);
    error Treasury__InsufficientBalance(address token, uint256 have, uint256 need);
    error Treasury__CallFailed(address target, bytes returnData);
    error Treasury__ZeroAddress();
    error Treasury__TransferCapExceeded(uint256 requested, uint256 remaining);

    // ─────────────────────────────────────────────────────────────────
    //  Write Functions
    //  Note: ALL of these revert if msg.sender != timelockQueue address.
    //        That check is the single most important line in the treasury.
    // ─────────────────────────────────────────────────────────────────

    /// @notice Transfer ERC-20 tokens to a recipient.
    /// @dev    Only callable by the TimelockQueue contract.
    ///         Enforces the per-epoch transfer cap from GovernanceGuard.
    /// @param  proposalId  The proposal that authorised this transfer
    /// @param  token       ERC-20 token address
    /// @param  recipient   Destination wallet
    /// @param  amount      Amount of tokens (in token's smallest unit)
    function executeTransfer(
        bytes32 proposalId,
        address token,
        address recipient,
        uint256 amount
    ) external;

    /// @notice Execute an arbitrary low-level call from the treasury.
    /// @dev    Only callable by the TimelockQueue contract.
    ///         Used for DeFi interactions, not simple transfers.
    /// @param  proposalId  The proposal that authorised this call
    /// @param  target      Contract to call
    /// @param  value       ETH to send with the call
    /// @param  data        Encoded calldata
    function executeCall(
        bytes32        proposalId,
        address        target,
        uint256        value,
        bytes calldata data
    ) external;

    /// @notice Upgrade a proxy to a new implementation.
    /// @dev    Only callable by the TimelockQueue contract.
    /// @param  proposalId         The proposal that authorised this upgrade
    /// @param  proxy              The proxy contract to upgrade
    /// @param  newImplementation  New logic contract address
    function executeUpgrade(
        bytes32 proposalId,
        address proxy,
        address newImplementation
    ) external;

    // ─────────────────────────────────────────────────────────────────
    //  Read Functions
    // ─────────────────────────────────────────────────────────────────

    /// @notice Returns the treasury's balance of any ERC-20 token.
    function tokenBalance(address token) external view returns (uint256);

    /// @notice Returns the treasury's ETH balance.
    function ethBalance() external view returns (uint256);

    /// @notice Returns total value transferred in current epoch (for cap check).
    function epochTransferred(address token) external view returns (uint256);
}