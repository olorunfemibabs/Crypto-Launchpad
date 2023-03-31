// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LaunchPad is Ownable{
    IERC20 public rewardToken;
    IERC20 public DAI;
    IERC20 public stakingToken;

    uint256 constant SECONDS_PER_YEAR = 31536000;

    uint256 public totalStaked;

    struct User {
        uint256 stakedAmount;
        uint256 startTime;
        uint256 reward;
    }

    mapping(address => User) users;
    error tryAgain();

    event Stake(address indexed staker, uint256 amount, uint256 date);

    address admin;

    constructor(
        IERC20 _stakingToken,
        IERC20 _rewardToken
    ) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    function setTokenAddress(address _tokenAddress) public onlyAdmin {
        rewardToken = IERC20(_tokenAddress);
    }

    function stake(uint _amount) external return(uint256) {
        require(_amount > 0, "amount must be over 0");

        User storage user = users[msg.sender];
        user.stakedAmount += _amount;
        user.startTime = block.timestamp;

        totalStaked += _amount;

        IERC20(stakingToken).transferFrom(msg.sender, address(this), _amount);

        emit Stake(msg.sender, _amount, block.timestamp);
    }

    function withdrawReward() public returns (uint256) {
        User storage user = users[msg.sender];
    
        require(block.timestamp >= startTime + 90, "Tokens still locked");
        uint256 amount = user.stakedAmount * 2 //2x the amount the person staked

        user.reward += amount
        IERC20(rewardToken).transfer(msg.sender, amount);

    }

    function adminWithdrawStaked() private {

        uint256 amount = totalStaked;
        IERC20(stakingToken).transfer(admin, amount);
    }
}