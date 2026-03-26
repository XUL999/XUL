// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// XUL Wallet - Treasury Contract
// 社区金库合约

contract Treasury {
    // ============ State Variables ============
    address public admin;
    address public governance;
    address public stakingVault;
    
    uint256 public totalBalance;
    uint256 public totalGrants;
    
    // Grant请求状态
    enum GrantState { Pending, Approved, Rejected, Paid }
    
    struct Grant {
        uint256 id;
        address applicant;
        uint256 amount;
        string description;
        uint256 requestedAt;
        GrantState state;
        bool paid;
    }
    
    mapping(uint256 => Grant) public grants;
    uint256 public grantCount;
    
    // ============ Events ============
    event GrantRequested(uint256 indexed id, address applicant, uint256 amount);
    event GrantApproved(uint256 indexed id);
    event GrantRejected(uint256 indexed id);
    event GrantPaid(uint256 indexed id, address recipient, uint256 amount);
    
    // ============ Constructor ============
    constructor() {
        admin = msg.sender;
    }
    
    // ============ Receive Function ============
    receive() external payable {
        totalBalance += msg.value;
    }
    
    // ============ Core Functions ============
    
    /// @notice Request a grant
    function requestGrant(string memory _description) external payable returns (uint256) {
        grantCount++;
        uint256 id = grantCount;
        
        grants[id] = Grant({
            id: id,
            applicant: msg.sender,
            amount: msg.value,
            description: _description,
            requestedAt: block.timestamp,
            state: GrantState.Pending,
            paid: false
        });
        
        totalBalance += msg.value;
        
        emit GrantRequested(id, msg.sender, msg.value);
        return id;
    }
    
    /// @notice Approve grant (governance only)
    function approveGrant(uint256 grantId) external {
        require(msg.sender == admin || msg.sender == governance, "Not authorized");
        require(grants[grantId].id != 0, "Grant not found");
        require(grants[grantId].state == GrantState.Pending, "Not pending");
        
        grants[grantId].state = GrantState.Approved;
        emit GrantApproved(grantId);
    }
    
    /// @notice Pay grant
    function payGrant(uint256 grantId) external {
        require(msg.sender == admin || msg.sender == governance, "Not authorized");
        Grant storage grant = grants[grantId];
        require(grant.id != 0, "Grant not found");
        require(grant.state == GrantState.Approved, "Not approved");
        require(!grant.paid, "Already paid");
        require(totalBalance >= grant.amount, "Insufficient balance");
        
        grant.paid = true;
        grant.state = GrantState.Paid;
        totalBalance -= grant.amount;
        totalGrants += grant.amount;
        
        (bool success, ) = payable(grant.applicant).call{value: grant.amount}("");
        require(success, "Transfer failed");
        
        emit GrantPaid(grantId, grant.applicant, grant.amount);
    }
    
    /// @notice Reject grant
    function rejectGrant(uint256 grantId) external {
        require(msg.sender == admin || msg.sender == governance, "Not authorized");
        require(grants[grantId].id != 0, "Grant not found");
        
        grants[grantId].state = GrantState.Rejected;
        emit GrantRejected(grantId);
    }
    
    // ============ Admin Functions ============
    
    function setGovernance(address _governance) external {
        require(msg.sender == admin, "Not admin");
        governance = _governance;
    }
    
    function setStakingVault(address _vault) external {
        require(msg.sender == admin, "Not admin");
        stakingVault = _vault;
    }
    
    function withdrawForOps(uint256 amount) external {
        require(msg.sender == admin, "Not admin");
        require(totalBalance >= amount, "Insufficient balance");
        
        totalBalance -= amount;
        (bool success, ) = payable(admin).call{value: amount}("");
        require(success, "Transfer failed");
    }
}
