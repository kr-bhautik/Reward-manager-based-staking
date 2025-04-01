// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RewardManagerStaking {

    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    uint256 public totalStakedAmount;
    address public rewardManager;

    struct Reward {
        uint256 duration;
        uint256 finishAt;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStaked;
    }

    Reward rewardDetails;
    mapping(address => uint256 ) public stakeOf;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewardOf;

    constructor(IERC20 _token) {
        token = _token;
        rewardManager = msg.sender;
    }

// ------------------------- MODIFIERS --------------------------------------------------
   
    modifier updateReward(address account) {
        rewardDetails.rewardPerTokenStaked = calculateRewardPerToken();
        rewardDetails.lastUpdateTime = lastRewardApplicableTime();

        if( account != address(0)) {
            rewardOf[account] = earned();
            userRewardPerTokenPaid[account] = rewardDetails.rewardPerTokenStaked;
        }
        _;
    }
    modifier onlyRewardManager() {
        require(msg.sender == rewardManager, "Not authorized to perform this task.");
        _;
    }

// ------------------------  EVENTS -----------------------------------------------------
  
    event Staked(address indexed user, uint256 amountStaked, uint256 stakedTime);
    event Withdrawed(address indexed user, uint256 amountWithrawed, uint256 withrawTime);
    event Claimed(address indexed user, uint256 amountClaimed, uint256 claimTime);
    event Exited(address indexed user, uint256 totalAmount, uint256 exitTime);

// ----------------------------- CORE FUNCTIONS ------------------------------------------------
    
    function stake(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "You have to stack more then 0");
        require(token.balanceOf(msg.sender) >= amount, "Not enough tokens on your account.");
        token.safeTransferFrom(msg.sender, address(this), amount);
        totalStakedAmount += amount;
        stakeOf[msg.sender] += amount;
    }

    // Dynamic reward claim.
    function claim(uint256 amount) public updateReward(msg.sender) {
        uint256 reward = rewardOf[msg.sender];
        require(reward >= amount, "You don't have that much reward to claim.");
        rewardOf[msg.sender] = 0;
        token.safeTransfer(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(stakeOf[msg.sender] >= amount , "You don't have enough staked amount to withraw.");
        totalStakedAmount -= amount;
        stakeOf[msg.sender] -= amount;
        token.safeTransfer(msg.sender, amount);
    }

    function exit() public {
        if( stakeOf[msg.sender] > 0 ){
            withdraw(stakeOf[msg.sender]);
        }
        claim(earned());
    }

// ------------------------- CONFIGURATIONS -----------------------------------------------
    
    function setDuration(uint256 _duration) public onlyRewardManager  {
        require(rewardDetails.finishAt <= block.timestamp, "Reward duration is not finished.");
        rewardDetails.duration = _duration;
    }

    function distributeReward(uint256 rewardAmount) public onlyRewardManager updateReward(address(0)) {
        require(rewardAmount > 0, "Can only distribute more than 0");
        if( block.timestamp >= rewardDetails.finishAt) {
            rewardDetails.rewardRate = rewardAmount / rewardDetails.duration;
        }
        else {
            uint256 remainingTime = rewardDetails.finishAt - block.timestamp;
            uint256 leftOverRewardAmount = remainingTime * rewardDetails.rewardRate;
            rewardDetails.rewardRate = (rewardAmount + leftOverRewardAmount) / rewardDetails.duration;
        }

        rewardDetails.lastUpdateTime = block.timestamp;
        rewardDetails.finishAt = block.timestamp + rewardDetails.duration;
    }

// --------------------------- VIEWS -----------------------------------------------------

    function lastRewardApplicableTime() public view returns (uint256){
        return block.timestamp >= rewardDetails.finishAt ? rewardDetails.finishAt : block.timestamp;
    }

    function calculateRewardPerToken() public view returns (uint256) {
        
        if( totalStakedAmount == 0){
            return rewardDetails.rewardPerTokenStaked;
        }

        uint256 rewardPToken = rewardDetails.rewardPerTokenStaked + (( lastRewardApplicableTime() - rewardDetails.lastUpdateTime) * rewardDetails.rewardRate * 1e18)/ totalStakedAmount;
        return rewardPToken;
    }

    function earned() public view returns (uint256) {
        uint256 earn = rewardOf[msg.sender] + (stakeOf[msg.sender] * (calculateRewardPerToken() - userRewardPerTokenPaid[msg.sender]) / 1e18);
        return earn;
    }
}