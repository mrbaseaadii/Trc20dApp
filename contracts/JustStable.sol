// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title JustStable Contract
 * @dev TRX-pegged stablecoin
 * Total Value Locked: $1,418,107.40
 * Owner: TTH5CGPRPiUQGxCJMppfV546i4w4yKow5w
 */

interface ITRC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract JustStable {
    string public name = "JustStable";
    string public symbol = "JUST";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    address public owner;
    ITRC20 public collateralToken; // TRX
    
    uint256 public constant COLLATERAL_RATIO = 15000; // 150%
    uint256 public constant MIN_STABILITY_FEE = 50; // 0.5%
    uint256 public constant DECIMALS = 10000;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public debt;
    mapping(address => uint256) public lastUpdate;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Minted(address indexed user, uint256 amount, uint256 collateralAmount);
    event Burned(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);
    
    constructor(address _collateralToken) {
        owner = msg.sender;
        collateralToken = ITRC20(_collateralToken);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    /**
     * @dev Deposit collateral (TRX)
     */
    function depositCollateral(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            collateralToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        collateral[msg.sender] += _amount;
        emit CollateralDeposited(msg.sender, _amount);
    }
    
    /**
     * @dev Mint JustStable stablecoin
     */
    function mint(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        
        uint256 requiredCollateral = (_amount * COLLATERAL_RATIO) / DECIMALS;
        require(collateral[msg.sender] >= requiredCollateral, "Insufficient collateral");
        
        debt[msg.sender] += _amount;
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
        lastUpdate[msg.sender] = block.timestamp;
        
        emit Minted(msg.sender, _amount, requiredCollateral);
        emit Transfer(address(0), msg.sender, _amount);
    }
    
    /**
     * @dev Burn JustStable stablecoin
     */
    function burn(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        require(debt[msg.sender] >= _amount, "Burn amount exceeds debt");
        
        balanceOf[msg.sender] -= _amount;
        debt[msg.sender] -= _amount;
        totalSupply -= _amount;
        
        emit Burned(msg.sender, _amount);
        emit Transfer(msg.sender, address(0), _amount);
    }
    
    /**
     * @dev Transfer tokens
     */
    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    /**
     * @dev Approve spending
     */
    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev Transfer from
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    /**
     * @dev Get collateral ratio for user
     */
    function getCollateralRatio(address _user) external view returns (uint256) {
        if (debt[_user] == 0) return type(uint256).max;
        return (collateral[_user] * DECIMALS) / debt[_user];
    }
    
    /**
     * @dev Check if position is healthy
     */
    function isHealthy(address _user) external view returns (bool) {
        if (debt[_user] == 0) return true;
        return (collateral[_user] * DECIMALS) / debt[_user] >= COLLATERAL_RATIO;
    }
}
