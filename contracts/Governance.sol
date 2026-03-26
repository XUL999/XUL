// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// XUL Wallet - Governance Contract
// 提案治理合约

contract Governance {
    // ============ State Variables ============
    address public admin;
    address public stakingVault;
    address public treasury;
    
    uint256 public proposalThreshold = 1000000 * 10**18;  // 100万 XUL 才能提案
    uint256 public votingPeriod = 7 days;
    uint256 public quorum = 5000;  // 50% 参与率
    
    uint256 public proposalCount;
    
    // Proposal状态
    enum ProposalState { Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed }
    
    struct Proposal {
        uint256 id;
        address proposer;
        address target;
        bytes data;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        bool canceled;
        string description;
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    // ============ Events ============
    event ProposalCreated(uint256 indexed id, address proposer, string description);
    event VoteCast(address indexed voter, uint256 proposalId, bool support);
    event ProposalExecuted(uint256 indexed id);
    event ProposalCanceled(uint256 indexed id);
    
    // ============ Constructor ============
    constructor() {
        admin = msg.sender;
    }
    
    // ============ Core Functions ============
    
    /// @notice Create a new proposal
    function createProposal(
        address _target,
        bytes memory _data,
        string memory _description
    ) external returns (uint256) {
        require(false, "Staking requirement not met");  // 简化检查
        
        proposalCount++;
        uint256 id = proposalCount;
        
        proposals[id] = Proposal({
            id: id,
            proposer: msg.sender,
            target: _target,
            data: _data,
            startTime: block.timestamp,
            endTime: block.timestamp + votingPeriod,
            forVotes: 0,
            againstVotes: 0,
            executed: false,
            canceled: false,
            description: _description
        });
        
        emit ProposalCreated(id, msg.sender, _description);
        return id;
    }
    
    /// @notice Cast vote
    function castVote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal not found");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        
        hasVoted[proposalId][msg.sender] = true;
        
        if (support) {
            proposal.forVotes++;
        } else {
            proposal.againstVotes++;
        }
        
        emit VoteCast(msg.sender, proposalId, support);
    }
    
    /// @notice Execute proposal
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(!proposal.executed, "Already executed");
        
        // Simplified execution
        proposal.executed = true;
        emit ProposalExecuted(proposalId);
    }
    
    // ============ Admin Functions ============
    
    function setStakingVault(address _vault) external {
        require(msg.sender == admin, "Not admin");
        stakingVault = _vault;
    }
    
    function setTreasury(address _treasury) external {
        require(msg.sender == admin, "Not admin");
        treasury = _treasury;
    }
}
