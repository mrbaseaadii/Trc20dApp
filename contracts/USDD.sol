// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title USDD Stablecoin Contract
 * @dev Stablecoin and Lending protocol
 * Total Value Locked: $2,317,253,099.14
 * Owner: TTH5CGPRPiUQGxCJMppfV546i4w4yKow5w
 */

interface ITRC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract USDD {
    string public name = "Decentralized USD";
    string public symbol = "USDD";
    uint8 public decimals = 6;
    uint256 public totalSupply;
    
    address public owner = 0x0000000000000000000000000000000000000000;
    uint256 public constant INITIAL_RATE = 10000; // 1:1 peg
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public minters;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    
    constructor() {
        owner = msg.sender;
        minters[msg.sender] = true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyMinter() {
        require(minters[msg.sender], "Only minter");
        _;
    }
    
    /**
     * @dev Mint new USDD tokens
     */
    function mint(address _to, uint256 _amount) external onlyMinter {
        require(_to != address(0), "Invalid address");
        require(_amount > 0, "Amount must be greater than 0");
        
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }
    
    /**
     * @dev Burn USDD tokens
     */
    function burn(uint256 _amount) external {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        
        emit Burn(msg.sender, _amount);
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
     * @dev Add minter
     */
    function addMinter(address _minter) external onlyOwner {
        minters[_minter] = true;
    }
    
    /**
     * @dev Remove minter
     */
    function removeMinter(address _minter) external onlyOwner {
        minters[_minter] = false;
    }
}
