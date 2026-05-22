// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title JustLend DAO Contract
 * @dev Lending and Staking protocol for TRON
 * Total Value Locked: $7,240,940,780.12
 */

interface ITRC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract JustLendDAO {
    ITRC20 public lendingToken;
    
    uint256 public totalLent;
    uint256 public totalBorrowed;
    uint256 public lendingRate = 83; // 0.0083 = 0.83%
    uint256 public borrowingRate = 150; // 1.50%
    uint256 public constant DECIMALS = 10000;
    uint256 public constant COLLATERAL_RATIO = 15000; // 150% required
    
    mapping(address => uint256) public lentAmount;
    mapping(address => uint256) public borrowedAmount;
    mapping(address => uint256) public collateralAmount;
    mapping(address => uint256) public lastInterestUpdate;
    
    event Lent(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    
    constructor(address _lendingToken) {
        lendingToken = ITRC20(_lendingToken);
    }
    
    /**
     * @dev Lend tokens and earn interest
     */
    function lend(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            lendingToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        lentAmount[msg.sender] += _amount;
        lastInterestUpdate[msg.sender] = block.timestamp;
        totalLent += _amount;
        
        emit Lent(msg.sender, _amount);
    }
    
    /**
     * @dev Deposit collateral for borrowing
     */
    function depositCollateral(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            lendingToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        collateralAmount[msg.sender] += _amount;
        emit CollateralDeposited(msg.sender, _amount);
    }
    
    /**
     * @dev Borrow tokens against collateral
     */
    function borrow(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= totalLent - totalBorrowed, "Insufficient liquidity");
        
        uint256 maxBorrow = (collateralAmount[msg.sender] * DECIMALS) / COLLATERAL_RATIO;
        require(
            borrowedAmount[msg.sender] + _amount <= maxBorrow,
            "Exceeds collateral ratio"
        );
        
        borrowedAmount[msg.sender] += _amount;
        lastInterestUpdate[msg.sender] = block.timestamp;
        totalBorrowed += _amount;
        
        require(lendingToken.transfer(msg.sender, _amount), "Transfer failed");
        emit Borrowed(msg.sender, _amount);
    }
    
    /**
     * @dev Repay borrowed tokens
     */
    function repay(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(borrowedAmount[msg.sender] >= _amount, "Repay amount exceeds debt");
        require(
            lendingToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        borrowedAmount[msg.sender] -= _amount;
        totalBorrowed -= _amount;
        
        emit Repaid(msg.sender, _amount);
    }
    
    /**
     * @dev Calculate lending interest
     */
    function calculateLendingInterest(address _user) public view returns (uint256) {
        if (lentAmount[_user] == 0) return 0;
        
        uint256 timePassed = block.timestamp - lastInterestUpdate[_user];
        uint256 interestPerDay = (lentAmount[_user] * lendingRate) / DECIMALS / 365;
        
        return (interestPerDay * timePassed) / 1 days;
    }
    
    /**
     * @dev Get health factor
     */
    function getHealthFactor(address _user) external view returns (uint256) {
        if (borrowedAmount[_user] == 0) return type(uint256).max;
        
        uint256 collateralValue = (collateralAmount[_user] * DECIMALS) / 100;
        return (collateralValue * DECIMALS) / (borrowedAmount[_user] * 100);
    }
}
