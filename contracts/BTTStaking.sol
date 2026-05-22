// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BTT Staking Governance Contract
 * @dev Governance staking for BitTorrent Token
 * Total Value Locked: $13,450,866.26
 * Owner: TTH5CGPRPiUQGxCJMppfV546i4w4yKow5w
 */

interface ITRC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BTTStaking {
    ITRC20 public bttToken;
    
    address public owner;
    uint256 public totalStaked;
    uint256 public rewardRate = 13; // -0.0013 = -0.13% (deflationary)
    uint256 public constant DECIMALS = 10000;
    uint256 public nextProposalId = 1;
    
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakingTime;
    mapping(address => uint256) public votingPower;
    mapping(uint256 => Proposal) public proposals;
    
    struct Proposal {
        uint256 id;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        mapping(address => bool) hasVoted;
    }
    
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event ProposalCreated(uint256 indexed proposalId, string description);
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId);
    
    constructor(address _bttToken) {
        owner = msg.sender;
        bttToken = ITRC20(_bttToken);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    modifier onlyStaker() {
        require(stakedAmount[msg.sender] > 0, "Not a staker");
        _;
    }
    
    /**
     * @dev Stake BTT tokens for governance
     */
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            bttToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        
        stakedAmount[msg.sender] += _amount;
        stakingTime[msg.sender] = block.timestamp;
        votingPower[msg.sender] = _amount;
        totalStaked += _amount;
        
        emit Staked(msg.sender, _amount);
    }
    
    /**
     * @dev Unstake BTT tokens
     */
    function unstake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(stakedAmount[msg.sender] >= _amount, "Insufficient staked amount");
        
        stakedAmount[msg.sender] -= _amount;
        votingPower[msg.sender] = stakedAmount[msg.sender];
        totalStaked -= _amount;
        
        require(bttToken.transfer(msg.sender, _amount), "Transfer failed");
        emit Unstaked(msg.sender, _amount);
    }
    
    /**
     * @dev Create governance proposal
     */
    function createProposal(string memory _description) external onlyStaker returns (uint256) {
        uint256 proposalId = nextProposalId;
        nextProposalId++;
        
        Proposal storage proposal = proposals[proposalId];
        proposal.id = proposalId;
        proposal.description = _description;
        proposal.startTime = block.timestamp;
        proposal.endTime = block.timestamp + 7 days;
        proposal.executed = false;
        
        emit ProposalCreated(proposalId, _description);
        return proposalId;
    }
    
    /**
     * @dev Vote on proposal
     */
    function vote(uint256 _proposalId, bool _support) external onlyStaker {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        
        proposal.hasVoted[msg.sender] = true;
        
        if (_support) {
            proposal.forVotes += votingPower[msg.sender];
        } else {
            proposal.againstVotes += votingPower[msg.sender];
        }
        
        emit VoteCast(_proposalId, msg.sender, _support);
    }
    
    /**
     * @dev Execute proposal if approved
     */
    function executeProposal(uint256 _proposalId) external onlyOwner {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.endTime, "Voting not ended");
        require(!proposal.executed, "Already executed");
        require(proposal.forVotes > proposal.againstVotes, "Proposal not approved");
        
        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }
    
    /**
     * @dev Get proposal details
     */
    function getProposal(uint256 _proposalId) external view returns (
        uint256 id,
        string memory description,
        uint256 forVotes,
        uint256 againstVotes,
        bool executed
    ) {
        Proposal storage proposal = proposals[_proposalId];
        return (
            proposal.id,
            proposal.description,
            proposal.forVotes,
            proposal.againstVotes,
            proposal.executed
        );
    }
}
