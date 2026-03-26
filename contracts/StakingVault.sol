// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

// XUL Wallet - Staking Vault Contract
// XUL 质押合约，年化收益 25%

contract StakingVault {
    // ============ State Variables ============
    address public admin;
    address public governance;
    address public xulToken;  // Native coin, address(0)
    
    // Staking info
    uint256 public totalStaked;
    uint256 public annualYield = 2500;  // 25% APY (in basis points)
    uint256 public minStakeAmount = 100 * 10**18;  // 100 XUL
    uint256 public unlockPeriod = 14 days;
    
    // User stake info
    struct StakeInfo {
        uint256 amount;
        uint256 startTime;
        uint256 pendingReward;
        bool claimed;
    }
    
    mapping(address => StakeInfo) public stakes;
    mapping(address => bool) public isStaking;
    
    // ============ Events ============
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);
    event RewardClaimed(address indexed user, uint256 reward);
    
    // ============ Constructor ============
    constructor() {
        admin = msg.sender;
        xulToken = address(0);  // Native coin
    }
    
    // ============ Core Functions ============
    
    /// @notice Stake XUL
    function stake() external payable {
        uint256 amount = msg.value;
        require(amount >= minStakeAmount, "Below minimum");
        
        if (isStaking[msg.sender]) {
            // Add to existing stake
            stakes[msg.sender].amount += amount;
            stakes[msg.sender].startTime = block.timestamp;
        } else {
            // New stake
            stakes[msg.sender] = StakeInfo({
                amount: amount,
                startTime: block.timestamp,
                pendingReward: 0,
                claimed: false
            });
            isStaking[msg.sender] = true;
        }
        
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }
    
    /// @notice Unstake XUL (after unlock period)
    function unstake() external {
        require(isStaking[msg.sender], "Not staking");
        
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(block.timestamp >= stakeInfo.startTime + unlockPeriod, "Still locked");
        
        uint256 amount = stakeInfo.amount;
        uint256 reward = calculateReward(msg.sender);
        uint256 total = amount + reward;
        
        // Reset stake
        delete stakes[msg.sender];
        isStaking[msg.sender] = false;
        totalStaked -= amount;
        
        // Transfer XUL + reward
        (bool success, ) = payable(msg.sender).call{value: total}("");
        require(success, "Transfer failed");
        
        emit Unstaked(msg.sender, amount, reward);
    }
    
    /// @notice Claim reward without unstaking
    function claimReward() external {
        require(isStaking[msg.sender], "Not staking");
        
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward");
        
        stakes[msg.sender].pendingReward += reward;
        stakes[msg.sender].startTime = block.timestamp;
        
        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "Transfer failed");
        
        emit RewardClaimed(msg.sender, reward);
    }
    
    /// @notice Calculate pending reward
    function calculateReward(address user) public view returns (uint256) {
        if (!isStaking[user]) return 0;
        
        StakeInfo memory stakeInfo = stakes[user];
        uint256 stakingDays = (block.timestamp - stakeInfo.startTime) / 1 days;
        uint256 yearlyReward = (stakeInfo.amount * annualYield) / 10000;
        uint256 reward = (yearlyReward * stakingDays) / 365;
        
        return reward;
    }
    
    // ============ Admin Functions ============
    
    function setMinStakeAmount(uint256 _amount) external {
        require(msg.sender == admin || msg.sender == governance, "Not authorized");
        minStakeAmount = _amount;
    }
    
    function setUnlockPeriod(uint256 _days) external {
        require(msg.sender == admin || msg.sender == governance, "Not authorized");
        unlockPeriod = _days * 1 days;
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == admin, "Not admin");
        governance = _governance;
    }
}
