// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TRX Staking Contract
 * @dev Governance staking mechanism for TRON ecosystem
 * Total Value Locked: $16,876,005,038.35
 */

interface ITRC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TRXStaking {
    ITRC20 public tronToken;
    
    uint256 public totalStaked;
    uint256 public rewardRate = 121; // 0.0121 = 1.21%
    uint256 public constant DECIMALS = 10000;
    
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakingTime;
    mapping(address => uint256) public rewards;
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    
    constructor(address _tronToken) {
        tronToken = ITRC20(_tronToken);
    }
    
    /**
     * @dev Stake TRX tokens
     */
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            tronToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        // Claim existing rewards before updating stake
        if (stakedAmount[msg.sender] > 0) {
            claimRewards();
        }
        
        stakedAmount[msg.sender] += _amount;
        stakingTime[msg.sender] = block.timestamp;
        totalStaked += _amount;
        
        emit Staked(msg.sender, _amount);
    }
    
    /**
     * @dev Calculate pending rewards
     */
    function getPendingRewards(address _user) public view returns (uint256) {
        if (stakedAmount[_user] == 0) return 0;
        
        uint256 stakingDuration = block.timestamp - stakingTime[_user];
        uint256 dailyReward = (stakedAmount[_user] * rewardRate) / DECIMALS / 365;
        uint256 reward = (dailyReward * stakingDuration) / 1 days;
        
        return reward + rewards[_user];
    }
    
    /**
     * @dev Claim rewards
     */
    function claimRewards() public {
        uint256 reward = getPendingRewards(msg.sender);
        require(reward > 0, "No rewards available");
        
        rewards[msg.sender] = 0;
        stakingTime[msg.sender] = block.timestamp;
        
        require(tronToken.transfer(msg.sender, reward), "Reward transfer failed");
        emit RewardClaimed(msg.sender, reward);
    }
    
    /**
     * @dev Unstake tokens
     */
    function unstake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(stakedAmount[msg.sender] >= _amount, "Insufficient staked amount");
        
        claimRewards();
        
        stakedAmount[msg.sender] -= _amount;
        totalStaked -= _amount;
        
        require(tronToken.transfer(msg.sender, _amount), "Transfer failed");
        emit Unstaked(msg.sender, _amount);
    }
}
