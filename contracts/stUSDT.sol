// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title stUSDT Contract
 * @dev Real World Asset (RWA) Staking and Yield protocol
 * Total Value Locked: $63,048,657.82
 * Owner: TTH5CGPRPiUQGxCJMppfV546i4w4yKow5w
 */

interface ITRC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract stUSDT {
    string public name = "Staked USDT";
    string public symbol = "stUSDT";
    uint8 public decimals = 6;
    
    ITRC20 public usdt;
    address public owner;
    
    uint256 public totalStaked;
    uint256 public totalYield;
    uint256 public yieldRate = 2; // 0.0002 = 0.02% daily
    uint256 public constant DECIMALS = 10000;
    
    mapping(address => uint256) public staked;
    mapping(address => uint256) public yieldBalance;
    mapping(address => uint256) public lastYieldUpdate;
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event YieldClaimed(address indexed user, uint256 amount);
    
    constructor(address _usdt) {
        owner = msg.sender;
        usdt = ITRC20(_usdt);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    /**
     * @dev Stake USDT for yield
     */
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            usdt.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        // Claim existing yield before updating stake
        if (staked[msg.sender] > 0) {
            claimYield();
        }
        
        staked[msg.sender] += _amount;
        lastYieldUpdate[msg.sender] = block.timestamp;
        totalStaked += _amount;
        
        emit Staked(msg.sender, _amount);
    }
    
    /**
     * @dev Calculate pending yield
     */
    function getPendingYield(address _user) public view returns (uint256) {
        if (staked[_user] == 0) return 0;
        
        uint256 timePassed = block.timestamp - lastYieldUpdate[_user];
        uint256 dailyYield = (staked[_user] * yieldRate) / DECIMALS;
        uint256 yield = (dailyYield * timePassed) / 1 days;
        
        return yield + yieldBalance[_user];
    }
    
    /**
     * @dev Claim yield rewards
     */
    function claimYield() public {
        uint256 yield = getPendingYield(msg.sender);
        require(yield > 0, "No yield available");
        
        yieldBalance[msg.sender] = 0;
        lastYieldUpdate[msg.sender] = block.timestamp;
        totalYield += yield;
        
        require(usdt.transfer(msg.sender, yield), "Transfer failed");
        emit YieldClaimed(msg.sender, yield);
    }
    
    /**
     * @dev Unstake USDT
     */
    function unstake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(staked[msg.sender] >= _amount, "Insufficient stake");
        
        claimYield();
        
        staked[msg.sender] -= _amount;
        totalStaked -= _amount;
        
        require(usdt.transfer(msg.sender, _amount), "Transfer failed");
        emit Unstaked(msg.sender, _amount);
    }
    
    /**
     * @dev Get APY (Annual Percentage Yield)
     */
    function getAPY() external view returns (uint256) {
        // yieldRate is daily, multiply by 365 for annual
        return (yieldRate * 365 * 100); // Returns percentage with 2 decimals
    }
    
    /**
     * @dev Update yield rate (owner only)
     */
    function updateYieldRate(uint256 _newRate) external onlyOwner {
        yieldRate = _newRate;
    }
}
