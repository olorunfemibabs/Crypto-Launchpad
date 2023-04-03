// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./VestingWallet.sol";

contract LaunchPad is VestingWallet, AccessControl, Ownable{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeCast for uint256;




    uint256 public totalStaked;
    uint256 public vestingPeriod;
    uint256 public rewardPeriod;
    IERC20 public rewardToken;
    IERC20 public stakingToken;


    struct User {
        uint256 stakedAmount;
        uint256 startTime;
        uint256 reward;
    }

    mapping(address => User) users;

    event Stake(address indexed staker, uint256 amount, uint256 date);

    address admin;

    constructor(
        IERC20 _stakingToken,
        IERC20 _rewardToken,
        uint256 _vestingPeriod
    ) VestingWallet(address(this), uint256(block.timestamp), _vestingPeriod) {
        require(_vestingPeriod < 90 days, "vesting period must be below 90 days");
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
        vestingPeriod = _vestingPeriod;
        //rewardPeriod = _vestingPeriod
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "only admin");
        _;
    }

    function stake(uint256 _amount) external returns(uint256) {
        require(_amount > 0, "amount must be over 0");

        User storage user = users[msg.sender];
        user.stakedAmount += _amount;
        user.startTime = block.timestamp;

        totalStaked += _amount;
        IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), _amount);

        emit Stake(msg.sender, _amount, block.timestamp);

        return _amount;
    
    }

    function withdrawReward() public returns (uint256) {
        User storage user = users[msg.sender];
    
        require(block.timestamp >= user.startTime + 90, "Tokens still locked");
        uint256 amount = user.stakedAmount * 2; //2x the amount the person staked

        user.reward += amount;
        IERC20(rewardToken).safeTransfer(msg.sender, amount);

        return amount;

    }

    function adminWithdrawStaked() private {

        uint256 amount = totalStaked;
        IERC20(stakingToken).transfer(admin, amount);
    }
}